import 'dart:async';
import 'dart:math';
import 'dart:ui' as prefix0;
import 'dart:ui';

import 'package:angles/angles.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      home: MyHomePage(title: 'Metshrek'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _minuteRotation = 0;
  double _hourRotation = 0;

  // Theme.of(context).textTheme.display1,

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var scale = 251 / (size.width * 0.5); // Shrek width divided by using width

    var faceWidth = size.width * 0.5;
    var faceHeight = faceWidth * (251 / 190); // Aspect ratio (251/190)

    var longEarWidth = (37 / 190) * faceWidth;
    var longEarHeight = longEarWidth * (114 / 37);

    var shortEarWidth =
        (37 / 190) * faceWidth; // 37 are the same widths for both ears
    var shortEarHeight = shortEarWidth * (89 / 37);

    print('Face width: $faceWidth');

    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
            child: Stack(
          children: [
//            Transform.rotate(
//              Transform.rotate(
//                child: Transform.translate(
//                  child: Transform.rotate(
//                    child: Image(
//                      image: AssetImage('assets/long_ear.png'),
//                      fit: BoxFit.none,
//                      width: faceWidth,
//                      height: faceHeight,
//                    ),
//                    angle: Angle.fromDegrees(90).radians,
//                  ),
//                  offset: Offset(faceWidth * 0.5, 0),
//                ),
//                angle: Angle.fromDegrees(_minuteRotation).radians,
//                origin: Offset(0, 0),
//              ),

            HandWidget(
              scale: scale,
              width: faceWidth,
              height: faceHeight,
              image: AssetImage('assets/long_ear.png'),
              minuteRotation: _minuteRotation,
            ),
            Image(
              image: AssetImage('assets/face.png'),
              fit: BoxFit.fill,
              width: faceWidth,
              height: faceHeight,
            ),
          ],
        )));
  }

  @override
  void initState() {
    super.initState();

    print('Starting rotation!');

    Timer.periodic(Duration(milliseconds: 10), (_) {
      setState(() {
        _minuteRotation += 1;
        if (_minuteRotation >= 360) {
          _minuteRotation = 0;
          _hourRotation += 10;
          if (_hourRotation >= 360) _hourRotation = 0;
        }
      });
    });
  }
}

class HandWidget extends StatefulWidget {
  final double scale;
  final double width;
  final double height;
  final AssetImage image;
  final minuteRotation;

  const HandWidget(
      {Key key,
      this.scale,
      this.width,
      this.height,
      this.image,
      this.minuteRotation})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => HandWidgetState();
}

class HandWidgetState extends State<HandWidget> {
  @override
  Widget build(BuildContext context) {

    var size = MediaQuery.of(context).size;

    var xOffset = widget.width / 2;
    var yOffset = widget.height / 2;

    var padding = widget.width * 0.2;
    var calculated = calculate(widget.width / 2 + padding, widget.height / 2 + padding, widget.minuteRotation);

    print(calculated);

    double deltaY = (calculated.dy);
    double deltaX = (calculated.dx);
    double resultRadians = atan2(deltaY, deltaX);

    return Stack(children: [
//      CustomPaint(
//        size: Size(widget.width, widget.height),
//        painter: Outliner(widget.width, widget.height),
//      ),
        Transform.translate(
//        child: Transform.translate(
            child: Transform.rotate(
                child: Image(
                  image: AssetImage('assets/long_ear.png'),
                  fit: BoxFit.none,
                  width: widget.width,
                  height: widget.height,
                ),
              angle: Angle.fromDegrees(Angle.fromRadians(resultRadians).degrees + 90).radians,
            ),
//          offset: Offset(widget.width * 0.5, 0),
//        ),
          offset: calculated,
        ),
    ]);
  }
}

class Outliner extends CustomPainter {
  final double width;
  final double height;

  Outliner(this.width, this.height);

  @override
  void paint(Canvas canvas, Size size) {
//    canvas.drawOval(Rect.fromLTWH(0, 0, width, height), Paint()..color = Colors.red);

    var xOffset = size.width / 2;
    var yOffset = size.height / 2;

    print('Dimens: $width, $height');

    var points = List<Offset>();
    for (double i = 0; i < 360; i += 0.5) {
      var pointOffset = calculate(width * 0.45, height * 0.45, i);
      points.add(pointOffset.translate(xOffset, yOffset));
    }

    canvas.drawPoints(
        PointMode.points,
        points,
        Paint()
          ..color = Colors.red
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

Offset calculate(double width, double height, double angleDegree) {
  var angleRadian = Angle.fromDegrees(angleDegree).radians;
  return Offset(width * cos(angleRadian), height * sin(angleRadian));
}
