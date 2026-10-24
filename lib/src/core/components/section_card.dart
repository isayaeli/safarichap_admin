import 'package:flutter/material.dart';

/// A titled card used on detail and form pages.
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget> actions;
  final EdgeInsetsGeometry padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.actions = const [],
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Label / value pair; wraps into a grid via [InfoGrid].
class InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;

  const InfoRow({super.key, required this.label, this.value, this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 2),
        child ??
            SelectableText(
              (value == null || value!.isEmpty) ? '-' : value!,
              style: const TextStyle(fontSize: 14),
            ),
      ],
    );
  }
}

class InfoGrid extends StatelessWidget {
  final List<Widget> children;
  final double itemWidth;

  const InfoGrid({super.key, required this.children, this.itemWidth = 220});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 24,
      runSpacing: 14,
      children: [
        for (final c in children) SizedBox(width: itemWidth, child: c),
      ],
    );
  }
}

/// Max-width scrollable page body with a header row.
class PageBody extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final List<Widget> children;
  final double maxWidth;

  const PageBody({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const [],
    required this.children,
    this.maxWidth = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null || actions.isNotEmpty) ...[
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Text(
                            title!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    Wrap(spacing: 8, runSpacing: 8, children: actions),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              for (final (i, child) in children.indexed) ...[
                if (i > 0) const SizedBox(height: 16),
                child,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
