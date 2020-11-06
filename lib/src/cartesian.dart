import 'dart:math';

import 'package:superdeclarative_geometry/src/polar_coords.dart';

import 'angles.dart';

/// Maps a `PolarCoord` to a Cartesian `Point` based on a given
/// orientation, e.g., the direction of the 0° axis and whether the
/// positive rotation direction is clockwise or counter-clockwise.
abstract class CartesianOrientation {
  static const CartesianOrientation screen = ScreenOrientation();
  static const CartesianOrientation math = MathOrientation();
  static const CartesianOrientation navigation = NavigationOrientation();

  bool isClockwise(Angle angle);

  bool isCounterClockwise(Angle angle);

  Angle makeClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]);

  Angle makeCounterClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]);

  Point polarToCartesian(PolarCoord polarCoord);

  PolarCoord cartesianToPolar(Point cartesianCoord);
}

/// Orientation with a reference direction pointing to the right, with a
/// clockwise rotation.
class ScreenOrientation implements CartesianOrientation {
  const ScreenOrientation();

  bool isClockwise(Angle angle) => angle.degrees >= 0;

  bool isCounterClockwise(Angle angle) => angle.degrees <= 0;

  Angle makeClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees >= 0.0
        ? angle
        : Angle.fromDegrees(360 + angle.degrees);
  }

  Angle makeCounterClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees <= 0.0
        ? angle
        : Angle.fromDegrees(angle.degrees - 360);
  }

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * cos(polarCoord.angle.radians),
      polarCoord.radius * sin(polarCoord.angle.radians),
    );
  }

  @override
  PolarCoord cartesianToPolar(Point<num> point) {
    return PolarCoord(
        point.magnitude, Angle.fromRadians(atan2(point.y, point.x)));
  }
}

/// Orientation with a reference direction pointing to the right, with a
/// counter-clockwise rotation.
class MathOrientation implements CartesianOrientation {
  const MathOrientation();

  bool isClockwise(Angle angle) => angle.degrees <= 0;

  bool isCounterClockwise(Angle angle) => angle.degrees >= 0;

  Angle makeClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees <= 0.0
        ? angle
        : Angle.fromDegrees(angle.degrees - 360);
  }

  Angle makeCounterClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees >= 0.0
        ? angle
        : Angle.fromDegrees(360 + angle.degrees);
  }

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * cos(polarCoord.angle.radians),
      polarCoord.radius * -sin(polarCoord.angle.radians),
    );
  }

  @override
  PolarCoord cartesianToPolar(Point<num> point) {
    return PolarCoord(
        point.magnitude, -Angle.fromRadians(atan2(point.y, point.x)));
  }
}

/// Orientation with a reference direction pointing up from the origin, with
/// a clockwise rotation.
class NavigationOrientation implements CartesianOrientation {
  const NavigationOrientation();

  bool isClockwise(Angle angle) => angle.degrees >= 0;

  bool isCounterClockwise(Angle angle) => angle.degrees <= 0;

  Angle makeClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees >= 0.0
        ? angle
        : Angle.fromDegrees(360 + angle.degrees);
  }

  Angle makeCounterClockwise(Angle angle,
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return angle.degrees <= 0.0
        ? angle
        : Angle.fromDegrees(angle.degrees - 360);
  }

  @override
  Point<num> polarToCartesian(PolarCoord polarCoord) {
    return Point(
      polarCoord.radius * cos((polarCoord.angle - Angle.deg90).radians),
      polarCoord.radius * sin((polarCoord.angle - Angle.deg90).radians),
    );
  }

  @override
  PolarCoord cartesianToPolar(Point<num> point) {
    return PolarCoord(point.magnitude,
        Angle.fromRadians(atan2(point.y, point.x)) + Angle.deg90);
  }
}

/// Extensions for `Angle` objects that introduce Cartesian concepts.
///
/// Clockwise and Counter-Clockwise: You might wonder why CW and CCW properties
/// are defined here, rather than on `Angle`, itself. Consider that when you
/// look at a device screen, positive angles move clockwise. When you look at
/// a mathematical graph, positive angles move counter-clockwise. An angle in
/// isolation cannot know whether it is CW or CCW. Thus, this directional
/// concept is tied to a particular Cartesian orientation.
extension CartesianAngle on Angle {
  /// True if this `Angle` represents a clockwise arc, or zero.
  bool isClockwise(
          [CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isClockwise(this);

  /// True if this `Angle` represents a counter-clockwise arc, or zero.
  bool isCounterClockwise(
          [CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isCounterClockwise(this);

  /// Clockwise for positive angles, counter-clockwise for negative angles.
  AngleDirection direction(
          [CartesianOrientation orientation = CartesianOrientation.screen]) =>
      isClockwise(orientation)
          ? AngleDirection.clockwise
          : AngleDirection.counterclockwise;

  /// Returns a clockwise version of this `Angle`.
  Angle makeClockwise(
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeClockwise(this);
  }

  /// Returns a counter-clockwise version of this `Angle`.
  Angle makeCounterClockwise(
      [CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeCounterClockwise(this);
  }
}

class CartesianPolarCoords {
  static PolarCoord fromPoint(
    Point point, [
    CartesianOrientation orientation = CartesianOrientation.screen,
  ]) {
    return orientation.cartesianToPolar(point);
  }
}

extension CartesianPolarCoord on PolarCoord {
  /// Maps this `PolarCoord` to a Cartesian `Point` by way of the provided
  /// `orientation`.
  ///
  /// By default a `ScreenOrientation` is used, which treats an angle of 0°
  /// as pointing to the right, and positive rotations as clockwise.
  Point toCartesian({
    CartesianOrientation orientation = CartesianOrientation.screen,
  }) {
    return orientation.polarToCartesian(this);
  }
}
