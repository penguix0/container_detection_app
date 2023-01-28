import 'dart:async';
import 'dart:io';

import 'package:container_detection_app/main.dart';
import 'package:flutter/material.dart';

class ServerWidget extends StatefulWidget {
  const ServerWidget({super.key});

  @override
  State<ServerWidget> createState() => _ServerWidgetState();
}

class _ServerWidgetState extends State<ServerWidget> {
  String databaseConnectionState = "unavailable";
  Color databaseConnectionStateColor = Colors.black;

  void checkServerConnectionState() {
    // Check if the given ip and port are valid
    String ip = prefs.getString("serverIP") as String;
    int port = int.parse(prefs.getString("serverPort") as String);

    // Ping the ip on the specified port
    Socket.connect(ip, port, timeout: const Duration(seconds: 5))
        .then((socket) {
      setState(() {
        databaseConnectionState = "online";
        databaseConnectionStateColor = Colors.green;
      });
      socket.destroy();
    }).catchError((error) {
      setState(() {
        databaseConnectionState = "offline";
        databaseConnectionStateColor = Colors.red;
      });
    });
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => checkServerConnectionState());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 0.0,
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Icon(
                Icons.phonelink,
                size: 36.0,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Database • ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  databaseConnectionState,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: databaseConnectionStateColor,
                  ),
                )
              ],
            ),
            // Filler
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, size: 32.0),
              ),
            )
          ],
        ),
      ),
    );
  }
}
