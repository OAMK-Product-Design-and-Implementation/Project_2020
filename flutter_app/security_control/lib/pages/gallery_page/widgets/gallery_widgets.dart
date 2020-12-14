import 'dart:io';
import 'package:animations/animations.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:marquee/marquee.dart';

import 'package:flutter/material.dart';
import 'package:security_control/models/photo.dart';

class PhotosList extends StatelessWidget {
  final List<List> photos;

  PhotosList({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(8),
        child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              // A grid view with 3 items per row
              crossAxisCount: 2,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              return OpenContainer(
                  transitionType: ContainerTransitionType.fade,
                  closedElevation: 0.0,
                  closedColor: Theme.of(context).cardColor,
                  closedBuilder: (BuildContext _, VoidCallback openContainer) {
                    return Expanded(
                      child: Card(
                          elevation: 0,
                          child: Stack(fit: StackFit.expand, children: [
                            Container(
                                child: Image.file(photos[index][0],
                                    fit: BoxFit.fitWidth)),
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                color: Theme.of(context).cardColor,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    DateFormat("yyyy-MM-dd  HH:mm:ss")
                                        .format(photos[index][1])
                                        .toString(),
                                    style:
                                        Theme.of(context).textTheme.bodyText1,
                                  ),
                                ),
                              ),
                            )
                          ])),
                    );
                  },
                  openBuilder: (BuildContext _, VoidCallback openContainer) {
                    return Scaffold(
                        appBar: AppBar(
                          title: Text("Picture"),
                          actions: <Widget>[
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                //TODO delete picture

                                Navigator.pop(context, true);
                              },
                              tooltip: 'Delete',
                            )
                          ],
                        ),
                        body: Card(
                            child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Image.file(photos[index][0]),
                            ),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0,
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Filename:",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Expanded(
                                          child: Text(
                                        p.basename(photos[index][0].path),
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      )),
                                    ])),
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 8.0,
                                    left: 8.0,
                                    right: 8.0,
                                    bottom: 8.0),
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Date:",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                      Expanded(
                                          child: Text(
                                        DateFormat("yyyy-MM-dd  HH:mm:ss")
                                            .format(photos[index][1])
                                            .toString(),
                                        textAlign: TextAlign.end,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ))
                                    ])),
                          ],
                        )));
                  });
            }));
  }
}
