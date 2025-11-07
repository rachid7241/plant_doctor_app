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
                        'Urgence: ${analysisResult.disease.urgency}',
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
            ),

            const SizedBox(height: 16),

            // Prévention
            _buildInfoCard(
              '🛡️ Prévention',
              analysisResult.disease.prevention,
            ),

            const SizedBox(height: 16),

            // Impact météo
            _buildInfoCard(
              '🌤️ Impact Météo',
              analysisResult.weatherImpact,
            ),

            const SizedBox(height: 16),

            // Recommandation générale
            _buildInfoCard(
              '📋 Recommandation',
              analysisResult.recommendation,
            ),

            const SizedBox(height: 20),

            // Bouton d'action
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retour à l\'accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String diseaseName) {
    if (diseaseName == 'Plante Sain') {
      return const Icon(Icons.check_circle, color: Colors.green, size: 40);
    } else {
      return const Icon(Icons.warning, color: Colors.orange, size: 40);
    }
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency) {
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

  Widget _buildInfoCard(String title, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
