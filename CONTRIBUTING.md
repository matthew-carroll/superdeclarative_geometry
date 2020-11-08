# Contributing to superdeclarative_geometry

The following describes expectations for filing issues and contributing code.

## Filing Issues

An issue might constitute a bug report or a feature request.

### Bug Reports

A bug report **must** include a set of minimal reproduction steps. This means the fewest possible steps required to reproduce the bug that you're reporting. If you do not provide reproduction steps, your issue will be closed. If you provide excessive steps, your issue may never be addressed.

When providing reproduction steps, be sure to include the output from `flutter --version` (or your Dart version), along with the current version of `superdeclarative_geometry` that you're using. Your bug might not exist in different combinations of the two systems.

### Feature Requests

A feature request **must** include the specific situation that you're attempting to solve. You do not necessarily need to propose a solution, but you must adequately explain your problem.

## Contributing Code

The goal of this package is to provide **thorough geometric** functionality optimized for **user interface** and **painting** purposes.

Thorough functionality means that if a concept is added to this package, the concept should include all typical use-cases. This package should not accumulate partial solutions.

User interface and painting purposes means that this package is not aimed at robust mathematical calculations. Minor loss of precision is likely to be endemic because this package uses Dart integers and doubles, rather than arbitrary precision constructs, such as BigInt.

### Pure Dart

This package is to remain a pure Dart package. This does not prevent the introduction of a Flutter package on top of this package, but this package will never accept Flutter-specific capabilities. This package will never add a source code dependency on Flutter.

### Driven by use-cases

Every addition to this package should address an explicit use-case that is deemed reasonably valuable. Contributions will not be accepted for ambiguous, hypothetical use-cases.

### Thoroughly tested

Every addition or alteration to this package should include effective tests that are relevant to the change.

Effective tests are the minimal volume of test cases and code that provides sufficient confidence in the correctness of the changes.