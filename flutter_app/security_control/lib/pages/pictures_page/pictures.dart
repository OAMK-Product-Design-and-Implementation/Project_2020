import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'pictures_viewmodel.dart';
import 'widgets/pictures_widgets.dart';

//Pictures page

class PicturesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<PicturesViewModel>.reactive(
      viewModelBuilder: () => PicturesViewModel(),
      //onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(model.appBarTitle),
          actions: [
            IconButton(
              icon: Icon(Icons.photo),
              onPressed: () {
                model.galleryButtonOnPressed();
              },
              tooltip: "Gallery",
            )
          ],
        ),
        body: ListView(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      model.pictureTitle,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  FutureBuilder<List<List>>(
                    future: model.getLatestPhoto(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) print(snapshot.error);

                      return snapshot.hasData
                          ? LatestPicture(photos: snapshot.data)
                          : Center(
                              child: Padding(
                                  padding: EdgeInsets.only(bottom: 16.0),
                                  child: CircularProgressIndicator()));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
