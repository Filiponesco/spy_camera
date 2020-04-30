<<<<<<< Updated upstream
=======
import 'package:camera/camera.dart';
import 'package:camera/new/camera.dart';
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
  CameraManagement _cam;
  @override
  void initState() {
    super.initState();
    _cam = new CameraManagement();
=======
  //CameraManagement _cam;
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
    print("INIT STATE");
    //_cam = new CameraManagement(_showToast);
    /*_cam.setupCameras().catchError(
        (error) => _showAlertDialog("Camera ${error.code}", error.description));*/
>>>>>>> Stashed changes
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

<<<<<<< Updated upstream
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String title, text;
  final titleController = TextEditingController();
  final textController = TextEditingController();
=======
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
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
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
    // tu będzie się stopowalo nagrywanie gdzy się kliknie notyfikacje
    _cam.stopVideoRecording();
/*    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('Notyfication click'),
      ),
    );*/
=======
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
  void _resumeRecordTimeOrShowError() async{
    try {
      var camStatus = Provider.of<CameraManagement>(context, listen: false);
      await camStatus.resumeVideoRecording();
      var timerService = TimerService.of(context);
      if (timerService.isRunning) {
        CamIsRunning = true;
        timerService.start();
      }
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
        CamIsRunning = true;
        timerService.stop();
      }
      hideNotification();
    } on CameraException catch (error) {
      _showAlertDialog(error.code, error.description);
    }
>>>>>>> Stashed changes
  }

  void _onClickChangeCamera() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    switch (camStatus.cameraPosition) {
      case CameraPosition.back:
        camStatus.cameraPosition = CameraPosition.front;
        break;
      case CameraPosition.front:
        camStatus.cameraPosition = CameraPosition.back;
        break;
    }
  }

  void _onClickStartPause() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    if (camStatus.isRecording) {
      _pauseRecordTimeOrShowError();
    } else if(camStatus.controller.value.isRecordingPaused){
        _resumeRecordTimeOrShowError();
    } else{
      _startRecordTimeNotifyOrShowError();
    }
  }
  void _onClickStop(){
    var timerService = TimerService.of(context);
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    if (camStatus.isRecording || camStatus.controller.value.isRecordingPaused) {
      _stopRecordTimeNotifyOrShowError();
      timerService.reset();
      hideNotification();
      CamIsRunning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);

<<<<<<< Updated upstream
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
                              print("Start recording");
                            }
                          },
                          child: Text(
                              !timerService.isRunning ? 'Start Cam' : 'Stop Cam'),
                        ),
                        RaisedButton(
                          onPressed: () {
                            timerService.reset();
                          },
                          child: Text('Reset Cam'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          new Container(
            child: AnimatedBuilder(
              animation: timerService,
              builder: (context, child) {
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
                        },
                        child: Text(!timerService.isRunning
                            ? 'Start Mic'
                            : 'Stop Mic')),
                    RaisedButton(
                      onPressed: () {
                        timerService.reset();
                      },
                      child: Text('Reset Mic'),
                    ),
                  ],
                );
              },
            ),
          ),
        ]),
=======
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
      body: Consumer<CameraManagement>(
        builder: (context, _camStatus, child) {
          //_camStatus.controller.
          //like callback
          _camStatus.informUI = _showToast;
          return Column(children: <Widget>[
            Text(_nameCam[_camStatus.cameraPosition]),
            RaisedButton(
                child: Text("Change camera"),
                onPressed:
                _camStatus.isRecording ? null : () => _onClickChangeCamera()),
            SizedBox(height: 30),
            Center(
              child: AnimatedBuilder(
                animation: timerService,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Cam time: ${timerService.currentDuration.inHours %
                              60}h : ${timerService.currentDuration.inMinutes %
                              60}m : ${timerService.currentDuration.inSeconds %
                              60}s'),
                      RaisedButton(
                        onPressed: () => _onClickStartPause(),
                        child: Text(
                            !timerService.isRunning ? 'START' : 'PAUSE'),
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
>>>>>>> Stashed changes
      ),
    );
  }
  @override
  void dispose() {
    var camStatus = Provider.of<CameraManagement>(context, listen: false);
    super.dispose();
    camStatus.controller.dispose();
  }
}
