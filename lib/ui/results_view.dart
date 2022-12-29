import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ResultsView extends StatelessWidget {
  late final XFile image;
  late final http.Response response;

  ResultsView({
    required this.image,
    required this.response,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Image.file(File(image.path))),
    );
  }
}
