import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import 'analysis_screen.dart';

/// ✅ Écran caméra optimisé avec gestion d'erreurs robuste
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  File? _selectedImage; // ✅ Prévisualisation avant analyse
  String? _errorMessage;

  /// ✅ Prendre une photo avec la caméra
  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200, // ✅ Limiter la taille
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Erreur caméra: ${e.toString()}');
    }
  }

  /// ✅ Sélectionner depuis la galerie
  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      _showError('Erreur galerie: ${e.toString()}');
    }
  }

  /// ✅ Analyser l'image sélectionnée
  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Analyser avec le service corrigé
      final result = await ApiService.analyzePlant(_selectedImage!);

      if (!mounted) return;

      // ✅ Navigation vers les résultats
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AnalysisScreen(
            imagePath: _selectedImage!.path,
            analysisResult: result,
          ),
        ),
      );
    } on ApiException catch (e) {
      // ✅ Gestion d'erreur spécifique
      _showError(e.userMessage);
    } catch (e) {
      _showError('Erreur inattendue: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// ✅ Afficher une erreur
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
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
          ? _buildLoadingState()
          : _selectedImage == null
              ? _buildInitialState()
              : _buildPreviewState(),
    );
  }

  /// ✅ État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Analyse en cours...',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            'Cela peut prendre quelques secondes',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// ✅ État initial (pas d'image)
  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Instructions
          Card(
            elevation: 2,
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
                    '• Prenez une photo claire des feuilles\n'
                    '• Cadrez bien la zone concernée\n'
                    '• Assurez un bon éclairage\n'
                    '• Évitez les ombres et reflets',
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

          // Message d'erreur si présent
          if (_errorMessage != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ État de prévisualisation (image sélectionnée)
  Widget _buildPreviewState() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Prévisualisation de l'image
          Expanded(
            child: Card(
              elevation: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _errorMessage = null;
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text('Annuler'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _analyzeImage,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Analyser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ Bouton d'action réutilisable
  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
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
