import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../camera_management.dart';

class CameraApp extends StatefulWidget {
  CameraApp(this.cam);
  final CameraManagement cam;
  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {

  @override
  Widget build(BuildContext context) {
    if(!widget.cam.isReady || !widget.cam.controller.value.isInitialized){
      return Container();
    } else{
      return AspectRatio(
      aspectRatio: widget.cam.controller.value.aspectRatio, // default: controller.value.aspectRatio
          child: CameraPreview(widget.cam.controller));
    }
    }
}
