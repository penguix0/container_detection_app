/// Used to store some values about the device throughout using the app
import 'dart:ui';

import 'package:camera/camera.dart';

class CameraViewSingleton {
  static double? ratio;
  static Size? screenSize;
  static Size? inputImageSize;
  static Size? get actualPreviewSize =>
      Size(screenSize!.width, screenSize!.width * ratio!);
  static List<CameraDescription>? cameras;
}
