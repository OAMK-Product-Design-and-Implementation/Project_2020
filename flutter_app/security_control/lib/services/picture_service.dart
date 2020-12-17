import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:security_control/models/photo.dart';
import 'package:security_control/services/local_storage_service.dart';
import 'package:security_control/services/service_locator.dart';

class PictureService {
  static PictureService _instance;

  static List<Directory> _externalStorageDirectories;
  static Directory _picturesDirectory;
  String _debugTag = "(TRACE) PictureService:";

  LocalStorageService _localStorageService = locator<LocalStorageService>();

  List<List> _pictureList = List();

  List<List> get picturesList => _pictureList;

  static Future<PictureService> getInstance() async {
    if (_instance == null) {
      _instance = PictureService();
    }

    if (_externalStorageDirectories == null) {
      _externalStorageDirectories =
          await getExternalStorageDirectories(type: StorageDirectory.pictures);
    }

    // print("" + _externalStorageDirectories.toString());
    // /storage/emulated/0/Android/data/com.oamkprojects.security_control/files/Pictures
    _picturesDirectory =
        Directory("/storage/emulated/0/SecurityControl/Pictures");
    return _instance;
  }

  Future<List<List>> fetchPhotos(http.Client client) async {
    // Returns a list of all photos available for viewing
    // Internally, fetches available photos from local storage and queries
    //    server for any new photos (by timestamp)
    String _serverAddress = _localStorageService.serverAddress.getValue();

    var status = await Permission.storage.status;
    if (status.isUndetermined) {
      // You can request multiple permissions at once.
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      print(statuses[
          Permission.storage]); // it should print PermissionStatus.granted
    }

    // First get available photos from _picturesDirectory (remember to check type):
    // Note: Returns empty list if nothing there
    await _picturesDirectory.create(recursive: true);
    //await File(_picturesDirectory.path + "/" + "test.jpg").create();

    // _pictureList = List<FileSystemEntity>();
    _pictureList.clear();

    List<FileSystemEntity> _fileList = await _picturesDirectory.list().toList();

    String _query;

    DateTime _latestPictureDate = DateTime.parse("2000-01-01 00:00:00");
    DateFormat _dateFormatWrite = DateFormat("yyyyMMddTHHmmss");
    //print(_debugTag + _dateFormatWrite.format(_latestPictureDate));

    if (_fileList.length == 0) {
      _query = "http://" +
          _serverAddress +
          "/api/imagesbytime/get/2000-01-01 00:00:00";
    } else {
      for (var f in _fileList) {
        if (f is File) {
          print(_debugTag + (f).path.toString());

          // If file is photo, add to returnable list:
          if (p.extension(f.path) == ".jpg") {
            String filename = p.basenameWithoutExtension(f.path).toString();

            _pictureList.add([
              f,
              DateTime.parse(
                  filename.substring(filename.length - 15, filename.length))
            ]);

            DateTime dateOfFile = DateTime.parse(
                filename.substring(filename.length - 15, filename.length));

            // If date of file is later than our latest, update latestDate:
            if (dateOfFile.isAfter(_latestPictureDate)) {
              _latestPictureDate = dateOfFile;
            }
          }
        }
      }
      print(
          _debugTag + "Latest picture date: " + _latestPictureDate.toString());
      _query = "http://" +
          _serverAddress +
          "/api/imagesbytime/get/" +
          _latestPictureDate.toString();
    }

    // Then query new photos based on latest photo name/date:
    var response;
    List imageJson;

    try {
      response = await http.get(_query);
    } catch (err) {
      print(_debugTag + "ERROR: could not fetch images: " + err.toString());
    } finally {
      print(_debugTag + "Got pictures from server: " + response.body);
    }

    if (!(response == null)) {
      try {
        imageJson = jsonDecode(response.body);
      } catch (err) {
        print(_debugTag +
            "ERROR: Could not process images from server response: " +
            err.toString());
      }
    }

    if (imageJson is List) {
      for (var itemList in imageJson) {
        // itemList[0] == deviceName
        // itemList[1] == filename
        // itemList[2] == deviceId
        // itemList[3] == Date [yyyy-mm-dd hh:mm:ss]
        // itemList[4] == data in encoded 64 format

        Uint8List bytes = base64.decode(itemList[4]);
        var status = await Permission.storage.status;
        if (status.isUndetermined) {
          // You can request multiple permissions at once.
          Map<Permission, PermissionStatus> statuses = await [
            Permission.storage,
          ].request();
          print(statuses[
              Permission.storage]); // it should print PermissionStatus.granted
        }
        // Filename: "deviceName_datetimeNowInMillis_DateTimeFromServer.jpg"
        File newImage = await File(_picturesDirectory.path +
                "/" +
                itemList[0] +
                "_" +
                DateTime.now().millisecondsSinceEpoch.toString() +
                "_" +
                _dateFormatWrite
                    .format(DateTime.parse(itemList[3]))
                    .toString() +
                ".jpg")
            .create();

        if (bytes.length != 0) {
          _pictureList.add([
            await newImage.writeAsBytes(bytes),
            DateTime.parse(itemList[3])
          ]);
        }
      }
    }

    _pictureList = _pictureList.reversed.toList();
    _pictureList.sort((a, b) {
      var adate = a[1]; //before -> var adate = a.expiry;
      var bdate = b[1]; //var bdate = b.expiry;
      return -adate.compareTo(bdate);
    });
    return _pictureList; // Reversed to get latest first I hope
  }

  List<Photo> parsePhotos(String responseBody) {
    final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();

    return parsed.map<Photo>((json) => Photo.fromJson(json)).toList();
  }
}
