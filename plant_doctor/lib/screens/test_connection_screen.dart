import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../services/location_service.dart';

class TestConnectionScreen extends StatefulWidget {
  const TestConnectionScreen({super.key});

  @override
  State<TestConnectionScreen> createState() => _TestConnectionScreenState();
}

class _TestConnectionScreenState extends State<TestConnectionScreen> {
  String _apiStatus = 'Non testé';
  String _weatherStatus = 'Non testé';
  String _locationStatus = 'Non testé';
  String _debugResult = 'Appuyez sur un test';
  bool _isTesting = false;
  bool _debugLoading = false;

  Future<void> _testAllConnections() async {
    if (_isTesting) return;

    setState(() {
      _isTesting = true;
      _apiStatus = 'Test en cours...';
      _weatherStatus = 'Test en cours...';
      _locationStatus = 'Test en cours...';
    });

    // Test 1: Localisation (avec timeout)
    await _testLocation();

    // Test 2: API Météo
    await _testWeather();

    // Test 3: API Maladies
    await _testDiseases();

    setState(() {
      _isTesting = false;
    });
  }

  Future<void> _testLocation() async {
    try {
      print('🔍 Début test localisation...');
      final position = await LocationService.getCurrentLocation().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout localisation (10s)');
        },
      );

      setState(() {
        _locationStatus =
            '✅ OK - Lat: ${position.latitude.toStringAsFixed(4)}, Lon: ${position.longitude.toStringAsFixed(4)}';
      });
      print('📍 Localisation réussie');
    } catch (e) {
      print('❌ Erreur localisation: $e');
      setState(() {
        _locationStatus = '❌ Erreur: $e';
      });
    }
  }

  Future<void> _testWeather() async {
    try {
      print('🔍 Début test météo...');
      final weather = await ApiService.getWeather(12.3713, -1.5197).timeout(
        const Duration(seconds: 10),
      );

      setState(() {
        _weatherStatus =
            '✅ OK - ${weather.temperature}°C, ${weather.conditions}';
      });
      print('🌤️ Météo réussie');
    } catch (e) {
      print('❌ Erreur météo: $e');
      setState(() {
        _weatherStatus = '❌ Erreur: $e';
      });
    }
  }

  Future<void> _testDiseases() async {
    try {
      print('🔍 Début test maladies...');
      final diseases = await ApiService.getDiseasesList().timeout(
        const Duration(seconds: 10),
      );

      setState(() {
        _apiStatus = '✅ OK - ${diseases['count']} maladies trouvées';
      });
      print('🌐 API maladies réussie');
    } catch (e) {
      print('❌ Erreur API: $e');
      setState(() {
        _apiStatus = '❌ Erreur: $e';
      });
    }
  }

  // NOUVELLE FONCTION: Test de connexion simple
  Future<void> _testConnection(String url) async {
    setState(() {
      _debugLoading = true;
      _debugResult = 'Test: $url\nEn cours...';
    });

    try {
      final response = await http.get(Uri.parse(url)).timeout(
            const Duration(seconds: 5),
          );

      setState(() {
        _debugResult =
            '✅ SUCCÈS!\nStatus: ${response.statusCode}\nRéponse: ${response.body.length > 100 ? response.body.substring(0, 100) + "..." : response.body}';
      });
    } catch (e) {
      setState(() {
        _debugResult =
            '❌ ÉCHEC!\nErreur: $e\n\nVérifie:\n1. API démarrée\n2. Bonne IP\n3. Bon port';
      });
    } finally {
      setState(() {
        _debugLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test de Connexion API'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Section 1: Tests automatiques
            const Text(
              'Tests Automatiques:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: _isTesting ? null : _testAllConnections,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: _isTesting
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 12),
                        Text('Test en cours...'),
                      ],
                    )
                  : const Text('Tester toutes les connexions'),
            ),

            const SizedBox(height: 16),

            // Résultats des tests automatiques
            Expanded(
              flex: 2,
              child: ListView(
                children: [
                  _buildStatusItem(
                      '📍 Localisation', _locationStatus, Icons.gps_fixed),
                  _buildStatusItem(
                      '🌐 API Maladies', _apiStatus, Icons.medical_services),
                  _buildStatusItem(
                      '🌤️ API Météo', _weatherStatus, Icons.wb_sunny),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            // Section 2: Diagnostic manuel des URLs
            const Text(
              '🔧 Diagnostic URLs:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDebugButton('10.0.2.2', 'http://10.0.2.2:8000/health'),
                _buildDebugButton('127.0.0.1', 'http://127.0.0.1:8000/health'),
                _buildDebugButton('localhost', 'http://localhost:8000/health'),
                _buildDebugButton('Ton IP',
                    'http://192.168.56.1:8000/health'), // ✅ TON IP ICI
              ],
            ),

            const SizedBox(height: 16),

            // Résultat du diagnostic
            Card(
              color: _debugResult.contains('✅')
                  ? Colors.green[50]
                  : _debugResult.contains('❌')
                      ? Colors.red[50]
                      : Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📊 Résultat Diagnostic:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _debugLoading
                        ? const Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 8),
                              Text('Test en cours...'),
                            ],
                          )
                        : Text(
                            _debugResult,
                            style: const TextStyle(
                                fontFamily: 'monospace', fontSize: 12),
                          ),
                  ],
                ),
              ),
            ),

            // Informations de débogage
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '💡 Informations:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('URL API actuelle: ${ApiService.baseUrl}'),
                    Text('Ton IP: 192.168.56.1'), // ✅ TON IP ICI
                    const Text('Port: 8000'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String title, String status, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: _getStatusColor(status)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status),
      ),
    );
  }

  Widget _buildDebugButton(String label, String url) {
    return ElevatedButton(
      onPressed: _debugLoading ? null : () => _testConnection(url),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange[700],
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('✅')) return Colors.green;
    if (status.contains('❌')) return Colors.red;
    if (status.contains('...')) return Colors.orange;
    return Colors.grey;
  }
}
