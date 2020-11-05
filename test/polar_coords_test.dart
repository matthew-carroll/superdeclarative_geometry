import 'dart:math';

import 'package:superdeclarative_geometry/src/angles.dart';
import 'package:superdeclarative_geometry/src/polar_coords.dart';
import 'package:superdeclarative_geometry/superdeclarative_geometry.dart';
import 'package:test/test.dart';

void main() {
  group('PolarCoord', () {
    group('Construction', () {
      //
    });

    group('Operators', () {
      test('adds PolarCoords together', () {
        expect(
            (PolarCoord(100, Angle.zero) +
                    PolarCoord(100, Angle.fromDegrees(90)))
                .isEquivalentTo(
                    CartesianPolarCoords.fromPoint(Point(100, 100))),
            true);
        expect(
            (PolarCoord(100, Angle.zero) +
                    PolarCoord(100, Angle.fromDegrees(-90)))
                .isEquivalentTo(
                    CartesianPolarCoords.fromPoint(Point(100, -100))),
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
  });
}
