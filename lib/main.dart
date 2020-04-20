import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    var timerService = TimerService.of(context);

    return DefaultTabController(
        length: 2,
        child: new Scaffold(
          appBar: AppBar(
            title: Text("Spy Camera"),
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
