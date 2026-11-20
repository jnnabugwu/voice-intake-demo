/// The design system. Screens import this file and never `shadcn_ui`
/// directly, so a kit upgrade or swap touches `shared/ui/` and `app/` only.
library;

export 'package:shadcn_ui/shadcn_ui.dart' show LucideIcons;

export 'package:intake/shared/ui/components.dart';
export 'package:intake/shared/ui/theme.dart';
