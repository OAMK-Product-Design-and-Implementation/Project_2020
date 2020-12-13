import 'package:flutter/cupertino.dart';
import 'package:security_control/pages/drifters_page/drifters.dart';
import 'package:security_control/services/gopigo_service.dart';
import 'package:stacked/stacked.dart';
import 'package:security_control/models/gopigo.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/services/server_sync_service.dart';

class DriftersViewModel extends BaseViewModel {
  var _serverSyncService = locator<ServerSyncService>();
  List _gopigolist = [];
  List _gopigoidlist = [2, 3, 16]; //TODO get this from service
  // @override
  //Future<List<GoPiGo>> futureToRun() => _gopigoService.getGoPiGoInfo();
  String _title = "GoPigo Patrollers";
  List get gopigolist => _gopigolist;
  String get title => _title;

  initialise() {
    // _serverSyncService.goPiGoListMapStream.listen((event) {
    //   _gopigolist = event.values.toList();
    //   notifyListeners();
    // });
    _gopigolist = _serverSyncService.goPiGoListMap.values.toList();
  }

  listener() async {
    //Start update listener
    print('DriftersViewModel Start update listener');
    _serverSyncService.goPiGoListMapStream.listen((event) {
      _gopigolist = event.values.toList();
      // _removeLoadingIndicator();
      if (_gopigolist.length < _gopigoidlist.length)
        _showLoadingIndicator();
      else
        notifyListeners();
    });
  }

  void _showLoadingIndicator() {
    print('loading indicator added');
    _gopigolist.add(GoPiGo.loading());
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _gopigolist.removeWhere((element) => element.id == -5);
    notifyListeners();
  }

  DriftersViewModel() {
    print('DriftersViewModel Constructor');
    if (!(_gopigolist.length > 0)) {
      _showLoadingIndicator();
    }
  }
}

class MapSectionViewModel extends DriftersViewModel {
  String _title = "Map Section ViewModel";
  String _mapPath = "lib/images/kulkureitti.png";
  double _boxHeight = 222.0;
  @override
  String get title => _title;
  String get map => _mapPath;
  double get height => _boxHeight;

  ///aligntment position calculated by (2*location/realsize)-1
  /// ie picture dimensions [1200 x 640]
  /// desired icon placement is at [400 x 312]
  ///  (2*400/1200)-1 = [-0,33] & (2*312/640)-1 = [-0,025]
  /// [Alignment(-0.33 , -0,025)] gets the correct position
  var _locationsMap = {
    '1': Alignment(0.289583, -0.783295),
    '2': Alignment(0.289583, 0.649152),
    '3': Alignment(-0.40395, 0.649152),
    '4': Alignment(-0.40395, -0.783295),
    'A': Alignment(-0.09375, -0.430744),
    'B': Alignment(0.24395, -0.13654),
    'C': Alignment(-0.0783, 0.26074),
    'D': Alignment(-0.45195, -0.08654),
    'A1': Alignment(0.14037, -0.430744),
    'B2': Alignment(0.14037, 0.26074),
    'C3': Alignment(-0.47395, 0.26074),
    'D4': Alignment(-0.47395, -0.430744),
    'Latauspaikka': Alignment(0.5625, -0.14506),
    'lost': Alignment(-0.95, -1),
    //TODO remove temporary positions
    'charge_station': Alignment(0.5625, -0.14506),
    'hall_00': Alignment(-0.45195, -0.08654),
  };

  get location => _locationsMap;
}

class StatusSectionViewModel extends DriftersViewModel {
  String _statusSectionTitle = "Active";
  String get statusSectionTitle => _statusSectionTitle;

  void updateDrifterBatterySetting(GoPiGo device, int newValue) {
    device.setBatteryLevel(newValue);
    notifyListeners();
  }
}

class GoPiGoSettingsViewModel extends BaseViewModel {
  GoPiGo _tempDevice = new GoPiGo.empty();
  GoPiGo _device;
  get name => _tempDevice.name;
  get batterylevel => _tempDevice.batterylevel;

  get id => _tempDevice.id;

  Object get device => _tempDevice;

  void sliderUpdate(int newValue) {
    _tempDevice.setBatteryLevel(newValue);
    notifyListeners();
  }

  void nameTextUpdate(String newText) {
    _tempDevice.setName(newText);
    notifyListeners();
  }

  void setdevice(GoPiGo device) {
    _tempDevice.setName(device.name);
    _tempDevice.setId(device.id);
    _tempDevice.setBatteryLevel(device.batterylevel);
    _device = device;
    print('setdevice ${device.name}');
  }

  void updateSettings() {
    print('GoPiGoSettingsViewModel/updateSettings');
    _device.setBatteryLevel(_tempDevice.batterylevel);
    _device.setName(_tempDevice.name);
  }
}
