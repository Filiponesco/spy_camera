import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:toast/toast.dart';

import 'pages/settings_page.dart';
import 'timer.dart';
import 'camera_management.dart';

void main() {
  final timerService = TimerService();
  runApp(
    TimerServiceProvider(
      service: timerService,
      child: ChangeNotifierProvider(
          create: (context) => CameraManagement(), child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: ThemeData(brightness: Brightness.dark),
      title: "Spy Camera",
      debugShowCheckedModeBanner: false,
      home: new HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool CamIsRunning = false;
  bool MicIsRunning = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title, text;
  final Map<CameraPosition, String> _nameCam = {
    CameraPosition.back: "Back camera",
    CameraPosition.front: "Front camera"
  };

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    setState(() {
      getSortingOrder('notification_title').then((val) => title = val);
      getSortingOrder('notification_description').then((val) => text = val);
    });
  }

  showNotification(int id, String title, String text) async {
    title = await getSortingOrder('notification_title');
    text = await getSortingOrder('notification_description');
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(id, title, text, platform,
        payload: 'payload');
  }

  hideNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.cancel(0);
  }

  Future onSelectNotification(String payload) {
    _stopRecordTimeNotifyOrShowError();
  }

  Future<String> getSortingOrder(String type) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(type);
  }

  Future<bool> setSortingOrder(String type, String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (type == 'title') {
      title = value;
    } else if (type == 'text') {
      text = value;
    }
    return prefs.setString(type, value);
  }

  void _showToast(String message) {
    Toast.show(message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) => GestureDetector(
              onTap: () => Navigator.pop(context),
              child: AlertDialog(
                title: Text(title),
                content: Text(message),
              ),
            ));
  }

  void _startRecordTimeNotifyOrShowError() async {
    try {
      var camStatus = Provider.of<CameraManagement>(context, listen: false);
      await camStatus.startVideoRecording();
      var timerService = TimerService.of(context);
      timerService.start();
      showNotification(0, title, text);
      CamIsRunning = true;
    } on CameraException catch (error) {
      _showAlertDialog(error.code, error.description);
    }
  }

  void _stopRecordTimeNotifyOrShowError() async {
    try {
      var camStatus = Provider.of<CameraManagement>(context, listen: false);
      await camStatus.stopVideoRecording();
      var timerService = TimerService.of(context);
      if (timerService.isRunning) {
        CamIsRunning = false;
        timerService.reset();
      }
      hideNotification();
    } on CameraException catch (error) {
      _showAlertDialog(error.code, error.description);
    }
  }

  void _pauseRecordTimeOrShowError() async {
    try {
      var camStatus = Provider.of<CameraManagement>(context, listen: false);
      await camStatus.pauseVideoRecording();
      var timerService = TimerService.of(context);
      if (timerService.isRunning) {
        CamIsRunning = true;
        timerService.stop();
      }
    } on CameraException catch (error) {
      _showAlertDialog(error.code, error.description);
    }
  }

  void _resumeRecordTimeOrShowError() async {
    try {
      var camStatus = Provider.of<CameraManagement>(context, listen: false);
      await camStatus.resumeVideoRecording();
      var timerService = TimerService.of(context);
      //if (timerService.isRunning) {
        CamIsRunning = true;
        timerService.start();
      //}
    } on CameraException catch (error) {
      _showAlertDialog(error.code, error.description);
    }
  }

  void _onClickStartPause() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    if (camStatus.controller.value.isRecordingVideo
        && !(camStatus.controller.value.isRecordingPaused)) {
      _pauseRecordTimeOrShowError();
    } else if (camStatus.controller.value.isRecordingPaused) {
      _resumeRecordTimeOrShowError();
    } else {
      _startRecordTimeNotifyOrShowError();
    }
  }

  void _onClickStop() {
    var timerService = TimerService.of(context);
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    if (camStatus.controller.value.isRecordingVideo ||
        camStatus.controller.value.isRecordingPaused) {
      _stopRecordTimeNotifyOrShowError();
      timerService.reset();
      hideNotification();
      CamIsRunning = false;
    }
  }

  void _onClickChangeCamera() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    switch (camStatus.camPos) {
      case CameraPosition.back:
        camStatus.camPos = CameraPosition.front;
        break;
      case CameraPosition.front:
        camStatus.camPos = CameraPosition.back;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Spy Camera"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsRoute()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CameraManagement>(builder: (context, camStatus, child) {
        camStatus.informUICallback = _showToast;
        //waiting for cameras
        if (camStatus.controller == null)
          return _loadingCameras();
        else {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
            Text(_nameCam[camStatus.camPos]),
            RaisedButton(
                child: Text("Change camera"),
                onPressed: (camStatus.controller.value.isRecordingVideo ||
                        camStatus.controller.value.isRecordingPaused)
                    ? null
                    : () => _onClickChangeCamera()),
            SizedBox(height: 30),
            Center(
              child: AnimatedBuilder(
                animation: timerService,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Cam time: ${timerService.currentDuration.inHours % 60}h : ${timerService.currentDuration.inMinutes % 60}m : ${timerService.currentDuration.inSeconds % 60}s'),
                      RaisedButton(
                        onPressed: () => _onClickStartPause(),
                        child:
                            Text(!timerService.isRunning ? 'START' : 'PAUSE'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          _onClickStop();
                        },
                        child: Text('STOP'),
                      ),
                    ],
                  );
                },
              ),
            ),
          ]);
        }
      }),
    );
  }
  Widget _loadingCameras(){
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height:10),
            Text("Loading cameras"),
            Text("Please wait"),
          ],
        ));
  }

  @override
  void dispose() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    super.dispose();
    camStatus.controller.dispose();
    camStatus.dispose();
  }
}
