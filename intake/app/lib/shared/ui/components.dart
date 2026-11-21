import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

enum _ButtonKind { primary, secondary, quiet, danger, outline }

/// A button named for what it means here, not for the kit's options.
class AppButton extends StatelessWidget {
  const AppButton.primary({super.key, required this.label, this.icon, this.onPressed, this.expand = false})
    : _kind = _ButtonKind.primary;
  const AppButton.secondary({super.key, required this.label, this.icon, this.onPressed, this.expand = false})
    : _kind = _ButtonKind.secondary;
  const AppButton.outline({super.key, required this.label, this.icon, this.onPressed, this.expand = false})
    : _kind = _ButtonKind.outline;
  const AppButton.quiet({super.key, required this.label, this.icon, this.onPressed, this.expand = false})
    : _kind = _ButtonKind.quiet;
  const AppButton.danger({super.key, required this.label, this.icon, this.onPressed, this.expand = false})
    : _kind = _ButtonKind.danger;

  final String label;
  final IconData? icon;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Fill the available width.
  final bool expand;
  final _ButtonKind _kind;

  @override
  Widget build(BuildContext context) {
    final leading = icon == null ? null : Icon(icon, size: 16);
    final child = Text(label);
    final width = expand ? double.infinity : null;
    // 48 dp minimum tap target.
    const height = 48.0;
    return switch (_kind) {
      _ButtonKind.primary => ShadButton(
        onPressed: onPressed,
        leading: leading,
        width: width,
        height: height,
        child: child,
      ),
      _ButtonKind.secondary => ShadButton.secondary(
        onPressed: onPressed,
        leading: leading,
        width: width,
        height: height,
        child: child,
      ),
      _ButtonKind.outline => ShadButton.outline(
        onPressed: onPressed,
        leading: leading,
        width: width,
        height: height,
        child: child,
      ),
      _ButtonKind.quiet => ShadButton.ghost(
        onPressed: onPressed,
        leading: leading,
        width: width,
        height: height,
        child: child,
      ),
      _ButtonKind.danger => ShadButton.destructive(
        onPressed: onPressed,
        leading: leading,
        width: width,
        height: height,
        child: child,
      ),
    };
  }
}

/// A round icon-only button with a spoken label, for the mic.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.size = 72,
    this.highlighted = false,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;

  /// Draws it filled (primary) instead of outlined.
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: size * 0.4);
    final shape = BorderRadius.circular(size / 2);
    final button = highlighted
        ? ShadButton(
            onPressed: onPressed,
            width: size,
            height: size,
            padding: EdgeInsets.zero,
            decoration: ShadDecoration(border: ShadBorder.all(radius: shape)),
            child: iconWidget,
          )
        : ShadButton.outline(
            onPressed: onPressed,
            width: size,
            height: size,
            padding: EdgeInsets.zero,
            decoration: ShadDecoration(border: ShadBorder.all(radius: shape)),
            child: iconWidget,
          );
    return Semantics(
      button: true,
      label: semanticLabel,
      enabled: onPressed != null,
      excludeSemantics: true,
      child: button,
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({super.key, this.title, this.description, this.child, this.footer, this.muted = false});

  final String? title;
  final String? description;
  final Widget? child;
  final Widget? footer;

  /// The quieter surface used for assistant bubbles.
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ShadCard(
      title: title == null ? null : Text(title!),
      description: description == null ? null : Text(description!),
      footer: footer,
      backgroundColor: muted ? theme.colorScheme.muted : null,
      width: double.infinity,
      child: child,
    );
  }
}

enum _AlertKind { info, danger }

/// For a state that holds until something changes. Something the person
/// can retry gets a toast instead ([showAppToast]).
class AppAlert extends StatelessWidget {
  const AppAlert.info({super.key, required this.title, this.description, this.icon}) : _kind = _AlertKind.info;
  const AppAlert.danger({super.key, required this.title, this.description, this.icon}) : _kind = _AlertKind.danger;

  final String title;
  final String? description;
  final IconData? icon;
  final _AlertKind _kind;

  @override
  Widget build(BuildContext context) {
    final desc = description == null ? null : Text(description!);
    return switch (_kind) {
      _AlertKind.info => ShadAlert(icon: Icon(icon ?? LucideIcons.info), title: Text(title), description: desc),
      _AlertKind.danger => ShadAlert.destructive(
        icon: Icon(icon ?? LucideIcons.triangleAlert),
        title: Text(title),
        description: desc,
      ),
    };
  }
}

enum _BadgeKind { neutral, outline, danger }

/// A small label. Status badges always pair a word with an icon.
class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.icon, this.color}) : _kind = _BadgeKind.neutral;
  const AppBadge.outline({super.key, required this.label, this.icon, this.color}) : _kind = _BadgeKind.outline;
  const AppBadge.danger({super.key, required this.label, this.icon, this.color}) : _kind = _BadgeKind.danger;

  final String label;
  final IconData? icon;

  /// Text and icon color; a semantic token from `context.tokens`.
  final Color? color;
  final _BadgeKind _kind;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
        Text(label),
      ],
    );
    return switch (_kind) {
      _BadgeKind.neutral => ShadBadge.secondary(foregroundColor: color, child: child),
      _BadgeKind.outline => ShadBadge.outline(foregroundColor: color, child: child),
      _BadgeKind.danger => ShadBadge.destructive(foregroundColor: color, child: child),
    };
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.placeholder,
    this.onSubmitted,
    this.onChanged,
    this.enabled = true,
    this.semanticLabel,
  });

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: semanticLabel ?? placeholder,
      child: ShadInput(
        controller: controller,
        placeholder: placeholder == null ? null : Text(placeholder!),
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        enabled: enabled,
        textInputAction: TextInputAction.send,
      ),
    );
  }
}

class AppTextArea extends StatelessWidget {
  const AppTextArea({super.key, this.controller, this.placeholder, this.onChanged, this.enabled = true});

  final TextEditingController? controller;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ShadTextarea(
      controller: controller,
      placeholder: placeholder == null ? null : Text(placeholder!),
      onChanged: onChanged,
      enabled: enabled,
    );
  }
}

/// One choice out of a few, such as the EN/ES toggle.
class AppSegmented<T> extends StatelessWidget {
  const AppSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.semanticLabel,
    this.enabled = true,
  });

  /// Value and label, in display order.
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final String? semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      container: true,
      // Scrolls sideways rather than overflow on a narrow phone.
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ShadToggleGroup<T>(
          // A new key per selection keeps the kit's internal value in step with ours.
          key: ValueKey(selected),
          initialValue: selected,
          allowDeselection: false,
          enabled: enabled,
          onChanged: (value) {
            if (value != null && value != selected) onChanged(value);
          },
          items: [
            for (final (value, label) in options)
              ShadToggleGroupItem<T>(
                value: value,
                child: Semantics(selected: value == selected, child: Text(label)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A short toast. Pass [onRetry] for something the person can try again.
void showAppToast(BuildContext context, String message, {String? retryLabel, VoidCallback? onRetry}) {
  final sonner = ShadSonner.of(context);
  final id = Object();
  sonner.show(
    ShadToast(
      id: id,
      title: Text(message),
      action: onRetry == null
          ? null
          : ShadButton.outline(
              height: 48,
              onPressed: () {
                sonner.hide(id);
                onRetry();
              },
              child: Text(retryLabel ?? 'Retry'),
            ),
    ),
  );
}

/// How far along something is, 0 to 1.
class AppProgress extends StatelessWidget {
  const AppProgress({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) => ShadProgress(value: value.clamp(0, 1));
}
