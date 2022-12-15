import 'package:camera/camera.dart';
import 'package:container_detection_app/ui/start_view.dart';
import 'package:flutter/material.dart';
import 'package:container_detection_app/ui/camera_view_singleton.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  CameraViewSingleton.cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: StartView());
  }
}
