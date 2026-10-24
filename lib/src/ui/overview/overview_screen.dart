import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safarichap_admin/src/core/components/section_card.dart';
import 'package:safarichap_admin/src/core/components/skeleton.dart';
import 'package:safarichap_admin/src/core/components/stat_tile.dart';
import 'package:safarichap_admin/src/core/money/currency.dart';
import 'package:safarichap_admin/src/core/money/money.dart';
import 'package:safarichap_admin/src/core/money/money_formatter.dart';
import 'package:safarichap_admin/src/core/resources/colors.dart';
import 'package:safarichap_admin/src/data/models/stats/stats.dart';
import 'package:safarichap_admin/src/st/st.dart';
import 'package:safarichap_admin/src/ui/onboarding/session_controller.dart';
import 'package:safarichap_admin/src/ui/shell/admin_section.dart';
import 'package:safarichap_admin/src/ui/shell/shell_controller.dart';

import 'overview_controller.dart';
import 'widgets/daily_bar_chart.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _controller = Get.put(OverviewController(sl()));
  final ShellController _shell = Get.find();
  final SessionController _session = Get.find();

  @override
  void dispose() {
    Get.delete<OverviewController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = _controller.stats.value;
      return PageBody(
        title: "Overview".tr,
        subtitle: "Last @days days".trParams({
          'days': '${_controller.days.value}',
        }),
        actions: [
          SegmentedButton<int>(
            segments: [
              for (final d in const [7, 30, 90])
                ButtonSegment(
                  value: d,
                  label: Text("@days days".trParams({'days': '$d'})),
                ),
            ],
            selected: {_controller.days.value},
            onSelectionChanged: (s) => _controller.setDays(s.first),
          ),
          IconButton(
            tooltip: "Refresh".tr,
            onPressed: _controller.getStats,
            icon: const Icon(Icons.refresh),
          ),
        ],
        children: stats == null ? [_loading()] : _content(stats),
      );
    });
  }

  Widget _loading() =>
      _TileGrid(children: List.generate(8, (_) => const Skeleton(height: 96)));

  void _go(AdminSection section) {
    if (_session.can(section.permission)) _shell.select(section);
  }

  List<String> _moneyLines(List<Money> values) =>
      values.isEmpty ? ['-'] : [for (final m in values) m.formatted];

  List<Widget> _content(AdminStats s) {
    final goals = s.goals;
    final collected = _moneyLines(s.collectedInPeriod);
    return [
      _TileGrid(
        children: [
          StatTile(
            label: "Collected (period)".tr,
            value: collected.first,
            details: collected.skip(1).toList(),
            icon: Icons.payments_outlined,
            onTap: () => _go(AdminSection.payments),
          ),
          StatTile(
            label: "Still to collect on open goals".tr,
            value: _moneyLines(s.outstanding).first,
            details: _moneyLines(s.outstanding).skip(1).toList(),
            icon: Icons.account_balance_wallet_outlined,
            accent: safariChapColors.secondaryColor,
          ),
          StatTile(
            label: "Active goals".tr,
            value: '${goals['active'] ?? 0}',
            details: [
              "@n paused".trParams({'n': '${goals['paused'] ?? 0}'}),
              "@n expired".trParams({'n': '${goals['expired'] ?? 0}'}),
            ],
            icon: Icons.savings_outlined,
            onTap: () => _go(AdminSection.goals),
          ),
          StatTile(
            label: "Customers".tr,
            value: '${s.users['total'] ?? 0}',
            details: [
              "@n new".trParams({'n': '${s.users['new'] ?? 0}'}),
            ],
            icon: Icons.people_alt_outlined,
            onTap: () => _go(AdminSection.users),
          ),
          StatTile(
            label: "Pending payments".tr,
            value: '${s.payments['pending'] ?? 0}',
            details: [
              "@n failed in period".trParams({
                'n': '${s.payments['failed_in_period'] ?? 0}',
              }),
            ],
            icon: Icons.hourglass_bottom_outlined,
            accent: Colors.orange,
            onTap: () => _go(AdminSection.payments),
          ),
          StatTile(
            label: "Open refunds".tr,
            value: '${s.refundsOpen}',
            details: [
              if (s.refundsFailed > 0)
                "@n failed".trParams({'n': '${s.refundsFailed}'}),
              ..._moneyLines(s.refundsOpenAmount).where((l) => l != '-'),
            ],
            icon: Icons.currency_exchange_outlined,
            accent: s.refundsFailed > 0 ? Colors.red : Colors.orange,
            onTap: () => _go(AdminSection.refunds),
          ),
          StatTile(
            label: "KYC waiting".tr,
            value: '${s.kycPending}',
            icon: Icons.badge_outlined,
            accent: Colors.blue,
            onTap: () => _go(AdminSection.kyc),
          ),
          StatTile(
            label: "Upcoming trips".tr,
            value: '${s.bookings['upcoming'] ?? 0}',
            details: [
              "@n in the next 30 days".trParams({
                'n': '${s.bookings['next_30_days'] ?? 0}',
              }),
            ],
            icon: Icons.flight_takeoff_outlined,
            accent: Colors.green,
            onTap: () => _go(AdminSection.bookings),
          ),
        ],
      ),
      _CollectionsCard(stats: s, controller: _controller),
      LayoutBuilder(
        builder: (context, constraints) {
          final signups = _SignupsCard(stats: s);
          final top = _TopTripsCard(stats: s);
          if (constraints.maxWidth < 800) {
            return Column(children: [signups, const SizedBox(height: 16), top]);
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: signups),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: top),
            ],
          );
        },
      ),
    ];
  }
}

class _TileGrid extends StatelessWidget {
  final List<Widget> children;
  const _TileGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / 270).floor().clamp(1, 4);
        final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in children) SizedBox(width: width, child: c),
          ],
        );
      },
    );
  }
}

class _CollectionsCard extends StatelessWidget {
  final AdminStats stats;
  final OverviewController controller;
  const _CollectionsCard({required this.stats, required this.controller});

  @override
  Widget build(BuildContext context) {
    final currencies = {
      for (final p in stats.collectionsSeries) p.amount.currency,
      Currency.tzs,
    }.toList()..sort((a, b) => a.index.compareTo(b.index));
    return Obx(() {
      final currency = controller.chartCurrency.value;
      final values = <DateTime, num>{
        for (final p in stats.collectionsSeries.where(
          (p) => p.amount.currency == currency,
        ))
          DateTime(p.date.year, p.date.month, p.date.day):
              p.amount.minor / currency.minorPerMajor,
      };
      final start = DateTime.now().subtract(Duration(days: stats.days - 1));
      return SectionCard(
        title: "Collections per day (@currency)".trParams({
          'currency': currency.code,
        }),
        actions: [
          if (currencies.length > 1)
            SegmentedButton<Currency>(
              showSelectedIcon: false,
              segments: [
                for (final c in currencies)
                  ButtonSegment(value: c, label: Text(c.code)),
              ],
              selected: {currency},
              onSelectionChanged: (s) =>
                  controller.chartCurrency.value = s.first,
            ),
        ],
        child: SizedBox(
          height: 260,
          child: DailyBarChart(
            start: start,
            days: stats.days,
            values: values,
            formatValue: (v) =>
                Money((v * currency.minorPerMajor).round(), currency).formatted,
            formatAxis: (v) =>
                Money((v * currency.minorPerMajor).round(), currency).compact,
          ),
        ),
      );
    });
  }
}

class _SignupsCard extends StatelessWidget {
  final AdminStats stats;
  const _SignupsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final start = DateTime.now().subtract(Duration(days: stats.days - 1));
    return SectionCard(
      title: "New customers per day".tr,
      child: SizedBox(
        height: 200,
        child: DailyBarChart(
          start: start,
          days: stats.days,
          values: {
            for (final p in stats.signupsSeries)
              DateTime(p.date.year, p.date.month, p.date.day): p.count,
          },
          formatValue: (v) => "@n sign-ups".trParams({'n': '${v.toInt()}'}),
          formatAxis: (v) => v == v.roundToDouble() ? '${v.toInt()}' : '',
        ),
      ),
    );
  }
}

class _TopTripsCard extends StatelessWidget {
  final AdminStats stats;
  const _TopTripsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final max = stats.topItineraries.fold<int>(
      1,
      (a, t) => t.goals > a ? t.goals : a,
    );
    return SectionCard(
      title: "Most saved-for trips".tr,
      child: stats.topItineraries.isEmpty
          ? Text(
              "No goals yet".tr,
              style: TextStyle(color: scheme.onSurfaceVariant),
            )
          : Column(
              children: [
                for (final t in stats.topItineraries)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.title,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              "@n goals".trParams({'n': '${t.goals}'}),
                              style: TextStyle(
                                color: scheme.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: t.goals / max,
                            minHeight: 6,
                            backgroundColor: scheme.outlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
