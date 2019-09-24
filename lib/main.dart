import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:angles/angles.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metshrek',
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
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.center,
          shrinkWrap: true,
          children: [
            Column(
//              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: faceHeight / 2,
                ),
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
  shrekTime
      .forEach((time) => string += '${time.toString().padLeft(2, '0')}:');
  return string.substring(0, 8);
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
  final format = DateFormat("HH:mm:ss");
  String metshrekTime = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text('Input time:'),
        DateTimeField(
//          style: Theme.of(context).textTheme.subhead,
          format: format,
          onShowPicker: (context, currentValue) async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
            );
            return DateTimeField.convert(time);
          },
          onChanged: (dateTime) {
            print('DateTime: $dateTime');
            setState(() {
              if (dateTime == null) {
                metshrekTime = '';
              } else {
                print('Before: $dateTime');
                dateTime = dateTime.add(dateTime.timeZoneOffset);
                print('Before: $dateTime');
                print('Mills: ${dateTime.millisecondsSinceEpoch}');
                var conv = convertToShrek(dateTime.millisecondsSinceEpoch);
                print('Conv: $conv');
                metshrekTime = getStyledTime(conv);
              }
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 5),
          child: Text('Metshrek time:'),
        ),
        Text(
          metshrekTime,
          style: Theme.of(context).textTheme.display1,
        )
      ]),
    );
  }
}
