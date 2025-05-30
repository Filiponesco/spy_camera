import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

enum CameraPosition{
  back,
  front
}
// singleton
class CameraManagement extends ChangeNotifier {
  static final CameraManagement _cameraManagement =
      CameraManagement._internal();

  factory CameraManagement() {
    _cameraManagement._setupCameras();
    return _cameraManagement;
  }
  CameraManagement._internal();

  SharedPreferences _prefs;
  CameraPosition _camPos = CameraPosition.back;
  List<CameraDescription> cameras;
  CameraController controller;
  Function(String message) informUICallback;

  set camPos (CameraPosition value){
    this._camPos = value;
    notifyListeners(); //notify that controller is not initialize
    _changeCamera();
  }
  CameraPosition get camPos{
    return this._camPos;
  }

  Future<void> _setupCameras() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[camPos.index], ResolutionPreset.medium);
    await controller.initialize();
    //_prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }
  Future<void> _changeCamera() async{
    controller = CameraController(cameras[camPos.index], ResolutionPreset.medium);
    print("controller ${controller.toString()}");
    await controller.initialize();
    notifyListeners();
  }

  Future<void> startVideoRecording() async {
    if(controller.value.isInitialized){
      if (_isVibrate("start")) _vibrate(50);
      String path = await _getVideoPath;
      await controller.startVideoRecording(path);
      print("Cam: start");
      informUICallback("Recording...");
      notifyListeners();
    }
    print("controller isn't initialized");
  }

  Future<void> stopVideoRecording() async {
      if (!controller.value.isRecordingVideo) {
        return null;
      }
      if(_isVibrate("end")) _vibrate(200);
      await controller.stopVideoRecording();

      informUICallback("Movie saved");
      notifyListeners();
  }
  Future<void> pauseVideoRecording() async{
    if(controller.value.isRecordingVideo) {
      await controller.pauseVideoRecording();
      informUICallback("Pause video");
      notifyListeners();
    }
    else return null;
  }
  Future<void> resumeVideoRecording() async{
    if(controller.value.isRecordingPaused) {
      await controller.resumeVideoRecording();
      informUICallback("Resume video");
      notifyListeners();
      print("Resume");
    }
    else {
      print("cant resume because isnt pause");
      return null;
    }
  }

  Future<String> get _getVideoPath async {
    //final directory = await DownloadsPathProvider.downloadsDirectory;
    final directory = await getExternalStorageDirectory();
    //final directory = await getTemporaryDirectory();
    var now = new DateTime.now();
    await initializeDateFormatting('pl_PL', null);
    var formatterData = new DateFormat('yyyy-MM-dd-hh-mm-ss');
    String formattedData = formatterData.format(now);
    final path = '${directory.path}/$formattedData.mp4';
    print("Will save temp movie to: $path");
    return path;
  }

  void _vibrate(int duration) async {
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: duration);
    } else {
      print("Vibrator no mounted on device");
      informUICallback("Vibrator no mounted on device");
      notifyListeners();
    }
  }

  bool _isVibrate(String when) {
    if(_prefs != null) {
      if (_prefs.getBool('vibration_$when') != null) {
        if (_prefs.getBool('vibration_$when'))
          return true;
      }
    }
    return false;
  }
}
