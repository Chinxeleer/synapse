class TranslationLanguage {
  final String code;   // what your API expects e.g. 'fr'
  final String name;   // what the user sees e.g. 'French'
  final String flag;   // emoji flag for visual context

  const TranslationLanguage({
    required this.code,
    required this.name,
    required this.flag,
  });

  // The full supported language list
  static const List<TranslationLanguage> supported = [
    TranslationLanguage(code: 'en', name: 'English',    flag: '🇬🇧'),
    TranslationLanguage(code: 'fr', name: 'French',     flag: '🇫🇷'),
    TranslationLanguage(code: 'es', name: 'Spanish',    flag: '🇪🇸'),
    TranslationLanguage(code: 'de', name: 'German',     flag: '🇩🇪'),
    TranslationLanguage(code: 'zh', name: 'Chinese',    flag: '🇨🇳'),
    TranslationLanguage(code: 'ar', name: 'Arabic',     flag: '🇸🇦'),
    TranslationLanguage(code: 'pt', name: 'Portuguese', flag: '🇧🇷'),
    TranslationLanguage(code: 'ru', name: 'Russian',    flag: '🇷🇺'),
    TranslationLanguage(code: 'ja', name: 'Japanese',   flag: '🇯🇵'),
    TranslationLanguage(code: 'sw', name: 'Swahili',    flag: '🇰🇪'),
    TranslationLanguage(code: 'zu', name: 'Zulu',       flag: '🇿🇦'),
    TranslationLanguage(code: 'sn', name: 'Shona',      flag: '🇿🇼'),
  ];
}