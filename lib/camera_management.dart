import 'dart:async';
import 'package:camera/camera.dart';
<<<<<<< Updated upstream
import 'package:path_provider/path_provider.dart';
=======
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
>>>>>>> Stashed changes
// singleton
//notify isRecording, which camera
class CameraManagement extends ChangeNotifier{
  static final CameraManagement _cameraManagement = CameraManagement._internal();
<<<<<<< Updated upstream
  factory CameraManagement(){
=======
  factory CameraManagement() {
    _cameraManagement._loadCameras();
    _cameraManagement._loadPreferences();
    print("Constructor");
>>>>>>> Stashed changes
    return _cameraManagement;
  }
  CameraManagement._internal();

  bool _isLoadCameras = false;
  bool _isLoadPreferences = false;
  bool _isSetupCameras = false;
  bool _isRecording = false;
  bool _isPause = false;
  Function(String message) _informUICallback;
  CameraController controller;
<<<<<<< Updated upstream
  bool isReady = false;
  bool isRecording = false;
=======
  SharedPreferences _prefs;
  CameraPosition _camPos = CameraPosition.back;
  List<CameraDescription> _cameras;
>>>>>>> Stashed changes

  set isRecording(bool value){
    this._isRecording = value;
    print("Notify is RECORDING");
    notifyListeners();
  }
  bool get isRecording{
    return this._isRecording;
  }
  set cameraPosition(CameraPosition value){
    this._camPos = value;
    notifyListeners();
  }
  CameraPosition get cameraPosition{
    return this._camPos;
  }
  bool get isReadyToSetup{
    if(_isLoadCameras && _isLoadPreferences && !isRecording)
      return true;
    else
      return false;
  }
  bool get isReadyToRecord{
    if(_isLoadCameras && _isLoadPreferences && _isSetupCameras && !isRecording)
      return true;
    else
      return false;
  }
  set informUI (Function(String) value){
    this._informUICallback = value;
    notifyListeners();
  }
  Future<void> _loadCameras() async{
    try{
        _cameras = await availableCameras();
        _isLoadCameras = true;
        print("Load cameras");
    } on CameraException catch(e){
      print("Load cameras: $e");
      _showAndThrowCameraException(e);
      return null;
    } catch(e){
      print("Big error, load cameras $e");
      return null;
    }
  }
  Future<void> _loadPreferences() async{
    try{
      _prefs = await SharedPreferences.getInstance();
      _isLoadPreferences = true;
      print("Load preferences");
    } catch(e){
      print("Big error, load preferences: $e");
      return null;
    }
  }
  Future<void> _setupCameras() async {
    try{
      if(isReadyToSetup) {
        controller =
            CameraController(_cameras[cameraPosition.index], ResolutionPreset.medium);
        await controller.initialize();
<<<<<<< Updated upstream
        isReady = true;
      }
    } on CameraException catch(e){
        _showCameraException(e);
        return null;
=======
        _isSetupCameras = true;
        print("setup cameras");
      }
    } on CameraException catch(e){
      _showAndThrowCameraException(e);
      return null;
    } catch(e){
      print("Big error, setup cameras: $e");
      return null;
>>>>>>> Stashed changes
    }
  }
  Future<void> startVideoRecording() async{
    try{
<<<<<<< Updated upstream
      if(!isRecording) {
        String path = await _getVideoPath;
        await controller.startVideoRecording(path);
        isRecording = true;
        print("Cam: start");
      }
    } on CameraException catch(e){
      _showCameraException(e);
=======
      await _setupCameras();
      if(isReadyToRecord) {
        if(_prefs.getBool('vibration_start') != null) {
          if (_prefs.getBool('vibration_start')) {
            _vibrate(50);
          }
        }
        String path = await _getVideoPath;
        await controller.startVideoRecording(path);
        isRecording = true;
        print("Start recording");
        _informUICallback("Recording...");
      }
    } on CameraException catch(e){
      _showAndThrowCameraException(e);
      print("CameraExcp $e");
>>>>>>> Stashed changes
      return null;
    }
  }
  Future<void> pauseVideoRecording() async{
    try{
      if(!controller.value.isRecordingVideo){
        return null;
      }
        controller.pauseVideoRecording();
        _isPause = true;
    } on CameraException catch(e){
      print("pause video $e");
      _showAndThrowCameraException(e);
    } catch(e){
      print("Big error, pause video recording $e");
    }
  }
  Future<void> resumeVideoRecording() async{
    try{
      if(!controller.value.isRecordingVideo){
        return null;
      }
      if(_isPause){
        controller.resumeVideoRecording();
        _isPause = false;
      }
      else
        return null;
    } on CameraException catch(e){
      print("resume video $e");
      _showAndThrowCameraException(e);
    } catch(e){
      print("Big error, resume video recording $e");
    }
  }
  Future<void> stopVideoRecording() async {
    try{
      if (!controller.value.isRecordingVideo) {
        return null;
      }
      await controller.stopVideoRecording();
      isRecording = false;
    } on CameraException catch(e){
      _showCameraException(e);
    }
  }
  Future<String> get _getVideoPath async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/${DateTime.now()}.mp4';
  }
  void _showCameraException(CameraException e){
    print("${e.code} ${e.description}");
<<<<<<< Updated upstream
=======
    throw e;
  }
  void _vibrate(int duration) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: duration);
    }
    else {
      print("Vibrator no mounted on device");
      _showAndThrowCameraException(CameraException("Vibrator", "Vibrator no mounted on device"));
    }
>>>>>>> Stashed changes
  }
}
enum CameraPosition{
  back,
  front
}