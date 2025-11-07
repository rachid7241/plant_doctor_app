class WeatherData {
  final double temperature;
  final int humidity;
  final String conditions;
  final String recommendation;
  final String location;

  WeatherData({
    required this.temperature,
    required this.humidity,
    required this.conditions,
    required this.recommendation,
    required this.location,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: json['humidity'] as int,
      conditions: json['conditions'] as String,
      recommendation: json['recommendation'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'conditions': conditions,
      'recommendation': recommendation,
      'location': location,
    };
  }

  @override
  String toString() {
    return 'WeatherData(temperature: $temperature, humidity: $humidity, conditions: $conditions, recommendation: $recommendation, location: $location)';
  }
}
