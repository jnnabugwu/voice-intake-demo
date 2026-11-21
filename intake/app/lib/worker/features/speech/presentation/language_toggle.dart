import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/speech/presentation/speech_strings.dart';

/// EN / ES. Sets the speech locale and the worker side's language together.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, required this.language, required this.onChanged, this.enabled = true});

  final Language language;
  final ValueChanged<Language> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppSegmented<Language>(
      semanticLabel: SpeechStrings.of(language).languageLabel,
      enabled: enabled,
      selected: language,
      onChanged: onChanged,
      options: [for (final l in Language.values) (l, l.shortLabel)],
    );
  }
}
