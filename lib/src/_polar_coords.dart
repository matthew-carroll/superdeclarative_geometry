import 'dart:math';

import '_angles.dart';
import '_common.dart';

/// Canonical mathematical concept of a "polar coordinate".
///
/// Polar coordinates are defined by an angle, and a distance from the origin,
/// e.g., (100, 45°). The distance is often referred to as the `radius`.
///
/// Polar coordinates offer an alternative expression to positions other than
/// Cartesian coordinates. Polar coordinates naturally lend themselves to
/// radial problem spaces, e.g., clock and watch faces, radial progress
/// indicators, radial thermostat and thermometer displays, etc.
///
/// Polar coordinates may be added together, subtracted from each other,
/// multiplied and divided by scalars, and rotated by an angle. It is also
/// possible to calculate the angle between polar coordinates.
class PolarCoord implements Equivalency<PolarCoord>, Approximately<PolarCoord> {
  const PolarCoord(
    this.radius,
    this.angle,
  ) : assert(radius >= 0, 'Radius values must be >= 0');

  final double radius;
  final Angle angle;

  /// Inverts the direction of this `PolarCoord`, i.e., rotates it by 180°.
  operator -() {
    return PolarCoord(
      radius,
      -angle,
    );
  }

  /// Adds `other` to this `PolarCoord`.
  ///
  /// `PolarCoord` addition is equivalent to 2D vector addition.
  PolarCoord operator +(PolarCoord other) {
    // Equation pull from:
    // https://math.stackexchange.com/questions/1365622/adding-two-polar-vectors
    return PolarCoord(
      sqrt(pow(radius, 2) +
          pow(other.radius, 2) +
          (2 * radius * other.radius * cos((other.angle - angle).radians))),
      angle +
          Angle.fromRadians(atan2(
              other.radius * sin((other.angle - angle).radians),
              radius + (other.radius * cos((other.angle - angle).radians)))),
    );
  }

  /// Subtracts `other` from this `PolarCoord`.
  ///
  /// `PolarCoord` subtraction is equivalent to 2D vector subtraction.
  PolarCoord operator -(PolarCoord other) {
    // Due to the complexity of the "+" operation, we implement subtraction as
    // the addition of the inverse of "other".
    return this + (-other);
  }

  /// Multiplies the radius and angle of this `PolarCoord` by the given `scalar`.
  PolarCoord operator *(num scalar) {
    return PolarCoord(radius * scalar, angle * scalar);
  }

  /// Divides the radius and angle of this `PolarCoord` by the given `scalar`.
  PolarCoord operator /(num scalar) {
    if (scalar == 0) {
      throw DivisionByZeroException();
    }
    return PolarCoord(radius / scalar, angle / scalar);
  }

  /// Returns a `PolarCoord` equivalent to this `PolarCoord` rotated by the
  /// given `Angle`.
  PolarCoord rotate(Angle angle) {
    return PolarCoord(radius, this.angle + angle);
  }

  /// Returns the `Angle` between this `PolarCoord` and `other`.
  ///
  /// By default, the returned `Angle` is equal to the `Angle` of this
  /// `PolarCoord` minus the `Angle` of `other`.
  ///
  /// To force a reflexive or non-reflexive version of the return `Angle`, pass
  /// `true` or `false` to `chooseReflexAngle` for reflexive or non-reflexive,
  /// respectively.
  Angle angleBetween(
    PolarCoord other, {
    bool chooseReflexAngle,
  }) {
    Angle angleBetween = angle - other.angle;

    // Ensure the Angle is reflexive or non-reflexive based on preference.
    if (chooseReflexAngle != null) {
      if (angleBetween.isReflexive && !chooseReflexAngle) {
        angleBetween = angleBetween.complement;
      } else if (!angleBetween.isReflexive && chooseReflexAngle) {
        angleBetween = angleBetween.complement;
      }
    }

    return angleBetween;
  }

  @override
  bool isEquivalentTo(PolarCoord other) {
    return radius == other.radius && angle.isEquivalentTo(other.angle);
  }

  @override
  bool isApproximately(PolarCoord other, {num percentVariance = 0.01}) {
    return (other.radius - radius).abs() / radius <= percentVariance &&
        angle.isApproximately(other.angle, percentVariance: percentVariance);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PolarCoord &&
          runtimeType == other.runtimeType &&
          radius == other.radius &&
          angle == other.angle;

  @override
  int get hashCode => radius.hashCode ^ angle.hashCode;

  @override
  String toString() => '($radius, ${angle.degrees}°)';
}
