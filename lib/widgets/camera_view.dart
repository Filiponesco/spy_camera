import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';

class CameraApp extends StatefulWidget {
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {

  Future<void> _setupCameras() async {
    List<CameraDescription> cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.medium);
    await controller.initialize();
    if (!mounted) {
      return;
    }
    setState(() {
      _isReady = true;
    });
  }
  Future<void> _startVideoRecording(filePath) async{
    await controller.startVideoRecording(filePath);
    setState(() {
      _isRecording = true;
    });
  }
  Future<void> _stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }
    setState(() {
      _isRecording = false;
    });
    await controller.stopVideoRecording();
  }
  Future<String> get _getVideoPath async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/media';
    await Directory(dirPath).create(recursive: true);
    return '$dirPath/${"timestamp"}.mp4';
  }
  CameraController controller;
  bool _isReady = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _setupCameras();
  }
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(!_isReady || !controller.value.isInitialized){
      return Container();
    } else{
      return AspectRatio(
          aspectRatio: 1, // default: controller.value.aspectRatio
          child: CameraPreview(controller));
    }
    }
}
