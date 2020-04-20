import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class TimerService extends ChangeNotifier {
  Stopwatch _stopwatch;
  Timer _timer;


  Duration get currentDuration => _currentDuration;
  Duration _currentDuration = Duration.zero;

  bool get isRunning => _timer != null;

  TimerService() {
    _stopwatch = Stopwatch();
  }

  void dur(Timer timer) {
    _currentDuration = _stopwatch.elapsed;

    notifyListeners();
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(Duration(seconds: 1), dur);
    _stopwatch.start();

    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _stopwatch.stop();
    _currentDuration = _stopwatch.elapsed;

    notifyListeners();
  }

  void reset() {
    stop();
    _stopwatch.reset();
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