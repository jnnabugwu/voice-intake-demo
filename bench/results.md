# Speech bench results

_Generated 2026-11-23 by `npm run bench` from `bench/references.json`._

| Engine | Speaker | Lines | WER | Medical-term miss rate | Live: first word | Live: final text | Batch: processing |
|---|---|---|---|---|---|---|---|
| Apple SpeechAnalyzer (on-device) | en_jn (en-US) | 20 | 14.6% | 13.3% | n/a | n/a | 0.16 s |
| AssemblyAI (cloud) | en_jn (en-US) | 20 | 10.3% | 6.7% | n/a | n/a | 3.78 s |
| Whisper large-v3-turbo (self-hosted) | en_jn (en-US) | 20 | 9.3% | 10.0% | n/a | n/a | 1.11 s |
| Apple SpeechAnalyzer (on-device) | es_mx (es-MX) | 21 | 11.5% | 28.6% | n/a | n/a | 0.18 s |
| AssemblyAI (cloud) | es_mx (es-MX) | 21 | 3.7% | 4.8% | n/a | n/a | 3.91 s |
| Whisper large-v3-turbo (self-hosted) | es_mx (es-MX) | 21 | 9.8% | 20.6% | n/a | n/a | 1.15 s |

Latency columns are medians and measure different things. **Live** (Chrome Web Speech, read aloud on `/bench`): time from mic on to the first partial word, and to the final text. **Batch** (file engines): wall-clock time per clip. For AssemblyAI that is upload, queue and transcription. For Apple and Whisper it is compute on the bench machine (named below), and Whisper's includes loading the model each time. Don't compare live and batch numbers with each other.

## Missed medical terms

**Apple SpeechAnalyzer (on-device), en_jn:** line 1 (swallow); line 4 (metformin); line 6 (lower back); line 9 (lisinopril); line 11 (warfarin); line 12 (amoxicillin); line 14 (blood sugar); line 21 (metformin)

**AssemblyAI (cloud), en_jn:** line 1 (swallow); line 9 (lisinopril); line 12 (amoxicillin); line 14 (blood sugar)

**Whisper large-v3-turbo (self-hosted), en_jn:** line 1 (swallow); line 4 (metformin); line 9 (lisinopril); line 11 (warfarin); line 12 (amoxicillin); line 14 (blood sugar)

**Apple SpeechAnalyzer (on-device), es_mx:** line 4 (metformina, 500 miligramos); line 6 (cargar); line 8 (infección de oído); line 9 (lisinopril); line 10 (alergia, ronchas); line 11 (ibuprofeno, anticoagulante, warfarina); line 12 (farmacia, amoxicilina); line 13 (150/95); line 16 (45 dólares, urgencias); line 19 (tos); line 21 (diabetes tipo 2, metformina)

**AssemblyAI (cloud), es_mx:** line 1 (tragar); line 10 (ronchas); line 16 (urgencias)

**Whisper large-v3-turbo (self-hosted), es_mx:** line 1 (tragar); line 7 (mareo, borroso); line 8 (infección de oído); line 9 (lisinopril); line 10 (alergia, ronchas); line 11 (warfarina); line 12 (amoxicilina); line 16 (urgencias); line 18 (sarpullido); line 19 (tos); line 21 (sala de emergencias)


## About this sample

- 21 scripted care-request lines per speaker, read aloud: one speaker per accent (en_jn: en-US, es_cu: es-US, es_mx: es-MX). Read speech is easier than real conversations. Treat these numbers as directional, not definitive.
- WER and term matching follow the `scoring` rule in `references.json`: lowercase, punctuation stripped, spoken numbers as digits, accents folded. A key term counts as found if any accepted variant appears.
- Every engine is scored against the script. Readers sometimes added words (a greeting, an "um") or dropped a few. That adds noise to WER, and not evenly: an ad-lib counts against an engine only if it transcribes it.
- Scores only. The recordings stay private and are never published.
- en_jn_19 is 0.7 s long, an empty take, so it isn't scored. Re-record it.
- Local engines ran on Apple M4 Pro (darwin arm64).
- No clips yet for: es_cu.
