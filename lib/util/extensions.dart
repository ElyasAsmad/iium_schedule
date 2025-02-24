import 'package:flutter/material.dart';

import '../enums/day_enum.dart';

extension TextBeautify on String {
  /// Remove dot zero. Ezample: `3.0` become `3`
  /// Not supprted for more than one trailing zero. For eg: `3.00` will become `3.0`.
  String removeTrailingDotZero() => replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
}

extension DayName on int {
  /// Convert int to human readable day name
  String englishDay() => Day.values[this - 1].name;
}

extension Utility on BuildContext {
  /// Move to next text field
  void nextEditableTextFocus() {
    do {
      FocusScope.of(this).nextFocus();
    } while (FocusScope.of(this).focusedChild!.context == null);
  }
}

extension TimeOfDayUtils on TimeOfDay {
  String _addLeadingZeroIfNeeded(int value) {
    if (value < 10) return '0$value';
    return value.toString();
  }

  /// Similar to .toString(), but without the class name
  String toRealString() {
    final String hourLabel = _addLeadingZeroIfNeeded(hour);
    final String minuteLabel = _addLeadingZeroIfNeeded(minute);

    return '$hourLabel:$minuteLabel';
  }

  /// Calculate the difference between TimeOfDay
  TimeOfDay difference(TimeOfDay other) {
    var diff = DateTime(2022, 11, 5, hour, minute)
        .difference(DateTime(2022, 11, 5, other.hour, other.minute));
    int twoDigitMinutes = diff.inMinutes.remainder(60);
    return TimeOfDay(hour: diff.inHours, minute: twoDigitMinutes);
  }
}
