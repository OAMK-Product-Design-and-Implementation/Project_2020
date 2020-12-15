import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:security_control/models/gopigo.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/services/server_sync_service.dart';

class DriftersViewModel extends BaseViewModel {
  var _serverSyncService = locator<ServerSyncService>();
  List _gopigolist = [];
  String _title = "GoPigo Patrollers";
  List get gopigolist => _gopigolist;
  String get title => _title;

  initalise() {
    _serverSyncService.updateGoPiGoIDlist();
  }

  listener() async {
    //Start update listener
    print('DriftersViewModel Start update listener');
    _serverSyncService.goPiGoListMapStream.listen((event) {
      _gopigolist = event.values.toList();
      notifyListeners();
    });
  }

  void _showLoadingIndicator() {
    print('loading indicator added');
    _gopigolist.add(GoPiGo.loading());
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
  String _mapPath = "lib/images/gopigorata.png";
  double _boxHeight = 222.0;
  @override
  String get title => _title;
  String get map => _mapPath;
  double get height => _boxHeight;

  /// aligntment position calculated by (2*location/realsize)-1
  /// ie picture dimensions [1200 x 640]
  /// desired icon placement is at [400 x 312]
  ///  (2*400/1200)-1 = [-0,33] & (2*312/640)-1 = [-0,025]
  /// [Alignment(-0.33 , -0,025)] gets the correct position
  var _locationsMap = {
    '0': Alignment(0.2204861, 0.68681),
    '1': Alignment(0.0434, 0.8926),
    '2': Alignment(-0.2325694, -0.0755627),
    '3': Alignment(-0.2325694, -0.7808),
    '4': Alignment(-0.0086, -0.875466),
    '5': Alignment(0.2204861, -0.35530),
    '6': Alignment(0.2204861, 0.31993),
    '7': Alignment(0.0434, 0.44639),
    '8': Alignment(-0.7850, 0.31993),
    '9': Alignment(-0.7850, -0.7808),
    '10': Alignment(0.72340, -0.7808),
    '11': Alignment(0.79340, 0.31993),
    'lost': Alignment(-0.80, -1),
  };

  get location => _locationsMap;
}

class StatusSectionViewModel extends DriftersViewModel {
  String _statusSectionTitle = "Active";
  String get statusSectionTitle => _statusSectionTitle;

  void updateDrifterBatterySetting(GoPiGo device, double newValue) {
    device.setBatteryLimit(newValue);
    notifyListeners();
  }
}

class GoPiGoSettingsViewModel extends BaseViewModel {
  GoPiGo _tempDevice = new GoPiGo.empty();
  GoPiGo _device;
  get name => _tempDevice.name;

  double get batterylimit => _tempDevice.batterylevel.lowerLimit;

  get id => _tempDevice.id;

  Object get device => _tempDevice;

  batterySlider(BuildContext context, device) {
    Widget batteryLimitSlider = Slider(
      value: batterylimit,
      min: 0,
      max: 100,
      divisions: 100,
      label: batterylimit.round().toString(),
      onChanged: (double value) {
        sliderUpdate('battery', 0, value);
      },
    );
    return batteryLimitSlider;
  }

  void sliderUpdate(String type, double upper, double lower) {
    switch (type) {
      case 'battery':
        _tempDevice.setBatteryLimit(lower);
        break;
    }
    notifyListeners();
  }

  void nameTextUpdate(String newText) {
    _tempDevice.setName(newText);
    notifyListeners();
  }

  void setdevice(GoPiGo device) {
    _tempDevice.setName(device.name);
    _tempDevice.setId(device.id);
    _tempDevice.setCurrentBatteryLevel(device.batterylevel.current);
    _tempDevice.setBatteryLimit(device.batterylevel.lowerLimit);
    _device = device;
    print('setdevice ${device.name}');
  }

  void updateSettings() {
    print('GoPiGoSettingsViewModel/updateSettings');
    _device.setName(_tempDevice.name);
    _device.setNewLimits(_tempDevice.batterylevel.lowerLimit, _tempDevice.id);
  }
}
