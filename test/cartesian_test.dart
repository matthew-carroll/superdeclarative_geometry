import 'dart:math';

import 'package:superdeclarative_geometry/superdeclarative_geometry.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('Cartesian', () {
    group('Angles', () {
      test('reports clockwise and counter-clockwise', () {
        expect(Angle.fromDegrees(45).isClockwise(), true);
        expect(Angle.fromDegrees(45).isCounterClockwise(), false);

        expect(Angle.fromDegrees(-45).isClockwise(), false);
        expect(Angle.fromDegrees(-45).isCounterClockwise(), true);

        expect(Angle.fromDegrees(0).isClockwise(), true);
        expect(Angle.fromDegrees(0).isClockwise(), true);
      });

      test('make clockwise and counterclockwise', () {
        expect(Angle.fromDegrees(45).makeClockwise(), Angle.fromDegrees(45));
        expect(Angle.fromDegrees(45).makeCounterClockwise(),
            Angle.fromDegrees(-315));
        expect(Angle.fromDegrees(-45).makeClockwise(), Angle.fromDegrees(315));
        expect(Angle.fromDegrees(-45).makeCounterClockwise(),
            Angle.fromDegrees(-45));
      });
    });

    group('Rotations', () {
      test('reports clockwise and counter-clockwise', () {
        expect(Rotation.fromDegrees(540).isClockwise(), true);
        expect(Rotation.fromDegrees(540).isCounterClockwise(), false);

        expect(Rotation.fromDegrees(-540).isClockwise(), false);
        expect(Rotation.fromDegrees(-540).isCounterClockwise(), true);

        expect(Rotation.fromDegrees(0).isClockwise(), true);
        expect(Rotation.fromDegrees(0).isClockwise(), true);
      });

      test('make clockwise and counterclockwise', () {
        expect(Rotation.fromDegrees(540).makeClockwise(),
            Rotation.fromDegrees(540));
        expect(Rotation.fromDegrees(540).makeCounterClockwise(),
            Rotation.fromDegrees(-540));
        expect(Rotation.fromDegrees(-540).makeClockwise(),
            Rotation.fromDegrees(540));
        expect(Rotation.fromDegrees(-540).makeCounterClockwise(),
            Rotation.fromDegrees(-540));
      });
    });

    group('PolarCoords', () {
      group('Construction', () {
        test('creates a PolarCoord from a Cartesian Point', () {
          expect(CartesianPolarCoords.fromPoint(Point(100, 0)),
              isEquivalentTo(PolarCoord(100, Angle.zero)));
          expect(CartesianPolarCoords.fromPoint(Point(0, 100)),
              isEquivalentTo(PolarCoord(100, Angle.fromDegrees(90))));
          expect(CartesianPolarCoords.fromPoint(Point(-100, 0)),
              isEquivalentTo(PolarCoord(100, Angle.fromDegrees(180))));
          expect(CartesianPolarCoords.fromPoint(Point(0, -100)),
              isEquivalentTo(PolarCoord(100, Angle.fromDegrees(270))));

          // Cartesian point at 45°
          expect(
              CartesianPolarCoords.fromPoint(
                Point(100, 100),
              ),
              isEquivalentTo(PolarCoord(
                100 / sin(pi / 4),
                Angle.fromDegrees(45),
              )));
        });
      });

      group('Cartesian Mapping', () {
        test('maps PolarCoords to screen-oriented Cartesian Points', () {
          expect(PolarCoord(100, Angle.fromDegrees(0)).toCartesian(),
              isApproximatelyPoint(Point(100, 0)));
          expect(PolarCoord(100, Angle.fromDegrees(90)).toCartesian(),
              isApproximatelyPoint(Point(0, 100)));
          expect(PolarCoord(100, Angle.fromDegrees(180)).toCartesian(),
              isApproximatelyPoint(Point(-100, 0)));
          expect(PolarCoord(100, Angle.fromDegrees(270)).toCartesian(),
              isApproximatelyPoint(Point(0, -100)));
        });

        test('maps PolarCoords to math-oriented Cartesian Points', () {
          expect(
              PolarCoord(100, Angle.fromDegrees(0))
                  .toCartesian(orientation: CartesianOrientation.math),
              isApproximatelyPoint(Point(100, 0)));
          expect(
              PolarCoord(100, Angle.fromDegrees(90))
                  .toCartesian(orientation: CartesianOrientation.math),
              isApproximatelyPoint(Point(0, 100)));
          expect(
              PolarCoord(100, Angle.fromDegrees(180))
                  .toCartesian(orientation: CartesianOrientation.math),
              isApproximatelyPoint(Point(-100, 0)));
          expect(
              PolarCoord(100, Angle.fromDegrees(270))
                  .toCartesian(orientation: CartesianOrientation.math),
              isApproximatelyPoint(Point(0, -100)));
        });

        test('maps PolarCoords to navigation-oriented Cartesian Points', () {
          expect(
              PolarCoord(100, Angle.fromDegrees(0))
                  .toCartesian(orientation: CartesianOrientation.navigation),
              isApproximatelyPoint(Point(0, -100)));
          expect(
              PolarCoord(100, Angle.fromDegrees(90))
                  .toCartesian(orientation: CartesianOrientation.navigation),
              isApproximatelyPoint(Point(100, 0)));
          expect(
              PolarCoord(100, Angle.fromDegrees(180))
                  .toCartesian(orientation: CartesianOrientation.navigation),
              isApproximatelyPoint(Point(0, 100)));
          expect(
              PolarCoord(100, Angle.fromDegrees(270))
                  .toCartesian(orientation: CartesianOrientation.navigation),
              isApproximatelyPoint(Point(-100, 0)));
        });
      });
    });
  });
}
