import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:iium_schedule/views/saved_schedule/saved_schedule_layout.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';

import '../constants.dart';
import '../hive_model/saved_schedule.dart';
import '../util/launcher_url.dart';
import '../util/my_ftoast.dart';
import 'check_update_page.dart';
import 'course browser/browser.dart';
import 'saved_schedule_selector.dart';
import 'scheduler/schedule_maker_entry.dart';

class MyBody extends StatefulWidget {

  const MyBody({ super.key });

  @override
  State<StatefulWidget> createState() => _MyBody();
}

class _MyBody extends State<MyBody> {

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    configureQuickAction(context);

    return Scaffold(
      // extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.grey.withAlpha(90))
            : SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.grey.withAlpha(90)),
        // systemOverlayStyle: SystemUiOverlayStyle.light
        //     .copyWith(statusBarColor: Colors.transparent),
        // shadowColor: Colors.transparent,
        // backgroundColor: Colors.transparent,
        // foregroundColor: Colors.transparent,
        titleSpacing: 0,
        centerTitle:
            false, // prevent the version render at the center of the screen for iphone/ipad
        titleTextStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Theme.of(context).brightness == Brightness.light
                ? Colors.black
                : Colors.white),
        title: FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (_, AsyncSnapshot<PackageInfo> snapshot) {
              return TextButton(
                // don't want to be as attractive like a button
                style: TextButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.bodySmall,
                    foregroundColor: Theme.of(context).colorScheme.onBackground),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _SimpleAboutDialog(),
                  );
                },
                child: Text(
                  'v${snapshot.data?.version}',
                ),
              );
            }),
        actions: [
          PopupMenuButton(
            elevation: 1.0,
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            tooltip: "Menu",
            onSelected: (value) async {
              switch (value) {
                case "website":
                  LauncherUrl.open("https://iiumschedule.iqfareez.com/");
                  break;
                case "feedback":
                  LauncherUrl.open(
                      "https://iiumschedule.iqfareez.com/feedback");
                  break;
                default:
              }
            },
            icon: const Icon(
              Icons.more_vert_outlined,
            ),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: "website",
                child: Text("Website"),
              ),
              PopupMenuItem(
                value: "feedback",
                child: Text("Send feedback"),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: <Widget>[
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'IIUM Schedule', 
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground, 
                    fontSize: 36.0, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20.0,),
                ValueListenableBuilder(
                  valueListenable: 
                    Hive.box<SavedSchedule>(kHiveSavedSchedule).listenable(), 
                  builder: (context, Box<SavedSchedule> box, _) {
                    if (box.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          "Your saved schedule will appear here",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context).colorScheme.onBackground
                          ),
                        ),
                      );
                    }
                    // return const Text('Hey');
                    return AnimatedList(
                      initialItemCount: box.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index, animation) {
                        var item = box.getAt(index);
                        return _CardItem(
                          item: item!,
                          animation: animation,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (_) => SavedScheduleLayout(
                                  savedSchedule: item,
                                ),
                              ),
                            );

                            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                          },
                          onDeleteAction: () async {
                            var res = await showDialog(
                              context: context,
                              builder: (_) => const _DeleteDialog(),
                            );

                            if (res ?? false) {
                              // ignore: use_build_context_synchronously
                              AnimatedList.of(context).removeItem(
                                  index,
                                  (context, animation) => _CardItem(
                                        item: item,
                                        animation: animation,
                                      ));
                              await box.deleteAt(index);
                            }
                          },
                        );
                      },
                    );
                  }
                ),
              ],
            ),
          ),
          const Browser()
        ][selectedIndex],
      ),
      floatingActionButton: selectedIndex == 0 ? FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(CupertinoPageRoute(builder: (_) => ScheduleMakerEntry()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ) : null,
      bottomNavigationBar:  NavigationBar(
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        selectedIndex: selectedIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Course Browser',
          )
        ],
      )
    );
  }
}

class _CardItem extends StatelessWidget {
  const _CardItem({
    Key? key,
    required this.item,
    required this.animation,
    this.onTap,
    this.onDeleteAction
  }) : super(key: key);

  final SavedSchedule item;
  final Animation<double> animation;
  final VoidCallback? onTap;
  final VoidCallback? onDeleteAction;

  @override
  Widget build(BuildContext context) {
    String formattedDate =
        DateFormat('dd MMM yyyy').format(DateTime.parse(item.lastModified));
    return ScaleTransition(
      scale: animation,
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.secondaryContainer,
        clipBehavior: Clip.hardEdge,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0)
          )
        ),
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 100,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title!, 
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondaryContainer, 
                              fontSize: 20.0, 
                              fontWeight: FontWeight.bold
                            ),
                          )
                        ),
                        Text(
                          'Modified on $formattedDate',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondaryContainer,
                            fontSize: 10.0
                          ),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onDeleteAction,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    icon: const Icon(Icons.delete)
                  )
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}

class _SimpleAboutDialog extends StatelessWidget {
  const _SimpleAboutDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
        title: const Text('About', style: TextStyle(fontWeight: FontWeight.bold),),
        children: [
          const SimpleDialogOption(
            child: Text(
                'This app enables students to make & check their schedules, specially tailoired for IIUM Students.'),
          ),
          SimpleDialogOption(
            child: const Text('\u00a9 2022 Muhammad Fareez'),
            onPressed: () => LauncherUrl.open('https://iqfareez.com'),
          ),
          SimpleDialogOption(
            child: const Text('Available on Android/Windows/Web'),
            onPressed: () =>
                LauncherUrl.open('https://iiumschedule.iqfareez.com/downloads'),
          ),
          const Divider(),
          if (!kIsWeb) // don't show this option when on web
            SimpleDialogOption(
              child: const Text('Check for updates...'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    fullscreenDialog: true,
                    builder: (_) => const CheckUpdatePage(),
                  ),
                );
              },
            ),
          SimpleDialogOption(
            onPressed: () async {
              final BuildContext _context = context;
              var deviceInfo = await DeviceInfoPlugin().deviceInfo;
              var packageInfo = await PackageInfo.fromPlatform();

              String deviceInfoData;

              // check device info is android, windows or web
              if (deviceInfo is AndroidDeviceInfo) {
                var androidVersion = deviceInfo.version;
                // eg: Android 11 (30)
                deviceInfoData =
                    'Android ${androidVersion.release} (${androidVersion.sdkInt})';
              } else if (deviceInfo is WindowsDeviceInfo) {
                var windowsVersion = deviceInfo.displayVersion;
                // eg: Windows 22H2
                deviceInfoData = 'Windows $windowsVersion';
              } else {
                // on web
                var browserName = (deviceInfo as WebBrowserInfo).browserName;
                var platform = deviceInfo.platform;
                // eg: Web chrome Win32
                deviceInfoData = 'Web ${browserName.name} $platform';
              }

              final data = {
                'device': deviceInfoData,
                'version': packageInfo.version,
              };

              await Clipboard.setData(
                  ClipboardData(text: data.values.join('; ')));
              MyFtoast.show(_context, 'Copied to clipboard');
            },
            child: const Text('Copy debug info'),
          ),
          SimpleDialogOption(
            child: const Text('View licenses'),
            onPressed: () => showLicensePage(
                context: context,
                applicationLegalese: '\u{a9} 2022 Muhammad Fareez'),
          ),
        ]);
  }
}

/// COnfigure the quick action if running on Android only
void configureQuickAction(BuildContext context) {
  // check if running on Android only
  if (kIsWeb || !Platform.isAndroid) return;

  const QuickActions quickActions = QuickActions();

  // callback for quick actions
  quickActions.initialize((shortcutType) {
    if (shortcutType == 'action_browser') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const Browser()));
    }
    if (shortcutType == 'action_create') {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ScheduleMakerEntry()));
    }

    if (shortcutType == 'action_view_saved') {
      print("hheehe");
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SavedScheduleSelector()));
    }
  });
  // setup quick actions
  quickActions.setShortcutItems(
    <ShortcutItem>[
      const ShortcutItem(
          type: 'action_browser',
          localizedTitle: 'Browse course',
          icon: 'ic_shortcut_search_outline'),
      const ShortcutItem(
          type: 'action_create',
          localizedTitle: 'Create new',
          icon: 'ic_shortcut_plus_square_outline'),
      const ShortcutItem(
          type: 'action_view_saved',
          localizedTitle: 'View saved schedule',
          icon: 'ic_shortcut_layout_outline')
    ],
  );
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold),),
      content: const Text('Deleted schedule will be gone forever!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            elevation: 0
          ),
          onPressed: () async {
            Navigator.pop(context, true);
          },
          child: Text("Delete", style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),),
        ),
      ],
    );
  }
}