import 'package:flutter_test/flutter_test.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/conversation/data/demo_chat_repository.dart';
import 'package:intake/worker/features/conversation/domain/chat_chunk.dart';
import 'package:intake/worker/features/conversation/domain/turn.dart';

Turn w(String text, [Language l = Language.en]) => Turn(id: text, speaker: Speaker.worker, text: text, language: l);
Turn a(String text, [Language l = Language.en]) => Turn(id: text, speaker: Speaker.assistant, text: text, language: l);

void main() {
  test('asks about what the worker has not covered, one question at a time', () {
    final first = DemoChatRepository.replyFor([w('My throat has been sore for three days')], Language.en);
    expect(first, contains('how bad is it'));
    expect(first, isNot(contains('How long')));
    expect('?'.allMatches(first), hasLength(1));
  });

  test('works through every topic, then wraps up without advice', () {
    final turns = <Turn>[w('I have a headache')];
    for (var i = 0; i < 6; i++) {
      turns
        ..add(a(DemoChatRepository.replyFor(turns, Language.en)))
        ..add(w('ok'));
    }
    final last = DemoChatRepository.replyFor(turns, Language.en);
    expect(last, contains('Tap Finish'));
    final said = turns.where((t) => t.speaker == Speaker.assistant).map((t) => t.text.toLowerCase()).join(' ');
    for (final banned in ['mg', 'dose', 'diagnos', 'you have', 'you should take']) {
      expect(said, isNot(contains(banned)));
    }
  });

  test('replies in Spanish', () {
    final reply = DemoChatRepository.replyFor([w('Me duele la garganta', Language.es)], Language.es);
    expect(reply, startsWith('Gracias por contarme.'));
    expect(reply, contains('¿Desde hace cuánto tiempo'));
  });

  test('streams word by word and ends with done', () async {
    final chunks = await DemoChatRepository(wordDelay: Duration.zero)
        .reply(conversationId: 'c', turnId: 't', language: Language.en, turns: [w('hi')])
        .toList();
    expect(chunks.last, const ChatChunk.done());
    expect(chunks.whereType<ChatDelta>().length, greaterThan(3));
  });
}
