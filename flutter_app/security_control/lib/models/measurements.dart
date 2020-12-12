import 'package:flutter/material.dart';
import 'dart:convert';

class Measurements {
  double _upperLimit;
  double _lowerLimit;
  double _current;

  double get upperLimit => _upperLimit;
  double get lowerLimit => _lowerLimit;
  double get current => _current;

  void setLimits(double upper, double lower) {
    if (upper == null) {
      _upperLimit = 40.0;
    } else {
      _upperLimit = upper;
    }

    if (lower == null) {
      _lowerLimit = 10.0;
    } else {
      _lowerLimit = lower;
    }
  }

  void setUpperLimit(double i) {
    if (i == null) {
      _upperLimit = 40.0;
    } else {
      _upperLimit = i;
    }
  }

  void setLowerLimit(double j) {
    if (j == null) {
      _lowerLimit = 10.0;
    } else {
      _lowerLimit = j;
    }
  }

  void setCurrent(double k) {
    if (k == null) {
      _current = 404.0;
    } else {
      _current = k;
    }
  }

  Measurements(this._upperLimit, this._lowerLimit, this._current);
  Measurements.empty();
}
