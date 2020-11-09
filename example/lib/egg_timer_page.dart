import 'package:example/_reorienting_gesture_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:superdeclarative_geometry/superdeclarative_geometry.dart';

import '_point_ext.dart';

class EggTimerPage extends StatefulWidget {
  @override
  _EggTimerPageState createState() => _EggTimerPageState();
}

class _EggTimerPageState extends State<EggTimerPage>
    with TickerProviderStateMixin {
  EggTimer _eggTimer;

  @override
  void initState() {
    super.initState();
    _eggTimer = EggTimer(tickerProvider: this)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _eggTimer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        fontFamily: GoogleFonts.bebasNeue().fontFamily,
        textTheme: TextTheme(
          bodyText2: TextStyle(
            fontSize: 22,
            letterSpacing: 2,
          ),
          button: TextStyle(
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
      ),
      child: Scaffold(
        body: Column(
          children: [
            _buildCountdown(),
            _buildDialRegion(),
            _buildResetAndRestartControls(),
            _buildStartAndPauseControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdown() {
    String timeDisplay = '';
    if (_eggTimer.state == _EggTimerState.ready) {
      timeDisplay = _eggTimer.minutes.toString().padLeft(2, '0');
    } else {
      final minutes = _eggTimer.minutes.toString().padLeft(2, '0');
      final seconds = _eggTimer.seconds.toString().padLeft(2, '0');
      timeDisplay = '$minutes:$seconds';
    }

    return Text(
      timeDisplay,
      style: TextStyle(
        fontSize: 120,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildDialRegion() {
    return Expanded(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: EggTimerDial(
            eggTimer: _eggTimer,
          ),
        ),
      ),
    );
  }

  Widget _buildResetAndRestartControls() {
    return AnimatedOpacity(
      opacity: _eggTimer.state == _EggTimerState.paused ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        height: 80,
        child: Row(
          children: [
            Spacer(),
            _buildIconTextButton(
              icon: Icons.refresh,
              title: 'RESTART',
              onPressed: _eggTimer.restart,
            ),
            Spacer(flex: 3),
            _buildIconTextButton(
              icon: Icons.arrow_back,
              title: 'RESET',
              onPressed: _eggTimer.reset,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTextButton({
    @required IconData icon,
    @required String title,
    @required VoidCallback onPressed,
  }) {
    return FlatButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 10),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildStartAndPauseControls() {
    if (_eggTimer.state == _EggTimerState.ready) {
      return SizedBox();
    }

    IconData icon;
    String title;
    VoidCallback onPressed;
    if (_eggTimer.state == _EggTimerState.running) {
      icon = Icons.pause;
      title = 'PAUSE';
      onPressed = _eggTimer.pause;
    } else if (_eggTimer.state == _EggTimerState.paused) {
      icon = Icons.play_arrow;
      title = 'RESUME';
      onPressed = _eggTimer.resume;
    }

    return RaisedButton(
      color: Colors.white,
      elevation: 0,
      onPressed: onPressed,
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon),
              SizedBox(width: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

class EggTimerDial extends StatefulWidget {
  const EggTimerDial({
    Key key,
    @required this.eggTimer,
    this.maxTime = const Duration(minutes: 15),
  }) : super(key: key);

  final EggTimer eggTimer;
  final Duration maxTime;

  @override
  _EggTimerDialState createState() => _EggTimerDialState();
}

class _EggTimerDialState extends State<EggTimerDial>
    with SingleTickerProviderStateMixin {
  Angle _angle = Angle.zero;

  _EggTimerState _prevTimerState;

  bool _isDragging = false;
  Angle _angleWhenDragStarted;
  Offset _dragStart;

  Angle _angleBeforeReset;
  AnimationController _resetAnimationController;

  @override
  void initState() {
    super.initState();

    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        setState(() {
          _angle = Angle.lerp(
              _angleBeforeReset, Angle.zero, _resetAnimationController.value);
        });
      });

    _prevTimerState = widget.eggTimer.state;
    widget.eggTimer.addListener(_onEggTimerChange);
  }

  @override
  void dispose() {
    widget.eggTimer.removeListener(_onEggTimerChange);

    _resetAnimationController.dispose();

    super.dispose();
  }

  void _onEggTimerChange() {
    if (_prevTimerState != _EggTimerState.ready &&
        widget.eggTimer.state == _EggTimerState.ready) {
      // The egg timer was reset. Animate back to zero.
      _angleBeforeReset = _angle;
      _resetAnimationController.forward(from: 0.0);
    }

    _prevTimerState = widget.eggTimer.state;

    if (!_isDragging) {
      setState(() {
        _angle = Angle.fromPercent(
            widget.eggTimer.time.inSeconds / widget.maxTime.inSeconds);
      });
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (widget.eggTimer.state != _EggTimerState.ready) {
      return;
    }

    _isDragging = true;
    _dragStart = details.localPosition;
    _angleWhenDragStarted = _angle;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.eggTimer.state != _EggTimerState.ready) {
      return;
    }

    // Calculate start drag PolarCoord.
    final dragStartPolar = CartesianPolarCoords.fromPoint(
      _dragStart.toPoint(),
      CartesianOrientation.navigation,
    );

    // Calculate current drag PolarCoord.
    final currentDragPolar = CartesianPolarCoords.fromPoint(
      details.localPosition.toPoint(),
      CartesianOrientation.navigation,
    );

    // Calculate the angle between the two PolarCoords.
    final angle =
        (currentDragPolar.angleBetween(dragStartPolar) + _angleWhenDragStarted)
            .makePositive();

    setState(() {
      _angle = angle;
      _setTimerToAngle();
    });
  }

  void _onDragEnd(DragEndDetails details) {
    _isDragging = false;
    widget.eggTimer.start();
  }

  void _onDragCancel() {
    _isDragging = false;
    widget.eggTimer.start();
  }

  void _setTimerToAngle() {
    final startTimeExact = widget.maxTime * (_angle.degrees / 360);
    final startTime =
        Duration(minutes: (startTimeExact.inSeconds / 60).round());

    widget.eggTimer.setTimer(startTime);
  }

  Offset _mapDragPointToCartesianOrientation(Offset localOffset) {
    const eggTimerOrientation = const EggTimerOrientation();
    return localOffset
        .toPoint()
        // transform the point from screen space to the desired CartesianOrientation.
        .fromScreenTo(eggTimerOrientation)
        .toOffset();
  }

  @override
  Widget build(BuildContext context) {
    return ReorientedGestureDetector(
      origin: ReorientedGestureDetector.originAtCenter,
      pointMapper: _mapDragPointToCartesianOrientation,
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      onPanCancel: _onDragCancel,
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Stack(
          children: [
            _buildOuterCircle(),
            _buildTicks(),
            _buildTimerArrow(_angle),
            _buildInnerKnob(_angle),
          ],
        ),
      ),
    );
  }

  Widget _buildOuterCircle() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF5F5F5), const Color(0xFFE8E8E8)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
    );
  }

  Widget _buildTicks() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(55.0),
      child: new CustomPaint(
        painter: new TickPainter(
          tickCount: widget.maxTime.inMinutes,
          ticksPerSection: 5,
        ),
      ),
    );
  }

  Widget _buildTimerArrow(Angle angle) {
    return Padding(
      padding: const EdgeInsets.all(65),
      child: SizedBox.expand(
        child: CustomPaint(
          painter: ArrowPainter(
            angle: angle,
          ),
        ),
      ),
    );
  }

  Widget _buildInnerKnob(Angle angle) {
    return Container(
      margin: const EdgeInsets.all(65),
      padding: const EdgeInsets.all(10),
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
        gradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [const Color(0xFFF5F5F5), const Color(0xFFE8E8E8)],
        ),
        boxShadow: [
          new BoxShadow(
            color: const Color(0x44000000),
            blurRadius: 2.0,
            spreadRadius: 1.0,
            offset: const Offset(0.0, 1.0),
          ),
        ],
      ),
      child: new Container(
        decoration: new BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
          border: new Border.all(
            color: const Color(0xFFDFDFDF),
            width: 1.5,
          ),
        ),
        child: new Center(
          child: new Transform(
            transform: new Matrix4.rotationZ(angle.radians),
            alignment: Alignment.center,
            child: new Image.asset(
              'assets/logo_mascot_icon.png',
              width: 50.0,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}

class TickPainter extends CustomPainter {
  final longTick = 14.0;
  final shortTick = 4.0;

  final tickCount;
  final ticksPerSection;
  final ticksInset;
  final tickPaint;
  final textPainter;
  final textStyle;

  TickPainter({
    this.tickCount = 35,
    this.ticksPerSection = 5,
    this.ticksInset = 0.0,
  })  : tickPaint = Paint(),
        textPainter = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        ),
        textStyle = TextStyle(
          color: Colors.black,
          fontFamily: GoogleFonts.bebasNeue().fontFamily,
          fontSize: 20.0,
        ) {
    tickPaint.color = Colors.black;
    tickPaint.strokeWidth = 1.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.translate(size.width / 2, size.height / 2);

    canvas.save();

    final radius = size.width / 2;
    for (var i = 0; i < tickCount; ++i) {
      final tickLength = i % ticksPerSection == 0 ? longTick : shortTick;

      canvas.drawLine(
        new Offset(0.0, -radius),
        new Offset(0.0, -radius - tickLength),
        tickPaint,
      );

      if (i % ticksPerSection == 0) {
        // Paint text.
        canvas.save();
        canvas.translate(0.0, -(size.width / 2) - 30.0);

        textPainter.text = new TextSpan(
          text: '$i',
          style: textStyle,
        );

        // Layout the text
        textPainter.layout();

        // Figure out which quadrant the text is in.
        final tickPercent = i / tickCount;
        var quadrant;
        if (tickPercent < 0.25) {
          quadrant = 1;
        } else if (tickPercent < 0.5) {
          quadrant = 4;
        } else if (tickPercent < 0.75) {
          quadrant = 3;
        } else {
          quadrant = 2;
        }

        switch (quadrant) {
          case 4:
            canvas.rotate(-Angle.deg90.radians);
            break;
          case 2:
          case 3:
            canvas.rotate(Angle.deg90.radians);
            break;
        }

        textPainter.paint(
          canvas,
          new Offset(
            -textPainter.width / 2,
            -textPainter.height / 2,
          ),
        );

        canvas.restore();
      }

      // TODO: example of where not having a full circle rotation is annoying
      // Ideally:
      // canvas.rotate((Angle.deg360 / tickCount).radians);
      canvas.rotate(Angle.fromDegrees(360 / tickCount).radians);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/// Paints a small black arrow pointing in the given `angle` direction in
/// screen orientation.
class ArrowPainter extends CustomPainter {
  final Paint dialArrowPaint;
  final Angle angle;

  ArrowPainter({this.angle}) : dialArrowPaint = new Paint() {
    dialArrowPaint.color = Colors.black;
    dialArrowPaint.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();

    final radius = size.height / 2;
    canvas.translate(radius, radius);
    canvas.rotate(angle.radians);

    Path path = new Path();
    path.moveTo(0.0, -radius - 10.0);
    path.lineTo(10.0, -radius + 5.0);
    path.lineTo(-10.0, -radius + 5.0);
    path.close();

    canvas.drawPath(path, dialArrowPaint);
    canvas.drawShadow(path, Colors.black, 3.0, false);

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class EggTimerOrientation extends NavigationOrientation {
  // The EggTimerOrientation is the same as navigation. We extend
  // NavigationOrientation to avoid confusion with the name.
  const EggTimerOrientation();
}

/// Logical representation of an egg timer that can be set, started, paused,
/// resumed, and stopped.
class EggTimer with ChangeNotifier {
  EggTimer({
    @required TickerProvider tickerProvider,
  }) : _tickerProvider = tickerProvider;

  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  final TickerProvider _tickerProvider;

  Ticker _ticker;

  _EggTimerState state = _EggTimerState.ready;

  /// Total time remaining in the countdown.
  Duration get time => _timeRemaining;

  /// Minutes remaining in the countdown, without the seconds.
  int get minutes => (_timeRemaining.inSeconds / 60).floor();

  /// Seconds remaining in the countdown, without the minutes.
  int get seconds => _timeRemaining.inSeconds % 60;

  Duration _countdown = Duration.zero;
  Duration _tickStartTime = Duration.zero;
  Duration _timeRemaining = Duration.zero;

  /// Sets the countdown time for this timer if the timer is ready.
  ///
  /// Has no effect if the timer is not ready.
  void setTimer(Duration countdown) {
    if (state == _EggTimerState.ready) {
      _countdown = countdown;
      _tickStartTime = countdown;
      _timeRemaining = countdown;
      notifyListeners();
    } else {
      print('Cannot set the timer when it is running or paused.');
    }
  }

  /// Starts the timer counting down if the timer is ready.
  void start() {
    if (state == _EggTimerState.ready) {
      state = _EggTimerState.running;
      _ticker = _tickerProvider.createTicker(_tick)..start();
      notifyListeners();
    } else {
      print('Cannot start an EggTimer that is already running.');
    }
  }

  /// Pauses the countdown if the timer is running.
  void pause() {
    if (state == _EggTimerState.running) {
      state = _EggTimerState.paused;
      _ticker.stop();
      notifyListeners();
    } else {
      print('Cannot pause an EggTimer that is not running.');
    }
  }

  /// Resumes ticking if the timer is paused.
  void resume() {
    if (state == _EggTimerState.paused) {
      state = _EggTimerState.running;
      _tickStartTime = _timeRemaining;
      _ticker.start();
      notifyListeners();
    } else {
      print('Cannot resume an EggTimer that is not paused.');
    }
  }

  /// Starts the timer ticking from the previous countdown start time.
  void restart() {
    if (state == _EggTimerState.paused) {
      _ticker.stop();

      _tickStartTime = _countdown;
      _timeRemaining = _countdown;

      state = _EggTimerState.running;
      _ticker.start();

      notifyListeners();
    } else {
      print('Cannot restart an EggTimer that is not paused.');
    }
  }

  /// Stops the `EggTimer`, if it's running, and turns the clock to zero.
  void reset() {
    if (state == _EggTimerState.paused) {
      state = _EggTimerState.ready;
      _countdown = Duration.zero;
      _tickStartTime = Duration.zero;
      _timeRemaining = Duration.zero;
      notifyListeners();
    } else {
      print('Cannot reset an EggTimer that is not paused.');
    }
  }

  void _tick(Duration elapsedTime) {
    _timeRemaining = _tickStartTime - elapsedTime;
    if (_timeRemaining <= Duration.zero) {
      _ticker.stop();
      _timeRemaining = Duration.zero;
      state = _EggTimerState.ready;
    }
    notifyListeners();
  }
}

enum _EggTimerState {
  ready,
  running,
  paused,
}
