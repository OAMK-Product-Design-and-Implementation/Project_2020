import 'dart:io';

import 'package:security_control/router.gr.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/service_locator.dart';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:security_control/models/photo.dart';
import 'package:security_control/services/picture_service.dart';
import 'package:http/http.dart' as http;

class PicturesViewModel extends ChangeNotifier {
  NavigationService _navigationService = locator<NavigationService>();
  String _appBarTitle = "Pictures";
  String _pictureTitle = "Latest Picture";
  String _galleryTitle = "Gallery";
  String _buttonLabel = "Picture Gallery";
  double _buttonFontSize = 18.0;

  String get appBarTitle => _appBarTitle;
  String get pictureTitle => _pictureTitle;
  String get galleryTitle => _galleryTitle;
  String get buttonLabel => _buttonLabel;
  double get buttonFontSize => _buttonFontSize;

  void galleryButtonOnPressed() {
    _navigationService.navigateTo(Routes.galleryPage);
  }

  Future<List<List>> getLatestPhoto() =>
      locator<PictureService>().fetchPhotos(http.Client());

}
