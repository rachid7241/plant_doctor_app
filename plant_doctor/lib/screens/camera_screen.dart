import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'analysis_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showError('Erreur caméra: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );

      if (image != null) {
        _analyzeImage(File(image.path));
      }
    } catch (e) {
      _showError('Erreur galerie: $e');
    }
  }

  Future<void> _analyzeImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.analyzePlant(imageFile);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(
            imagePath: imageFile.path,
            analysisResult: result,
          ),
        ),
      );
    } catch (e) {
      _showError('Erreur analyse: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyser une Plante'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instructions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.photo_camera,
                            size: 64,
                            color: Colors.green[700],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Comment analyser votre plante',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            '• Prenez une photo claire de la plante\n'
                            '• Cadrez bien les feuilles concernées\n'
                            '• Assurez un bon éclairage\n'
                            '• Évitez les ombres portées',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        'Appareil Photo',
                        Icons.camera_alt,
                        _takePhoto,
                      ),
                      _buildActionButton(
                        'Galerie',
                        Icons.photo_library,
                        _pickFromGallery,
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButton(
      String text, IconData icon, VoidCallback onPressed) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(20),
            shape: const CircleBorder(),
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(text),
      ],
    );
  }
}
