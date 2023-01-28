import 'package:container_detection_app/Image/image.dart';
import 'package:container_detection_app/Recognition/recognition.dart';
import 'package:container_detection_app/services/objectbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides access to the ObjectBox Store throughout the app.
late ObjectBox objectbox;
int tabIndex = 0;
late SharedPreferences prefs;

Future<void> main() async {
  // This is required so ObjectBox can get the application directory
  // to store the database in.
  WidgetsFlutterBinding.ensureInitialized();

  objectbox = await ObjectBox.create();

  prefs = await SharedPreferences.getInstance();

  runApp(MaterialApp(
    theme: ThemeData(
      colorSchemeSeed: const Color.fromARGB(255, 39, 107, 0),
      useMaterial3: true,
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      /* dark theme settings */
    ),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    initialRoute: '/images',
    routes: {
      // When navigating to the "/" route, build the FirstScreen widget.
      '/images': (context) => const Images(),
      // When navigating to the "/second" route, build the SecondScreen widget.
      '/recognition': (context) => const Recognition(),
    },
  ));
}

class MainSubMenu extends StatelessWidget {
  const MainSubMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: const Icon(
        Icons.more_vert,
      ), //don't specify icon if you want 3 dot menu
      color: Theme.of(context).colorScheme.tertiaryContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.zero,
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Reset",
            style:
                TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
          ),
        ),
        PopupMenuItem<int>(
          value: 1,
          child: Text(
            "Adjust bays",
            style:
                TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
          ),
        ),
      ],
      onSelected: (item) {
        if (item == 0) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Delete Image Database?',
              ),
              content: const Text(
                'Are you sure you want to delete the current image database?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    'Cancel',
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inverseSurface,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context, 'OK');
                    objectbox.clearShipBox();
                    objectbox.putDefaultData();
                    objectbox.clearPictureBox();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
            ),
          );
        } else if (item == 1) {
          showDialog<String>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: const Text(
                'Adjust the amount of bays',
              ),
              content: const Text(
                'You can now type the amount of bays you wish to configure.',
              ),
              actions: <Widget>[
                FutureBuilder(
                  future: objectbox.getBays("Default"),
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    Widget child;
                    if (snapshot.hasData) {
                      child = TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Enter the amount",
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        initialValue: snapshot.data.toString(),
                        onFieldSubmitted: (bays) async {
                          int bayNum = int.parse(bays);
                          if (int.parse(bays) <= 0) {
                            bayNum = 1;
                          }
                          objectbox.setBays("Default", bayNum);
                        }, // Only numbers can be entered
                      );
                    } else {
                      child = Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      );
                    }
                    return child;
                  },
                )
              ],
            ),
          ).then((val) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Images()),
            );
          });
        }
      },
    );
  }
}
