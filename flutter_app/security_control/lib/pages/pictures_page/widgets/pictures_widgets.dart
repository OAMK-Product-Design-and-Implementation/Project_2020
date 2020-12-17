import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class LatestPicture extends StatelessWidget {
  final List<List> photos;

  LatestPicture({Key key, this.photos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: Image.file(photos[0][0]),
        ),
        Padding(
            padding:
                EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Filename:",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Expanded(
                      child: Text(
                    p.basename(photos[0][0].path),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyText1,
                  )),
                ])),
        Padding(
            padding:
                EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0, bottom: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Date:",
                    textAlign: TextAlign.start,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  Expanded(
                      child: Text(
                    DateFormat("yyyy-MM-dd  HH:mm:ss")
                        .format(photos[0][1])
                        .toString(),
                    textAlign: TextAlign.end,
                    style: Theme.of(context).textTheme.bodyText1,
                  ))
                ])),
      ],
    );
  }
}
