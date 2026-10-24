import 'package:flutter/material.dart';

enum BusyButtonKind { filled, tonal, outlined, text }

/// A Material button that shows a small spinner in place of its icon while
/// [busy], and can't be pressed again until the request finishes.
class BusyButton extends StatelessWidget {
  /// Already translated by the caller, like a plain button's child.
  final String label;
  final IconData? icon;
  final bool busy;
  final VoidCallback? onPressed;
  final BusyButtonKind kind;
  final ButtonStyle? style;

  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
    this.icon,
    this.kind = BusyButtonKind.filled,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final pressed = busy ? null : onPressed;
    final child = Text(label);
    final Widget? leading = busy
        ? const SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : icon == null
        ? null
        : Icon(icon, size: 18);

    if (leading == null) {
      return switch (kind) {
        BusyButtonKind.filled => FilledButton(
          style: style,
          onPressed: pressed,
          child: child,
        ),
        BusyButtonKind.tonal => FilledButton.tonal(
          style: style,
          onPressed: pressed,
          child: child,
        ),
        BusyButtonKind.outlined => OutlinedButton(
          style: style,
          onPressed: pressed,
          child: child,
        ),
        BusyButtonKind.text => TextButton(
          style: style,
          onPressed: pressed,
          child: child,
        ),
      };
    }
    return switch (kind) {
      BusyButtonKind.filled => FilledButton.icon(
        style: style,
        onPressed: pressed,
        icon: leading,
        label: child,
      ),
      BusyButtonKind.tonal => FilledButton.tonalIcon(
        style: style,
        onPressed: pressed,
        icon: leading,
        label: child,
      ),
      BusyButtonKind.outlined => OutlinedButton.icon(
        style: style,
        onPressed: pressed,
        icon: leading,
        label: child,
      ),
      BusyButtonKind.text => TextButton.icon(
        style: style,
        onPressed: pressed,
        icon: leading,
        label: child,
      ),
    };
  }
}
