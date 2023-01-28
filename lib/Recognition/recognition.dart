import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:container_detection_app/Recognition/server_widget.dart';
import 'package:container_detection_app/main.dart';
import 'package:container_detection_app/models.dart';
import 'package:container_detection_app/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class Recognition extends StatefulWidget {
  const Recognition({super.key});

  @override
  State<Recognition> createState() => _RecognitionState();
}

class _RecognitionState extends State<Recognition> {
  String serverCheck = "";
  String zipPath = "";

  double infoElevation = 0.0;
  double serverInfoElevation = 0.0;

  Future<int> zipFiles() async {
    Directory? appDocDirectory = await getExternalStorageDirectory();
    var encoder = ZipFileEncoder();

    if (await File(appDocDirectory!.path).exists()) {
      File(appDocDirectory.path).delete();
    }

    encoder.create("${appDocDirectory.path}/files.zip");

    // Iterate through all bays and images in the bays
    for (int bay = 0; bay < await objectbox.getBays("Default"); bay++) {
      List<Picture> pictures =
          objectbox.getPictures(objectbox.getShip("Default") as Ship, bay);
      for (int picture = 0; picture < pictures.length; picture++) {
        // Add each image to the encoder
        encoder.addFile(File(pictures[picture].path));
      }
    }
    // Finally add the image database for the server to work with
    String dbPath = "${objectbox.store.directoryPath}/data.mdb";
    if (await File(dbPath).exists()) {
      encoder.addFile(File(dbPath));
    } else {
      debugPrint("Critical database not found at: $dbPath");
    }
    setState(() {
      zipPath = encoder.zipPath;
      debugPrint(zipPath);
    });
    encoder.close();

    return 0;
  }

  void uploadZip() async {
    // Check if the given ip and port are valid
    String ip = prefs.getString("serverIP") as String;
    int port = int.parse(prefs.getString("serverPort") as String);

    // Ping the ip on the specified port
    Socket.connect(ip, port, timeout: const Duration(seconds: 5))
        .then((socket) {
      setState(() {
        serverCheck = "Succes! Server alive.";
      });
      socket.destroy();
    }).catchError((error) {
      setState(() {
        serverCheck = "Exception on Socket $error";
        return;
      });
    });

    final bytes = await File(zipPath).readAsBytes();

    // Create a request to send to the server
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("http://$ip:$port/api/upload_zip"),
    );
    final multipartFile = http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: 'file.zip',
    );
    request.files.add(multipartFile);
    final response = await request.send();
    setState(() {
      serverCheck = response.toString();
    });
  }

  void requestStartDetection() async {
    // Check if the given ip and port are valid
    String ip = prefs.getString("serverIP") as String;
    int port = int.parse(prefs.getString("serverPort") as String);

    var response =
        await http.get(Uri.parse("http://$ip:$port/api/start_detection"));

    // Check the status code
    if (response.statusCode == 200) {
      // Request was successful
      debugPrint(response.body);
    } else {
      // Request failed
      debugPrint('Request failed with status: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const ServerWidget(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: infoElevation,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '''
Once you have finished collecting all images you may press the send button. The send button will send all images to your server for object recognition.''',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: serverInfoElevation,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: IpAddressTextField(),
                      ),
                    ),
                    const Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: PortTextField(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(serverCheck),
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await zipFiles();
                uploadZip();
                requestStartDetection();
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.surface,
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                child: Text("Send"),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: const MenuNavigationBar(),
    );
  }
}

class IpAddressTextField extends StatelessWidget {
  const IpAddressTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "IP-address:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        Flexible(
          child: TextField(
            onSubmitted: (value) async {
              await prefs.setString('serverIP', value);
            },
            decoration: InputDecoration(
              hintText: prefs.getString("serverIP"),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[0-9.]")),
              LengthLimitingTextInputFormatter(15),
              IpAddressInputFormatter()
            ],
          ),
        ),
      ],
    );
  }
}

class PortTextField extends StatelessWidget {
  const PortTextField({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          "Port:",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        Flexible(
          child: TextField(
            onSubmitted: (value) async {
              await prefs.setString('serverPort', value);
            },
            decoration: InputDecoration(
              hintText: prefs.getString("serverPort"),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
          ),
        ),
      ],
    );
  }
}

class IpAddressInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    int dotCounter = 0;
    var buffer = StringBuffer();
    String ipField = "";

    for (int i = 0; i < text.length; i++) {
      if (dotCounter < 4) {
        if (text[i] != ".") {
          ipField += text[i];
          if (ipField.length < 3) {
            buffer.write(text[i]);
          } else if (ipField.length == 3) {
            if (int.parse(ipField) <= 255) {
              buffer.write(text[i]);
            } else {
              if (dotCounter < 3) {
                buffer.write(".");
                dotCounter++;
                buffer.write(text[i]);
                ipField = text[i];
              }
            }
          } else if (ipField.length == 4) {
            if (dotCounter < 3) {
              buffer.write(".");
              dotCounter++;
              buffer.write(text[i]);
              ipField = text[i];
            }
          }
        } else {
          if (dotCounter < 3) {
            buffer.write(".");
            dotCounter++;
            ipField = "";
          }
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
