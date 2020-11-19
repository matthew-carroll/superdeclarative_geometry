import 'dart:math' as math;

import 'angles.dart';

/// Adds standard trigonometry calculations to `Angle`.
extension AngleTrigonomotry on Angle {
  /// Standard `dart:math` `atan()` function, adjusted to return an `Angle` instead
  /// of a `double`.
  static Angle atan(double x) {
    return Angle.fromRadians(math.atan(x));
  }

  /// Standard `dart:math` `atan2()` function, adjusted to return an `Angle` instead
  /// of a `double`.
  static Angle atan2(double a, double b) {
    return Angle.fromRadians(math.atan2(a, b));
  }

  double sin() => math.sin(this.radians);

  double cos() => math.cos(this.radians);

  double tan() => math.tan(this.radians);
}
