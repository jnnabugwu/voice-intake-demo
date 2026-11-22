// Apple's on-device speech engine (SpeechAnalyzer + SpeechTranscriber), the one an
// iPhone build would use, run on a recorded clip. Built and called by `npm run bench`.
//
//   transcribe prepare <locale>        download the on-device model for <locale> if needed
//   transcribe <locale> <file.wav>     print the final transcript
//
// Audio never leaves the machine.
import AVFoundation
import Foundation
import Speech

@main
struct Transcribe {
  static func main() async {
    let args = CommandLine.arguments
    do {
      if args.count == 3, args[1] == "prepare" {
        _ = try await transcriber(for: args[2], install: true)
      } else if args.count == 3 {
        print(try await transcribe(locale: args[1], file: URL(fileURLWithPath: args[2])))
      } else {
        fail("usage: transcribe prepare <locale> | transcribe <locale> <file.wav>")
      }
    } catch {
      fail("\(error)")
    }
  }

  static func transcriber(for identifier: String, install: Bool) async throws -> SpeechTranscriber {
    guard let locale = await SpeechTranscriber.supportedLocale(equivalentTo: Locale(identifier: identifier)) else {
      throw Failure("locale \(identifier) isn't supported on this Mac")
    }
    let module = SpeechTranscriber(locale: locale, preset: .transcription)
    if install, let request = try await AssetInventory.assetInstallationRequest(supporting: [module]) {
      try await request.downloadAndInstall()
    }
    return module
  }

  static func transcribe(locale: String, file: URL) async throws -> String {
    let module = try await transcriber(for: locale, install: false)
    let audio = try AVAudioFile(forReading: file)
    let collect = Task {
      var text = ""
      for try await result in module.results where result.isFinal { text += String(result.text.characters) }
      return text
    }
    let analyzer = SpeechAnalyzer(modules: [module])
    if let end = try await analyzer.analyzeSequence(from: audio) {
      try await analyzer.finalizeAndFinish(through: end)
    } else {
      await analyzer.cancelAndFinishNow()
    }
    return try await collect.value.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  struct Failure: Error, CustomStringConvertible {
    let description: String
    init(_ description: String) { self.description = description }
  }

  static func fail(_ message: String) -> Never {
    FileHandle.standardError.write(Data((message + "\n").utf8))
    exit(1)
  }
}
