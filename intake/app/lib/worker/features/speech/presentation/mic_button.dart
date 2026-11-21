import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:intake/worker/features/speech/presentation/speech_state.dart';
import 'package:intake/worker/features/speech/presentation/speech_strings.dart';

/// The 72 dp mic. Its ring pulses in `listening` while the mic is live, and
/// holds still under reduced motion.
class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.phase,
    required this.language,
    required this.onStart,
    required this.onStop,
    this.enabled = true,
  });

  final SpeechPhase phase;
  final Language language;
  final VoidCallback onStart;
  final VoidCallback onStop;

  /// False while a reply streams.
  final bool enabled;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(MicButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final listening = widget.phase is SpeechListening || widget.phase is SpeechStarting;
    final reduced = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (listening && !reduced) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = listening ? 1 : 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = SpeechStrings.of(widget.language);
    final (icon, label, onPressed, live) = switch (widget.phase) {
      SpeechIdle() || SpeechUnavailable() => (LucideIcons.mic, strings.startListening, widget.onStart, false),
      SpeechStarting() => (LucideIcons.mic, strings.starting, null, true),
      SpeechListening() => (LucideIcons.square, strings.stopListening, widget.onStop, true),
    };
    final listening = context.tokens.listening;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: live ? listening.withValues(alpha: 0.35 + 0.65 * _pulse.value) : listening.withValues(alpha: 0),
            width: 4,
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(4), child: child),
      ),
      child: AppIconButton(
        icon: icon,
        semanticLabel: label,
        highlighted: live,
        onPressed: widget.enabled ? onPressed : null,
      ),
    );
  }
}
