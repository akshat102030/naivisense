import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/date_utils.dart';
import '../../../data/models/child.dart';
import '../../../data/models/session.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import 'package:go_router/go_router.dart';
import '../providers/therapist_provider.dart';
import 'session_notes_screen.dart';
import 'create_session_screen.dart';

class TherapistHomeScreen extends ConsumerWidget {
  const TherapistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(therapistChildrenProvider);
    final sessions = ref.watch(therapistSessionsProvider);
    final pending  = ref.watch(therapistPendingVerificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Hi, ${user?.name.split(' ').first ?? 'Therapist'}'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(therapistChildrenProvider);
          ref.invalidate(therapistSessionsProvider);
          ref.invalidate(therapistPendingVerificationsProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStats(context, children, sessions, pending),
                  const SizedBox(height: 24),
                  _buildTodaySessions(context, ref, sessions, children),
                  const SizedBox(height: 24),
                  _buildChildrenList(context, children),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateSession(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildStats(BuildContext context, AsyncValue children,
      AsyncValue sessions, AsyncValue pending) {
    final childCount   = children.valueOrNull?.length ?? 0;
    final sessionCount = sessions.valueOrNull?.length ?? 0;
    final pendingCount = pending.valueOrNull?.length ?? 0;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: [
        StatTile(
          label:     'Children',
          value:     '$childCount',
          icon:      Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),
        StatTile(
          label:     'Sessions',
          value:     '$sessionCount',
          icon:      Icons.event_note,
          iconColor: AppColors.mintGreen,
        ),
        StatTile(
          label:     'Pending',
          value:     '$pendingCount',
          icon:      Icons.pending_actions,
          iconColor: AppColors.warmYellow,
        ),
      ],
    );
  }

  Widget _buildTodaySessions(BuildContext context, WidgetRef ref,
      AsyncValue<List<SessionModel>> sessions,
      AsyncValue<List<ChildModel>> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Sessions",
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        sessions.when(
          loading: () => const sw.LoadingWidget(),
          error:   (e, _) => sw.ErrorWidget(message: e.toString()),
          data:    (list) {
            final today = list.where((s) {
              final d = s.scheduledAt;
              final n = DateTime.now();
              return d.year == n.year && d.month == n.month && d.day == n.day;
            }).toList();

            if (today.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No sessions today',
                icon: Icons.event_available,
              );
            }

            final childMap = {
              for (final c in (children.valueOrNull ?? [])) c.id: c.name
            };

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: today.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final s = today[i];
                final childName = childMap[s.childId] ?? 'Unknown Child';
                return _SessionCard(
                  session:   s,
                  childName: childName,
                  onNotes: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SessionNotesScreen(
                        session:   s,
                        childName: childName,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildChildrenList(
      BuildContext context, AsyncValue<List<ChildModel>> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Children', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        children.when(
          loading: () => const sw.LoadingWidget(),
          error:   (e, _) => sw.ErrorWidget(message: e.toString()),
          data:    (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children assigned yet',
                icon: Icons.child_care,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ChildTile(child: list[i]),
            );
          },
        ),
      ],
    );
  }

  void _showCreateSession(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  final String childName;
  final VoidCallback onNotes;

  const _SessionCard({
    required this.session,
    required this.childName,
    required this.onNotes,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == 'completed';
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.mintGreen : AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(childName,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  '${session.typeLabel}  •  ${AppDateUtils.formatTime(session.scheduledAt)}  •  ${session.durationMin} min',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          isCompleted
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mintGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Done',
                      style: TextStyle(
                          color: AppColors.mintGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                )
              : TextButton(
                  onPressed: onNotes,
                  child: const Text('Add Notes'),
                ),
        ],
      ),
    );
  }
}

class _ChildTile extends StatelessWidget {
  final ChildModel child;
  const _ChildTile({required this.child});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withValues(alpha:0.15),
            child: Text(
              child.name[0].toUpperCase(),
              style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(child.name, style: Theme.of(context).textTheme.bodyLarge),
                Text('${child.ageYears} yrs • ${child.diagnosis}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
