import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/failure.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/speech/presentation/speech_strings.dart';

/// Typed input, for when speech is unavailable or the worker prefers to type.
/// [reason] explains why speech isn't working, above the field.
class TypedFallback extends StatefulWidget {
  const TypedFallback({super.key, required this.language, required this.onSubmitted, this.reason, this.enabled = true});

  final Language language;
  final Failure? reason;
  final ValueChanged<String> onSubmitted;
  final bool enabled;

  @override
  State<TypedFallback> createState() => _TypedFallbackState();
}

class _TypedFallbackState extends State<TypedFallback> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSubmitted(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = SpeechStrings.of(widget.language);
    final reason = widget.reason;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (reason != null) ...[
          AppAlert.info(
            icon: LucideIcons.micOff,
            title: strings.unavailableTitle(reason),
            description: '${strings.unavailableBody(reason)} ${strings.bestInChrome}',
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                placeholder: strings.typeInstead,
                enabled: widget.enabled,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(width: 8),
            AppButton.secondary(
              label: strings.send,
              icon: LucideIcons.send,
              onPressed: widget.enabled ? _submit : null,
            ),
          ],
        ),
      ],
    );
  }
}
