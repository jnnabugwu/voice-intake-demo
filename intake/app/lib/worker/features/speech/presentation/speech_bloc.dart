import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intake/shared/core/ids.dart';
import 'package:intake/shared/core/language.dart';
import 'package:intake/worker/features/speech/domain/speech_engine.dart';
import 'package:intake/worker/features/speech/domain/utterance.dart';
import 'package:intake/worker/features/speech/presentation/speech_event.dart';
import 'package:intake/worker/features/speech/presentation/speech_state.dart';

export 'package:intake/worker/features/speech/presentation/speech_event.dart';
export 'package:intake/worker/features/speech/presentation/speech_state.dart';

/// Owns the mic: status, language, live partial text and the last utterance.
class SpeechBloc extends Bloc<SpeechEvent, SpeechState> {
  SpeechBloc(this._engine, this._ids) : super(const SpeechState()) {
    on<SpeechStarted>(_onStarted, transformer: droppable());
    on<SpeechStopped>(_onStopped);
    on<SpeechLanguageChanged>(_onLanguageChanged);
  }

  final SpeechEngine _engine;
  final IdGenerator _ids;

  Future<void> _onStarted(SpeechStarted event, Emitter<SpeechState> emit) async {
    final language = state.language;
    emit(state.copyWith(phase: const SpeechPhase.starting()));
    var heard = '';
    var ended = false;

    await emit.forEach<SpeechResult>(
      _engine.listen(localeId: language.localeId),
      onData: (result) {
        switch (result) {
          case SpeechPartial(:final text):
            heard = text;
            return state.copyWith(phase: SpeechPhase.listening(partial: text));
          case SpeechCompleted(:final text):
            ended = true;
            return _finished(text.trim().isEmpty ? heard : text, language);
          case SpeechFailed(:final failure):
            ended = true;
            return state.copyWith(phase: SpeechPhase.unavailable(failure: failure));
        }
      },
    );
    // An engine that closed without a terminal value: keep what was heard.
    if (!ended && !isClosed) emit(_finished(heard, language));
  }

  SpeechState _finished(String text, Language language) {
    final trimmed = text.trim();
    return state.copyWith(
      phase: const SpeechPhase.idle(),
      lastUtterance: trimmed.isEmpty
          ? state.lastUtterance
          : Utterance(id: _ids.next('u'), text: trimmed, language: language),
    );
  }

  Future<void> _onStopped(SpeechStopped event, Emitter<SpeechState> emit) => _engine.stop();

  Future<void> _onLanguageChanged(SpeechLanguageChanged event, Emitter<SpeechState> emit) async {
    if (event.language == state.language) return;
    if (state.phase is SpeechListening || state.phase is SpeechStarting) await _engine.stop();
    emit(state.copyWith(language: event.language));
  }

  @override
  Future<void> close() async {
    await _engine.stop();
    return super.close();
  }
}
