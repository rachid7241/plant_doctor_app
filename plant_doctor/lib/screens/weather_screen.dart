import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../models/weather_data.dart';

/// ✅ Écran météo optimisé avec cache et rafraîchissement intelligent
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  WeatherData? _weatherData;
  bool _isLoading = false;
  String _error = '';

  // ✅ Cache des données météo
  static WeatherData? _cachedWeather;
  static DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 10);

  @override
  void initState() {
    super.initState();
    _loadWeatherData();
  }

  /// ✅ Charger les données avec cache intelligent
  Future<void> _loadWeatherData({bool forceRefresh = false}) async {
    // Vérifier le cache si pas de rafraîchissement forcé
    if (!forceRefresh && _isCacheValid()) {
      setState(() {
        _weatherData = _cachedWeather;
        _isLoading = false;
        _error = '';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Obtenir la position
      final position = await LocationService.getCurrentLocation();

      // Obtenir la météo
      final weather = await ApiService.getWeather(
        position.latitude,
        position.longitude,
      );

      // ✅ Mettre en cache
      _cachedWeather = weather;
      _cacheTime = DateTime.now();

      setState(() {
        _weatherData = weather;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.userMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur inattendue: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  /// ✅ Vérifier si le cache est valide
  bool _isCacheValid() {
    if (_cachedWeather == null || _cacheTime == null) return false;
    final difference = DateTime.now().difference(_cacheTime!);
    return difference < _cacheDuration;
  }

  /// ✅ Obtenir le temps restant du cache
  String _getCacheTimeRemaining() {
    if (_cacheTime == null) return '';
    final elapsed = DateTime.now().difference(_cacheTime!);
    final remaining = _cacheDuration - elapsed;

    if (remaining.isNegative) return '';

    final minutes = remaining.inMinutes;
    return 'Données mises à jour il y a ${elapsed.inMinutes} min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo Locale'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          // ✅ Bouton de rafraîchissement
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed:
                _isLoading ? null : () => _loadWeatherData(forceRefresh: true),
            tooltip: 'Rafraîchir',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _weatherData == null) {
      return _buildLoading();
    }

    if (_error.isNotEmpty && _weatherData == null) {
      return _buildError();
    }

    if (_weatherData == null) {
      return _buildNoData();
    }

    return _buildWeatherContent();
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text('Chargement des données météo...'),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
            Text(
              _error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _loadWeatherData(forceRefresh: true),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
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
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _loadWeatherData(forceRefresh: true),
            child: const Text('Charger les données'),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    final weather = _weatherData!;
    final cacheInfo = _getCacheTimeRemaining();

    return RefreshIndicator(
      onRefresh: () => _loadWeatherData(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ✅ Indicateur de cache
            if (cacheInfo.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      cacheInfo,
                      style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),

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
                          '🌡️',
                          '${weather.temperature}°C',
                          'Température',
                        ),
                        _buildWeatherInfo(
                          '💧',
                          '${weather.humidity}%',
                          'Humidité',
                        ),
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
          ],
        ),
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
