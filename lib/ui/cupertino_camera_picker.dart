import 'package:flutter/cupertino.dart';
import 'package:container_detection_app/ui/camera_view_singleton.dart';

class CupertinoCameraPicker extends StatefulWidget {
  const CupertinoCameraPicker({super.key});

  @override
  State<CupertinoCameraPicker> createState() => _CupertinoCameraPickerState();
}

const double _kItemExtent = 32.0;

class _CupertinoCameraPickerState extends State<CupertinoCameraPicker> {
  int _selectedCamera = CameraViewSingleton.currentCamera;

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
    return CupertinoButton(
      padding: EdgeInsets.zero,
      // Display a CupertinoPicker with list of fruits.
      onPressed: () => _showDialog(
        CupertinoPicker(
          magnification: 1.22,
          squeeze: 1.2,
          useMagnifier: true,
          itemExtent: _kItemExtent,
          // This is called when selected item is changed.
          onSelectedItemChanged: (int selectedItem) {
            setState(() {
              _selectedCamera = selectedItem;
            });
          },
          children: List<Widget>.generate(CameraViewSingleton.cameras!.length,
              (int index) {
            return Center(
              child: Text(
                CameraViewSingleton.cameras![index].name,
              ),
            );
          }),
        ),
      ),
      // This displays the selected fruit name.
      child: Text(
        CameraViewSingleton.cameras![_selectedCamera].name,
        style: const TextStyle(
          fontSize: 22.0,
        ),
      ),
    );
  }
}
