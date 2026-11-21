import 'dart:async';

import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

/// Scripted replies chosen by keywords, so a clean clone runs a whole intake
/// with zero keys. It asks about whatever the worker hasn't covered yet, one
/// question at a time, and never diagnoses or advises.
class DemoChatRepository implements ChatRepository {
  DemoChatRepository({this.wordDelay = const Duration(milliseconds: 35)});

  /// Pause between streamed words; zero in tests.
  final Duration wordDelay;

  @override
  Stream<ChatChunk> reply({
    required String conversationId,
    required String turnId,
    required Language language,
    required List<Turn> turns,
  }) async* {
    final text = replyFor(turns, language);
    final words = text.split(' ');
    for (var i = 0; i < words.length; i++) {
      if (wordDelay > Duration.zero) await Future<void>.delayed(wordDelay);
      yield ChatChunk.delta(i == 0 ? words[i] : ' ${words[i]}');
    }
    yield const ChatChunk.done();
  }

  /// The whole reply for the conversation so far. Public for tests.
  static String replyFor(List<Turn> turns, Language language) {
    final script = _scripts[language]!;
    final said = turns.where((t) => t.speaker == Speaker.worker).map((t) => t.text.toLowerCase()).join(' \n ');
    final asked = turns.where((t) => t.speaker == Speaker.assistant).map((t) => t.text).join(' \n ');
    final isFirst = !turns.any((t) => t.speaker == Speaker.assistant);

    for (final topic in _Topic.values) {
      final question = script.questions[topic]!;
      if (asked.contains(question)) continue;
      if (_patterns[topic]!.hasMatch(said)) continue;
      return '${isFirst ? script.firstAck : script.ack} $question';
    }
    return script.wrapUp;
  }

  static final _patterns = {
    _Topic.duration: RegExp(
      r'\b(\d+|one|two|three|four|five|six|seven|a|un|una|dos|tres|cuatro|cinco)\s+(hours?|days?|weeks?|months?|horas?|d[ií]as?|semanas?|mes(es)?)\b'
      r'|\b(yesterday|since|last night|this morning|ayer|desde|anoche|esta mañana)\b',
    ),
    _Topic.severity: RegExp(
      r'\b(\d+|ten|diez)\s*(/|out of|de|sobre)\s*(10|ten|diez)\b|\b(mild|moderate|severe|terrible|leve|moderad[oa]|fuerte|grave)\b',
    ),
    _Topic.otherSymptoms: RegExp(r'\b(also|and also|fever|cough|nausea|también|fiebre|tos|náuseas)\b'),
    _Topic.medications: RegExp(
      r'\b(take|taking|medication|medicine|pills?|mg|milligrams?|allerg\w*|tomo|tomando|medicamentos?|medicina|pastillas?|miligramos|alérgic\w*|alergia)\b',
    ),
  };

  static const _scripts = {
    Language.en: _Script(
      firstAck: "Thanks for telling me. I'll ask a few short questions so a clinician can review this.",
      ack: 'Got it, thank you.',
      questions: {
        _Topic.duration: 'How long has this been going on?',
        _Topic.severity: 'On a scale of 1 to 10, how bad is it right now?',
        _Topic.otherSymptoms: 'Is anything else bothering you, like a fever or a cough?',
        _Topic.medications: 'Do you take any medications, or have any allergies?',
      },
      wrapUp:
          "Thank you, that's everything I need. Tap Finish and a clinician will review it. "
          "You'll see the next step here once they approve it.",
    ),
    Language.es: _Script(
      firstAck: 'Gracias por contarme. Le haré unas preguntas cortas para que un médico lo revise.',
      ack: 'Entendido, gracias.',
      questions: {
        _Topic.duration: '¿Desde hace cuánto tiempo le pasa esto?',
        _Topic.severity: 'Del 1 al 10, ¿qué tan fuerte es ahora?',
        _Topic.otherSymptoms: '¿Le molesta algo más, como fiebre o tos?',
        _Topic.medications: '¿Toma algún medicamento o tiene alguna alergia?',
      },
      wrapUp:
          'Gracias, es todo lo que necesito. Toque Terminar y un médico lo revisará. '
          'Verá el siguiente paso aquí cuando lo apruebe.',
    ),
  };
}

enum _Topic { duration, severity, otherSymptoms, medications }

class _Script {
  const _Script({required this.firstAck, required this.ack, required this.questions, required this.wrapUp});

  final String firstAck;
  final String ack;
  final Map<_Topic, String> questions;
  final String wrapUp;
}
