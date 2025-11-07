class AnalysisResult {
  final Disease disease;
  final String weatherImpact;
  final String recommendation;
  final String timestamp;

  AnalysisResult({
    required this.disease,
    required this.weatherImpact,
    required this.recommendation,
    required this.timestamp,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      disease: Disease.fromJson(json['disease']),
      weatherImpact: json['weather_impact'],
      recommendation: json['recommendation'],
      timestamp: json['timestamp'],
    );
  }
}

class Disease {
  final String name;
  final double confidence;
  final String treatment;
  final String prevention;
  final String urgency;

  Disease({
    required this.name,
    required this.confidence,
    required this.treatment,
    required this.prevention,
    required this.urgency,
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'],
      confidence: (json['confidence'] as num).toDouble(),
      treatment: json['treatment'],
      prevention: json['prevention'],
      urgency: json['urgency'],
    );
  }
}

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
      humidity: json['humidity'],
      conditions: json['conditions'],
      recommendation: json['recommendation'],
      location: json['location'],
    );
  }
}
