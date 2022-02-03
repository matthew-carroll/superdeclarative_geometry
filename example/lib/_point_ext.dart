import 'dart:math';

import 'dart:ui';

extension FlutterPoint on Point {
  Offset toOffset() {
    return Offset(this.x.toDouble(), this.y.toDouble());
  }
}

extension PointForOffset on Offset {
  Point toPoint() {
    return Point(this.dx, this.dy);
  }
}
