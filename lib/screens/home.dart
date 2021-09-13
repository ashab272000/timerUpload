import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mettrial/models/timer.dart';
import 'package:mettrial/services/cloudstore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? startTime;
  DateTime? endTime;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mettrial"),
        centerTitle: true,
      ),
      body: Column(
        children: [_buildTimer()],
      ),
    );
  }

  Widget _buildTimer() {
    return Container(
      height: 300,
      child: Center(
        child: StreamBuilder(
          stream: CloudStore().getTimer(),
          initialData: DateTime.now().millisecondsSinceEpoch,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              MetTimer timerData = MetTimer.fromMap(snapshot.data.data());
              return Column(children: [
                _buildTimerTemp(timerData),
                _buildPostTimer(),
                _buildUpdateButton()
              ]);
            } else if (snapshot.hasError) {
              return Container(
                child: Text("Something went wrong !!"),
              );
            } else {
              return Column(
                  children: [_buildPostTimer(), _buildUpdateButton()]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildTimerTemp(MetTimer data) {
    var _timer = new Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
    var text = "Time Remaing before start time";
    var secondsLeft = data.startTime - DateTime.now().millisecondsSinceEpoch;
    if (secondsLeft < 0) {
      secondsLeft = data.endTime - DateTime.now().millisecondsSinceEpoch;
      text = "Time Remaing before end time";
      if (secondsLeft < 0) {
        return Container(
          child: Text(
            "Timer Completed",
            style: TextStyle(
                fontSize: 48,
                color: Colors.blue[400],
                fontWeight: FontWeight.w600),
          ),
        );
      }
    }

    secondsLeft = (secondsLeft / 1000).floor();
    var hoursTime = (secondsLeft / 3600).floor();
    var minutesTime = ((secondsLeft % 3600) / 60).floor();
    var secondsTime = (secondsLeft % 3600) % 60;

    return _timerText(hoursTime, minutesTime, secondsTime, text: text);
  }

  Widget _buildPostTimer() {
    return Container(
      child: Center(
        child: Column(
          children: [
            _datePickerButton(),
            _datePickerButton(isStart: false),
          ],
        ),
      ),
    );
  }

  Widget _datePickerButton({bool isStart = true}) {
    var timeFor = null;
    if (isStart) {
      timeFor = startTime;
    } else {
      timeFor = endTime;
    }

    return TextButton(
        onPressed: () async {
          final DateTime? newDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2030));
          if (newDate == null) {
            return;
          }

          final TimeOfDay? newTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: DateTime.now().hour, minute: DateTime.now().minute),
          );

          if (newTime == null) {
            return;
          }

          setState(() {
            if (isStart) {
              startTime = DateTime(newDate.year, newDate.month, newDate.day,
                  newTime.hour, newTime.minute);
            } else {
              endTime = DateTime(newDate.year, newDate.month, newDate.day,
                  newTime.hour, newTime.minute);
            }
          });
        },
        child: timeFor == null
            ? Text("Pick a ${isStart ? "Start" : "End"} time")
            : Text(
                "${isStart ? "Start" : "End"} time: ${timeFor!.day}/${timeFor!.month} @ ${timeFor!.hour}:${timeFor!.minute}"));
  }

  Widget _timerText(int hours, int minutes, int seconds,
      {String text = "Time Remaing before start time"}) {
    var hourString = _timeToString(hours);
    var minString = _timeToString(minutes);
    var secString = _timeToString(seconds);
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(text),
          Text(
            "$hourString:$minString:$secString",
            style: TextStyle(
              fontSize: 48,
              color: Colors.blue[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ]);
  }

  Widget _buildUpdateButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
            child: Text("Update"),
            onPressed: () {
              if (startTime != null && endTime != null) {
                CloudStore().addTimer(
                  MetTimer(startTime!.millisecondsSinceEpoch,
                      endTime!.millisecondsSinceEpoch),
                );
                setState(() {
                  startTime = null;
                  endTime = null;
                });
              }
            })
      ],
    );
  }

  String _timeToString(int time) {
    if (time < 10) return '0$time';
    return '$time';
  }
}
