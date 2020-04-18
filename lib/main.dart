import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:toast/toast.dart';

void main() {
  final timerService = TimerService();
  runApp(
    TimerServiceProvider(
      service: timerService,
      child: MyApp(),
    ),
  );
}

class TimerService extends ChangeNotifier {
  Stopwatch _watch;
  Timer _timer;

  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _watch = Stopwatch();
  }

  void _onTick(Timer timer) {
    _currentDuration = _watch.elapsed;

    // notify all listening widgets
    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), _onTick);
    _watch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _watch.stop();
    _currentDuration = _watch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _watch.reset();
    _currentDuration = Duration.zero;

    notifyListeners();
  }

  static TimerService of(BuildContext context) {
    var provider = context.inheritFromWidgetOfExactType(TimerServiceProvider)
        as TimerServiceProvider;
    return provider.service;
  }
}

class TimerServiceProvider extends InheritedWidget {
  const TimerServiceProvider({Key key, this.service, Widget child})
      : super(key: key, child: child);

  final TimerService service;

  @override
  bool updateShouldNotify(TimerServiceProvider old) => service != old.service;
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

class _HomePageState extends State<HomePage> {
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
                animation: timerService, // listen to ChangeNotifier
                builder: (context, child) {
                  // this part is rebuilt whenever notifyListeners() is called
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Time: ${timerService.currentDuration}'),
                      RaisedButton(
                        onPressed: !timerService.isRunning
                            ? timerService.start
                            : timerService.stop,
                        child: Text(!timerService.isRunning ? 'Start' : 'Stop'),
                      ),
                      RaisedButton(
                        onPressed: timerService.reset,
                        child: Text('Reset'),
                      )
                    ],
                  );
                },
              ),
            ),
            new Container(
              child: AnimatedBuilder(
                animation: timerService, // listen to ChangeNotifier
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Time: ${timerService.currentDuration}'),
                      RaisedButton(
                          onPressed: !timerService.isRunning
                              ? timerService.start
                              : timerService.stop,
                          child:
                              Text(!timerService.isRunning ? 'Start' : 'Stop')
                      ),
                      RaisedButton(
                        onPressed: timerService.reset,
                        child: Text('Reset'),
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
