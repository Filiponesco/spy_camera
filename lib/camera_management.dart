import 'dart:io';
import 'package:camera/camera.dart';
import 'package:downloads_path_provider/downloads_path_provider.dart';
import 'package:path_provider/path_provider.dart';
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

  Future<void> setupCameras() async {
    try{
      if(!isReady){
        List<CameraDescription> cameras = await availableCameras();
        controller = CameraController(cameras[0], ResolutionPreset.medium);
        await controller.initialize();
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
        String path = await _getVideoPath;
        await controller.startVideoRecording(path);
        isRecording = true;
        print("Cam: START");
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
  }

}