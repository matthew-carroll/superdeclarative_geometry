import 'dart:math';

import '_common.dart';

/// Canonical mathematical concept of an "angle".
///
/// The opening between two rays. An `Angle` exists within the range
/// (-360°, 360°). A new `Angle` produced from an existing `Angle` by
/// adding, subtracting, dividing, multiplying, etc. will be limited to the
/// the aforementioned range. To represent angles beyond 360°, see `Rotation`.
class Angle implements Equivalency<Angle>, Approximately<Angle> {
  /// Linearly interpolates between `a1` and `a2` at time/percent `t`.
  static Angle lerp(Angle a1, Angle a2, double t) {
    return Angle.fromRadians(a1.radians + ((a2.radians - a1.radians) * t));
  }

  // Convenient constant Angles.
  static const Angle zero = const Angle.fromDegrees(0);
  static const Angle deg30 = const Angle.fromDegrees(30);
  static const Angle deg45 = const Angle.fromDegrees(45);
  static const Angle deg60 = const Angle.fromDegrees(60);
  static const Angle deg90 = const Angle.fromDegrees(90);
  static const Angle deg180 = const Angle.fromDegrees(180);

  static const _maxDegrees = 360;
  static const _maxRadians = 2 * pi;

  /// Constructs a new `Angle` from the given `degrees`.
  ///
  /// The resulting `Angle` confines the `degrees` to (-360°, 360°) by mod'ing
  /// the incoming value. This restriction is done in a manner that preserves the
  /// sign of the `Angle` such that -361° becomes -1°.
  const Angle.fromDegrees(num degrees)
      : this.degrees = degrees >= 0 || degrees == -360
            ? degrees % _maxDegrees
            : (degrees % _maxDegrees) - 360,
        this.radians = (degrees >= 0 || degrees == -360
                ? degrees % _maxDegrees
                : (degrees % _maxDegrees) - 360) *
            pi /
            180,
        this.percent = degrees >= 0 || degrees == -360
            ? (degrees % _maxDegrees) / 360
            : ((degrees % _maxDegrees) - 360) / 360;

  /// Constructs a new `Angle` from the given `radians`.
  ///
  /// The resulting `Angle` confines the `radians` to (-2pi, 2pi) by mod'ing
  /// the incoming value.
  const Angle.fromRadians(num radians)
      : this.radians = radians >= 0 || radians == -2 * pi
            ? radians % _maxRadians
            : (radians % _maxRadians) - (2 * pi),
        this.degrees = (radians >= 0 || radians == -2 * pi
                ? radians % _maxRadians
                : (radians % _maxRadians) - (2 * pi)) *
            180 /
            pi,
        this.percent = radians >= 0 || radians == -2 * pi
            ? (radians % _maxRadians) / (2 * pi)
            : ((radians % _maxRadians) - (2 * pi)) / (2 * pi);

  /// Constructs a new `Angle` from the given `percent`.
  ///
  /// The resulting `Angle` confines the `percent` to (-1.0, 1.0) by mod'ing
  /// the incoming value.
  const Angle.fromPercent(double percent)
      : this.percent = percent >= 0 || percent == -1.0
            ? percent % 1.0
            : (percent % 1.0) - 1.0,
        this.radians = percent >= 0 || percent == -1.0
            ? (percent % 1.0) * (2 * pi)
            : ((percent % 1.0) - 1.0) * (2 * pi),
        this.degrees = percent >= 0 || percent == -1.0
            ? (percent % 1.0) * 360
            : ((percent % 1.0) - 1.0) * 360;

  /// Angle expressed as degrees.
  final num degrees;

  /// Angle expressed as radians.
  final num radians;

  /// Angle expressed as a percentage.
  final num percent;

  /// True if this `Angle` is greater than or equal to zero.
  bool get isPositive => degrees >= 0;

  /// True if this `Angle` is less than zero.
  bool get isNegative => degrees < 0;

  /// True if this `Angle` is acute, i.e., in [0°, 90°).
  bool get isAcute => degrees.abs() < 90;

  /// True if this `Angle` is obtuse, i.e., in [90°, 180°).
  bool get isObtuse => !isAcute && degrees.abs() < 180;

  /// True if this `Angle` is reflexive, i.e., in [180°, 360°).
  bool get isReflexive => !isAcute && !isObtuse;

  /// This `Angle`s category, e.g., acute, obtuse, or reflexive.
  AngleCategory get category => isAcute
      ? AngleCategory.acute
      : isObtuse ? AngleCategory.obtuse : AngleCategory.reflex;

  /// Returns a positive version of this `Angle`.
  ///
  /// If this `Angle` is already positive, this `Angle` is returned.
  ///
  /// If this `Angle` is negative, then its positive complement is returned.
  Angle makePositive() => isPositive ? this : Angle.fromDegrees(360 + degrees);

  /// Returns a negative version of this `Angle`.
  ///
  /// If this `Angle` is already negative, this `Angle` is returned.
  ///
  /// If this `Angle` is positive, then its negative complement is returned.
  Angle makeNegative() => isNegative ? this : Angle.fromDegrees(degrees - 360);

  /// Converts a non-reflexive `Angle` to its reflexive complement, or a
  /// reflexive `Angle` to its non-reflexive complement, e.g., 90° -> 270° or
  /// 270° -> 90°.
  Angle get complement {
    return Angle.fromDegrees((360 - degrees.abs()) * degrees.sign);
  }

  /// Returns a new `Angle`, which is the same as this `Angle` but in the
  /// opposite direction.
  Angle operator -() {
    return Angle.fromDegrees(-degrees);
  }

  /// Adds two `Angle`s together, producing a new `Angle`.
  ///
  /// Adding a negative `Angle` has the same effect as subtracting a positive
  /// `Angle`.
  Angle operator +(Angle other) {
    return Angle.fromDegrees(degrees + other.degrees);
  }

  /// Subtracts the `other` `Angle` from this `Angle`, producing a new `Angle`.
  Angle operator -(Angle other) {
    return Angle.fromDegrees(degrees - other.degrees);
  }

  /// Multiplies this `Angle` by the given scalar.
  Angle operator *(num scalar) {
    return Angle.fromDegrees(degrees * scalar);
  }

  /// Divides this `Angle` by the given scalar.
  Angle operator /(num scalar) {
    if (scalar == 0) {
      throw DivisionByZeroException();
    }
    return Angle.fromDegrees(degrees / scalar);
  }

  /// Adds the `other` `Angle` to this `Angle`, producing a `Rotation`.
  ///
  /// The difference between a `Rotation` and an `Angle` is that a `Rotation`
  /// can be arbitrarily large in the positive or negative direction.
  Rotation rotate(Angle other) {
    return Rotation.fromDegrees(degrees + other.degrees);
  }

  @override
  bool isEquivalentTo(Angle other) {
    return degrees % 360 == other.degrees % 360;
  }

  @override
  bool isApproximately(Angle other, {num percentVariance = 0.01}) {
    return (other.degrees - degrees).abs() / degrees <= percentVariance;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Angle &&
          runtimeType == other.runtimeType &&
          degrees == other.degrees;

  @override
  int get hashCode => degrees.hashCode;

  @override
  String toString() {
    return '$degrees°';
  }
}

enum AngleDirection {
  // A positive angle.
  clockwise,
  // A negative angle.
  counterclockwise,
}

enum AngleCategory {
  // Angle in [0°, 90°)
  acute,
  // Angle in [90°, 180)
  obtuse,
  // Angle in [180°, 360)
  reflex,
}

/// `Rotation` is like an angle that may exceed 360° in the positive or negative
/// direction.
class Rotation {
  static const Rotation zero = Rotation.fromDegrees(0);

  const Rotation.fromDegrees(num degrees)
      : degrees = degrees,
        radians = degrees * pi / 180;

  const Rotation.fromRadians(num radians)
      : radians = radians,
        degrees = radians * 180 / pi;

  Rotation.fromAngle(Angle angle)
      : degrees = angle.degrees,
        radians = angle.radians;

  /// Angle expressed as degrees.
  final num degrees;

  /// Angle expressed as radians.
  final num radians;

  /// Returns an inverted version of this `Rotation`, e.g., -90° to 90°.
  operator -() {
    return Rotation.fromDegrees(-degrees);
  }

  /// Returns the sum of this `Rotation` and the `other` `Rotation`.
  Rotation operator +(Rotation other) {
    return Rotation.fromDegrees(degrees + other.degrees);
  }

  /// Returns the subtraction of `other` from this `Rotation`.
  Rotation operator -(Rotation other) {
    return Rotation.fromDegrees(degrees - other.degrees);
  }

  /// Multiplies this `Rotation` by the given `scalar`.
  Rotation operator *(num scalar) {
    return Rotation.fromDegrees(degrees * scalar);
  }

  /// Divides this `Rotation` by the given `scalar`.
  Rotation operator /(num scalar) {
    if (scalar == 0) {
      throw DivisionByZeroException();
    }
    return Rotation.fromDegrees(degrees / scalar);
  }

  /// Returns an `Angle` that is equivalent to this `Rotation` with all 360°
  /// cycles removed.
  Angle reduceToAngle() => Angle.fromDegrees(degrees);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Rotation &&
          runtimeType == other.runtimeType &&
          degrees == other.degrees;

  @override
  int get hashCode => degrees.hashCode;

  @override
  String toString() {
    return '$degrees°';
  }
}
