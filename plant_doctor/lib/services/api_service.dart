import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // ✅ AJOUT CRITIQUE
import 'package:image/image.dart' as img;
import '../models/analysis_result.dart';
import '../models/weather_data.dart' as weather;

class ApiService {
  static const String baseUrl = "http://192.168.56.1:8000";
  static const Duration timeout = Duration(seconds: 30);

  static Map<String, String> get _headers => {
        'Accept': 'application/json',
      };

  /// ✅ ANALYSE AVEC CORRECTION DU CONTENT-TYPE
  static Future<AnalysisResult> analyzePlant(File imageFile) async {
    print('=' * 60);
    print('🔍 DÉBUT ANALYSE IMAGE');
    print('=' * 60);

    try {
      // 1. Lire l'image
      print('📖 Lecture du fichier: ${imageFile.path}');
      final bytes = await imageFile.readAsBytes();
      print('   Taille originale: ${bytes.length / 1024} KB');

      // 2. Décoder l'image
      print('🖼️ Décodage de l\'image...');
      img.Image? decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        print('❌ Impossible de décoder l\'image');
        throw ApiException('Image invalide ou corrompue');
      }

      print('   Format détecté: ${decodedImage.width}x${decodedImage.height}');

      // 3. Redimensionner si nécessaire
      if (decodedImage.width > 1200 || decodedImage.height > 1200) {
        print('📐 Redimensionnement de l\'image...');
        decodedImage = img.copyResize(
          decodedImage,
          width: decodedImage.width > decodedImage.height ? 1200 : null,
          height: decodedImage.height > decodedImage.width ? 1200 : null,
        );
        print(
            '   Nouvelle taille: ${decodedImage.width}x${decodedImage.height}');
      }

      // 4. Convertir en JPEG
      print('🔄 Conversion en JPEG...');
      final jpegBytes = img.encodeJpg(decodedImage, quality: 85);
      print('   Taille après conversion: ${jpegBytes.length / 1024} KB');

      // 5. Créer la requête
      print('📤 Création de la requête HTTP...');
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/analyze'),
      );

      // 6. ✅ CORRECTION CRITIQUE: Forcer le Content-Type
      print('📎 Ajout du fichier avec Content-Type forcé...');
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          jpegBytes,
          filename: 'plant_image.jpg',
          contentType: MediaType('image', 'jpeg'), // ✅ CORRECTION
        ),
      );

      print('   URL: $baseUrl/api/v1/analyze');
      print('   Champ: file');
      print('   Filename: plant_image.jpg');
      print('   Content-Type: image/jpeg (forcé)');

      // 7. Envoyer la requête
      print('🚀 Envoi de la requête...');
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Réponse reçue:');
      print('   Status: ${response.statusCode}');

      // 8. Traiter la réponse
      if (response.statusCode == 200) {
        print('✅ SUCCÈS!');

        final jsonResponse = json.decode(response.body);
        print('=' * 60);
        return AnalysisResult.fromJson(jsonResponse);
      } else {
        print('❌ ERREUR ${response.statusCode}');
        print('   Body: ${response.body}');
        print('=' * 60);

        throw ApiException(
          'Erreur serveur (${response.statusCode})',
          statusCode: response.statusCode,
          details: response.body,
        );
      }
    } on SocketException catch (e) {
      print('❌ Erreur réseau: $e');
      print('=' * 60);
      throw ApiException('Pas de connexion internet');
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      print('=' * 60);
      throw ApiException('Délai d\'attente dépassé. Vérifiez votre connexion.');
    } on http.ClientException catch (e) {
      print('❌ Erreur client HTTP: $e');
      print('=' * 60);
      throw ApiException('Erreur de communication avec le serveur');
    } catch (e, stackTrace) {
      print('❌ Erreur inattendue: $e');
      print('Stack trace: $stackTrace');
      print('=' * 60);
      throw ApiException('Erreur inattendue: ${e.toString()}');
    }
  }

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

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => message;

  String get userMessage {
    if (message.contains('connexion') || message.contains('internet')) {
      return 'Vérifiez votre connexion internet';
    } else if (message.contains('délai') || message.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre. Réessayez.';
    } else if (statusCode == 500) {
      return 'Erreur serveur. Réessayez plus tard.';
    } else if (statusCode == 404) {
      return 'Service non disponible';
    } else if (statusCode == 400) {
      return 'Fichier image invalide. Essayez une autre photo.';
    }
    return 'Une erreur est survenue. Réessayez.';
  }
}
