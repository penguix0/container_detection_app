import 'package:camera/camera.dart';
import 'package:container_detection_app/ui/camera_view_singleton.dart';
import 'package:flutter/material.dart';

/// CameraApp is the Main Application.
class DetectionView extends StatefulWidget {
  /// Default Constructor
  const DetectionView({Key? key}) : super(key: key);

  @override
  State<DetectionView> createState() => _DetectionViewState();
}

class _DetectionViewState extends State<DetectionView> {
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    controller =
        CameraController(CameraViewSingleton.cameras![0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: CameraPreview(controller),
    );
  }
}
