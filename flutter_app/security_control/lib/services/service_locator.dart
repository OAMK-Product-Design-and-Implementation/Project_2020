import 'package:get_it/get_it.dart';
import 'package:security_control/services/navigation_service.dart';
import 'package:security_control/services/picture_service.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/gopigo_service.dart';
import 'package:security_control/services/server_sync_service.dart';
import 'package:security_control/services/messages_sync_service.dart';
import 'package:security_control/services/sensor_sync_service.dart';
import 'package:security_control/services/history_service.dart';

/*
  "Using get_it, class types can be registered in two ways.

  Factory: When you request an instance of the type from the service provider you'll get a new instance everytime.
  Good for registering ViewModels that need to run the same logic on start or that has to be new when the view is opened.

  Singleton: Singletons can be registered in two ways. Provide an implementation upon registration or provide a lamda
  that will be invoked the first time your instance is requested (LazySingleton). The Locator keeps a single instance of
  your registered type and will always return you that instance."

  Source for implementation:
  https://www.filledstacks.com/snippet/dependency-injection-in-flutter/
*/

GetIt locator = GetIt.instance;

Future setupLocator() async {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => PictureService());
  locator.registerLazySingleton(() => GoPiGoService());

  var instance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(instance);
  //locator.registerLazySingleton(() => LocalStorageService());
  var syncInstance = ServerSyncService();
  locator.registerSingleton<ServerSyncService>(syncInstance);

  var messagesSyncInstance = MessagesSyncService();
  locator.registerSingleton<MessagesSyncService>(messagesSyncInstance);
  var sensorSyncInstance = SensorSyncService();
  locator.registerSingleton<SensorSyncService>(sensorSyncInstance);
  //history
  var historySyncInstance = HistorySyncService();
  locator.registerSingleton<HistorySyncService>(historySyncInstance);
}
