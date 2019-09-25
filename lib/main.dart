import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:angles/angles.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metshrek',
      theme: ThemeData(
        primaryColor: Color(0xFFA1A30F),
        accentColor: Color(0xFFAC8B21),
      ),
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
  List<int> shrekTime = [0, 0, 0, 0];

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var scale = 251 / (size.width * 0.5); // Shrek width divided by using width

    var faceWidth = size.width * 0.5;
    var faceHeight = faceWidth * (251 / 190); // Aspect ratio (251/190)

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: ListView(
          shrinkWrap: true,
          children: [
            Column(
              children: [
                Container(height: faceHeight / 2),
                Stack(
                  children: [
                    ...Hand.values.map((hand) => HandWidget(
                          scale: scale,
                          width: faceWidth,
                          height: faceHeight,
                          hand: hand,
                          time: shrekTime,
                        )),
                    Image(
                      image: AssetImage('assets/face.png'),
                      fit: BoxFit.fill,
                      width: faceWidth,
                      height: faceHeight,
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                getStyledTime(getShrekTime()),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display2,
              ),
//              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Text(
                'Metshrek conversions',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.display1,
              ),
            ),
            MetshrekToStandard(),
            Text(
              'Countdown',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.display1,
            ),
            MetshrekCountdown(),
            Container(height: size.height / 2),
          ],
        ));
  }

  @override
  void initState() {
    super.initState();

    Timer.periodic(Duration(milliseconds: 100),
        (_) => setState(() => shrekTime = getShrekTime()));
  }

  List<int> getShrekTime() {
    var today = DateTime.now();
    var time =
        DateTime.now().difference(DateTime(today.year, today.month, today.day));
    return convertToShrek(time.inMilliseconds);
  }
}

List<int> convertToShrek(int milliseconds) {
  var shrek = milliseconds / 1000 / 60 / 90;

  var hours = shrek.truncate();
  var minutes = (shrek - hours) * 90;
  var shrekonds = (minutes - minutes.truncate()) * 90;

  var ret = [
    hours,
    minutes.truncate(),
    shrekonds.truncate(),
    (shrekonds * 10000).truncate()
  ];
  return ret;
}

String getStyledTime(List<int> shrekTime) {
  var string = '';
  shrekTime.forEach((time) => string += '${time.toString().padLeft(2, '0')}:');
  return string.substring(0, 8);
}

String getFractionalMetshrek(List<int> metshrek) {
  var top = (metshrek[0] * 90) + metshrek[1];
  var bottom = 90;
  return simplifyFraction(top / bottom);
}

String simplifyFraction(double x) {
  if (x < 0) return "-" + simplifyFraction(-x);
  double tolerance = 1.0E-6;
  double h1 = 1;
  double h2 = 0;
  double k1 = 0;
  double k2 = 1;
  double b = x;
  do {
    double a = b.floorToDouble();
    double aux = h1;
    h1 = a * h1 + h2;
    h2 = aux;
    aux = k1;
    k1 = a * k1 + k2;
    k2 = aux;
    b = 1 / (b - a);
  } while ((x - h1 / k1).abs() > x * tolerance);
  return '${h1.truncate()}/${k1.truncate()}';
}

enum Hand { HOUR, MINUTE, SHREKOND }

class HandWidget extends StatefulWidget {
  static const shortEar = AssetImage('assets/short_ear.png');
  static const longEar = AssetImage('assets/long_ear.png');

  final double scale;
  final double width;
  final double height;
  final Hand hand;
  final AssetImage image;
  final List<int> time;

  const HandWidget(
      {Key key, this.scale, this.width, this.height, this.hand, this.time})
      : this.image = hand == Hand.HOUR ? shortEar : longEar,
        super(key: key);

  @override
  State<StatefulWidget> createState() => HandWidgetState();
}

class HandWidgetState extends State<HandWidget> {
  @override
  Widget build(BuildContext context) {
    var time = widget.time;
    double angle;
    if (widget.hand == Hand.HOUR || widget.hand == Hand.MINUTE) {
      angle = (time[widget.hand.index] / 90) * 360;
    } else {
      angle = (time[3] / 10000 / 90) * 360;
    }

    var padding =
        widget.hand == Hand.HOUR ? widget.width * 0.1 : widget.width * 0.2;
    var calculated = calculate(
        widget.width / 2 + padding, widget.height / 2 + padding, angle);

    double deltaY = (calculated.dy);
    double deltaX = (calculated.dx);
    double resultRadians = atan2(deltaY, deltaX);

    return Stack(children: [
      Transform.translate(
        child: Transform.rotate(
          child: Image(
            image: widget.image,
            fit: BoxFit.none,
            width: widget.width,
            height: widget.height,
          ),
          angle:
              Angle.fromDegrees(Angle.fromRadians(resultRadians).degrees + 90)
                  .radians,
        ),
        offset: calculated,
      ),
    ]);
  }

  Offset calculate(double width, double height, double angleDegree) {
    var angleRadian = Angle.fromDegrees(angleDegree - 90).radians;
    return Offset(width * cos(angleRadian), height * sin(angleRadian));
  }
}

class MetshrekToStandard extends StatefulWidget {
  @override
  State<MetshrekToStandard> createState() => MetshrekToStandardState();
}

class MetshrekToStandardState extends State<MetshrekToStandard> {
  final format = DateFormat("HH:mm");
  String metshrekTime = '';
  String fractionalTime = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text('Input time:'),
        DateTimeField(
          format: format,
          onShowPicker: (context, currentValue) async {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime(1970)),
            );
            return DateTimeField.convert(time);
          },
          onChanged: (dateTime) => setState(() {
            if (dateTime == null) {
              metshrekTime = '';
              fractionalTime = '';
            } else {
              var shrekTime = convertToShrek(
                  dateTime.add(dateTime.timeZoneOffset).millisecondsSinceEpoch);
              metshrekTime = getStyledTime(shrekTime);
              fractionalTime = getFractionalMetshrek(shrekTime);
            }
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
          child: Text('Metshrek time:'),
        ),
        Text(
          metshrekTime,
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
          child: Text('Fractional Metshrek time:'),
        ),
        Text(
          fractionalTime,
          style: Theme.of(context).textTheme.display1,
        ),
      ]),
    );
  }
}

class MetshrekCountdown extends StatefulWidget {
  @override
  State<MetshrekCountdown> createState() => MetshrekCountdownState();
}

class MetshrekCountdownState extends State<MetshrekCountdown> {
  final format = DateFormat("HH:mm");
  String metshrekTime = '';
  String fractionalTime = '';
  DateTime target;
  Timer currentTimer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text('Countdown to (Standard time):'),
        DateTimeField(
          format: format,
          onShowPicker: (context, currentValue) async {
            final time = await showTimePicker(
              context: context,
              initialTime:
                  TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.convert(time);
          },
          onChanged: (dateTime) => setState(() {
            target = dateTime;
            currentTimer?.cancel();
            if (target == null) return;

            currentTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
              setState(() {
                var now = DateTime.now();
                var shrekTime = convertToShrek(target.difference(DateTime(1970, 1, 1, now.hour, now.minute, now.second, now.millisecond)).inMilliseconds);
                metshrekTime = getStyledTime(shrekTime);
                fractionalTime = getFractionalMetshrek(shrekTime);
              });
            });
          }),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
          child: Text('Remaining time (Metshrek):'),
        ),
        Text(
          metshrekTime,
          style: Theme.of(context).textTheme.display1,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
          child: Text('Remaining time (Fractional Metshrek):'),
        ),
        Text(
          fractionalTime,
          style: Theme.of(context).textTheme.display1,
        ),
      ]),
    );
  }
}
