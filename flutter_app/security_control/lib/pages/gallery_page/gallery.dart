import 'dart:io';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'widgets/gallery_widgets.dart';
import 'gallery_viewmodel.dart';
import 'package:security_control/models/photo.dart';

//Gallery page

class GalleryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<GalleryViewModel>.reactive(
      viewModelBuilder: () => GalleryViewModel(),
      //onModelReady: (model) => model.loadData(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(title: Text(model.appBarTitle)),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: PhotosList(photos:
                  model.getPhotos()
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
