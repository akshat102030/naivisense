import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../shared/widgets/trend_chart.dart';
import '../../../features/reports/screens/weekly_report_screen.dart';
import '../providers/therapist_provider.dart';
import 'create_session_screen.dart';
import 'session_notes_screen.dart';

class TherapistChildProfileScreen extends ConsumerWidget {
  final ChildModel child;
  const TherapistChildProfileScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessions = ref.watch(therapistChildSessionsProvider(child.id));
    final plan     = ref.watch(therapistChildPlanProvider(child.id));
    final dietPlan = ref.watch(therapistChildDietPlanProvider(child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(therapistChildSessionsProvider(child.id));
          ref.invalidate(therapistChildPlanProvider(child.id));
          ref.invalidate(therapistChildDietPlanProvider(child.id));
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  _buildDiagnosis(context),
                  const SizedBox(height: 16),
                  _buildQuickStats(sessions),
                  const SizedBox(height: 20),
                  _buildAddSessionButton(context),
                  const SizedBox(height: 24),
                  _buildProgressCharts(context, sessions),
                  const SizedBox(height: 24),
                  _buildActivePlan(context, plan),
                  const SizedBox(height: 24),
                  _buildDietPlan(context, dietPlan),
                  const SizedBox(height: 24),
                  _buildSessionHistory(context, ref, sessions),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero App Bar ─────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    final (sevLabel, sevColor) = switch (child.severity) {
      'mild'         => ('Mild',         AppColors.mintGreen),
      'moderate'     => ('Moderate',     AppColors.warmYellow),
      'high_support' => ('High Support', AppColors.softCoral),
      _              => ('—',            Colors.white70),
    };

    return SliverAppBar(
      expandedHeight: 190,
      pinned: true,
      backgroundColor: AppColors.therapistGradient.colors.last,
      leading: BackButton(
        color: Colors.white,
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(gradient: AppColors.therapistGradient),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(child.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20)),
                        const SizedBox(height: 4),
                        Text('${child.ageYears} years old',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4)),
                          ),
                          child: Text(sevLabel,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: sevColor)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Diagnosis ────────────────────────────────────────────────────────────

  Widget _buildDiagnosis(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: child.diagnosis
          .map((d) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: Text(d,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryBlue)),
              ))
          .toList(),
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────────────────

  Widget _buildQuickStats(AsyncValue<List<SessionModel>> sessions) {
    final all       = sessions.valueOrNull ?? [];
    final completed = all.where((s) => s.status == 'completed').length;
    final upcoming  = all.where((s) =>
        s.status == 'scheduled' && s.scheduledAt.isAfter(DateTime.now())).length;

    return Row(
      children: [
        _StatChip(label: 'Total',     value: '${all.length}',  color: AppColors.primaryBlue,   icon: Icons.event_note_outlined),
        const SizedBox(width: 10),
        _StatChip(label: 'Completed', value: '$completed',     color: AppColors.mintGreen,     icon: Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatChip(label: 'Upcoming',  value: '$upcoming',      color: AppColors.warmYellow,    icon: Icons.upcoming_outlined),
      ],
    );
  }

  // ── Add Session ──────────────────────────────────────────────────────────

  Widget _buildAddSessionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CreateSessionScreen(preselectedChild: child),
          ),
        ),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Schedule New Session',
            style: TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  // ── Progress Charts ──────────────────────────────────────────────────────

  Widget _buildProgressCharts(
      BuildContext context, AsyncValue<List<SessionModel>> sessions) {
    final completed = (sessions.valueOrNull
            ?.where((s) => s.status == 'completed' && s.notes != null)
            .toList() ?? [])
          ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

    if (completed.isEmpty) {
      return _SectionCard(
        title: 'Progress Charts',
        icon: Icons.show_chart,
        child: _emptyMsg('No completed sessions with notes yet'),
      );
    }

    final labels = completed
        .map((s) => AppDateUtils.formatShortDate(s.scheduledAt))
        .toList();

    return _SectionCard(
      title: 'Progress Trends',
      icon: Icons.show_chart,
      child: Column(
        children: [
          TrendChart(
            title: 'Attention',
            values: completed
                .map((s) => s.notes!.attentionScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.primaryBlue,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Communication',
            values: completed
                .map((s) => s.notes!.communicationScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.mintGreen,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Motor Skills',
            values: completed
                .map((s) => s.notes!.motorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.warmYellow,
          ),
          const SizedBox(height: 16),
          TrendChart(
            title: 'Behavior',
            values: completed
                .map((s) => s.notes!.behaviorScore.toDouble())
                .toList(),
            labels: labels,
            lineColor: AppColors.softCoral,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WeeklyReportScreen(
                    childId:   child.id,
                    childName: child.name,
                  ),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: const Text('View Full Report'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Active Plan ──────────────────────────────────────────────────────────

  Widget _buildActivePlan(
      BuildContext context, AsyncValue<HomePlanModel?> plan) {
    return _SectionCard(
      title: 'Home Plan',
      icon: Icons.assignment_outlined,
      child: plan.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, __) => _emptyMsg('Could not load plan'),
        data: (p) {
          if (p == null) return _emptyMsg('No active home plan');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text('${p.tasks.length} tasks',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue)),
                ],
              ),
              if (p.tasks.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...p.tasks.take(4).map((t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Text(t.icon,
                              style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.title,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                  '${t.timeOfDay}  •  ${t.durationMin} min  •  ${t.frequency}',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                if (p.tasks.length > 4)
                  Text('+ ${p.tasks.length - 4} more tasks',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
              ],
            ],
          );
        },
      ),
    );
  }

  // ── Session History ──────────────────────────────────────────────────────

  Widget _buildSessionHistory(BuildContext context, WidgetRef ref,
      AsyncValue<List<SessionModel>> sessions) {
    return _SectionCard(
      title: 'Session History',
      icon: Icons.history,
      child: sessions.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (e, _) => _emptyMsg('Could not load sessions'),
        data: (list) {
          if (list.isEmpty) return _emptyMsg('No sessions yet');
          final sorted = [...list]
            ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const Divider(height: 16),
            itemBuilder: (_, i) =>
                _SessionRow(session: sorted[i], child: child, ref: ref),
          );
        },
      ),
    );
  }

  // ── Diet Chart ───────────────────────────────────────────────────────────
  Widget _buildDietPlan(
      BuildContext context, AsyncValue<DietPlanModel?> plan) {
    return _SectionCard(
      title: 'Diet Chart',
      icon: Icons.restaurant_outlined,
      child: plan.when(
        loading: () => const SizedBox(
            height: 40,
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryBlue))),
        error: (_, __) => _emptyMsg('Could not load diet plan'),
        data: (p) {
          if (p == null) return _emptyMsg('No active diet plan');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.date_range_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${AppDateUtils.formatDate(p.startDate)} → ${AppDateUtils.formatDate(p.endDate)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  Text('${p.meals.length} meals',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primaryBlue)),
                ],
              ),
              const SizedBox(height: 12),
              if (p.notes != null && p.notes!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(p.notes!,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ),
              ...p.meals.map((m) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(m.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(m.mealTime,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mintGreen,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                        if (m.description != null && m.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(m.description!,
                                style: const TextStyle(fontSize: 12)),
                          ),
                        if (m.ingredients.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'Ingredients: ${m.ingredients.join(", ")}',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        Text(
                          '${m.caloriesApprox} kcal • ${m.frequency}',
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }

  Widget _emptyMsg(String msg) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(msg,
              style: const TextStyle(color: AppColors.textSecondary)),
        ),
      );
}

// ── Stat Chip ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatChip(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 5),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: AppColors.primaryBlue, size: 16),
              ),
              const SizedBox(width: 10),
              Text(title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ── Session Row ───────────────────────────────────────────────────────────

class _SessionRow extends StatelessWidget {
  final SessionModel session;
  final ChildModel child;
  final WidgetRef ref;
  const _SessionRow(
      {required this.session, required this.child, required this.ref});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = switch (session.status) {
      'completed' => (AppColors.mintGreen, 'Completed'),
      'cancelled' => (AppColors.softCoral, 'Cancelled'),
      _           => (AppColors.warmYellow, 'Scheduled'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.typeLabel,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    '${AppDateUtils.formatDate(session.scheduledAt)}  •  ${AppDateUtils.formatTime(session.scheduledAt)}  •  ${session.durationMin} min',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(statusLabel,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor)),
            ),
          ],
        ),
        if (session.status == 'completed' && session.notes != null) ...[
          const SizedBox(height: 8),
          _NotesPreview(notes: session.notes!),
        ] else if (session.status == 'scheduled') ...[
          const SizedBox(height: 6),
          TextButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SessionNotesScreen(
                  session:   session,
                  childName: child.name,
                ),
              ),
            ),
            icon: const Icon(Icons.edit_outlined, size: 14),
            label: const Text('Add Notes'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ],
    );
  }
}

class _NotesPreview extends StatelessWidget {
  final SessionNotes notes;
  const _NotesPreview({required this.notes});

  @override
  Widget build(BuildContext context) {
    final moodEmoji = switch (notes.mood) {
      'happy'   => '😊',
      'calm'    => '😌',
      'anxious' => '😰',
      'sad'     => '😢',
      'angry'   => '😠',
      _         => '😐',
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$moodEmoji ${notes.mood}',
                  style: const TextStyle(fontSize: 12)),
              const Spacer(),
              _Score('Att', notes.attentionScore, AppColors.primaryBlue),
              const SizedBox(width: 8),
              _Score('Com', notes.communicationScore, AppColors.mintGreen),
              const SizedBox(width: 8),
              _Score('Mot', notes.motorScore, AppColors.warmYellow),
              const SizedBox(width: 8),
              _Score('Beh', notes.behaviorScore, AppColors.softCoral),
            ],
          ),
          if (notes.whatWorked != null && notes.whatWorked!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.thumb_up_outlined,
                    size: 12, color: AppColors.mintGreen),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(notes.whatWorked!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.4)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Score extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Score(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color)),
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textSecondary)),
      ],
    );
  }
}
