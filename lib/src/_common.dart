abstract class Equivalency<T> {
  bool isEquivalentTo(T other);
}

abstract class Approximately<T> {
  bool isApproximately(T other, {num percentVariance = 0.01});
}

class DivisionByZeroException implements Exception {
  const DivisionByZeroException();

  @override
  String toString() => "DivisionByZeroException";
}
