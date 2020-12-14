//TODO this is deprecated, delete?
class MeasurementLimits {
  int batteryLimit;
  double upperTemperatureLimit;
  double lowerTemperatureLimit;
  double upperHumidityLimit;
  double lowerHumidityLimit;
  double upperPressureLimit;
  double lowerPressureLimit;

  MeasurementLimits(
      {this.batteryLimit,
      this.upperTemperatureLimit,
      this.lowerTemperatureLimit,
      this.upperHumidityLimit,
      this.lowerHumidityLimit,
      this.upperPressureLimit,
      this.lowerPressureLimit});

  factory MeasurementLimits.fromJson(Map<String, dynamic> json) {
    return MeasurementLimits(
      batteryLimit: json['batterylimit'] as int,
      upperTemperatureLimit: json['upperTemperatureLimit'] as double,
      lowerTemperatureLimit: json['lowerTemperatureLimit'] as double,
      upperHumidityLimit: json['upperHumidityLimit'] as double,
      lowerHumidityLimit: json['lowerHumidityLimit'] as double,
      upperPressureLimit: json['upperPressureLimit'] as double,
      lowerPressureLimit: json['lowerPressureLimit'] as double,
    );
  }
}
