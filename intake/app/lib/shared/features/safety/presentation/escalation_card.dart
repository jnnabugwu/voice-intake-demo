import 'package:flutter/widgets.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/shared/features/safety/domain/red_flag.dart';
import 'package:intake/shared/ui/ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// The full-screen card that stops the chat: 911 for an emergency, 988 for a
/// crisis, in the conversation's language. It renders from state, not as a
/// route or a dialog, so neither the back button nor a tap outside can
/// dismiss it. It takes focus and is announced when it appears.
class EscalationCard extends StatelessWidget {
  const EscalationCard({super.key, required this.flag, required this.language});

  final RedFlag flag;
  final Language language;

  @override
  Widget build(BuildContext context) {
    final es = language == Language.es;
    final crisis = flag.kind == RedFlagKind.crisis;
    final title = crisis
        ? (es ? 'Usted no está solo. Hay ayuda ahora mismo.' : "You're not alone. Help is available right now.")
        : (es ? 'Esto puede ser una emergencia.' : 'This may be an emergency.');
    final body = crisis
        ? (es
              ? 'Llame o envíe un mensaje de texto al 988 (línea de crisis y suicidio) para hablar con alguien ahora. Si está en peligro inmediato, llame al 911.'
              : 'Call or text 988 (Suicide & Crisis Lifeline) to talk with someone now. If you are in immediate danger, call 911.')
        : (es
              ? 'Llame al 911 ahora. No espere una respuesta en esta app.'
              : "Call 911 now. Don't wait for a reply in this app.");
    final call911 = AppButton.danger(
      label: es ? 'Llamar al 911' : 'Call 911',
      icon: LucideIcons.phone,
      expand: true,
      onPressed: () => launchUrl(Uri.parse('tel:911')),
    );
    final label988 = es ? 'Llamar o enviar texto al 988' : 'Call or text 988';
    void open988() => launchUrl(Uri.parse('tel:988'));
    final call988 = crisis
        ? AppButton.danger(label: label988, icon: LucideIcons.messageCircle, expand: true, onPressed: open988)
        : AppButton.outline(label: label988, icon: LucideIcons.messageCircle, expand: true, onPressed: open988);
    return Semantics(
      container: true,
      liveRegion: true,
      explicitChildNodes: true,
      child: ColoredBox(
        color: context.tokens.background,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.all(24),
              children: [
                Focus(
                  autofocus: true,
                  child: Icon(
                    crisis ? LucideIcons.heartHandshake : LucideIcons.siren,
                    size: 48,
                    color: context.tokens.escalation,
                  ),
                ),
                const SizedBox(height: 16),
                AppAlert.danger(title: title, description: body),
                const SizedBox(height: 24),
                if (crisis) ...[
                  call988,
                  const SizedBox(height: 12),
                  call911,
                ] else ...[
                  call911,
                  const SizedBox(height: 12),
                  call988,
                ],
                const SizedBox(height: 24),
                Text(
                  es ? 'Un médico también verá lo que nos contó.' : 'A clinician will also see what you told us.',
                  style: context.type.muted,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The two help lines as buttons, offered after the assistant declines and
/// hands off to a clinician. Not a stop: the worker can keep going.
class HelpLines extends StatelessWidget {
  const HelpLines({super.key, required this.language});

  final Language language;

  @override
  Widget build(BuildContext context) {
    final es = language == Language.es;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        AppButton.outline(
          label: es ? 'Emergencia: 911' : 'Emergency: 911',
          icon: LucideIcons.phone,
          onPressed: () => launchUrl(Uri.parse('tel:911')),
        ),
        AppButton.outline(
          label: es ? 'Crisis: 988' : 'Crisis: 988',
          icon: LucideIcons.messageCircle,
          onPressed: () => launchUrl(Uri.parse('tel:988')),
        ),
      ],
    );
  }
}
