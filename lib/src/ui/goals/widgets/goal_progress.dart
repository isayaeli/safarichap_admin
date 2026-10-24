import 'package:flutter/material.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/data/models/goal/goal.dart';

/// Paid amount over a thin progress bar.
class GoalProgress extends StatelessWidget {
  final GoalSummary goal;
  const GoalProgress({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${goal.paid.formatted} · ${(goal.progress * 100).round()}%',
          style: const TextStyle(fontSize: 12.5),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: goal.progress,
            minHeight: 5,
            backgroundColor: scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
