import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:container_detection_app/models.dart';
import 'package:container_detection_app/objectbox.g.dart'; // created by `flutter pub run build_runner build`

/// Provides access to the ObjectBox Store throughout the app.
///
/// Create this in the apps main function.
class ObjectBox {
  /// The Store of this app.
  late final Store store;

  // Keeping reference to avoid Admin getting closed.
  // ignore: unused_field
  late final Admin _admin;

  /// Two Boxes: one for Ships, one for Pictures.
  late final Box<Ship> shipBox;
  late final Box<Picture> pictureBox;

  ObjectBox._create(this.store) {
    // Optional: enable ObjectBox Admin on debug builds.
    // https://docs.objectbox.io/data-browser
    // if (Admin.isAvailable()) {
    //   // Keep a reference until no longer needed or manually closed.
    //   _admin = Admin(store);
    // }

    shipBox = Box<Ship>(store);
    pictureBox = Box<Picture>(store);

    // Add a default user if the box is empty.
    if (shipBox.isEmpty()) {
      putDefaultData();
      debugPrint("shipBox empty! inserting default user data");
    }
  }

  /// Create an instance of ObjectBox to use throughout the app.
  static Future<ObjectBox> create() async {
    // Note: on desktop systems this returns the users documents directory,
    // so make sure to create a unique sub-directory.
    // On mobile using the default (not supplying any directory) is typically
    // fine, as apps have their own directory structure.
    final documentsDirectory = await getApplicationDocumentsDirectory();
    String name = "data";
    // Check if there is already a database and if there is, delete it.
    bool exists =
        await Directory(p.join(documentsDirectory.path, name)).exists();
    bool deleteDB = false;
    // ignore: dead_code
    if (exists && deleteDB) {
      debugPrint("Deleting database");
      Directory(p.join(documentsDirectory.path, name))
          .deleteSync(recursive: true);
    }
    final databaseDirectory = p.join(documentsDirectory.path, "data");
    debugPrint("Opening ObjectBox store from custom path: $databaseDirectory");
    // Future<Store> openStore() {...} is defined in the generated objectbox.g.dart
    final store = await openStore(directory: databaseDirectory);
    return ObjectBox._create(store);
  }

  void putDefaultData() {
    Ship ship = Ship("Default", 12);

    // When the Task is put, its Tag will automatically be put into the Tag Box.
    // Both ToOne and ToMany automatically put new Objects when the Object owning them is put.
    shipBox.put(ship, mode: PutMode.insert);
  }

  Ship? getShip(String name) {
    final query = shipBox.query(Ship_.name.equals(name)).build();
    List<Ship> ships = query.find();
    if (ships.isNotEmpty) {
      return ships[0];
    }
    return null;
  }

  Future<int> getBays(String name) async {
    // Query for all tasks, sorted by their date.
    // https://docs.objectbox.io/queries
    final query = shipBox.query(Ship_.name.equals(name)).build();
    List<Ship> ships = query.find();
    if (ships.isNotEmpty) {
      return ships[0].bays;
    }
    return 10;
  }

  void setBays(String name, int bays) {
    // Either updates the current value or creates a new ship
    final ship = Ship(name, bays);
    ship.id = getShip(name)!.id;
    shipBox.put(ship, mode: PutMode.update);
  }

  List<Picture> getPictures(Ship ship, int bay) {
    // Query for all tasks, sorted by their date.
    // https://docs.objectbox.io/queries
    ToMany<Picture> pictures = ship.pictures;
    List<Picture> picturesInShip = [];

    for (int picture = 0; picture < pictures.length; picture++) {
      if (pictures[picture].bay == bay) {
        picturesInShip.add(pictures[picture]);
      }
    }

    return picturesInShip;
  }

  Picture getPictureFromPath(Ship ship, String path) {
    ToMany<Picture> pictures = ship.pictures;
    for (int picture = 0; picture < pictures.length; picture++) {
      String filename = basename(pictures[picture].path);

      if (filename == path) {
        return pictures[picture];
      }
    }
    return Picture("Placeholder", -1, "", 0, 0, "", "");
  }

  void clearShipBox() {
    shipBox.removeAll();
  }

  void clearPictureBox() {
    pictureBox.removeAll();
  }

  void removePicture(int id) {
    pictureBox.remove(id);
  }

  Future<int> addPicture(Picture picture) async {
    // If the picture id does not yet exist add it to the database
    pictureBox.put(picture, mode: PutMode.insert);
    return 1;
  }
}
//   void saveTask(Task? task, String text, Tag tag) {
//     if (text.isEmpty) {
//       // Do not allow an empty task text.
//       // A real app might want to display an UI hint about that.
//       return;
//     }
//     if (task == null) {
//       // Add a new task (task id is 0).
//       task = Task(text);
//     } else {
//       // Update an existing task (task id is > 0).
//       task.text = text;
//     }
//     // Set or update the target of the to-one relation to Tag.
//     task.tag.target = tag;
//     taskBox.put(task);
//     debugPrint('Saved task ${task.text} with tag ${task.tag.target!.name}');
//   }

//   void removeTask(int taskId) {
//     taskBox.remove(taskId);
//   }

//   int addTag(String name) {
//     if (name.isEmpty) {
//       // Do not allow an empty tag name.
//       // A real app might want to display an UI hint about that.
//       return -1;
//     }
//     // Do not allow adding a tag with an existing name.
//     // A real app might want to display an UI hint about that.
//     final existingTags = tagBox.getAll();
//     for (var existingTag in existingTags) {
//       if (existingTag.name == name) {
//         return -1;
//       }
//     }

//     final newTagId = tagBox.put(Tag(name));
//     debugPrint("Added tag: ${tagBox.get(newTagId)!.name}");

//     return newTagId;
//   }
// }
