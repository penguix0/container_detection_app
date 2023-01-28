import 'dart:convert';

import 'package:container_detection_app/main.dart';
import 'package:container_detection_app/models.dart';
import 'package:container_detection_app/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as Path;

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Future<dynamic> getData() async {
    // Check if the given ip and port are valid
    String ip = prefs.getString("serverIP") as String;
    int port = int.parse(prefs.getString("serverPort") as String);

    var response = await http.get(Uri.parse("http://$ip:$port/api/get_json"));

    // Check the status code
    if (response.statusCode != 200) {
      return "";
    }
    List<Widget> widgets = [];
    List containers = jsonDecode(response.body);
    for (var element in containers) {
      for (var container in element["objects"]) {
        String name = "ID unavailable";
        if (container["id"] != null) {
          if (container["id"].isNotEmpty) {
            List idParts = container["id"];
            name = idParts.join(" ");
          }
        }

        double confidence;
        try {
          confidence = double.parse(container["confidence"]);
        } on Exception catch (_) {
          confidence = 0.0;
        }
        Picture picture = objectbox.getPictureFromPath(
          objectbox.getShip("Default") as Ship,
          element["path"],
        );

        List<double> points = [];
        try {
          for (var point in container["points"]) {
            points.add(point);
          }
        } on Exception catch (_) {}

        int randomDigit = container["randomDigit"] as int;

        // If a placeholder image was returned
        if (picture.path == "") {
          continue;
        }
        widgets.add(
          ResultListItem(
            context: context,
            picture: picture,
            name: name,
            confidence: confidence,
            points: points,
            filename: element["path"],
            randomDigit: randomDigit,
          ),
        );
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Results"),
      ),
      body: FutureBuilder(
        future: getData(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          Widget child;
          if (snapshot.hasData) {
            child = ListView(
              padding: const EdgeInsets.all(8.0),
              shrinkWrap: true,
              children: snapshot.data,
            );
          } else if (snapshot.hasError) {
            child = Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ],
              ),
            );
          } else {
            child = Column(
              children: const [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text('Awaiting result...'),
                ),
              ],
            );
          }
          return child;
        },
      ),
      bottomNavigationBar: const MenuNavigationBar(),
    );
  }
}

class ResultListItem extends StatelessWidget {
  const ResultListItem({
    Key? key,
    required this.context,
    required this.picture,
    required this.name,
    required this.confidence,
    required this.points,
    required this.filename,
    required this.randomDigit,
  }) : super(key: key);

  final BuildContext context;
  final Picture picture;
  final String name;
  final double confidence;
  final List<double> points;
  final String filename;
  final int randomDigit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.network(
                height: 100,
                fit: BoxFit.cover,
                // The link consists of multiple parts
                // http://
                // prefs.getString("serverIP") = server ip address
                // :
                // prefs.getString("serverPort") = server port
                // /api/images/
                // Path.basenameWithoutExtension(filename) = for example "image"
                // randomDigit
                // Path.extension(filename) = for example ".jpg"

                "http://${prefs.getString("serverIP")}:${int.parse(prefs.getString("serverPort") as String)}/api/images/${Path.basenameWithoutExtension(filename)}${randomDigit.toString()}${Path.extension(filename)}?${DateTime.now().millisecondsSinceEpoch.toString()}",
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Confidence: $confidence%"),
              ],
            ),
            // Filler
            Expanded(
              child: Container(),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Bay ${picture.bay}"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
