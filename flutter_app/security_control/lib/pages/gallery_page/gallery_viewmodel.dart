import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:security_control/services/picture_service.dart';
import 'package:security_control/services/service_locator.dart';

class GalleryViewModel extends ChangeNotifier {
  final String _appBarTitle = "Gallery";
  String _dropDownButtonHint = '  Select a device';
  static Item _selectedGallery;
  double _dropDownIconSize = 30.0;

  String get appBarTitle => _appBarTitle;

  String get dropDownButtonHint => _dropDownButtonHint;

  Item get selectedGallery => _selectedGallery;

  double get dropDownIconSize => _dropDownIconSize;

  List<Item> galleries = <Item>[
    const Item('Drone', Icon(Icons.airplanemode_active_rounded)),
    const Item('GoPiGo', Icon(Icons.directions_car_rounded)),
  ];

  void setDropDownValue(Item selected) {
    _selectedGallery = selected;
    notifyListeners();
  }

  List<List> getPhotos() => locator<PictureService>().picturesList;
}

class Item {
  const Item(this.name, this.icon);

  final String name;
  final Icon icon;
}
