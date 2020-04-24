import 'dart:io';
import 'package:camera/camera.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
// singleton
class CameraManagement{
  static final CameraManagement _cameraManagement = CameraManagement._internal();
  factory CameraManagement(){
    return _cameraManagement;
  }
  CameraManagement._internal();

  CameraController controller;
  bool isReady = false;
  bool isRecording = false;
  SharedPreferences _prefs;

  Future<void> setupCameras() async {
    try{
      if(!isReady){
        List<CameraDescription> cameras = await availableCameras();
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        await controller.initialize();
        _prefs = await SharedPreferences.getInstance();
        isReady = true;
      }
    } on CameraException catch(e){
        _showCameraException(e);
        return null;
    }
    print("setup cameras");
  }
  Future<void> startVideoRecording() async{
    try{
      if(!isRecording) {

        if(_prefs.getBool('vibration_start')) {
          _vibrate(50);
        }
          String path = await _getVideoPath;
          await controller.startVideoRecording(path);
          isRecording = true;
          print("Cam: start");
      }
    } on CameraException catch(e){
      _showCameraException(e);
      return null;
    }
  }
  Future<void> stopVideoRecording() async {
    try{
      if (!controller.value.isRecordingVideo) {
        return null;
      }
      if(_prefs.getBool('vibration_end')) {
        _vibrate(200);
      }
      await controller.stopVideoRecording();
      isRecording = false;
    } on CameraException catch(e){
      _showCameraException(e);
    }
  }
  Future<String> get _getVideoPath async {
    /*final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/${DateTime.now()}.mp4';*/
    final directory = await DownloadsPathProvider.downloadsDirectory;
    var now = new DateTime.now();
    await initializeDateFormatting('pl_PL', null);
    var formatterData = new DateFormat('yyyy-MM-dd-hh-mm-ss');
    String formattedData = formatterData.format(now);

    final path = '${directory.path}/$formattedData.mp4';
    print("Save movie to: $path");
    return path;
  }
  void _showCameraException(CameraException e){
    print("${e.code} ${e.description}");
  }
  void _vibrate(int duration) async {
    if (await Vibration.hasVibrator()) {
    Vibration.vibrate(duration: duration);
    }
  }

}