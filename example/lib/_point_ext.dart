import 'dart:math';

import 'dart:ui';

extension FlutterPoint on Point {
  Offset toOffset() {
    return Offset(this.x, this.y);
  }
}

extension PointForOffset on Offset {
  Point toPoint() {
    return Point(this.dx, this.dy);
  }
}
