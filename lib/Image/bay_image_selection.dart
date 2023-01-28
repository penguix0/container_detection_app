import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:container_detection_app/main.dart';
import 'package:container_detection_app/models.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:camera/camera.dart';

class BayImageSelection extends StatefulWidget {
  const BayImageSelection(
      {super.key, required this.screenTitle, required this.bayNumber});
  final String screenTitle;
  final int bayNumber;

  @override
  State<BayImageSelection> createState() {
    return _BayImageSelectionState();
  }
}

class _BayImageSelectionState extends State<BayImageSelection> {
  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;
  List<ContainerImage> images = [];
  bool cameraAvailable = false;

  void getImages() {
    // Get all images and make sure the paths exist
    List<ContainerImage> newImages = [];
    for (int i = 0;
        i <
            objectbox
                .getPictures(
                    objectbox.getShip("Default") as Ship, widget.bayNumber)
                .length;
        i++) {
      if (File(objectbox
              .getPictures(
                  objectbox.getShip("Default") as Ship, widget.bayNumber)[i]
              .path)
          .existsSync()) {
        newImages.add(
          ContainerImage(
            bayNumber: widget.bayNumber,
            path: objectbox
                .getPictures(
                    objectbox.getShip("Default") as Ship, widget.bayNumber)[i]
                .path,
            pictureID: objectbox
                .getPictures(
                    objectbox.getShip("Default") as Ship, widget.bayNumber)[i]
                .id,
            refresh: () => getImages(),
          ),
        );
      }
    }
    setState(() {
      images = newImages;
    });
  }

  Future<void> checkCameraAvailability() async {
    // Get a list of available cameras.
    // Get a list of available cameras.
    try {
      var cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        setState(() {
          cameraAvailable = true;
        });
      }
    } on CameraException {
      setState(() {
        cameraAvailable = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getImages();
    checkCameraAvailability();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.screenTitle,
          style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
        ),
      ),
      body: GestureDetector(
        onScaleStart: (details) {
          _baseScaleFactor = _scaleFactor;
        },
        onScaleUpdate: (details) {
          setState(
            () {
              _scaleFactor = _baseScaleFactor * details.scale;
            },
          );
        },
        child: GlowingOverscrollIndicator(
          color: Theme.of(context).colorScheme.secondaryContainer,
          axisDirection: AxisDirection.down,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            mainAxisSpacing: 0.0,
            crossAxisSpacing: 0.0,
            children: images,
          ),
        ),
      ),

      // A FAB consisiting of two buttons, one for picking images from the gallery and one for taking pictures
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          LayoutBuilder(builder: (context, constraints) {
            if (cameraAvailable) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FloatingActionButton(
                  // assigning a hero tag somehow fixes an error
                  heroTag: "camera",
                  onPressed: () {
                    getImage(widget.bayNumber, true);
                    // Refresh images
                    getImages();
                  },
                  child: const Icon(Icons.photo_camera),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: FloatingActionButton(
              heroTag: "gallery",
              onPressed: () {
                getImage(widget.bayNumber, false);
                // Refresh images
                getImages();
              },
              child: const Icon(Icons.collections),
            ),
          ),
        ],
      ), //fab(context, widget.bayNumber, () => getImages()),
    );
  }
}

class ContainerImage extends StatelessWidget {
  const ContainerImage({
    Key? key,
    required this.bayNumber,
    required this.path,
    required this.pictureID,
    required this.refresh,
  }) : super(key: key);

  final int bayNumber;
  final String path;
  final int pictureID;
  final Function refresh;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.file(
        File(
          path,
        ),
      ),
      // Create an image viewer
      onTap: () {
        showImageViewer(
          context,
          Image.file(
            File(path),
          ).image,
          doubleTapZoomable: true,
          swipeDismissible: true,
        );
      },
      // Show pop up menu
      onLongPress: () async {
        await showMenu(
          context: context,
          position: const RelativeRect.fromLTRB(
            100,
            0,
            10,
            0,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(25),
            ),
          ),
          color: Theme.of(context).colorScheme.secondaryContainer,
          items: [
            PopupMenuItem(
              value: 1,
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              onTap: () {
                // Delete the picture from the database, arguments: path, ship, bay
                objectbox.removePicture(pictureID);
                refresh();
              },
            ),
          ],
          elevation: 8.0,
        ).then(
          (value) {},
        );
      },
    );
  }
}

void getImage(int bayNumber, bool fromCamera) async {
  try {
    XFile? image;
    if (fromCamera == true) {
      // Step 1: Retrieve image from picker.
      image = await ImagePicker().pickImage(source: ImageSource.camera);
    } else {
      // Step 1: Retrieve image from picker
      image = await ImagePicker().pickImage(source: ImageSource.gallery);
    }

    // Step 2: Check for valid file.
    if (image == null) {
      debugPrint("Invalid image file");
      return;
    }

    // Get the user's current location
    double latitude = 0.0;
    double longitude = 0.0;

    // // Step 3: Get directory where we can duplicate selected file.
    // final Directory duplicateFileDir = await getApplicationDocumentsDirectory();
    // final String duplicateFilePath = duplicateFileDir.path;
    final String imageName = basename(image.path);

    // Save the image
    await GallerySaver.saveImage(image.path);

    var imagePath = image.path;

    // Step 5: Get the image height and width.
    var decodedImage =
        await decodeImageFromList(File(image.path).readAsBytesSync());
    var width = decodedImage.width;
    var height = decodedImage.height;

    var picture = Picture(
        imageName.toString(),
        bayNumber.toInt(),
        imagePath.toString(),
        width.toInt(),
        height.toInt(),
        json.encode([latitude, longitude]),
        json.encode([0.0, 0.0, 0.0]));
    picture.ship.target = objectbox.getShip("Default");
    await objectbox.addPicture(picture);
  } on PlatformException catch (e) {
    debugPrint('Failed to pick image: $e');
  }
}
