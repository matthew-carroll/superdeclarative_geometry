import 'dart:math';

import 'package:superdeclarative_geometry/src/common.dart';
import 'package:test/test.dart';

Matcher isEquivalentTo(Equivalency other) {
  return IsEquivalentTo(other);
}

class IsEquivalentTo extends Matcher {
  const IsEquivalentTo(this.expectedEquivalency);

  final Equivalency expectedEquivalency;

  @override
  Description describe(Description description) {
    return description
        .add('an equivalent of ')
        .addDescriptionOf(expectedEquivalency);
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is Equivalency) {
      return item.isEquivalentTo(expectedEquivalency);
    } else {
      return false;
    }
  }
}

Matcher isApproximately(Approximately other) {
  return IsApproximately(other);
}

class IsApproximately extends Matcher {
  const IsApproximately(this.expectedApproximateValue);

  final Approximately expectedApproximateValue;

  @override
  Description describe(Description description) {
    return description
        .add('an approximate value of ')
        .addDescriptionOf(expectedApproximateValue);
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is Approximately) {
      return item.isApproximately(expectedApproximateValue);
    } else {
      return false;
    }
  }
}

Matcher isApproximatelyPoint(Point other,
    {num percentVariance = 0.0000000000001}) {
  return IsApproximatelyPoint(other, percentVariance);
}

class IsApproximatelyPoint extends Matcher {
  const IsApproximatelyPoint(this.expectedPoint, this.delta);

  final Point expectedPoint;
  final num delta;

  @override
  Description describe(Description description) {
    return description
        .add('an approximate (+/- ${delta}) value of ')
        .addDescriptionOf(expectedPoint);
  }

  @override
  Description describeMismatch(
      item, Description mismatchDescription, Map matchState, bool verbose) {
    return mismatchDescription
        .add('X variance: ${item.x - expectedPoint.x}')
        .add(', Y variance: ${item.y - expectedPoint.y}');
  }

  @override
  bool matches(item, Map<dynamic, dynamic> matchState) {
    if (item is Point) {
      return _isApproximatelyEqual(item.x, expectedPoint.x) &&
          _isApproximatelyEqual(item.y, expectedPoint.y);
    } else {
      return false;
    }
  }

  bool _isApproximatelyEqual(num actual, num expected) {
    return (expected - actual).abs() <= delta;
  }
}
