import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multilingual/features/text_translation/data/translation_service.dart';
import 'package:multilingual/features/text_translation/ui/tappable_translated_text.dart';

/// Displays the translated text result.
/// Receives a TranslationResult and renders it cleanly.
class TranslationResultPage extends StatelessWidget {
  final TranslationResult result;

  const TranslationResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "NTT's Translation",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        actions: [
          // Copy translated text to clipboard
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: result.translatedText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy_outlined, color: Colors.white),
            tooltip: 'Copy translation',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Extracted text section ──────────────────────────────
              _SectionCard(
                label: 'Extracted Text (English)',
                content: result.extractedText,
                icon: Icons.document_scanner_outlined,
              ),

              const SizedBox(height: 16),
              const Icon(Icons.arrow_downward, color: Colors.grey),
              const SizedBox(height: 16),

              // ── Translated text section ────────────────────────────────
              _SectionCard(
                label: 'Translation (${result.targetLanguage})',
                content: result.translatedText,
                icon: Icons.translate,
                highlighted: true,
              ),

              const SizedBox(height: 24),
              // ── Scan another button ────────────────────────────────
              FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Translate Another'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final String content;
  final IconData icon;
  final bool highlighted;

  const _SectionCard({
    required this.label,
    required this.content,
    required this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: highlighted
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),
            highlighted
                ? TappableTranslatedText(
                    text: content.isNotEmpty ? content : '(nothing detected)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  )
                : Text(
                    content.isNotEmpty ? content : '(nothing detected)',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
          ],
        ),
      ),
    );
  }
}
