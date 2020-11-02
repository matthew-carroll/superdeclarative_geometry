import 'dart:math';

import 'package:superdeclarative_geometry/src/angles.dart';
import 'package:superdeclarative_geometry/src/common.dart';
import 'package:test/test.dart';

void main() {
  group('Angle', () {
    group('Value Ranges', () {
      test('limits degree values to (-360°, 360°)', () {
        expect(Angle.fromDegrees(360).degrees, 0);
        expect(Angle.fromDegrees(361).degrees, 1);
        expect(Angle.fromDegrees(450).degrees, 90);
        expect(Angle.fromDegrees(-360).degrees, 0);
        expect(Angle.fromDegrees(-361).degrees, -1);
        expect(Angle.fromDegrees(-450).degrees, -90);
      });

      test('limits radian values to (-2pi, 2pi)', () {
        expect(Angle.fromRadians(2 * pi).radians, 0);
        expect(Angle.fromRadians(2.1 * pi).radians, 0.1 * pi);
        expect(Angle.fromRadians(3 * pi).radians, pi);
        expect(Angle.fromRadians(-2 * pi).radians, 0);
        expect(Angle.fromRadians(-2.1 * pi).radians, -0.1 * pi);
        expect(Angle.fromRadians(-3 * pi).radians, -pi);
      });
    });

    group('Conversions', () {
      test('converts degrees to radians', () {
        expect(Angle.fromDegrees(0).radians, 0);
        expect(Angle.fromDegrees(90).radians, pi / 2);
        expect(Angle.fromDegrees(180).radians, pi);
        expect(Angle.fromDegrees(270).radians, 3 * pi / 2);
        expect(Angle.fromDegrees(-90).radians, -pi / 2);
      });

      test('converts radians to degrees', () {
        expect(Angle.fromRadians(0).degrees, 0);
        expect(Angle.fromRadians(pi / 2).degrees, 90);
        expect(Angle.fromRadians(pi).degrees, 180);
        expect(Angle.fromRadians(3 * pi / 2).degrees, 270);
        expect(Angle.fromRadians(-pi / 2).degrees, -90);
      });
    });

    group('Inspection', () {
      test('reports clockwise and counter-clockwise', () {
        expect(Angle.fromDegrees(45).isClockwise, true);
        expect(Angle.fromDegrees(45).isCounterClockwise, false);

        expect(Angle.fromDegrees(-45).isClockwise, false);
        expect(Angle.fromDegrees(-45).isCounterClockwise, true);

        expect(Angle.fromDegrees(0).isClockwise, true);
        expect(Angle.fromDegrees(0).isClockwise, true);
      });

      test('reports acute', () {
        expect(Angle.fromDegrees(0).isAcute, true);
        expect(Angle.fromDegrees(0).category, AngleCategory.acute);
        expect(Angle.fromDegrees(89).isAcute, true);
        expect(Angle.fromDegrees(89).category, AngleCategory.acute);

        expect(Angle.fromDegrees(-89).isAcute, true);
        expect(Angle.fromDegrees(-89).category, AngleCategory.acute);
      });

      test('reports obtuse', () {
        expect(Angle.fromDegrees(90).isObtuse, true);
        expect(Angle.fromDegrees(90).category, AngleCategory.obtuse);
        expect(Angle.fromDegrees(179).isObtuse, true);
        expect(Angle.fromDegrees(179).category, AngleCategory.obtuse);

        expect(Angle.fromDegrees(-90).isObtuse, true);
        expect(Angle.fromDegrees(-90).category, AngleCategory.obtuse);
        expect(Angle.fromDegrees(-179).isObtuse, true);
        expect(Angle.fromDegrees(-179).category, AngleCategory.obtuse);
      });

      test('reports reflexive', () {
        expect(Angle.fromDegrees(180).isReflexive, true);
        expect(Angle.fromDegrees(180).category, AngleCategory.reflex);
        expect(Angle.fromDegrees(359).isReflexive, true);
        expect(Angle.fromDegrees(359).category, AngleCategory.reflex);

        expect(Angle.fromDegrees(-180).isReflexive, true);
        expect(Angle.fromDegrees(-180).category, AngleCategory.reflex);
        expect(Angle.fromDegrees(-359).isReflexive, true);
        expect(Angle.fromDegrees(-359).category, AngleCategory.reflex);
      });

      test('equivalency', () {
        expect(Angle.fromDegrees(270).isEquivalentTo(Angle.fromDegrees(-90)),
            true);
        expect(Angle.fromDegrees(-90).isEquivalentTo(Angle.fromDegrees(270)),
            true);
      });
    });

    group('Operands', () {
      test('negative operator', () {
        expect(-Angle.fromDegrees(90), Angle.fromDegrees(-90));
        expect(-Angle.fromDegrees(-90), Angle.fromDegrees(90));
      });

      test('adds and subtracts angles', () {
        // Adding non-zero Angles
        expect(Angle.fromDegrees(120) + Angle.fromDegrees(30),
            Angle.fromDegrees(150));
        expect(Angle.fromDegrees(120) + Angle.fromDegrees(-30),
            Angle.fromDegrees(90));

        // Adding a zero Angle
        expect(Angle.fromDegrees(45) + Angle.zero, Angle.fromDegrees(45));

        // Subtracting non-zero Angles
        expect(Angle.fromDegrees(120) - Angle.fromDegrees(30),
            Angle.fromDegrees(90));
        expect(Angle.fromDegrees(120) - Angle.fromDegrees(-30),
            Angle.fromDegrees(150));

        // Subtracting a zero Angle
        expect(Angle.fromDegrees(45) - Angle.zero, Angle.fromDegrees(45));
      });

      test('multiplies an angle by a scalar', () {
        expect(Angle.fromDegrees(0) * 100, Angle.zero);
        expect(Angle.fromDegrees(45) * 2, Angle.fromDegrees(90));
        expect(Angle.fromDegrees(90) * 4, Angle.zero);
        expect(Angle.fromDegrees(90) * 0.5, Angle.fromDegrees(45));
        expect(Angle.fromDegrees(45) * -1, Angle.fromDegrees(-45));
        expect(Angle.fromDegrees(-45) * -1, Angle.fromDegrees(45));
      });

      test('divides an angle by a scalar', () {
        expect(Angle.fromDegrees(0) / 100, Angle.zero);
        expect(() => Angle.fromDegrees(90) / 0,
            throwsA(isA<DivisionByZeroException>()));
        expect(Angle.fromDegrees(90) / 2, Angle.fromDegrees(45));
        expect(Angle.fromDegrees(45) / 0.5, Angle.fromDegrees(90));
        expect(Angle.fromDegrees(45) / -1, Angle.fromDegrees(-45));
        expect(Angle.fromDegrees(-45) / -1, Angle.fromDegrees(45));
      });
    });

    group('alteration', () {
      test('inversion', () {
        expect(Angle.fromDegrees(45).invert(), Angle.fromDegrees(315));
        expect(Angle.fromDegrees(315).invert(), Angle.fromDegrees(45));
        expect(Angle.fromDegrees(-45).invert(), Angle.fromDegrees(-315));
        expect(Angle.fromDegrees(-315).invert(), Angle.fromDegrees(-45));
        expect(Angle.fromDegrees(45).invert().invert(), Angle.fromDegrees(45));
      });

      test('make clockwise and counterclockwise', () {
        expect(Angle.fromDegrees(45).makeClockwise(), Angle.fromDegrees(45));
        expect(Angle.fromDegrees(45).makeCounterClockwise(),
            Angle.fromDegrees(-45));
        expect(Angle.fromDegrees(-45).makeClockwise(), Angle.fromDegrees(45));
        expect(Angle.fromDegrees(-45).makeCounterClockwise(),
            Angle.fromDegrees(-45));
      });

      test('rotates an angle', () {
        expect(Angle.fromDegrees(45).rotate(Angle.fromDegrees(45)),
            Rotation.fromDegrees(90));
        expect(Angle.fromDegrees(180).rotate(Angle.fromDegrees(180)),
            Rotation.fromDegrees(360));
        expect(Angle.fromDegrees(270).rotate(Angle.fromDegrees(270)),
            Rotation.fromDegrees(540));
        expect(Angle.fromDegrees(-45).rotate(Angle.fromDegrees(-45)),
            Rotation.fromDegrees(-90));
        expect(Angle.fromDegrees(-180).rotate(Angle.fromDegrees(-180)),
            Rotation.fromDegrees(-360));
      });
    });
  });

  group('Rotation', () {
    group('Conversions', () {
      test('converts degrees to radians', () {
        expect(Rotation.fromDegrees(0).radians, 0);
        expect(Rotation.fromDegrees(90).radians, pi / 2);
        expect(Rotation.fromDegrees(180).radians, pi);
        expect(Rotation.fromDegrees(270).radians, 3 * pi / 2);
        expect(Rotation.fromDegrees(-90).radians, -pi / 2);
      });

      test('converts radians to degrees', () {
        expect(Rotation.fromRadians(0).degrees, 0);
        expect(Rotation.fromRadians(pi / 2).degrees, 90);
        expect(Rotation.fromRadians(pi).degrees, 180);
        expect(Rotation.fromRadians(3 * pi / 2).degrees, 270);
        expect(Rotation.fromRadians(-pi / 2).degrees, -90);
      });
    });

    group('Orientation', () {
      test('reports clockwise and counter-clockwise', () {
        expect(Rotation.fromDegrees(45).isClockwise, true);
        expect(Rotation.fromDegrees(45).isCounterClockwise, false);

        expect(Rotation.fromDegrees(-45).isClockwise, false);
        expect(Rotation.fromDegrees(-45).isCounterClockwise, true);

        expect(Rotation.fromDegrees(0).isClockwise, true);
        expect(Rotation.fromDegrees(0).isClockwise, true);
      });
    });

    group('Operands', () {
      test('inverts itself', () {
        expect(-Rotation.fromDegrees(90), Rotation.fromDegrees(-90));
        expect(-Rotation.fromDegrees(-90), Rotation.fromDegrees(90));
      });

      test('adds and subtracts rotations', () {
        // Adding non-zero Angles
        expect(Rotation.fromDegrees(120) + Rotation.fromDegrees(30),
            Rotation.fromDegrees(150));
        expect(Rotation.fromDegrees(120) + Rotation.fromDegrees(-30),
            Rotation.fromDegrees(90));

        // Adding a zero Angle
        expect(
            Rotation.fromDegrees(45) + Rotation.zero, Rotation.fromDegrees(45));

        // Subtracting non-zero Angles
        expect(Rotation.fromDegrees(120) - Rotation.fromDegrees(30),
            Rotation.fromDegrees(90));
        expect(Rotation.fromDegrees(120) - Rotation.fromDegrees(-30),
            Rotation.fromDegrees(150));

        // Subtracting a zero Angle
        expect(
            Rotation.fromDegrees(45) - Rotation.zero, Rotation.fromDegrees(45));
      });

      test('multiplies a rotation by a scalar', () {
        expect(Rotation.fromDegrees(0) * 100, Rotation.zero);
        expect(Rotation.fromDegrees(45) * 2, Rotation.fromDegrees(90));
        expect(Rotation.fromDegrees(360) * 4, Rotation.fromDegrees(1440));
        expect(Rotation.fromDegrees(90) * 0.5, Rotation.fromDegrees(45));
        expect(Rotation.fromDegrees(45) * -1, Rotation.fromDegrees(-45));
        expect(Rotation.fromDegrees(-45) * -1, Rotation.fromDegrees(45));
      });

      test('divides a rotation by a scalar', () {
        expect(Rotation.fromDegrees(0) / 100, Rotation.zero);
        expect(() => Rotation.fromDegrees(90) / 0,
            throwsA(isA<DivisionByZeroException>()));
        expect(Rotation.fromDegrees(90) / 2, Rotation.fromDegrees(45));
        expect(Rotation.fromDegrees(45) / 0.5, Rotation.fromDegrees(90));
        expect(Rotation.fromDegrees(45) / -1, Rotation.fromDegrees(-45));
        expect(Rotation.fromDegrees(-45) / -1, Rotation.fromDegrees(45));
      });
    });

    group('rotation to angle', () {
      test('reduces a rotation to an angle', () {
        expect(Rotation.fromDegrees(0).reduceToAngle(), Angle.fromDegrees(0));
        expect(
            Rotation.fromDegrees(180).reduceToAngle(), Angle.fromDegrees(180));
        expect(Rotation.fromDegrees(360).reduceToAngle(), Angle.fromDegrees(0));
        expect(
            Rotation.fromDegrees(540).reduceToAngle(), Angle.fromDegrees(180));
        expect(
            Rotation.fromDegrees(-360).reduceToAngle(), Angle.fromDegrees(0));
        expect(Rotation.fromDegrees(-540).reduceToAngle(),
            Angle.fromDegrees(-180));
      });
    });
  });
}
