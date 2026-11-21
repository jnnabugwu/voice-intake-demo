/// The conversation's language. Both sides use it: the worker speaks in it,
/// and the physician sees it on the summary.
enum Language {
  en('en-US', 'EN'),
  es('es-US', 'ES');

  const Language(this.localeId, this.shortLabel);

  /// The preferred speech locale. Engines fall back to another locale of the
  /// same language when this one isn't offered.
  final String localeId;

  /// The label on the EN/ES toggle.
  final String shortLabel;

  /// ISO 639-1 code, as sent to the proxy (`en` or `es`).
  String get code => name;

  static Language fromCode(String? code) => code == 'es' ? Language.es : Language.en;
}
