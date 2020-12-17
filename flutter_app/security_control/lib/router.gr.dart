// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// ignore_for_file: public_member_api_docs

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'pages/batterystation_page/batterystation.dart';
import 'pages/drifters_page/drifters.dart';
import 'pages/drone_page/drone.dart';
import 'pages/gallery_page/gallery.dart';
import 'pages/home_page/home.dart';
import 'pages/login_page/login.dart';
import 'pages/pictures_page/pictures.dart';
import 'pages/sensors_page/sensors.dart';
import 'pages/settings_page/notification_settings.dart';
import 'pages/settings_page/server_settings.dart';
import 'pages/settings_page/settings.dart';

class Routes {
  static const String loginPage = '/';
  static const String driftersPage = '/drifters-page';
  static const String dronePage = '/drone-page';
  static const String galleryPage = '/gallery-page';
  static const String homePage = '/home-page';
  static const String picturesPage = '/pictures-page';
  static const String sensorsPage = '/sensors-page';
  static const String settingsPage = '/settings-page';
  static const String serverSettingsPage = '/server-settings-page';
  static const String notificationSettingsPage = '/notification-settings-page';
  static const String batteryStationPage = '/battery-station-page';
  static const all = <String>{
    loginPage,
    driftersPage,
    dronePage,
    galleryPage,
    homePage,
    picturesPage,
    sensorsPage,
    settingsPage,
    serverSettingsPage,
    notificationSettingsPage,
    batteryStationPage,
  };
}

class Router extends RouterBase {
  @override
  List<RouteDef> get routes => _routes;
  final _routes = <RouteDef>[
    RouteDef(Routes.loginPage, page: LoginPage),
    RouteDef(Routes.driftersPage, page: DriftersPage),
    RouteDef(Routes.dronePage, page: DronePage),
    RouteDef(Routes.galleryPage, page: GalleryPage),
    RouteDef(Routes.homePage, page: HomePage),
    RouteDef(Routes.picturesPage, page: PicturesPage),
    RouteDef(Routes.sensorsPage, page: SensorsPage),
    RouteDef(Routes.settingsPage, page: SettingsPage),
    RouteDef(Routes.serverSettingsPage, page: ServerSettingsPage),
    RouteDef(Routes.notificationSettingsPage, page: NotificationSettingsPage),
    RouteDef(Routes.batteryStationPage, page: BatteryStationPage),
  ];
  @override
  Map<Type, AutoRouteFactory> get pagesMap => _pagesMap;
  final _pagesMap = <Type, AutoRouteFactory>{
    LoginPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => LoginPage(),
        settings: data,
      );
    },
    DriftersPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DriftersPage(),
        settings: data,
      );
    },
    DronePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => DronePage(),
        settings: data,
      );
    },
    GalleryPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => GalleryPage(),
        settings: data,
      );
    },
    HomePage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => HomePage(),
        settings: data,
      );
    },
    PicturesPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => PicturesPage(),
        settings: data,
      );
    },
    SensorsPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SensorsPage(),
        settings: data,
      );
    },
    SettingsPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => SettingsPage(),
        settings: data,
      );
    },
    ServerSettingsPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => ServerSettingsPage(),
        settings: data,
      );
    },
    NotificationSettingsPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => NotificationSettingsPage(),
        settings: data,
      );
    },
    BatteryStationPage: (data) {
      return MaterialPageRoute<dynamic>(
        builder: (context) => BatteryStationPage(),
        settings: data,
      );
    },
  };
}
