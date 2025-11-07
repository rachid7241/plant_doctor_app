import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/weather_data.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String _error = '';
  String _debugInfo = 'Non initialisé';

  @override
  void initState() {
    super.initState();
    print('🌤️ Écran Météo - initState appelé');
    _loadWeatherData();
  }

  Future<void> _loadWeatherData() async {
    print('🌤️ Écran Météo - Début chargement données');

    setState(() {
      _isLoading = true;
      _error = '';
      _debugInfo = 'Démarrage du chargement...';
    });

    try {
      // Étape 1: Géolocalisation
      setState(() {
        _debugInfo = '📍 Obtention de la position...';
      });
      print('🌤️ Étape 1: Obtention position');

      final position = await LocationService.getCurrentLocation();
      setState(() {
        _debugInfo =
            '📍 Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
      print(
          '🌤️ Position obtenue: ${position.latitude}, ${position.longitude}');

      // Étape 2: API Météo
      setState(() {
        _debugInfo = '🌤️ Appel API météo...';
      });
      print('🌤️ Étape 2: Appel API météo');

      final weather = await ApiService.getWeather(
        position.latitude,
        position.longitude,
      );

      print(
          '🌤️ Données météo reçues: ${weather.temperature}°C, ${weather.conditions}');

      setState(() {
        _weatherData = weather;
        _debugInfo = '✅ Données chargées avec succès!';
      });
    } catch (e) {
      print('❌ Écran Météo - Erreur: $e');
      setState(() {
        _error = 'Erreur: $e';
        _debugInfo = '❌ Échec: $e';
      });
    } finally {
      print('🌤️ Écran Météo - Chargement terminé');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
        '🌤️ Écran Météo - build appelé, isLoading: $_isLoading, error: $_error, weatherData: $_weatherData');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo Locale'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeatherData,
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              print('🐛 État actuel:');
              print('  - isLoading: $_isLoading');
              print('  - error: $_error');
              print('  - weatherData: $_weatherData');
              print('  - debugInfo: $_debugInfo');
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoading();
    }

    if (_error.isNotEmpty) {
      return _buildError();
    }

    if (_weatherData == null) {
      return _buildNoData();
    }

    return _buildWeatherContent();
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text('Chargement des données météo...'),
          const SizedBox(height: 10),
          Text(
            _debugInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Erreur de chargement',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _debugInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWeatherData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoData() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'Aucune donnée météo disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            _debugInfo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadWeatherData,
            child: const Text('Charger les données'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    final weather = _weatherData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Carte principale météo
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.wb_sunny, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    weather.location,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildWeatherInfo(
                          '🌡️', '${weather.temperature}°C', 'Température'),
                      _buildWeatherInfo(
                          '💧', '${weather.humidity}%', 'Humidité'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    weather.conditions,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Recommandation
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Recommandation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(weather.recommendation),
                ],
              ),
            ),
          ),

          // Debug info
          const SizedBox(height: 20),
          Card(
            color: Colors.grey[100],
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🐛 Debug Info:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _debugInfo,
                    style:
                        const TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherInfo(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
