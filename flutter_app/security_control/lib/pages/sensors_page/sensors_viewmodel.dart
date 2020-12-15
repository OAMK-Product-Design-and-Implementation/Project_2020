import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:security_control/models/ruuvitag.dart';
import 'package:security_control/services/service_locator.dart';
import 'package:security_control/services/sensor_sync_service.dart';

class SensorsViewModel extends BaseViewModel {
  var _sensorSyncService = locator<SensorSyncService>();
  List _ruuvitaglist = [];
  String _title = "Sensors";
  String get title => _title;
  List get ruuvitaglist => _ruuvitaglist;

  initialise() {
    print('SensorsViewModel initialise');
    _sensorSyncService.updateRuuvitagIDlist();
  }

  listener() async {
    print('SensorsViewModel Start update listener');
    _sensorSyncService.ruuviTagListMapStream.listen((event) {
      _ruuvitaglist = event.values.toList();
      notifyListeners();
    });
  }

  void _showLoadingIndicator() {
    print('loading indicator added');
    _ruuvitaglist.add(RuuviTag.loading());
    notifyListeners();
  }

  SensorsViewModel() {
    print('SensorsViewModel Constructor');
    if (!(_ruuvitaglist.length > 0)) {
      print("force get ruuvitag info");
      _showLoadingIndicator();
    }
  }
}

class StatusSectionViewModel extends SensorsViewModel {
  String _statusSectionTitle = "RuuviTags";
  String get statusSectionTitle => _statusSectionTitle;

  void updateSensorMeasurements(RuuviTag device, double newBattery,
      double newTemperature, double newPressure, double newHumidity) {
    device.setCurrentBatteryLevel(newBattery);
    device.setCurrentTemperature(newTemperature);
    device.setCurrentPressure(newPressure);
    device.setCurrentHumidity(newHumidity);
    notifyListeners();
  }
}

class RuuviTagSettingsViewModel extends BaseViewModel {
  RuuviTag _tempDevice = new RuuviTag();
  RuuviTag _device;
  get name => _tempDevice.name;
  get id => _tempDevice.id;

  double get batterylimit => _tempDevice.batterylevel.lowerLimit;
  double get tempLowerLimit => _tempDevice.temperature.lowerLimit;
  double get tempUpperLimit => _tempDevice.temperature.upperLimit;
  double get humiLowerLimit => _tempDevice.humidity.lowerLimit;
  double get humiUpperLimit => _tempDevice.humidity.upperLimit;
  double get presLowerLimit => _tempDevice.pressure.lowerLimit;
  double get presUpperLimit => _tempDevice.pressure.upperLimit;

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

  temperatureRangeSlider(BuildContext context, device) {
    Widget temperatureLimitSlider = RangeSlider(
        values: RangeValues(tempLowerLimit, tempUpperLimit),
        min: -100,
        max: 100,
        divisions: 200,
        labels: RangeLabels(
          tempLowerLimit.round().toString(),
          tempUpperLimit.round().toString(),
        ),
        onChanged: (RangeValues values) {
          sliderUpdate('temperature', values.end, values.start);
        });
    return temperatureLimitSlider;
  }

  humidityRangeSlider(BuildContext context, device) {
    Widget humidityLimitSlider = RangeSlider(
        values: RangeValues(humiLowerLimit, humiUpperLimit),
        min: 0,
        max: 100,
        divisions: 100,
        labels: RangeLabels(
          humiLowerLimit.round().toString(),
          humiUpperLimit.round().toString(),
        ),
        onChanged: (RangeValues values) {
          sliderUpdate('humidity', values.end, values.start);
        });
    return humidityLimitSlider;
  }

  pressureRangeSlider(BuildContext context, device) {
    Widget pressureLimitSlider = RangeSlider(
        values: RangeValues(presLowerLimit, presUpperLimit),
        min: 0,
        max: 1500,
        divisions: 150,
        labels: RangeLabels(
          presLowerLimit.round().toString(),
          presUpperLimit.round().toString(),
        ),
        onChanged: (RangeValues values) {
          sliderUpdate('pressure', values.end, values.start);
        });
    return pressureLimitSlider;
  }

  void sliderUpdate(String type, double upper, double lower) {
    switch (type) {
      case 'battery':
        _tempDevice.setBatteryLimit(lower);
        break;
      case 'temperature':
        _tempDevice.setTemperatureLimits(upper, lower);
        break;
      case 'humidity':
        _tempDevice.setHumidityLimits(upper, lower);
        break;
      case 'pressure':
        _tempDevice.setPressureLimits(upper, lower);
        break;
    }
    notifyListeners();
  }

  void nameTextUpdate(String newText) {
    _tempDevice.setName(newText);
    notifyListeners();
  }

  void setdevice(RuuviTag device) {
    _tempDevice.setName(device.name);
    _tempDevice.setId(device.id);
    _tempDevice.setCurrentBatteryLevel(device.batterylevel.current);
    _tempDevice.setCurrentTemperature(device.temperature.current);
    _tempDevice.setCurrentHumidity(device.humidity.current);
    _tempDevice.setCurrentPressure(device.pressure.current);
    _tempDevice.setBatteryLimit(device.batterylevel.lowerLimit);
    _tempDevice.setTemperatureLimits(
        device.temperature.upperLimit, device.temperature.lowerLimit);
    _tempDevice.setHumidityLimits(
        device.humidity.upperLimit, device.humidity.lowerLimit);
    _tempDevice.setPressureLimits(
        device.pressure.upperLimit, device.pressure.lowerLimit);
    _device = device;
    print('setdevice ${device.name}');
  }

  //POST NEW LIMITS
  void updateSettings() {
    print('GoPiGoSettingsViewModel/updateSettings');
    _device.setName(_tempDevice.name);
    _device.setNewLimits(
        _tempDevice.temperature.upperLimit,
        _tempDevice.temperature.lowerLimit,
        _tempDevice.humidity.upperLimit,
        _tempDevice.humidity.lowerLimit,
        _tempDevice.pressure.upperLimit,
        _tempDevice.pressure.lowerLimit,
        _tempDevice.batterylevel.lowerLimit,
        _tempDevice.id);

    print("RUUVITAG NAME SET : " +
        _tempDevice.name +
        "SET NEW RUUVITAG LIMITS : " +
        '${_tempDevice.temperature.upperLimit},' +
        '${_tempDevice.temperature.lowerLimit},' +
        '${_tempDevice.humidity.upperLimit},' +
        '${_tempDevice.humidity.lowerLimit},' +
        '${_tempDevice.pressure.upperLimit},' +
        '${_tempDevice.pressure.lowerLimit},' +
        '${_tempDevice.batterylevel.lowerLimit},' +
        '${_tempDevice.id}');
  }
}
