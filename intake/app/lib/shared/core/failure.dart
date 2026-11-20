/// Every way a repository or engine can fail. The UI picks its message by
/// switching on the type, never by reading text.
///
/// Failures compare by type (and code, where they carry one), so Bloc states
/// that hold a failure have value equality.
sealed class Failure {
  const Failure();

  @override
  bool operator ==(Object other) => other.runtimeType == runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => '$runtimeType';
}

/// The network or the proxy couldn't be reached. Retryable.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// The proxy's per-IP rate limit. Retryable after a moment.
final class RateLimitedFailure extends Failure {
  const RateLimitedFailure();
}

/// The proxy's daily spend cap is reached. Holds until tomorrow.
final class SpendCapFailure extends Failure {
  const SpendCapFailure();
}

/// The browser or the person refused the microphone.
final class MicPermissionFailure extends Failure {
  const MicPermissionFailure();
}

/// No speech recognition in this browser (Firefox, Brave, some in-app browsers).
final class SpeechUnavailableFailure extends Failure {
  const SpeechUnavailableFailure();
}

/// Anything else. [code] is for logs, never for the UI.
final class UnknownFailure extends Failure {
  const UnknownFailure([this.code]);

  final String? code;

  @override
  bool operator ==(Object other) => other is UnknownFailure && other.code == code;

  @override
  int get hashCode => Object.hash(UnknownFailure, code);
}
