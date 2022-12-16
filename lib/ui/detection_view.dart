// ignore_for_file: unnecessary_const

import 'package:camera/camera.dart';
import 'package:container_detection_app/size_config.dart';
import 'package:container_detection_app/ui/camera_view_singleton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

const double _kItemExtent = 32.0;

/// CameraApp is the Main Application.
class DetectionView extends StatefulWidget {
  /// Default Constructor
  const DetectionView({Key? key}) : super(key: key);

  @override
  State<DetectionView> createState() => _DetectionViewState();
}

class _DetectionViewState extends State<DetectionView> {
  late CameraController controller;
  int _selectedCamera = CameraViewSingleton.currentCamera;

  void initCamera() {
    controller = CameraController(
        CameraViewSingleton.cameras![_selectedCamera], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => Container(
              height: 216,
              padding: const EdgeInsets.only(top: 6.0),
              // The Bottom margin is provided to align the popup above the system navigation bar.
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              // Provide a background color for the popup.
              color: CupertinoColors.systemBackground.resolveFrom(context),
              // Use a SafeArea widget to avoid system overlaps.
              child: SafeArea(
                top: false,
                child: child,
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Stack(
      alignment: FractionalOffset.center,
      children: <Widget>[
        Positioned.fill(
          child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller)),
        ),
        Positioned(
            child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(children: [
                      SizedBox(
                        width: SizeConfig.blockSizeVertical! * 10,
                        height: SizeConfig.blockSizeVertical! * 10,
                        child: CupertinoButton.filled(
                          padding: EdgeInsets.all(10),
                          onPressed: () {
                            _showDialog(CupertinoPicker(
                                magnification: 1.22,
                                squeeze: 1.2,
                                useMagnifier: true,
                                itemExtent: _kItemExtent,
                                // This is called when selected item is changed.
                                onSelectedItemChanged: (int selectedItem) {
                                  setState(() {
                                    if (_selectedCamera != selectedItem) {
                                      _selectedCamera = selectedItem;
                                      CameraViewSingleton.currentCamera =
                                          selectedItem;
                                      initCamera();
                                    }
                                  });
                                },
                                children: List<Widget>.generate(
                                    CameraViewSingleton.cameras!.length,
                                    (int index) {
                                  return Center(
                                    child: Text(
                                      CameraViewSingleton.cameras![index].name,
                                    ),
                                  );
                                })));
                          },
                          child: Container(
                            alignment: Alignment.center,
                            decoration:
                                const BoxDecoration(shape: BoxShape.circle),
                            child: Icon(
                              size: SizeConfig.blockSizeVertical! * 5,
                              Icons.photo_camera,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.all(SizeConfig.blockSizeVertical! * 1),
                        child: SizedBox(
                          width: SizeConfig.blockSizeVertical! * 10,
                          height: SizeConfig.blockSizeVertical! * 10,
                          child: CupertinoButton.filled(
                            padding: EdgeInsets.all(10),
                            onPressed: () async {
                              // Take the Picture in a try / catch block. If anything goes wrong,
                              // catch the error.
                              try {
                                // Attempt to take a picture and get the file `image`
                                // where it was saved.
                                final image = await controller.takePicture();

                                if (!mounted) return;
                              } catch (e) {
                                // If an error occurs, log the error to the console.
                                print(e);
                              }
                              ;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration:
                                  const BoxDecoration(shape: BoxShape.circle),
                              child: Icon(
                                size: SizeConfig.blockSizeVertical! * 5,
                                Icons.camera,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]))))
      ],
    );
  }
}
