import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multilingual/core/models/languages.dart';
import 'package:multilingual/features/text_translation/data/translation_service.dart';
import 'package:multilingual/features/text_translation/ui/language_selector.dart';
import 'package:multilingual/features/text_translation/ui/results_screen.dart';
import 'package:multilingual/services/camera_services.dart';

class CameraTranslationScreen extends StatefulWidget {
  const CameraTranslationScreen({super.key});

  @override
  State<CameraTranslationScreen> createState() =>
      _CameraTranslationScreenState();
}

class _CameraTranslationScreenState extends State<CameraTranslationScreen> {
  bool _isLoading = false;

  // The user's chosen target language — default to English
  TranslationLanguage _targetLanguage = TranslationLanguage.supported.first;

  Future<void> _handleImageCaptured(File imageFile) async {
    setState(() => _isLoading = true);

    try {
      final result = await TranslationCameraService.translateImageText(
        imageFile: imageFile,
        targetLanguage: _targetLanguage.code, // pass the code to the API
      );

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TranslationResultPage(result: result),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Understand & Translate Text',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // ── Language selector sits above the camera ──────────
                LanguageSelector(
                  selected: _targetLanguage,
                  onChanged: (lang) {
                    // Rebuild with the new choice — next capture uses this
                    setState(() => _targetLanguage = lang);
                  },
                ),

                const SizedBox(height: 16),

                // ── Camera takes up the remaining space ──────────────
                Expanded(
                  child: CameraCaptureWidget(
                    onImageCaptured: _handleImageCaptured,
                    showGalleryOption: true,
                  ),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const ColoredBox(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Translating...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
