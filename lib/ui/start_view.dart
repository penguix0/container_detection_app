import 'package:container_detection_app/ui/camera_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:container_detection_app/size_config.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:container_detection_app/ui/detection_view.dart';

class StartView extends StatelessWidget {
  const StartView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Init the size_config variables
    SizeConfig().init(context);
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: EdgeInsets.only(
              top: SizeConfig.blockSizeVertical! * 15,
              bottom: SizeConfig.blockSizeVertical! * 5),
          child: const AutoSizeText(
            "What's new?",
            style: TextStyle(fontSize: 40),
            maxLines: 2,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                size: 40,
                Icons.photo_camera,
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // ignore: prefer_const_literals_to_create_immutables
                    children: [
                      const AutoSizeText(
                        "Item 1",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      ),
                      const AutoSizeText(
                        "Example text",
                        style: TextStyle(fontSize: 20),
                        maxLines: 2,
                      ),
                    ],
                  ))
            ])),
        Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(
                Icons.photo_camera,
              ),
              const AutoSizeText(
                "Item 2",
                style: TextStyle(fontSize: 20),
                maxLines: 2,
              ),
            ])),
      ]),
      bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              bottom: SizeConfig.blockSizeVertical! * 10,
              left: SizeConfig.blockSizeHorizontal! * 10,
              right: SizeConfig.blockSizeHorizontal! * 10),
          child: Container(
            /// Scale the button automatically based on window size
            width: SizeConfig.blockSizeHorizontal! * 20,
            constraints: BoxConstraints(
                minWidth: SizeConfig.blockSizeHorizontal! * 10, maxWidth: 1000),
            height: SizeConfig.blockSizeVertical! * 10,
            child: CupertinoButton(
              color: CupertinoColors.activeBlue,
              borderRadius: BorderRadius.circular(25),
              child: const AutoSizeText(
                'Continue',
                style: TextStyle(fontSize: 25),
                maxLines: 1,
              ),
              onPressed: () => Navigator.of(context).push(CupertinoPageRoute(
                builder: (BuildContext context) {
                  return DetectionView();
                },
              )),
            ),
          )),
    );
  }
}
