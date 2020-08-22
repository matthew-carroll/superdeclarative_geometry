import 'dart:math';

import 'angles.dart';
import 'common.dart';

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
  PolarCoord.fromCartesian(Point point)
      : this.radius = point.magnitude,
        this.angle = Angle.fromRadians(atan2(point.y, point.x));

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
  ///
  /// To force a clockwise or counter-clockwise direction for the return `Angle`,
  /// pass the desired `AngleDirection` in `desiredDirection`.
  Angle angleBetween(
    PolarCoord other, {
    bool chooseReflexAngle,
    AngleDirection desiredDirection,
  }) {
    Angle angleBetween = angle - other.angle;

    // Ensure the Angle is reflexive or non-reflexive based on preference.
    if (chooseReflexAngle != null) {
      if (angleBetween.isReflexive && !chooseReflexAngle) {
        angleBetween = angleBetween.invert();
      } else if (!angleBetween.isReflexive && chooseReflexAngle) {
        angleBetween = angleBetween.invert();
      }
    }

    // Ensure the Angle is CW or CCW based on preference.
    if (desiredDirection != null) {
      switch (desiredDirection) {
        case AngleDirection.clockwise:
          angleBetween = angleBetween.makeClockwise();
          break;
        case AngleDirection.counterclockwise:
          angleBetween = angleBetween.makeCounterClockwise();
          break;
      }
    }

    return angleBetween;
  }

  /// Maps this `PolarCoord` to a Cartesian `Point` by way of the provided
  /// `orientation`.
  ///
  /// By default a `ScreenOrientation` is used, which treats an angle of 0°
  /// as pointing to the right, and positive rotations as clockwise.
  Point toCartesian(
      {CartesianOrientation orientation = CartesianOrientation.screen}) {
    return orientation.polarToCartesian(this);
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

/// Maps a `PolarCoord` to a Cartesian `Point` based on a given
/// orientation, e.g., the direction of the 0° axis and whether the
/// positive rotation direction is clockwise or counter-clockwise.
abstract class CartesianOrientation {
  static const CartesianOrientation screen = ScreenOrientation();
  static const CartesianOrientation math = MathOrientation();
  static const CartesianOrientation navigation = NavigationOrientation();

  Point polarToCartesian(PolarCoord polarCoord);
}

/// Orientation with a reference direction pointing to the right, with a
/// clockwise rotation.
class ScreenOrientation implements CartesianOrientation {
  const ScreenOrientation();

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * cos(polarCoord.angle.radians),
      polarCoord.radius * sin(polarCoord.angle.radians),
    );
  }
}

/// Orientation with a reference direction pointing to the right, with a
/// counter-clockwise rotation.
class MathOrientation implements CartesianOrientation {
  const MathOrientation();

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * cos(polarCoord.angle.radians),
      polarCoord.radius * -sin(polarCoord.angle.radians),
    );
  }
}

/// Orientation with a reference direction pointing up from the origin, with
/// a clockwise rotation.
class NavigationOrientation implements CartesianOrientation {
  const NavigationOrientation();

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * sin(polarCoord.angle.radians),
      polarCoord.radius * cos(polarCoord.angle.radians),
    );
  }
}
