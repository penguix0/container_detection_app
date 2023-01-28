import 'package:container_detection_app/Image/select_card.dart';
import 'package:container_detection_app/main.dart';
import 'package:container_detection_app/navigation_bar.dart';
import 'package:flutter/material.dart';

class Images extends StatefulWidget {
  const Images({super.key});

  @override
  State<Images> createState() => _ImagesState();
}

class _ImagesState extends State<Images> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Bay Selector",
          style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
        ),
        actions: const <Widget>[
          MainSubMenu(),
        ],
      ),
      body: const CardView(),
      bottomNavigationBar: const MenuNavigationBar(),
    );
  }
}

class CardView extends StatefulWidget {
  const CardView({
    Key? key,
  }) : super(key: key);

  @override
  State<CardView> createState() => _CardViewState();
}

class _CardViewState extends State<CardView> {
  double padding = 4.0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: objectbox.getBays("Default"),
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          Widget children;
          if (snapshot.hasData) {
            children = Padding(
              padding: EdgeInsets.all(padding),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: padding,
                mainAxisSpacing: padding,
                shrinkWrap: true,
                children: [
                  for (int i = 0; i < snapshot.data!; i++)
                    SelectCard(cardIcon: Icons.folder, bayNumber: i)
                ],
              ),
            );
          } else {
            children = CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary);
          }
          return children;
        });
  }
}
