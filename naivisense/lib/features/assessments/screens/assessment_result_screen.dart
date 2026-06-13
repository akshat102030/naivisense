import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/assessment.dart';
import '../../../data/models/child.dart';
import '../data/assessment_domains.dart';

class AssessmentResultScreen extends StatelessWidget {
  final AssessmentModel assessment;
  final ChildModel child;

  const AssessmentResultScreen({
    super.key,
    required this.assessment,
    required this.child,
  });

  Color get _riskColor => switch (assessment.riskLevel) {
        'green' => AppColors.mintGreen,
        'red'   => AppColors.softCoral,
        _       => AppColors.warmYellow,
      };

  String get _riskLabel => switch (assessment.riskLevel) {
        'green' => 'Low Risk',
        'red'   => 'High Risk',
        _       => 'Moderate Risk',
      };

  String get _riskMessage => switch (assessment.riskLevel) {
        'green' => 'The child is performing well overall. Continue current therapy plan.',
        'red'   => 'Multiple areas need immediate attention. Intensive therapy recommended.',
        _       => 'Some areas need focused intervention. Review therapy goals.',
      };

  @override
  Widget build(BuildContext context) {
    final scores = assessment.domainScores.toKeyedMap();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${child.name} — Assessment Report'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          TextButton.icon(
            onPressed: () =>
                Navigator.popUntil(context, (r) => r.isFirst),
            icon:  const Icon(Icons.home_outlined, size: 18),
            label: const Text('Home'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overall score card
          _buildOverallCard(context),
          const SizedBox(height: 20),

          // Risk level
          _buildRiskCard(context),
          const SizedBox(height: 20),

          // Domain scores
          Text('Domain Breakdown',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
          const SizedBox(height: 12),
          ...kAssessmentDomains.map((domain) {
            final score = scores[domain.key] ?? 0;
            return _DomainScoreBar(
              domain: domain,
              score:  score,
            );
          }),
          const SizedBox(height: 20),

          // Concern areas
          _buildConcernAreas(context, scores),
          const SizedBox(height: 20),

          // Strength areas
          _buildStrengthAreas(context, scores),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildOverallCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _riskColor.withValues(alpha: 0.9),
            _riskColor.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            '${assessment.overallScorePct.toStringAsFixed(0)}%',
            style: const TextStyle(
              color:      Colors.white,
              fontSize:   56,
              fontWeight: FontWeight.w800,
              height:     1,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Overall Assessment Score',
              style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 12),
          Text(
            _typeLabel(assessment.type),
            style: const TextStyle(
                color:      Colors.white,
                fontSize:   13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            _formatDate(assessment.date),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _riskColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: _riskColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:        _riskColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_riskIcon, color: _riskColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _riskLabel,
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: _riskColor),
                ),
                const SizedBox(height: 2),
                Text(
                  _riskMessage,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConcernAreas(
      BuildContext context, Map<String, double> scores) {
    final concerns = kAssessmentDomains
        .where((d) => (scores[d.key] ?? 0) < 40)
        .toList();
    if (concerns.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Areas of Concern',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.softCoral,
                )),
        const SizedBox(height: 8),
        Wrap(
          spacing:    8,
          runSpacing: 8,
          children: concerns
              .map((d) => _AreaChip(
                    label: d.title,
                    color: AppColors.softCoral,
                    icon:  d.icon,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildStrengthAreas(
      BuildContext context, Map<String, double> scores) {
    final strengths = kAssessmentDomains
        .where((d) => (scores[d.key] ?? 0) >= 70)
        .toList();
    if (strengths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Strength Areas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.mintGreen,
                )),
        const SizedBox(height: 8),
        Wrap(
          spacing:    8,
          runSpacing: 8,
          children: strengths
              .map((d) => _AreaChip(
                    label: d.title,
                    color: AppColors.mintGreen,
                    icon:  d.icon,
                  ))
              .toList(),
        ),
      ],
    );
  }

  IconData get _riskIcon => switch (assessment.riskLevel) {
        'green' => Icons.check_circle_outline,
        'red'   => Icons.error_outline,
        _       => Icons.warning_amber_outlined,
      };

  String _typeLabel(String t) => switch (t) {
        'initial'   => 'Initial Baseline Assessment',
        'monthly'   => 'Monthly Reassessment',
        'quarterly' => 'Quarterly Review',
        _           => t,
      };

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')} '
      '${_months[d.month - 1]} '
      '${d.year}';

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];
}

// ── Domain Score Bar ──────────────────────────────────────────────────────

class _DomainScoreBar extends StatelessWidget {
  final AssessmentDomain domain;
  final double score;

  const _DomainScoreBar({required this.domain, required this.score});

  Color get _barColor {
    if (score >= 70) return AppColors.mintGreen;
    if (score >= 40) return AppColors.warmYellow;
    return AppColors.softCoral;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Icon(domain.icon, size: 18, color: domain.color),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              domain.title,
              style: const TextStyle(fontSize: 12),
              maxLines:  1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value:           score / 100,
                minHeight:       10,
                backgroundColor: AppColors.divider,
                color:           _barColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 38,
            child: Text(
              '${score.toStringAsFixed(0)}%',
              style: TextStyle(
                  fontSize:   12,
                  fontWeight: FontWeight.w600,
                  color:      _barColor),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _AreaChip({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:        color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w500,
                color:      color),
          ),
        ],
      ),
    );
  }
}
