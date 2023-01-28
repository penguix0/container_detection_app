import 'package:objectbox/objectbox.dart';

@Entity()
class Ship {
  @Id()
  int id = 0;

  String name;

  int bays;

  @Backlink()
  final pictures = ToMany<Picture>();

  Ship(this.name, this.bays);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "bays": bays,
      };
  // Implement toString to make it easier to see information about
  // each picture when using the print statement.
  @override
  String toString() {
    return 'Ship{id: $id, name: $name, bay: $bays}';
  }

  Map<String, dynamic> toJson() => {"id": id, "name": name, "bays": bays};
}

@Entity()
class Picture {
  @Id()
  int id = 0;

  String name;
  int bay;
  String path;
  int width;
  int height;
  String location; // Stored as JSON
  String orientation; // Stored as JSON

  final ship = ToOne<Ship>();

  Picture(this.name, this.bay, this.path, this.width, this.height,
      this.location, this.orientation);

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "ship": ship,
        "bay": bay,
        "path": path,
        "width": width,
        "height": height,
        "location": location,
        "orientation": orientation,
      };
  // Implement toString to make it easier to see information about
  // each picture when using the print statement.
  @override
  String toString() {
    return 'Picture{id: $id, name: $name, ship: $ship, bay: $bay, path: $path, width: $width, height: $height, location: $location, orientation: $orientation}';
  }
}
