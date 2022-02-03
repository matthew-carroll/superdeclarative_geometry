import 'dart:math';

import 'package:flutter/material.dart';
import 'package:superdeclarative_geometry/superdeclarative_geometry.dart';

import '_point_ext.dart';
import '_reorienting_gesture_detector.dart';

/// Displays a draggable `PolarCoord` on a graph, allowing selection of "math",
/// "screen", or "navigation" orientation, and displays the current `PolarCoord`
/// value.
class MathGraphPage extends StatefulWidget {
  @override
  _MathGraphPageState createState() => _MathGraphPageState();
}

class _MathGraphPageState extends State<MathGraphPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  CartesianOrientation _graphOrientation = CartesianOrientation.math;
  PolarCoord _polarCoord = PolarCoord(150, Angle.deg60);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildOrientationTabs(),
        Expanded(
          child: DraggablePolarCoordGraph(
              graphOrientation: _graphOrientation,
              polarCoord: _polarCoord,
              onPolarCoordChange: (PolarCoord newCoord) {
                setState(() {
                  _polarCoord = newCoord;
                });
              }),
        ),
        _buildCoordinateInfo(),
      ],
    );
  }

  Widget _buildOrientationTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: Colors.black,
        tabs: [
          Tab(
            child: Text('Math'),
          ),
          Tab(
            child: Text('Screen'),
          ),
          Tab(
            child: Text('Navigation'),
          ),
        ],
        onTap: (selectedIndex) {
          setState(
            () {
              switch (selectedIndex) {
                case 0:
                  _graphOrientation = CartesianOrientation.math;
                  break;
                case 1:
                  _graphOrientation = CartesianOrientation.screen;
                  break;
                case 2:
                  _graphOrientation = CartesianOrientation.navigation;
                  break;
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildCoordinateInfo() {
    String coordinateSpaceName = 'Unknown';
    if (_graphOrientation == CartesianOrientation.math) {
      coordinateSpaceName = 'Mathematics';
    } else if (_graphOrientation == CartesianOrientation.screen) {
      coordinateSpaceName = 'Device Screen';
    } else if (_graphOrientation == CartesianOrientation.navigation) {
      coordinateSpaceName = 'Navigation';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coordinate Space: $coordinateSpaceName',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Polar Coordinate: (${_polarCoord.radius.round()}, ${_polarCoord.angle.makePositive().degrees.round()}°)',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays a draggable `PolarCoord` on graph paper, drawing the angle between
/// the zero-axis and the `PolarCoord`, as well as the complementary angle.
class DraggablePolarCoordGraph extends StatefulWidget {
  const DraggablePolarCoordGraph({
    Key? key,
    required this.graphOrientation,
    this.polarCoord = const PolarCoord(100, Angle.zero),
    this.onPolarCoordChange,
  }) : super(key: key);

  final CartesianOrientation graphOrientation;
  final PolarCoord polarCoord;
  final void Function(PolarCoord)? onPolarCoordChange;

  @override
  _DraggablePolarCoordGraphState createState() => _DraggablePolarCoordGraphState();
}

class _DraggablePolarCoordGraphState extends State<DraggablePolarCoordGraph> {
  final double _touchDotRadius = 25;

  Offset? _startDragTouchVector;
  PolarCoord? _startDragPolarCoord;
  Offset? _currentDragTouchVector;

  void _onDragStart(DragStartDetails details) {
    _startDragTouchVector = details.localPosition;
    _startDragPolarCoord = widget.polarCoord;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    _currentDragTouchVector = details.localPosition;
    final dragDeltaOffset = _currentDragTouchVector! - _startDragTouchVector!;
    final dragDeltaPoint = Point(dragDeltaOffset.dx, dragDeltaOffset.dy);

    setState(() {
      widget.onPolarCoordChange?.call(
        _startDragPolarCoord!.moveInCartesianSpace(
          dragDeltaPoint,
          orientation: widget.graphOrientation,
        ),
      );
    });
  }

  Offset _mapDragPointToCartesianOrientation(Offset localOffset) {
    return localOffset
        .toPoint()
        // transform the point from screen space to the desired CartesianOrientation.
        .fromScreenTo(widget.graphOrientation)
        .toOffset();
  }

  Offset _computeDotPosition(Size widgetSize) {
    final center = widgetSize.center(Offset.zero);
    return widget.polarCoord
        .toCartesian(orientation: widget.graphOrientation)
        .toScreenPoint(fromOrientation: widget.graphOrientation)
        .toOffset()
        .translate(-_touchDotRadius, -_touchDotRadius)
        .translate(center.dx, center.dy);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final dotPosition = _computeDotPosition(constraints.biggest);
      return Stack(
        children: [
          _buildGraph(),
          Positioned(
            left: dotPosition.dx,
            top: dotPosition.dy,
            child: _buildDragTouchTarget(),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: _buildOrientationDirectionInfo(),
          ),
        ],
      );
    });
  }

  Widget _buildGraph() {
    return CustomPaint(
      painter: _GraphPainter(
        graphOrientation: widget.graphOrientation,
        polarCoord: widget.polarCoord,
        backgroundColor: const Color(0xFF44AAFF),
        primaryLineColor: const Color(0xFFAACCFF),
        secondaryLineColor: const Color(0xFF66BBFF),
        primaryAngleColor: const Color(0xFFCCEEFF),
        complementaryAngleColor: const Color(0xFFCCEEFF),
        vectorColor: Colors.white,
      ),
      size: Size.infinite,
    );
  }

  Widget _buildDragTouchTarget() {
    return ReorientedGestureDetector(
      origin: ReorientedGestureDetector.originAtCenter,
      pointMapper: _mapDragPointToCartesianOrientation,
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      child: Container(
        width: 2 * _touchDotRadius,
        height: 2 * _touchDotRadius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }

  Widget _buildOrientationDirectionInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.graphOrientation == CartesianOrientation.math ? 'CCW' : 'CW',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        SizedBox(width: 8),
        Transform(
          transform: widget.graphOrientation == CartesianOrientation.math ? Matrix4.rotationY(pi) : Matrix4.identity(),
          alignment: Alignment.center,
          child: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _GraphPainter extends CustomPainter {
  _GraphPainter({
    CartesianOrientation graphOrientation = CartesianOrientation.math,
    required PolarCoord polarCoord,
    Color backgroundColor = Colors.white,
    Color primaryLineColor = const Color(0xFFAAAAAA),
    Color secondaryLineColor = const Color(0xFFDDDDDD),
    Color vectorColor = Colors.black,
    Color primaryAngleColor = const Color(0xFF44AAFF),
    Color complementaryAngleColor = const Color(0xFF44AAFF),
  })  : _graphOrientation = graphOrientation,
        _polarCoord = polarCoord,
        _bkPaint = Paint()..color = backgroundColor,
        _primaryLinePaint = Paint()
          ..color = primaryLineColor
          ..strokeWidth = 1,
        _secondaryLinePaint = Paint()
          ..color = secondaryLineColor
          ..strokeWidth = 1,
        _vectorPaint = Paint()
          ..color = vectorColor
          ..strokeWidth = 3,
        _primaryAnglePaint = Paint()
          ..color = primaryAngleColor
          ..strokeWidth = 2,
        _complementaryAnglePaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = complementaryAngleColor
          ..strokeWidth = 2;

  final CartesianOrientation _graphOrientation;
  final PolarCoord _polarCoord;

  final double _lineSpacing = 25;

  final Paint _bkPaint;
  final Paint _primaryLinePaint;
  final Paint _secondaryLinePaint;

  final Paint _vectorPaint;
  final Paint _primaryAnglePaint;
  final Paint _complementaryAnglePaint;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);

    _paintGraph(canvas, size);

    _paintPolarCoord(canvas, size, _polarCoord);
  }

  void _paintBackground(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _bkPaint);
  }

  void _paintGraph(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, size.height),
      _primaryLinePaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(size.width, center.dy),
      _primaryLinePaint,
    );

    final verticalLineCount = (size.width / 2) / _lineSpacing;
    for (int i = 1; i < verticalLineCount; ++i) {
      canvas.drawLine(
        Offset(center.dx + (i * _lineSpacing), 0),
        Offset(center.dx + (i * _lineSpacing), size.height),
        _secondaryLinePaint,
      );
      canvas.drawLine(
        Offset(center.dx + (-i * _lineSpacing), 0),
        Offset(center.dx + (-i * _lineSpacing), size.height),
        _secondaryLinePaint,
      );
    }

    final horizontalLineCount = (size.height / 2) / _lineSpacing;
    for (int i = 1; i < horizontalLineCount; ++i) {
      canvas.drawLine(
        Offset(0, center.dy + (i * _lineSpacing)),
        Offset(size.width, center.dy + (i * _lineSpacing)),
        _secondaryLinePaint,
      );
      canvas.drawLine(
        Offset(0, center.dy + (-i * _lineSpacing)),
        Offset(size.width, center.dy + (-i * _lineSpacing)),
        _secondaryLinePaint,
      );
    }

    // Draw the zero axis for the given orientation.
    if (_graphOrientation == CartesianOrientation.math || _graphOrientation == CartesianOrientation.screen) {
      canvas.drawLine(
        Offset(center.dx, center.dy),
        Offset(size.width, center.dy),
        _vectorPaint,
      );
    } else if (_graphOrientation == CartesianOrientation.navigation) {
      canvas.drawLine(
        Offset(center.dx, center.dy),
        Offset(center.dx, 0),
        _vectorPaint,
      );
    }
  }

  void _paintPolarCoord(Canvas canvas, Size size, PolarCoord polarCoord) {
    final center = size.center(Offset.zero);

    // Radius of the angle arcs.
    final primaryAngleSegmentRadius = _polarCoord.radius * 0.3;
    final complementaryAngleSegmentRadius = _polarCoord.radius * 0.35;

    // Convert the polarCoord to an Offset that can be painted on the screen.
    final Offset vector = polarCoord
        // (x, y) of the polar coord as seen in the graph's coord system
        .toCartesian(orientation: _graphOrientation)
        // (x, y) of the polar coord as seen in the screen's coord system
        .toScreenPoint(fromOrientation: _graphOrientation)
        // convert to an Offset so that Flutter can use this point
        .toOffset()
        // use center point as origin, instead of upper left
        .translate(center.dx, center.dy);

    // We want the graph to always paint our angle in the positive direction
    // all the way around, so make it positive.
    final primaryAngle = polarCoord.angle.makePositive();

    // Convert the primary and secondary angle values from their
    // respective CartesianOrientation to angle values that make
    // sense for the screen.
    final Angle primaryAngleStart = _graphOrientation.toScreenAngle(Angle.zero);
    final Angle primaryAngleSweep = _graphOrientation.toScreenAngle(primaryAngle) - primaryAngleStart;
    final Angle complementaryAngleStart = primaryAngleSweep + primaryAngleStart;
    final Angle complementaryAngleSweep = primaryAngleSweep.complement;

    // Paint a filled arc from the zero-axis to the polarCoord.
    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        width: 2 * primaryAngleSegmentRadius,
        height: 2 * primaryAngleSegmentRadius,
      ),
      primaryAngleStart.radians.toDouble(),
      primaryAngleSweep.radians.toDouble(),
      true,
      _primaryAnglePaint,
    );

    // Paint a curve (no fill) from the polarCoord all the way back around
    // to the zero-axis.
    canvas.drawArc(
      Rect.fromCenter(
        center: center,
        width: 2 * complementaryAngleSegmentRadius,
        height: 2 * complementaryAngleSegmentRadius,
      ),
      complementaryAngleStart.radians.toDouble(),
      complementaryAngleSweep.radians.toDouble(),
      false,
      _complementaryAnglePaint,
    );

    // Paint a ray from the origin of the graph to the polarCoord.
    canvas.drawLine(
      center,
      vector,
      _vectorPaint,
    );
    canvas.drawCircle(center, 5, _vectorPaint);
    canvas.drawCircle(vector, 10, _vectorPaint);
  }

  @override
  bool shouldRepaint(_GraphPainter oldDelegate) {
    return _graphOrientation != oldDelegate._graphOrientation ||
        _polarCoord != oldDelegate._polarCoord ||
        _lineSpacing != oldDelegate._lineSpacing ||
        _bkPaint.color != oldDelegate._bkPaint.color ||
        _primaryLinePaint.color != oldDelegate._primaryLinePaint.color ||
        _secondaryLinePaint.color != oldDelegate._secondaryLinePaint.color ||
        _vectorPaint.color != oldDelegate._vectorPaint.color ||
        _primaryAnglePaint.color != oldDelegate._primaryAnglePaint.color ||
        _complementaryAnglePaint.color != oldDelegate._complementaryAnglePaint.color;
  }
}
