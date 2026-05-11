import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/reports_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../../../shared/widgets/trend_chart.dart';
import '../providers/reports_provider.dart';

class WeeklyReportScreen extends ConsumerWidget {
  final String childId;
  final String childName;

  const WeeklyReportScreen({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now    = DateTime.now();
    final from   = now.subtract(const Duration(days: 30));
    final params = ReportParams(childId: childId, from: from, to: now);
    final report = ref.watch(progressReportProvider(params));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('$childName — Progress Report'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: report.when(
        loading: () => const sw.LoadingWidget(),
        error:   (e, _) => sw.ErrorWidget(message: e.toString()),
        data:    (r) => _ReportBody(report: r),
      ),
    );
  }
}

class _ReportBody extends StatelessWidget {
  final ProgressReport report;

  const _ReportBody({required this.report});

  @override
  Widget build(BuildContext context) {
    final ratings = report.sessions
        .map<double>((s) => ((s['rating'] as num?) ?? 0).toDouble())
        .toList();
    final labels  = List.generate(
      ratings.length,
      (i) => 'S${i + 1}',
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryRow(
          sessionCount:  report.totalSessions,
          avgRating:     report.avgRating,
          compliancePct: report.compliancePct,
        ),
        const SizedBox(height: 20),
        if (ratings.isNotEmpty)
          AppCard(
            child: TrendChart(
              title:  'Session Ratings',
              values: ratings,
              labels: labels,
            ),
          ),
        const SizedBox(height: 20),
        AppCard(
          child: _ComplianceBar(pct: report.compliancePct),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int sessionCount;
  final double avgRating;
  final double compliancePct;

  const _SummaryRow({
    required this.sessionCount,
    required this.avgRating,
    required this.compliancePct,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _KpiCard(label: 'Sessions', value: '$sessionCount')),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Avg Rating', value: avgRating.toStringAsFixed(1))),
        const SizedBox(width: 12),
        Expanded(child: _KpiCard(label: 'Compliance', value: '${compliancePct.round()}%')),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;

  const _KpiCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.primaryBlue)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ComplianceBar extends StatelessWidget {
  final double pct;
  const _ComplianceBar({required this.pct});

  @override
  Widget build(BuildContext context) {
    final color = pct >= 70
        ? AppColors.mintGreen
        : pct >= 40
            ? AppColors.warmYellow
            : AppColors.softCoral;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Home Plan Compliance',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  minHeight: 12,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text('${pct.round()}%',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ],
    );
  }
}
