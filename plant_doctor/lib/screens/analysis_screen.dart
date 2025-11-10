import 'dart:io';
import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class AnalysisScreen extends StatelessWidget {
  final String imagePath;
  final AnalysisResult analysisResult;

  const AnalysisScreen({
    super.key,
    required this.imagePath,
    required this.analysisResult,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultats d\'Analyse'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image analysée
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.file(
                  File(imagePath),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Résultat principal
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildStatusIcon(analysisResult.disease.name),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                analysisResult.disease.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Confiance: ${(analysisResult.disease.confidence * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Urgence
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getUrgencyColor(analysisResult.disease.urgency),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Urgence: ${_getUrgencyText(analysisResult.disease.urgency)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Traitement
            _buildInfoCard(
              '💊 Traitement Recommandé',
              analysisResult.disease.treatment,
              Icons.medical_services,
            ),

            const SizedBox(height: 16),

            // Prévention
            _buildInfoCard(
              '🛡️ Prévention',
              analysisResult.disease.prevention,
              Icons.shield,
            ),

            const SizedBox(height: 16),

            // Impact météo
            _buildInfoCard(
              '🌤️ Impact Météo',
              analysisResult.weatherImpact,
              Icons.wb_sunny,
            ),

            const SizedBox(height: 16),

            // Recommandation générale
            _buildInfoCard(
              '📋 Recommandation',
              analysisResult.recommendation,
              Icons.lightbulb,
            ),

            const SizedBox(height: 20),

            // Boutons d'action
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String diseaseName) {
    if (diseaseName.toLowerCase().contains('sain') ||
        diseaseName.toLowerCase().contains('healthy')) {
      return const Icon(Icons.check_circle, color: Colors.green, size: 40);
    } else {
      return const Icon(Icons.warning, color: Colors.orange, size: 40);
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getUrgencyText(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'high':
        return 'Élevée';
      case 'medium':
        return 'Moyenne';
      case 'low':
        return 'Faible';
      default:
        return urgency;
    }
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.green[700], size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Bouton réanalyser
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Analyser une autre plante'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bouton accueil
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Retour à l\'accueil'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }
}