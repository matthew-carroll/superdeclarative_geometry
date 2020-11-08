# SuperDeclarative Geometry

First-class support for angles, polar coordinates, and related math.

---

If you get value from this package, please consider supporting SuperDeclarative!

<a href="https://donate.superdeclarative.com" target="_blank" alt="Donate"><img src="https://img.shields.io/badge/Donate-%24%24-green"></a>

---

## Get Started

[![pub](https://img.shields.io/pub/v/superdeclarative_geometry.svg?style=flat)](https://pub.dev/packages/superdeclarative_geometry)

```yaml
dependencies:
  superdeclarative_geometry: ^[VERSION]
```

---

## Quick Reference

### Angles

Create an `Angle` from degrees or radians:

```dart
final degreesToRadians = Angle.fromDegrees(45);
final radiansToDegrees = Angle.fromRadians(pi / 4);
```

Retrieve `Angle` values as degrees or radians:

```dart
myAngle.degrees;
myAngle.radians;
```

Determine an `Angle`'s direction and force it to be positive or negative:

```dart
myAngle.isPositive;
myAngle.isNegative;

myAngle.makePositive(); // Ex: -270° ->  90°
myAngle.makeNegative(); // Ex:  270° -> -90°
```

Determine the category of an `Angle`:

```dart
myAngle.isAcute;
myAngle.isObtuse;
myAngle.isReflexive;
myAngle.category;
```

Determine if two `Angle`s are equivalent, regardless of direction:

```dart
Angle.fromDegrees(90).isEquivalentTo(Angle.fromDegrees(-270));
```

Invert, add, subtract, multiply, and divide `Angle`s:

```dart
-Angle.fromDegrees(30);

Angle.fromDegrees(30) + Angle.fromDegrees(15);

Angle.fromDegrees(30) - Angle.fromDegrees(15);

Angles.fromDegrees(45) * 2;

Angles.fromDegrees(90) / 2;
```

Rotate an `Angle`:

```dart
final Rotation rotation = myAngle.rotate(Angle.fromDegrees(150));
```

---

### Rotations

`Angle`s are confined to values in (-360°, 360°). For values beyond this range, the concept of a `Rotation` is provided.

A `Rotation` is almost identical to an `Angle` except that a `Rotation` can be arbitrarily large in the positive or negative direction. This allows for the accumulation of turns over time.

Create a `Rotation`:

```dart
final rotation = Rotation.fromDegrees(540);
```

Add, subtract, multiply, and divide `Rotation`s just like `Angle`s.

Reduce a `Rotation` to an `Angle`:

```dart
Rotation.fromDegrees(540).reduceToAngle();
```

---

### Polar Coordinates

Define polar coordinates by a radius and an angle, or by a Cartesian point:

```dart
PolarCoord(100, PolarCoord.fromDegrees(45));

PolarCoord.fromCartesian(0, 100);
```

Add, subtract, multiply, and divide `PolarCoord`s:

```dart
PolarCoord(100, Angle.fromDegrees(45)) + PolarCoord(200, Angle.fromDegrees(135));

PolarCoord(100, Angle.fromDegrees(45)) - PolarCoord(200, Angle.fromDegrees(135));

PolarCoord(100, Angle.fromDegrees(15)) * 2;

PolarCoord(200, Angle.fromDegrees(30)) / 2;
```

Map a `PolarCoord` to a Cartesian `Point`:

```dart
// Map to Cartesian coordinates.
final Point point = PolarCoord(100, Angle.fromDegrees(45)).toCartesian();
```

---

### Cartesian Orientations

Different use-cases treat angles in different ways.

Mathematics treats the positive x-axis as a 0° angle and treats positive angles as running counter-clockwise.

Flutter app screens treat the positive x-axis as a 0° angle, but then treats positive angles as running clockwise.

Ship navigation treats the positive y-axis as a 0° angle and then treats positive angles as running clockwise.

Each of these situations apply a different orientation when mapping an angle, or a polar coordinate, to a location in Cartesian space. This concept of orientation is supported by `superdeclarative_geometry` by way of `CartesianOrientation`s.

Both `Angle` and `PolarCoord` support `CartesianOrientation` mappings.

```dart
final polarCoord = PolarCoord(100, Angle.fromDegrees(30));

// Treat angles like a Flutter screen.
// This point is 30° clockwise from the x-axis.
final screenPoint = polarCoord.toCartesian(); // defaults to "screen" orientation

// Treat angles like mathematics.
// This point is 30° counter-clockwise from the x-axis.
final mathPoint = polarCoord.toCartesian(orientation: CartesianOrientation.math);

// Treat angles like navigators.
// This point is 30° clockwise from the y-axis.
final navigationPoint = polarCoord.toCartesian(orientation: CartesianOrientation.navigation);
```

You can define a custom `CartesianOrientation` by implementing the interface. Then, you can pass an instance of your custom orientation into `PolarCoord`'s `toCartesian()` method.