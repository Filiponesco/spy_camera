import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:spycamera/widgets/camera_view.dart';

import 'pages/settings_page.dart';
import 'timer.dart';
import 'widgets/camera_view.dart';
import 'camera_management.dart';

void main() {
  final timerService = TimerService();
  runApp(
    TimerServiceProvider(
      service: timerService,
      child: MyApp(),
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
  CameraManagement _cam;
  bool CamIsRunning = false;
  bool MicIsRunning = false;

  @override
  void initState() {
    super.initState();
    _cam = new CameraManagement();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
    setState(() {
      getSortingOrder('title').then((val) => titleController.text = val);
      getSortingOrder('text').then((val) => textController.text = val);
      getSortingOrder('title').then((val) => title = val);
      getSortingOrder('text').then((val) => text = val);
    });
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title, text;
  final titleController = TextEditingController();
  final textController = TextEditingController();

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

  showNotification(int id, String title, String text) async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(id, title, text, platform,
        payload: 'payload');
  }

  Future onSelectNotification(String payload) {
    var timerService = TimerService.of(context);
    if (timerService.isRunning) {
      CamIsRunning = true;
      timerService.stop();
    }
    _cam.stopVideoRecording();
/*    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('Notyfication click'),
      ),
    );*/
  }

  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);

    return DefaultTabController(
      length: 2,
      child: new Scaffold(
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
          bottom: TabBar(tabs: [
            Tab(
              icon: Icon(Icons.videocam),
            ),
            Tab(
              icon: Icon(Icons.mic),
            ),
          ]),
        ),
        body: TabBarView(children: [
          new Container(
            child: Column(
              children: <Widget>[
                FutureBuilder(
                    future: _cam.setupCameras(),
                    builder: (BuildContext context, _) {
                      print("Reset camera");
                      return CameraApp(_cam);
                    }),
                SizedBox(height: 10),
                AnimatedBuilder(
                  animation: timerService,
                  builder: (context, child) {
                    if (!MicIsRunning) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              'Cam time: ${timerService.currentDuration.inHours % 60}h : ${timerService.currentDuration.inMinutes % 60}m : ${timerService.currentDuration.inSeconds % 60}s'),
                          RaisedButton(
                            onPressed: () {
                              showNotification(
                                  0, title, text); // funkcja do powiadomienia
                              !timerService.isRunning
                                  ? timerService.start()
                                  : timerService.stop();
                              if (_cam.isRecording) {
                                _cam.stopVideoRecording();
                                print("Stop recording");
                              } else {
                                _cam.startVideoRecording();
                                CamIsRunning = true;
                                print("Start recording");
                              }
                            },
                            child: Text(!timerService.isRunning
                                ? 'Start Cam'
                                : 'Stop Cam'),
                          ),
                          RaisedButton(
                            onPressed: () {
                              timerService.reset();
                              CamIsRunning = false;
                            },
                            child: Text('Reset Cam'),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Text('Mic ON. Reset mic to start Cam')]);
                    }
                  },
                ),
              ],
            ),
          ),
          new Container(
            child: AnimatedBuilder(
              animation: timerService,
              builder: (context, child) {
                if (!CamIsRunning) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Mic time: ${timerService.currentDuration.inHours % 60}h : ${timerService.currentDuration.inMinutes % 60}m : ${timerService.currentDuration.inSeconds % 60}s'),
                      RaisedButton(
                          onPressed: () {
                            !timerService.isRunning
                                ? timerService.start()
                                : timerService.stop();
                            if (timerService.isRunning) {
                              MicIsRunning = true;
                            }
                          },
                          child: Text(!timerService.isRunning
                              ? 'Start Mic'
                              : 'Stop Mic')),
                      RaisedButton(
                        onPressed: () {
                          timerService.reset();
                          MicIsRunning = false;
                        },
                        child: Text('Reset Mic'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[Text('Cam ON. Reset cam to start Mic')]);
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _cam.controller.dispose();
  }
}
