class WeatherModel {
  final String cityName;
  final double temperature;
  final String mainCondition;

  WeatherModel(
      {required this.cityName,
        required this.mainCondition,
        required this.temperature});

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
        cityName: json["name"],
        mainCondition: json["weather"][0]["main"],
        temperature: json["main"]['temp']);
  }
}