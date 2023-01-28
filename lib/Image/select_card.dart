import 'package:container_detection_app/Image/bay_image_selection.dart';
import 'package:flutter/material.dart';

class SelectCard extends StatefulWidget {
  const SelectCard({Key? key, required this.cardIcon, required this.bayNumber})
      : super(key: key);
  final IconData cardIcon;
  final int bayNumber;

  @override
  State<SelectCard> createState() => _SelectCardState();
}

class _SelectCardState extends State<SelectCard> {
  double cardPadding = 0.0;
  double cardElevation = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: GestureDetector(
        onTapDown: (details) {
          setState(() {
            cardElevation = 5.0;
          });
        },
        onTapCancel: () {
          setState(() {
            cardElevation = 0.0;
          });
        },
        onTapUp: (details) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BayImageSelection(
                screenTitle: "Bay ${widget.bayNumber}",
                bayNumber: widget.bayNumber,
              ),
            ),
          );
        },
        onLongPress: () {
          setState(() {
            cardPadding = 8.0;
          });
        },
        onLongPressCancel: () {
          setState(() {
            cardElevation = 0.0;
          });
        },
        onLongPressUp: () {
          setState(() {
            cardPadding = 0.0;
          });
        },
        child: AnimatedPadding(
          padding: EdgeInsets.all(cardPadding),
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Card(
            elevation: cardElevation,
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Icon(
                    widget.cardIcon,
                    size: 50.0,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Bay ${widget.bayNumber}"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
