import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension StringX on String {
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  String truncate(int max, {String ellipsis = '…'}) =>
      length <= max ? this : '${substring(0, max)}$ellipsis';
}

extension DurationX on Duration {
  String get formatted {
    final m = inMinutes;
    final s = inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

extension IntX on int {
  String get minuteRead => '$this min read';
}
