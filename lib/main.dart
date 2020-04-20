import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'timer.dart';

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
    if(type == 'title'){
      title = value;
    } else if(type == 'text'){
      text = value;
    }
    return prefs.setString(type, value);
  }
  showNotification(int id, String title, String text) async {
    var android = new AndroidNotificationDetails(
        'channel id',
        'channel NAME',
        'CHANNEL DESCRIPTION',
        priority: Priority.High,
        importance: Importance.Max
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        id,
        title,
        text,
        platform,
        payload: 'payload');
  }
  Future onSelectNotification(String payload) { // tu będzie się dtopowalo nagrywanie gdzy się kliknie notyfikacje
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('Notyfication click'),
      ),
    );
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
                  showDialog(
                    context: context,
                    builder: (_) => new AlertDialog(
                      title: new Text('Settings'),
                      content: SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Column(
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.all(10.0),
                                  child:Align(
                                    alignment: Alignment.centerLeft,
                                    child: new Text("Notyfication"),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(5.0),
                                  child:TextField(
                                    onChanged: (text) {
                                      setSortingOrder('title', text);
                                    },
                                    controller: titleController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        hintText: "Title"
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(5.0),
                                  child:TextField(
                                    onChanged: (text) {
                                      setSortingOrder('text', text);
                                    },
                                    controller: textController,
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15.0)
                                        ),
                                        hintText: "Text"
                                    ),
                                  ),
                                ),
                                Divider(
                                  color: Colors.black,
                                  height: 36,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
              child: AnimatedBuilder(
                animation: timerService,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                          'Cam time: ${timerService.currentDuration
                              .inHours % 60}h : ${timerService.currentDuration
                              .inMinutes % 60}m : ${timerService.currentDuration
                              .inSeconds % 60}s'),
                      RaisedButton(
                        onPressed: () {
                          showNotification(0, title, text); // funkcja do powiadomienia
                          !timerService.isRunning
                              ? timerService.start()
                              : timerService.stop();
                        },
                        child: Text(
                            !timerService.isRunning ? 'Start Cam' : 'Stop Cam'),
                      ),
                      RaisedButton(
                        onPressed: () {
                          timerService.reset();
                        },
                        child: Text('Reset Cam'),
                      )
                    ],
                  );
                },
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
                          'Mic time: ${timerService.currentDuration
                              .inHours % 60}h : ${timerService.currentDuration
                              .inMinutes % 60}m : ${timerService.currentDuration
                              .inSeconds % 60}s'),
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
                      )
                    ],
                  );
                },
              ),
            ),
          ]),
        ));
  }
}
