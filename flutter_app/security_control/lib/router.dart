import 'package:auto_route/auto_route_annotations.dart';
import 'package:security_control/pages/drifters_page/drifters.dart';
import 'package:security_control/pages/drone_page/drone.dart';
import 'package:security_control/pages/gallery_page/gallery.dart';
import 'package:security_control/pages/home_page/home.dart';
import 'package:security_control/pages/login_page/login.dart';
import 'package:security_control/pages/pictures_page/pictures.dart';
import 'package:security_control/pages/sensors_page/sensors.dart';
import 'package:security_control/pages/settings_page/settings.dart';
import 'package:security_control/pages/settings_page/notification_settings.dart';
import 'package:security_control/pages/settings_page/server_settings.dart';
import 'package:security_control/pages/batterystation_page/batterystation.dart';

// You can re-generate the routes (if adding more here) by using:
//  $ flutter packages pub run build_runner build

@MaterialAutoRouter(routes: [
  MaterialRoute(page: LoginPage, initial: true),
  MaterialRoute(page: DriftersPage, initial: false),
  MaterialRoute(page: DronePage, initial: false),
  MaterialRoute(page: GalleryPage, initial: false),
  MaterialRoute(page: HomePage, initial: false),
  MaterialRoute(page: PicturesPage, initial: false),
  MaterialRoute(page: SensorsPage, initial: false),
  MaterialRoute(page: SettingsPage, initial: false),
  MaterialRoute(page: ServerSettingsPage, initial: false),
  MaterialRoute(page: NotificationSettingsPage, initial: false),
  MaterialRoute(page: BatteryStationPage, initial: false),
])
class $Router {}
