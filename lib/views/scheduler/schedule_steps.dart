import 'package:flutter/cupertino.dart';

/// To be used together with the [NavigationController]
class ScheduleSteps extends InheritedWidget {
  const ScheduleSteps(
      {Key? key,
      required this.pageController,
      required this.pageNotifier,
      required Widget child})
      : super(key: key, child: child);

  final PageController pageController;
  final ValueNotifier<int> pageNotifier;

  static ScheduleSteps of(BuildContext context) {
    final ScheduleSteps? result =
        context.dependOnInheritedWidgetOfExactType<ScheduleSteps>();
    assert(result != null, 'No ScheduleSteps found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(ScheduleSteps oldWidget) {
    return pageNotifier.value != oldWidget.pageNotifier.value;
  }
}
