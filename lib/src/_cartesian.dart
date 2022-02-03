import 'dart:math';

import 'package:superdeclarative_geometry/src/_polar_coords.dart';

import '_angles.dart';

/// Frame of reference for mapping `Angle`s and `PolarCoord`s to Cartesian
/// coordinates.
///
/// `CartesianOrientation`s exist because the 0° axis and the positive direction
/// of an `Angle` changes depending on use-case.
///
/// In mathematics a 0° angle points to the right, and a positive angle rotates
/// counter-clockwise.
///
/// In screen space a 0° angle points to the right, and a positive angle rotates
/// clockwise.
///
/// In ship navigation a 0° angle points up, and a positive angle rotates
/// clockwise.
///
/// In each of the above use-cases, the exact same `Angle` or `PolarCoord`
/// corresponds to different Cartesian coordinates due to the orientation.
abstract class CartesianOrientation {
  static const CartesianOrientation screen = ScreenOrientation();
  static const CartesianOrientation math = MathOrientation();
  static const CartesianOrientation navigation = NavigationOrientation();

  /// Returns true if the given `angle` represents a clockwise movement from
  /// the 0° axis, or false otherwise.
  bool isAngleClockwise(Angle angle);

  /// Returns true if the given `angle` represents a counter-clockwise movement
  /// from the 0° axis, or false otherwise.
  bool isAngleCounterClockwise(Angle angle);

  /// Returns a clockwise version of the given `angle`, as seen through the
  /// given `orientation`.
  Angle makeAngleClockwise(Angle angle);

  /// Returns a counter-clockwise version of the given `angle`, as seen through
  /// the given `orientation`.
  Angle makeAngleCounterClockwise(Angle angle);

  /// Returns the given `angle` as seen by a screen's coordinate system.
  Angle toScreenAngle(Angle angle);

  /// Returns true if the given `rotation` represents a clockwise movement from
  /// the 0° axis, or false otherwise.
  bool isRotationClockwise(Rotation rotation);

  /// Returns true if the given `rotation` represents a counter-clockwise movement
  /// from the 0° axis, or false otherwise.
  bool isRotationCounterClockwise(Rotation rotation);

  /// Returns a clockwise version of the given `rotation`, as seen through the
  /// given `orientation`.
  Rotation makeRotationClockwise(Rotation rotation);

  /// Returns a counter-clockwise version of the given `rotation`, as seen through
  /// the given `orientation`.
  Rotation makeRotationCounterClockwise(Rotation rotation);

  /// Returns the given `rotation` as seen by a screen's coordinate system.
  Rotation toScreenRotation(Rotation rotation);

  /// Maps the given `polarCoord` to Cartesian coordinates within this orientation.
  Point polarToCartesian(PolarCoord polarCoord);

  /// Maps the given `cartesianCoord` within this orientation to a `PolarCoord`.
  PolarCoord cartesianToPolar(Point cartesianCoord);

  /// Returns the given `point` as seen by a screen's coordinate system.
  Point toScreenPoint(Point point);

  /// Returns the given screen-based `point` as seen by this coordinate system.
  Point fromScreenPoint(Point point);
}

/// Orientation with a reference direction pointing to the right, with a
/// clockwise rotation.
class ScreenOrientation implements CartesianOrientation {
  const ScreenOrientation();

  @override
  bool isAngleClockwise(Angle angle) => angle.degrees >= 0;

  @override
  bool isAngleCounterClockwise(Angle angle) => angle.degrees <= 0;

  @override
  Angle makeAngleClockwise(Angle angle) {
    return angle.degrees >= 0.0 ? angle : Angle.fromDegrees(360 + angle.degrees);
  }

  @override
  Angle makeAngleCounterClockwise(Angle angle) {
    return angle.degrees <= 0.0 ? angle : Angle.fromDegrees(angle.degrees - 360);
  }

  @override
  Angle toScreenAngle(Angle angle) {
    return angle;
  }

  bool isRotationClockwise(Rotation rotation) => rotation.degrees >= 0;

  bool isRotationCounterClockwise(Rotation rotation) => rotation.degrees <= 0;

  Rotation makeRotationClockwise(Rotation rotation) {
    return isRotationClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  Rotation makeRotationCounterClockwise(Rotation rotation) {
    return isRotationCounterClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  @override
  Rotation toScreenRotation(Rotation rotation) {
    return rotation;
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
    return PolarCoord(point.magnitude, Angle.fromRadians(atan2(point.y, point.x)));
  }

  @override
  Point toScreenPoint(Point point) {
    return point;
  }

  @override
  Point fromScreenPoint(Point point) {
    return point;
  }
}

/// Orientation with a reference direction pointing to the right, with a
/// counter-clockwise rotation.
class MathOrientation implements CartesianOrientation {
  const MathOrientation();

  @override
  bool isAngleClockwise(Angle angle) => angle.degrees <= 0;

  @override
  bool isAngleCounterClockwise(Angle angle) => angle.degrees >= 0;

  @override
  Angle makeAngleClockwise(Angle angle) {
    return angle.degrees <= 0.0 ? angle : Angle.fromDegrees(angle.degrees - 360);
  }

  @override
  Angle makeAngleCounterClockwise(Angle angle) {
    return angle.degrees >= 0.0 ? angle : Angle.fromDegrees(360 + angle.degrees);
  }

  @override
  Angle toScreenAngle(Angle angle) {
    return -angle;
  }

  bool isRotationClockwise(Rotation rotation) => rotation.degrees <= 0;

  bool isRotationCounterClockwise(Rotation rotation) => rotation.degrees >= 0;

  Rotation makeRotationClockwise(Rotation rotation) {
    return isRotationClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  Rotation makeRotationCounterClockwise(Rotation rotation) {
    return isRotationCounterClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  @override
  Rotation toScreenRotation(Rotation rotation) {
    return -rotation;
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
      point.magnitude,
      Angle.fromRadians(atan2(point.y, point.x)),
    );
  }

  @override
  Point toScreenPoint(Point point) {
    return Point(point.x, -point.y);
  }

  @override
  Point fromScreenPoint(Point point) {
    return Point(point.x, -point.y);
  }
}

/// Orientation with a reference direction pointing up from the origin, with
/// a clockwise rotation.
// TODO: Right now navigation is coded to use the same coordinate system as the
//       screen, but I think the zero axis should be the y-axis and then the
//       quadrants should start in the upper right with Q1 and then go
//       clockwise.
class NavigationOrientation implements CartesianOrientation {
  const NavigationOrientation();

  @override
  bool isAngleClockwise(Angle angle) => angle.degrees >= 0;

  @override
  bool isAngleCounterClockwise(Angle angle) => angle.degrees <= 0;

  @override
  Angle makeAngleClockwise(Angle angle) {
    return angle.degrees >= 0.0 ? angle : Angle.fromDegrees(360 + angle.degrees);
  }

  @override
  Angle makeAngleCounterClockwise(Angle angle) {
    return angle.degrees <= 0.0 ? angle : Angle.fromDegrees(angle.degrees - 360);
  }

  @override
  Angle toScreenAngle(Angle angle) {
    return angle - Angle.deg90;
  }

  bool isRotationClockwise(Rotation rotation) => rotation.degrees <= 0;

  bool isRotationCounterClockwise(Rotation rotation) => rotation.degrees >= 0;

  Rotation makeRotationClockwise(Rotation rotation) {
    return isRotationClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  Rotation makeRotationCounterClockwise(Rotation rotation) {
    return isRotationCounterClockwise(rotation) ? rotation : Rotation.fromDegrees(-rotation.degrees);
  }

  @override
  Rotation toScreenRotation(Rotation rotation) {
    return rotation + Rotation.fromAngle(Angle.deg90);
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
    return PolarCoord(
      point.magnitude,
      Angle.fromRadians(atan2(point.y, point.x)) + Angle.deg90,
    );
  }

  @override
  Point toScreenPoint(Point point) {
    return point;
  }

  @override
  Point fromScreenPoint(Point point) {
    return point;
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
  bool isClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isAngleClockwise(this);

  /// True if this `Angle` represents a counter-clockwise arc, or zero.
  bool isCounterClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isAngleCounterClockwise(this);

  /// Returns `AngleDirection.clockwise` if this `Angle` is clockwise within
  /// the given `orientation`, or `AngleDirection.counterClockwise` otherwise.
  AngleDirection direction([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      isClockwise(orientation) ? AngleDirection.clockwise : AngleDirection.counterclockwise;

  /// Returns a clockwise version of this `Angle`.
  Angle makeClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeAngleClockwise(this);
  }

  /// Returns a counter-clockwise version of this `Angle`.
  Angle makeCounterClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeAngleCounterClockwise(this);
  }
}

/// Extensions for `Rotation` objects that introduce Cartesian concepts.
///
/// Clockwise and Counter-Clockwise: You might wonder why CW and CCW properties
/// are defined here, rather than on `Rotation`, itself. Consider that when you
/// look at a device screen, positive rotations move clockwise. When you look at
/// a mathematical graph, positive rotations move counter-clockwise. A rotation in
/// isolation cannot know whether it is CW or CCW. Thus, this directional
/// concept is tied to a particular Cartesian orientation.
extension CartesianRotation on Rotation {
  /// True if this `Rotation` represents a clockwise turn, or zero.
  bool isClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isRotationClockwise(this);

  /// True if this `Rotation` represents a counter-clockwise turn, or zero.
  bool isCounterClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      orientation.isRotationCounterClockwise(this);

  /// Returns `AngleDirection.clockwise` if this `Rotation` is clockwise within
  /// the given `orientation`, or `AngleDirection.counterClockwise` otherwise.
  AngleDirection direction([CartesianOrientation orientation = CartesianOrientation.screen]) =>
      isClockwise(orientation) ? AngleDirection.clockwise : AngleDirection.counterclockwise;

  /// Returns a clockwise version of this `Rotation`.
  Rotation makeClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeRotationClockwise(this);
  }

  /// Returns a counter-clockwise version of this `Rotation`.
  Rotation makeCounterClockwise([CartesianOrientation orientation = CartesianOrientation.screen]) {
    return orientation.makeRotationCounterClockwise(this);
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

  /// Returns a `PolarCoord` that is equivalent to this `PolarCoord` offset
  /// by the given `delta` in the given `orientation`.
  PolarCoord moveInCartesianSpace(
    Point delta, {
    CartesianOrientation orientation = CartesianOrientation.screen,
  }) {
    return CartesianPolarCoords.fromPoint(
      this.toCartesian(orientation: orientation) + delta,
      orientation,
    );
  }
}

extension CartesianPoint on Point {
  Point toScreenPoint({
    required CartesianOrientation fromOrientation,
  }) {
    return fromOrientation.toScreenPoint(this);
  }

  Point fromScreenTo(CartesianOrientation orientation) {
    return orientation.fromScreenPoint(this);
  }

  Point translate(Point offset) {
    return Point(this.x + offset.x, this.y + offset.y);
  }
}
