import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            const ListTile(
              title: Text('Feature 1'),
              subtitle: Text('Description of Feature 1'),
            ),
            const ListTile(
              title: Text('Feature 2'),
              subtitle: Text('Description of Feature 2'),
            ),
            const ListTile(
              title: Text('Feature 3'),
              subtitle: Text('Description of Feature 3'),
            ),
            TextButton(
              child: const Text(
                "Continue",
                style: TextStyle(fontSize: 25),
              ),
              onPressed: () async {
                print("pressed");
              },
            ),
          ],
        ),
      ),
    );
  }
}
