import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/analysis_result.dart';
import '../models/weather_data.dart' as weather;

class ApiService {
  static const String baseUrl = "http://192.168.56.1:8000";

  static Future<AnalysisResult> analyzePlant(File imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/analyze'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(responseData);
        return AnalysisResult.fromJson(jsonResponse);
      } else {
        throw Exception('Erreur API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau: $e');
    }
  }

  static Future<weather.WeatherData> getWeather(
      double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/weather?lat=$latitude&lon=$longitude'),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(response.body);
        return weather.WeatherData.fromJson(jsonResponse);
      } else {
        throw Exception('Erreur API météo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau météo: $e');
    }
  }

  static Future<Map<String, dynamic>> getDiseasesList() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/diseases'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Erreur API maladies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur réseau maladies: $e');
    }
  }
}
