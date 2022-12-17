import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ResultsView extends StatelessWidget {
  late final XFile image;
  late final Map<String, dynamic> json;

  ResultsView({
    required this.image,
    required this.json,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('arg1: $image, arg2: $json'),
      ),
    );
  }
}
