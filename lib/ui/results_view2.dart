import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';




class ResultsView extends StatelessWidget {
  late final XFile image;
  late final http.Response response;

  ResultsView({
    required this.image,
    required this.response,
  });

@override
  Widget build(BuildContext context) {
    final imageData = decodeImageFromXfile(image.path);
    final imageProperties = getImageProperties(imageData);
    final imageWidth = imageProperties.width;
    final imageHeight = imageProperties.height;

    return Scaffold(
      body: Center(
        child: Image(
          image: MemoryImage(imageData),
          width: imageWidth,
          height: imageHeight,
        ),
      ),
    );
  }
}