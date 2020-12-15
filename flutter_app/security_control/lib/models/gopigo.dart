import 'dart:convert';
import 'package:security_control/models/measurements.dart';

class GoPiGo {
  int _id;
  String _name;
  Measurements _batterylevel = Measurements.empty();
  String _location;
  bool _connected;
  Function(int, String)
      _updateNameCallBack; // If not null, called when setName() is called
  Function(int, double) _updateLimitsCallBack;
  GoPiGo(this._id, this._name, this._batterylevel);
  GoPiGo.empty();
  GoPiGo.loading() {
    _id = -5;
  }

  GoPiGo.fromJson(String content, this._id, String limitcontent,
      [Function(int, String) updateNameCallBack,
      Function(int, double) updateLimitsCallBack]) {
    // Server brings our info in list form unfortunately, so we must do this manually
    // Content =
    List details = jsonDecode(content)[0];
    this._name = details[0] ?? 'GoPiGo_$id';
    this._batterylevel.setCurrent(details[1]);
    this._location = details[2] ?? 'lost';
    if (details[3] == 0) {
      this._connected = false;
    } else {
      this._connected = true;
    }
    if (updateNameCallBack != null) {
      _updateNameCallBack = updateNameCallBack;
    }

    double limits = jsonDecode(limitcontent)[0][0];
    this._batterylevel.setLowerLimit(limits);

    if (updateLimitsCallBack != null) {
      _updateLimitsCallBack = updateLimitsCallBack;
    }
  }

  String get name => _name;
  int get id => _id;
  get batterylevel => _batterylevel;
  bool get connected => _connected;
  String get location => _location;

  void setId(int i) => _id = i;
  void setCurrentBatteryLevel(double i) => _batterylevel.setCurrent(i);
  void setBatteryLimit(double i) => _batterylevel.setLowerLimit(i);
  void setName(String newName) {
    _name = newName;
    if (_updateNameCallBack != null) {
      _updateNameCallBack(_id, _name);
    }
  }

  void setNewLimits(double lowerBattery, int id) {
    _batterylevel.setLowerLimit(lowerBattery);
    _id = id;
    if (_updateLimitsCallBack != null) {
      _updateLimitsCallBack(_id, _batterylevel.lowerLimit);
    }
  }
}
