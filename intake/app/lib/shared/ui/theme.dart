import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The app's two themes. Slate's cool neutrals keep the screen quiet, so the
/// four status tokens stand out. Only this folder names a color.
abstract final class AppTheme {
  static const _light = {
    'listening': Color(0xff2563eb),
    'pending': Color(0xffb45309),
    'approved': Color(0xff15803d),
    'escalation': Color(0xffb91c1c),
  };

  static const _dark = {
    'listening': Color(0xff60a5fa),
    'pending': Color(0xfffbbf24),
    'approved': Color(0xff4ade80),
    'escalation': Color(0xfff87171),
  };

  static final light = ShadThemeData(
    brightness: Brightness.light,
    colorScheme: const ShadSlateColorScheme.light(custom: _light),
  );

  static final dark = ShadThemeData(
    brightness: Brightness.dark,
    colorScheme: const ShadSlateColorScheme.dark(custom: _dark),
  );
}

/// Semantic colors. A status is never shown by color alone: each token
/// always comes with an icon and a word.
class AppTokens {
  const AppTokens._(this._scheme);

  final ShadColorScheme _scheme;

  /// The mic is live.
  Color get listening => _scheme.custom['listening']!;

  /// Waiting on a clinician.
  Color get pending => _scheme.custom['pending']!;

  /// A clinician approved this.
  Color get approved => _scheme.custom['approved']!;

  /// Emergency or crisis.
  Color get escalation => _scheme.custom['escalation']!;

  Color get background => _scheme.background;
  Color get foreground => _scheme.foreground;
  Color get muted => _scheme.muted;
  Color get mutedForeground => _scheme.mutedForeground;
  Color get border => _scheme.border;
  Color get destructive => _scheme.destructive;
  Color get primary => _scheme.primary;
  Color get primaryForeground => _scheme.primaryForeground;
}

/// The type scale screens may use. Transcript text uses [large]; partial
/// words use [muted] until they turn final; physician fields use [p] and
/// [small].
class AppType {
  const AppType._(this._theme);

  final ShadTextTheme _theme;

  TextStyle get h2 => _theme.h2;
  TextStyle get h3 => _theme.h3;
  TextStyle get h4 => _theme.h4;
  TextStyle get lead => _theme.lead;
  TextStyle get large => _theme.large;
  TextStyle get p => _theme.p;
  TextStyle get small => _theme.small;
  TextStyle get muted => _theme.muted;
}

extension AppThemeContext on BuildContext {
  AppTokens get tokens => AppTokens._(ShadTheme.of(this).colorScheme);
  AppType get type => AppType._(ShadTheme.of(this).textTheme);
}
