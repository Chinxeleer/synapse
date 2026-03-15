import 'package:flutter/material.dart';
import 'package:multilingual/core/models/languages.dart';

/// A dropdown that lets the user pick a target translation language.
/// Reusable — you can drop this into the text translation UI too.
class LanguageSelector extends StatelessWidget {
  final TranslationLanguage selected;
  final void Function(TranslationLanguage) onChanged;
  final String label;

  const LanguageSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.label = 'Translate to',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Theme(
          data: Theme.of(context).copyWith(
            canvasColor: Colors.grey[900], // dropdown background
          ),
          child: DropdownButtonFormField<TranslationLanguage>(
            initialValue: selected,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            // Build one item per supported language
            items: TranslationLanguage.supported.map((lang) {
              return DropdownMenuItem(
                value: lang,
                child: Row(
                  children: [
                    Text(lang.flag, style: const TextStyle(fontSize: 20,color: Colors.white)),
                    const SizedBox(width: 10),
                    Text(lang.name, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }).toList(),
            onChanged: (lang) {
              if (lang != null) onChanged(lang);
            },
          ),
        ),
      ],
    );
  }
}
