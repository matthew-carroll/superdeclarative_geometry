import 'dart:math';

import 'package:superdeclarative_geometry/src/angles.dart';
import 'package:superdeclarative_geometry/src/polar_coords.dart';
import 'package:test/test.dart';

import 'common.dart';

void main() {
  group('PolarCoord', () {
    group('Construction', () {
      test('creates a PolarCoord from a Cartesian Point', () {
        expect(PolarCoord.fromCartesian(Point(100, 0)),
            isEquivalentTo(PolarCoord(100, Angle.zero)));
        expect(PolarCoord.fromCartesian(Point(0, 100)),
            isEquivalentTo(PolarCoord(100, Angle.fromDegrees(90))));
        expect(PolarCoord.fromCartesian(Point(-100, 0)),
            isEquivalentTo(PolarCoord(100, Angle.fromDegrees(180))));
        expect(PolarCoord.fromCartesian(Point(0, -100)),
            isEquivalentTo(PolarCoord(100, Angle.fromDegrees(270))));

        // Cartesian point at 45°
        expect(
            PolarCoord.fromCartesian(
              Point(100, 100),
            ),
            isEquivalentTo(PolarCoord(
              100 / sin(pi / 4),
              Angle.fromDegrees(45),
            )));
      });
    });

    group('Operators', () {
      test('adds PolarCoords together', () {
        expect(
            (PolarCoord(100, Angle.zero) +
                    PolarCoord(100, Angle.fromDegrees(90)))
                .isEquivalentTo(PolarCoord.fromCartesian(Point(100, 100))),
            true);
        expect(
            (PolarCoord(100, Angle.zero) +
                    PolarCoord(100, Angle.fromDegrees(-90)))
                .isEquivalentTo(PolarCoord.fromCartesian(Point(100, -100))),
            true);
      });
    });

    group('Rotation', () {
      test('rotates PolarCoords by Angles', () {
        expect(
          PolarCoord(100, Angle.fromDegrees(30)).rotate(Angle.fromDegrees(30)),
          PolarCoord(100, Angle.fromDegrees(60)),
        );
        expect(
          PolarCoord(100, Angle.fromDegrees(30)).rotate(Angle.fromDegrees(360)),
          PolarCoord(100, Angle.fromDegrees(30)),
        );
        expect(
          PolarCoord(100, Angle.fromDegrees(30)).rotate(Angle.fromDegrees(-30)),
          PolarCoord(100, Angle.fromDegrees(0)),
        );
      });
    });

    group('Angle Between', () {
      test('angle between polar coords', () {
        expect(
          PolarCoord(100, Angle.fromDegrees(90)).angleBetween(
            PolarCoord(100, Angle.fromDegrees(45)),
          ),
          Angle.fromDegrees(45),
        );
        expect(
          PolarCoord(100, Angle.fromDegrees(90)).angleBetween(
            PolarCoord(100, Angle.fromDegrees(45)),
            chooseReflexAngle: true,
          ),
          Angle.fromDegrees(315),
        );
        expect(
          PolarCoord(100, Angle.fromDegrees(90)).angleBetween(
              PolarCoord(100, Angle.fromDegrees(45)),
              desiredDirection: AngleDirection.counterclockwise),
          Angle.fromDegrees(-45),
        );

        expect(
          PolarCoord(100, Angle.fromDegrees(-90)).angleBetween(
            PolarCoord(100, Angle.fromDegrees(-45)),
          ),
          Angle.fromDegrees(-45),
        );

        expect(
          PolarCoord(100, Angle.fromDegrees(90)).angleBetween(
            PolarCoord(100, Angle.fromDegrees(-45)),
          ),
          Angle.fromDegrees(135),
        );
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
            isApproximatelyPoint(Point(0, -100)));
        expect(
            PolarCoord(100, Angle.fromDegrees(180))
                .toCartesian(orientation: CartesianOrientation.math),
            isApproximatelyPoint(Point(-100, 0)));
        expect(
            PolarCoord(100, Angle.fromDegrees(270))
                .toCartesian(orientation: CartesianOrientation.math),
            isApproximatelyPoint(Point(0, 100)));
      });

      test('maps PolarCoords to navigation-oriented Cartesian Points', () {
        expect(
            PolarCoord(100, Angle.fromDegrees(0))
                .toCartesian(orientation: CartesianOrientation.navigation),
            isApproximatelyPoint(Point(0, 100)));
        expect(
            PolarCoord(100, Angle.fromDegrees(90))
                .toCartesian(orientation: CartesianOrientation.navigation),
            isApproximatelyPoint(Point(100, 0)));
        expect(
            PolarCoord(100, Angle.fromDegrees(180))
                .toCartesian(orientation: CartesianOrientation.navigation),
            isApproximatelyPoint(Point(0, -100)));
        expect(
            PolarCoord(100, Angle.fromDegrees(270))
                .toCartesian(orientation: CartesianOrientation.navigation),
            isApproximatelyPoint(Point(-100, 0)));
      });
    });
  });
}
