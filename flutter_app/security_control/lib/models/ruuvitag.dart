import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:security_control/models/measurements.dart';

//TODO: conform to servers model of RuuviTag
class RuuviTag {
  int _id;
  String _name;
  String _location;
  bool _dooropen;

  Measurements _batterylevel = Measurements.empty();
  Measurements _temperature = Measurements.empty();
  Measurements _humidity = Measurements.empty();
  Measurements _pressure = Measurements.empty();
  bool _connected; // = true; //TODO delete? no use/info from database
  Function(int, String) _updateNameCallBack;
  Function(double, double, double, double, double, double, double, int)
      _updateLimitsCallBack;

  //getters
  int get id => _id;
  String get name => _name;
  String get location => _location;
  bool get dooropen => _dooropen;
  Measurements get batterylevel => _batterylevel;
  Measurements get temperature => _temperature;
  Measurements get humidity => _humidity;
  Measurements get pressure => _pressure;
  bool get connected => _connected;

  //setters

  void setId(int i) => _id = i;
  void setCurrentBatteryLevel(double i) => _batterylevel.setCurrent(i);
  void setCurrentTemperature(double k) => _temperature.setCurrent(k);
  void setCurrentHumidity(double k) => _humidity.setCurrent(k);
  void setCurrentPressure(double k) => _pressure.setCurrent(k);
  void setBatteryLimit(double i) => _batterylevel.setLowerLimit(i);
  void setTemperatureLimits(double upper, double lower) {
    _temperature.setUpperLimit(upper);
    _temperature.setLowerLimit(lower);
  }

  void setHumidityLimits(double upper, double lower) {
    _humidity.setUpperLimit(upper);
    _humidity.setLowerLimit(lower);
  }

  void setPressureLimits(double upper, double lower) {
    _pressure.setUpperLimit(upper);
    _pressure.setLowerLimit(lower);
  }

  //constructor
  RuuviTag({
    id,
    name,
    location,
    dooropen,
    batterylevel,
    temperature,
    humidity,
    pressure,
  }) {
    _id = id;
    _name = name;
    _location = location;
    _dooropen = dooropen;
    _batterylevel.setCurrent(batterylevel);
    _temperature.setCurrent(temperature);
    _humidity.setCurrent(humidity);
    _pressure.setCurrent(pressure);
  }
  RuuviTag.empty();

  RuuviTag.fromJson(
    String content,
    this._id,
    String limitcontent, [
    Function(int, String) updateNameCallBack,
    Function(double, double, double, double, double, double, double, int)
        updateLimitsCallBack,
  ]) {
    List details = jsonDecode(content)[0];
    this._batterylevel.setCurrent(details[0]);
    this._name = details[1] ?? 'Ruuvitag_$id';
    this._location = details[2] ?? 'lost';
    if (details[3] == 0) {
      this._dooropen = false;
    } else {
      this._dooropen = true;
    }
    this._temperature.setCurrent(details[4]);
    this._humidity.setCurrent(details[5]);
    this._pressure.setCurrent(details[6]);
    if (details[7] == 0) {
      this._connected = false;
    } else {
      this._connected = true;
    }

    if (updateNameCallBack != null) {
      _updateNameCallBack = updateNameCallBack;
    }

    List limits = jsonDecode(limitcontent)[0];
    this._temperature.setLimits(limits[0], limits[1]);
    this._humidity.setLimits(limits[2], limits[3]);
    this._pressure.setLimits(limits[4], limits[5]);
    this._batterylevel.setLowerLimit(limits[6]);

    if (updateLimitsCallBack != null) {
      _updateLimitsCallBack = updateLimitsCallBack;
    }

    print("RUUVITAG FROMJSON : " +
        '${_batterylevel.current}' +
        ", " +
        '${_batterylevel.lowerLimit}' +
        ", " +
        '${temperature.current}' +
        ", " +
        '${_temperature.upperLimit}' +
        ", " +
        '${_temperature.lowerLimit}' +
        ", " +
        '${_humidity.current}' +
        ", " +
        '${_humidity.upperLimit}' +
        ", " +
        '${_humidity.lowerLimit}' +
        ", " +
        '${_pressure.current}' +
        ", " +
        '${_pressure.upperLimit}' +
        ", " +
        '${_pressure.lowerLimit}');
  }

  void setName(String newName) {
    _name = newName;
    if (_updateNameCallBack != null) {
      _updateNameCallBack(_id, _name);
    }
  }

  void setNewLimits(
      double upperTemp,
      double lowerTemp,
      double upperHumi,
      double lowerHumi,
      double upperPres,
      double lowerPres,
      double lowerBattery,
      int id) {
    _temperature.setLimits(upperTemp, lowerTemp);
    _humidity.setLimits(upperHumi, lowerHumi);
    _pressure.setLimits(upperPres, lowerPres);
    _batterylevel.setLowerLimit(lowerBattery);
    _id = id;
    if (_updateLimitsCallBack != null) {
      _updateLimitsCallBack(
          _temperature.upperLimit,
          _temperature.lowerLimit,
          _humidity.upperLimit,
          _humidity.lowerLimit,
          _pressure.upperLimit,
          _pressure.lowerLimit,
          _batterylevel.lowerLimit,
          _id);
    }
  }

  //TODO underwork pls ignore
  String status() {
    return _connected ? 'connected' : 'disconnected';
  }

  TextStyle statusStyle(context) {
    return _connected
        ? Theme.of(context)
            .textTheme
            .caption //TODO find correct theme to make this orange text
        : Theme.of(context).textTheme.button;
  }
}
