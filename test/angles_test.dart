import 'dart:math';

import 'package:dart_test_matchers/dart_test_matchers.dart';
import 'package:superdeclarative_geometry/src/_angles.dart';
import 'package:superdeclarative_geometry/src/_common.dart';
import 'package:test/test.dart';

void main() {
  group('Angle', () {
    group('Useful Angle Constants', () {
      test('lockdown Angle constants', () {
        expect(
          Angle.zero,
          Angle.fromDegrees(0),
        );
        expect(
          Angle.deg30,
          Angle.fromDegrees(30),
        );
        expect(
          Angle.deg45,
          Angle.fromDegrees(45),
        );
        expect(
          Angle.deg60,
          Angle.fromDegrees(60),
        );
        expect(
          Angle.deg90,
          Angle.fromDegrees(90),
        );
        expect(
          Angle.deg180,
          Angle.fromDegrees(180),
        );
      });
    });

    group('Linear Interpolation', () {
      test('lerp spot checks', () {
        expect(
          Angle.lerp(Angle.fromDegrees(0), Angle.fromDegrees(180), 0.5),
          Angle.fromDegrees(90),
        );
        expect(
          Angle.lerp(Angle.fromDegrees(45), Angle.fromDegrees(135), 0.5),
          Angle.fromDegrees(90),
        );
        expect(
          Angle.lerp(Angle.fromDegrees(0), Angle.fromDegrees(360), 0.5),
          Angle
              .zero, // This is because 360 degrees cannot be represented by an Angle.
        );
        expect(
          Angle.lerp(Angle.fromDegrees(0), Angle.fromDegrees(-180), 0.5),
          Angle.fromDegrees(-90),
        );
        expect(
          Angle.lerp(Angle.fromDegrees(-45), Angle.fromDegrees(-135), 0.5),
          Angle.fromDegrees(-90),
        );
        expect(
          Angle.lerp(Angle.fromDegrees(0), Angle.fromDegrees(-360), 0.5),
          Angle
              .zero, // This is because 360 degrees cannot be represented by an Angle.
        );
      });
    });

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

      test('limits percent values to [-1.0, 1.0]', () {
        expect(Angle.fromPercent(1.0).percent, 0.0);
        expect(Angle.fromPercent(1.1).percent,
            moreOrLessEquals(0.1, epsilon: 1e-16));
        expect(Angle.fromPercent(1.5).percent, 0.5);
        expect(Angle.fromPercent(-1.0).percent, 0.0);
        expect(Angle.fromPercent(-1.1).percent,
            moreOrLessEquals(-0.1, epsilon: 1e-16));
        expect(Angle.fromPercent(-1.5).percent, -0.5);
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

      test('converts degrees to percent', () {
        expect(Angle.fromDegrees(0).percent, 0);
        expect(Angle.fromDegrees(90).percent, 0.25);
        expect(Angle.fromDegrees(180).percent, 0.5);
        expect(Angle.fromDegrees(270).percent, 0.75);
        expect(Angle.fromDegrees(-90).percent, -0.25);
      });

      test('converts radians to degrees', () {
        expect(Angle.fromRadians(0).degrees, 0);
        expect(Angle.fromRadians(pi / 2).degrees, 90);
        expect(Angle.fromRadians(pi).degrees, 180);
        expect(Angle.fromRadians(3 * pi / 2).degrees, 270);
        expect(Angle.fromRadians(-pi / 2).degrees, -90);
      });

      test('converts radians to percent', () {
        expect(Angle.fromRadians(0).percent, 0);
        expect(Angle.fromRadians(pi / 2).percent, 0.25);
        expect(Angle.fromRadians(pi).percent, 0.5);
        expect(Angle.fromRadians(3 * pi / 2).percent, 0.75);
        expect(Angle.fromRadians(-pi / 2).percent, -0.25);
      });

      test('converts percent to degrees', () {
        expect(Angle.fromPercent(0).degrees, 0);
        expect(Angle.fromPercent(0.25).degrees, 90);
        expect(Angle.fromPercent(0.5).degrees, 180);
        expect(Angle.fromPercent(0.75).degrees, 270);
        expect(Angle.fromPercent(-0.25).degrees, -90);
      });

      test('converts percent to radians', () {
        expect(Angle.fromPercent(0).radians, 0);
        expect(Angle.fromPercent(0.25).radians, pi / 2);
        expect(Angle.fromPercent(0.5).radians, pi);
        expect(Angle.fromPercent(0.75).radians, 3 * pi / 2);
        expect(Angle.fromPercent(-0.25).radians, -(pi / 2));
      });
    });

    group('Inspection', () {
      test('reports positive and negative', () {
        expect(Angle.fromDegrees(0).isPositive, true);
        expect(Angle.fromDegrees(270).isPositive, true);
        expect(Angle.fromDegrees(-270).isPositive, false);

        expect(Angle.fromDegrees(0).isNegative, false);
        expect(Angle.fromDegrees(-270).isNegative, true);
        expect(Angle.fromDegrees(270).isNegative, false);
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
      test('makes positive and negative', () {
        expect(Angle.fromDegrees(270).makePositive(), Angle.fromDegrees(270));
        expect(Angle.fromDegrees(-270).makePositive(), Angle.fromDegrees(90));

        expect(Angle.fromDegrees(270).makeNegative(), Angle.fromDegrees(-90));
        expect(Angle.fromDegrees(-270).makeNegative(), Angle.fromDegrees(-270));
      });

      test('inversion', () {
        expect(Angle.fromDegrees(45).complement, Angle.fromDegrees(315));
        expect(Angle.fromDegrees(315).complement, Angle.fromDegrees(45));
        expect(Angle.fromDegrees(-45).complement, Angle.fromDegrees(-315));
        expect(Angle.fromDegrees(-315).complement, Angle.fromDegrees(-45));
        expect(
            Angle.fromDegrees(45).complement.complement, Angle.fromDegrees(45));
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
