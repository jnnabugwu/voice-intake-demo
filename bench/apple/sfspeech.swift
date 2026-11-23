// Apple's older speech engine (SFSpeechRecognizer), the one today's Flutter
// (`speech_to_text`) and React Native (`expo-speech-recognition`) packages call on
// iOS, run on a recorded clip. Built and called by `npm run bench`.
//
//   sfspeech check <locale> [--on-device]             can it run for <locale> here?
//   sfspeech <locale> <file.wav> [--on-device]        transcribe one clip
//
// Without --on-device, Apple picks server or on-device (the packages' default), so
// audio may go to Apple's servers. --on-device is the packages' `onDevice: true`.
//
// Prints one JSON line: {"text": "..."} or {"ok": true}, or {"error": "..."} with exit 1.
// It runs as a small app (`open -W`), not a bare CLI: macOS asks the launching app for
// the speech-recognition usage description, so a bare CLI under a terminal is killed.
import Foundation
import Speech

@main
struct SFSpeech {
  static func main() async {
    let args = Array(CommandLine.arguments.dropFirst())
    let onDevice = args.contains("--on-device")
    let rest = args.filter { $0 != "--on-device" }
    do {
      if rest.count == 2, rest[0] == "check" {
        try await authorize()
        _ = try recognizer(for: rest[1], onDevice: onDevice)
        emit(["ok": true])
      } else if rest.count == 2 {
        try await authorize()
        let text = try await transcribe(locale: rest[0], file: URL(fileURLWithPath: rest[1]), onDevice: onDevice)
        emit(["text": text])
      } else {
        throw Failure("usage: sfspeech check <locale> [--on-device] | sfspeech <locale> <file.wav> [--on-device]")
      }
    } catch {
      emit(["error": "\(error)"])
      exit(1)
    }
  }

  static func authorize() async throws {
    let status = await withCheckedContinuation { done in
      SFSpeechRecognizer.requestAuthorization { done.resume(returning: $0) }
    }
    guard status == .authorized else {
      throw Failure(
        "speech recognition isn't allowed (status \(status.rawValue)); allow \"Speech bench\" in System Settings > Privacy & Security > Speech Recognition")
    }
  }

  static func recognizer(for locale: String, onDevice: Bool) throws -> SFSpeechRecognizer {
    guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: locale)) else {
      throw Failure("locale \(locale) isn't supported")
    }
    guard recognizer.isAvailable else { throw Failure("the recognizer for \(locale) isn't available right now") }
    if onDevice, !recognizer.supportsOnDeviceRecognition {
      throw Failure("no on-device model for \(locale) on this Mac")
    }
    return recognizer
  }

  static func transcribe(locale: String, file: URL, onDevice: Bool) async throws -> String {
    let recognizer = try recognizer(for: locale, onDevice: onDevice)
    // Callbacks on a background queue: the main queue belongs to the async main.
    recognizer.queue = OperationQueue()
    let request = SFSpeechURLRecognitionRequest(url: file)
    request.shouldReportPartialResults = false
    request.requiresOnDeviceRecognition = onDevice

    let once = Once()
    return try await withCheckedThrowingContinuation { done in
      let task = recognizer.recognitionTask(with: request) { result, error in
        if let result, result.isFinal {
          if once.claim() { done.resume(returning: result.bestTranscription.formattedString) }
        } else if let error = error as NSError? {
          // 1110: no speech detected. That's an empty transcript, not a failure.
          if error.domain == "kAFAssistantErrorDomain", error.code == 1110 {
            if once.claim() { done.resume(returning: "") }
          } else if once.claim() {
            done.resume(throwing: Failure("\(error.domain) \(error.code): \(error.localizedDescription)"))
          }
        }
      }
      _ = task
    }
  }

  static func emit(_ object: [String: Any]) {
    let data = (try? JSONSerialization.data(withJSONObject: object)) ?? Data(#"{"error":"couldn't encode the result"}"#.utf8)
    FileHandle.standardOutput.write(data + Data("\n".utf8))
  }

  /// The callback can fire more than once; the continuation resumes exactly once.
  final class Once: @unchecked Sendable {
    private let lock = NSLock()
    private var used = false
    func claim() -> Bool {
      lock.lock()
      defer { lock.unlock() }
      if used { return false }
      used = true
      return true
    }
  }

  struct Failure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
  }
}
