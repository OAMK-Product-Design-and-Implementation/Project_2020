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
              Card(
                child: DropdownButton<Item>(
                  isExpanded: true,
                  hint: Text(model.dropDownButtonHint),
                  iconSize: model.dropDownIconSize,
                  value: model.selectedGallery,
                  onChanged: (Item value) {
                    model.setDropDownValue(value);
                  },
                  items: model.galleries.map((Item device) {
                    return DropdownMenuItem<Item>(
                      value: device,
                      child: Row(
                        children: <Widget>[
                          device.icon,
                          SizedBox(
                            width: 10.0,
                          ),
                          Text(
                            device.name,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
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
