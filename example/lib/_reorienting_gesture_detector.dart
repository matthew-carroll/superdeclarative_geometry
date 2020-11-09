import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A `GestureDetector` that reports all local coordinates in relation to a
/// custom origin, selected by the given `origin` selector.
///
/// A `ReorientedGestureDetector` could be used, for example, to easily work
/// with drag gestures about an origin at the center of a widget, which is
/// useful for dials, radial sliders, etc.
class ReorientedGestureDetector extends StatefulWidget {
  static const OriginSelector originAtCenter = _originAtCenter;
  static Offset _originAtCenter(Size plotSize) {
    return plotSize.center(Offset.zero);
  }

  const ReorientedGestureDetector({
    Key key,
    @required this.origin,
    this.pointMapper,
    this.child,
    this.onTapDown,
    this.onTapUp,
    this.onTap,
    this.onTapCancel,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onSecondaryTapCancel,
    this.onTertiaryTapDown,
    this.onTertiaryTapUp,
    this.onTertiaryTapCancel,
    this.onDoubleTapDown,
    this.onDoubleTap,
    this.onDoubleTapCancel,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressMoveUpdate,
    this.onLongPressUp,
    this.onLongPressEnd,
    this.onSecondaryLongPress,
    this.onSecondaryLongPressStart,
    this.onSecondaryLongPressMoveUpdate,
    this.onSecondaryLongPressUp,
    this.onSecondaryLongPressEnd,
    this.onVerticalDragDown,
    this.onVerticalDragStart,
    this.onVerticalDragUpdate,
    this.onVerticalDragEnd,
    this.onVerticalDragCancel,
    this.onHorizontalDragDown,
    this.onHorizontalDragStart,
    this.onHorizontalDragUpdate,
    this.onHorizontalDragEnd,
    this.onHorizontalDragCancel,
    this.onForcePressStart,
    this.onForcePressPeak,
    this.onForcePressUpdate,
    this.onForcePressEnd,
    this.onPanDown,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onPanCancel,
    this.onScaleStart,
    this.onScaleUpdate,
    this.onScaleEnd,
    this.behavior,
    this.excludeFromSemantics = false,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

  final OriginSelector origin;
  final PointMapper pointMapper;
  final Widget child;

  final GestureTapDownCallback onTapDown;
  final GestureTapUpCallback onTapUp;
  final GestureTapCallback onTap;
  final GestureTapCancelCallback onTapCancel;
  final GestureTapCallback onSecondaryTap;
  final GestureTapDownCallback onSecondaryTapDown;
  final GestureTapUpCallback onSecondaryTapUp;
  final GestureTapCancelCallback onSecondaryTapCancel;
  final GestureTapDownCallback onTertiaryTapDown;
  final GestureTapUpCallback onTertiaryTapUp;
  final GestureTapCancelCallback onTertiaryTapCancel;
  final GestureTapDownCallback onDoubleTapDown;
  final GestureTapCallback onDoubleTap;
  final GestureTapCancelCallback onDoubleTapCancel;
  final GestureLongPressCallback onLongPress;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressMoveUpdateCallback onLongPressMoveUpdate;
  final GestureLongPressUpCallback onLongPressUp;
  final GestureLongPressEndCallback onLongPressEnd;
  final GestureLongPressCallback onSecondaryLongPress;
  final GestureLongPressStartCallback onSecondaryLongPressStart;
  final GestureLongPressMoveUpdateCallback onSecondaryLongPressMoveUpdate;
  final GestureLongPressUpCallback onSecondaryLongPressUp;
  final GestureLongPressEndCallback onSecondaryLongPressEnd;
  final GestureDragDownCallback onVerticalDragDown;
  final GestureDragStartCallback onVerticalDragStart;
  final GestureDragUpdateCallback onVerticalDragUpdate;
  final GestureDragEndCallback onVerticalDragEnd;
  final GestureDragCancelCallback onVerticalDragCancel;
  final GestureDragDownCallback onHorizontalDragDown;
  final GestureDragStartCallback onHorizontalDragStart;
  final GestureDragUpdateCallback onHorizontalDragUpdate;
  final GestureDragEndCallback onHorizontalDragEnd;
  final GestureDragCancelCallback onHorizontalDragCancel;
  final GestureDragDownCallback onPanDown;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragCancelCallback onPanCancel;
  final GestureScaleStartCallback onScaleStart;
  final GestureScaleUpdateCallback onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;
  final GestureForcePressStartCallback onForcePressStart;
  final GestureForcePressPeakCallback onForcePressPeak;
  final GestureForcePressUpdateCallback onForcePressUpdate;
  final GestureForcePressEndCallback onForcePressEnd;
  final HitTestBehavior behavior;
  final bool excludeFromSemantics;
  final DragStartBehavior dragStartBehavior;

  @override
  _ReorientedGestureDetectorState createState() =>
      _ReorientedGestureDetectorState();
}

typedef OriginSelector = Offset Function(Size plotSize);

typedef PointMapper = Offset Function(Offset localOffset);

class _ReorientedGestureDetectorState extends State<ReorientedGestureDetector> {
  DragDownDetails _reorientDragDown(DragDownDetails details) {
    return DragDownDetails(
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  DragStartDetails _reorientDragStart(DragStartDetails details) {
    return DragStartDetails(
      sourceTimeStamp: details.sourceTimeStamp,
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  DragUpdateDetails _reorientDragUpdate(DragUpdateDetails details) {
    return DragUpdateDetails(
      sourceTimeStamp: details.sourceTimeStamp,
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  TapDownDetails _reorientTapDown(TapDownDetails details) {
    return TapDownDetails(
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  TapUpDetails _reorientTapUp(TapUpDetails details) {
    return TapUpDetails(
      kind: details.kind,
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  LongPressStartDetails _reorientLongPressStart(LongPressStartDetails details) {
    return LongPressStartDetails(
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
    );
  }

  LongPressMoveUpdateDetails _reorientLongPressUpdate(
      LongPressMoveUpdateDetails details) {
    return LongPressMoveUpdateDetails(
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
      offsetFromOrigin: details.offsetFromOrigin,
      localOffsetFromOrigin: _reorientPosition(details.localOffsetFromOrigin),
    );
  }

  LongPressEndDetails _reorientLongPressEnd(LongPressEndDetails details) {
    return LongPressEndDetails(
      globalPosition: details.globalPosition,
      localPosition: _reorientPosition(details.localPosition),
      velocity: details.velocity,
    );
  }

  ForcePressDetails _reorientForcePress(ForcePressDetails details) {
    return ForcePressDetails(
      globalPosition: details.globalPosition,
      localPosition: details.localPosition,
      pressure: details.pressure,
    );
  }

  /// Given a `localPosition` with respect to this widget's natural origin
  /// (upper left corner), computes a new local position in relation to a new
  /// origin, which is selected by `widget.origin`.
  Offset _reorientPosition(Offset localPosition) {
    final plotSize = (context.findRenderObject() as RenderBox).size;
    final origin = widget.origin(plotSize);
    final reorientedPosition = localPosition - origin;
    return widget.pointMapper != null
        ? widget.pointMapper(reorientedPosition)
        : reorientedPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Panning
      onPanDown: widget.onPanDown != null
          ? (details) {
              return _reorientDragDown(details);
            }
          : null,
      onPanStart: widget.onPanStart != null
          ? (details) {
              widget.onPanStart?.call(_reorientDragStart(details));
            }
          : null,
      onPanUpdate: widget.onPanUpdate != null
          ? (details) {
              widget.onPanUpdate?.call(_reorientDragUpdate(details));
            }
          : null,
      onPanEnd: widget.onPanEnd,
      onPanCancel: widget.onPanCancel,
      // Horizontal Drag
      onHorizontalDragDown: widget.onHorizontalDragDown != null
          ? (details) {
              return _reorientDragDown(details);
            }
          : null,
      onHorizontalDragStart: widget.onHorizontalDragStart != null
          ? (details) {
              widget.onHorizontalDragStart?.call(_reorientDragStart(details));
            }
          : null,
      onHorizontalDragUpdate: widget.onHorizontalDragUpdate != null
          ? (details) {
              widget.onHorizontalDragUpdate?.call(_reorientDragUpdate(details));
            }
          : null,
      onHorizontalDragEnd: widget.onHorizontalDragEnd,
      onHorizontalDragCancel: widget.onHorizontalDragCancel,
      // Vertical Drag
      onVerticalDragDown: widget.onVerticalDragDown != null
          ? (details) {
              return _reorientDragDown(details);
            }
          : null,
      onVerticalDragStart: widget.onVerticalDragStart != null
          ? (details) {
              widget.onVerticalDragStart?.call(_reorientDragStart(details));
            }
          : null,
      onVerticalDragUpdate: widget.onVerticalDragUpdate != null
          ? (details) {
              widget.onVerticalDragUpdate?.call(_reorientDragUpdate(details));
            }
          : null,
      onVerticalDragEnd: widget.onVerticalDragEnd,
      onVerticalDragCancel: widget.onVerticalDragCancel,
      // Taps
      onTap: widget.onTap,
      onTapDown: widget.onTapDown != null
          ? (details) {
              return _reorientTapDown(details);
            }
          : null,
      onTapUp: widget.onTapUp != null
          ? (details) {
              return _reorientTapUp(details);
            }
          : null,
      onTapCancel: widget.onTapCancel,
      onSecondaryTap: widget.onSecondaryTap,
      onSecondaryTapDown: widget.onSecondaryTapDown != null
          ? (details) {
              return _reorientTapDown(details);
            }
          : null,
      onSecondaryTapUp: widget.onSecondaryTapUp != null
          ? (details) {
              return _reorientTapUp(details);
            }
          : null,
      onSecondaryTapCancel: widget.onSecondaryTapCancel,
      onTertiaryTapDown: widget.onTertiaryTapDown != null
          ? (details) {
              return _reorientTapDown(details);
            }
          : null,
      onTertiaryTapUp: widget.onTertiaryTapUp != null
          ? (details) {
              return _reorientTapUp(details);
            }
          : null,
      onTertiaryTapCancel: widget.onTertiaryTapCancel,
      // Double Taps
      onDoubleTap: widget.onDoubleTap,
      onDoubleTapDown: widget.onDoubleTapDown != null
          ? (details) {
              return _reorientTapDown(details);
            }
          : null,
      onDoubleTapCancel: widget.onDoubleTapCancel,
      // Long Press
      onLongPress: widget.onLongPress,
      onLongPressStart: widget.onLongPressStart != null
          ? (details) {
              return _reorientLongPressStart(details);
            }
          : null,
      onLongPressMoveUpdate: widget.onLongPressMoveUpdate != null
          ? (details) {
              return _reorientLongPressUpdate(details);
            }
          : null,
      onLongPressEnd: widget.onLongPressEnd != null
          ? (details) {
              return _reorientLongPressEnd(details);
            }
          : null,
      onLongPressUp: widget.onLongPressUp,
      onSecondaryLongPress: widget.onSecondaryLongPress,
      onSecondaryLongPressStart: widget.onSecondaryLongPressStart != null
          ? (details) {
              return _reorientLongPressStart(details);
            }
          : null,
      onSecondaryLongPressMoveUpdate:
          widget.onSecondaryLongPressMoveUpdate != null
              ? (details) {
                  return _reorientLongPressUpdate(details);
                }
              : null,
      onSecondaryLongPressEnd: widget.onSecondaryLongPressEnd != null
          ? (details) {
              return _reorientLongPressEnd(details);
            }
          : null,
      onSecondaryLongPressUp: widget.onSecondaryLongPressUp,
      // Force Press
      onForcePressStart: widget.onForcePressStart != null
          ? (details) {
              return _reorientForcePress(details);
            }
          : null,
      onForcePressUpdate: widget.onForcePressUpdate != null
          ? (details) {
              return _reorientForcePress(details);
            }
          : null,
      onForcePressPeak: widget.onForcePressPeak != null
          ? (details) {
              return _reorientForcePress(details);
            }
          : null,
      onForcePressEnd: widget.onForcePressEnd != null
          ? (details) {
              return _reorientForcePress(details);
            }
          : null,
      // Scale
      onScaleStart: widget.onScaleStart != null
          ? (details) {
              return ScaleStartDetails(
                focalPoint: details.focalPoint,
                localFocalPoint: _reorientPosition(details.localFocalPoint),
              );
            }
          : null,
      onScaleUpdate: widget.onScaleUpdate != null
          ? (details) {
              return ScaleUpdateDetails(
                focalPoint: details.focalPoint,
                localFocalPoint: _reorientPosition(details.localFocalPoint),
                scale: details.scale,
                horizontalScale: details.horizontalScale,
                verticalScale: details.verticalScale,
                rotation: details.rotation,
              );
            }
          : null,
      onScaleEnd: widget.onScaleEnd,
      child: widget.child ?? SizedBox(),
    );
  }
}
