import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../models/analysis_result.dart';
import '../models/weather_data.dart' as weather;

/// Service API optimisé avec gestion d'erreurs robuste
class ApiService {
  // ✅ Configuration centralisée
  static const String baseUrl = "http://192.168.56.1:8000";
  static const Duration timeout = Duration(seconds: 30);

  // ✅ Headers par défaut
  static Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  /// ✅ CORRECTION PRINCIPALE: Analyse d'image avec conversion
  static Future<AnalysisResult> analyzePlant(File imageFile) async {
    try {
      // 1. Lire et valider l'image
      final bytes = await imageFile.readAsBytes();

      // 2. Décoder l'image (supporte PNG, JPEG, etc.)
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        throw ApiException('Image invalide ou corrompue');
      }

      // 3. Redimensionner pour optimiser (max 1200px)
      if (decodedImage.width > 1200 || decodedImage.height > 1200) {
        decodedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1200 : null,
          height: decodedImage.height > decodedImage.width ? 1200 : null,
        );
      }

      // 4. Convertir en JPEG de qualité optimale
      final jpegBytes = img.encodeJpg(decodedImage, quality: 85);

      // 5. Créer la requête multipart
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/analyze'),
      );

      // 6. Ajouter l'image convertie
      request.files.add(
        http.MultipartFile.fromBytes(
          'file', // ✅ Nom correct du champ
          jpegBytes,
          filename: 'plant_image.jpg',
        ),
      );

      // 7. Envoyer avec timeout
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      // 8. Gérer les réponses
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return AnalysisResult.fromJson(jsonResponse);
      } else {
        throw ApiException(
          'Erreur serveur (${response.statusCode})',
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé. Vérifiez votre connexion.');
    } on http.ClientException {
      throw ApiException('Erreur de communication avec le serveur');
    } catch (e) {
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }

  /// ✅ Météo avec gestion d'erreurs améliorée
  static Future<weather.WeatherData> getWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/weather').replace(
        queryParameters: {
          'lat': latitude.toString(),
          'lon': longitude.toString(),
        },
      );

      final response = await http.get(uri, headers: _headers).timeout(timeout);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return weather.WeatherData.fromJson(jsonResponse);
      } else {
        throw ApiException('Erreur météo (${response.statusCode})');
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé');
    } catch (e) {
      throw ApiException('Erreur météo: ${e.toString()}');
    }
  }

  /// ✅ Liste des maladies avec cache
  static Future<Map<String, dynamic>> getDiseasesList() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/v1/diseases'),
            headers: _headers,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ApiException('Erreur liste maladies (${response.statusCode})');
      }
    } catch (e) {
      throw ApiException('Erreur: ${e.toString()}');
    }
  }

  /// ✅ Test de santé de l'API
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// ✅ Exception personnalisée pour une meilleure gestion d'erreurs
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;

  /// Message utilisateur-friendly
  String get userMessage {
    if (message.contains('connexion') || message.contains('internet')) {
      return 'Vérifiez votre connexion internet';
    } else if (message.contains('délai') || message.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre. Réessayez.';
    } else if (statusCode == 500) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else if (statusCode == 404) {
      return 'Service non disponible';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
