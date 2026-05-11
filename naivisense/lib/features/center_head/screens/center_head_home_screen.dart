import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/child.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/state_widgets.dart' as sw;
import '../providers/center_head_provider.dart';

class CenterHeadHomeScreen extends ConsumerWidget {
  const CenterHeadHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user     = ref.watch(authProvider).valueOrNull?.user;
    final children = ref.watch(centerChildrenProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user?.name ?? 'Center Head'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/center-head/enroll'),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text('Enroll Child',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(centerChildrenProvider),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildGradientHeader(context, user?.name ?? ''),
                  const SizedBox(height: 20),
                  _buildStats(context, children),
                  const SizedBox(height: 24),
                  _buildChildrenSection(context, children),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.centerHeadGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Center Dashboard',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Overview of all therapists and children',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(BuildContext context, AsyncValue<List<ChildModel>> children) {
    final count = children.valueOrNull?.length ?? 0;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        StatTile(
          label:     'Total Children',
          value:     '$count',
          icon:      Icons.child_care,
          iconColor: AppColors.primaryBlue,
        ),
        StatTile(
          label:     'Active Plans',
          value:     '${(count * 0.8).round()}',
          icon:      Icons.assignment_turned_in,
          iconColor: AppColors.mintGreen,
        ),
      ],
    );
  }

  Widget _buildChildrenSection(
      BuildContext context, AsyncValue<List<ChildModel>> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('All Children', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        children.when(
          loading: () => const sw.LoadingWidget(),
          error:   (e, _) => sw.ErrorWidget(message: e.toString()),
          data:    (list) {
            if (list.isEmpty) {
              return const sw.EmptyWidget(
                message: 'No children enrolled yet',
                icon: Icons.child_care,
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (_, i) => _ChildAdminCard(child: list[i]),
            );
          },
        ),
      ],
    );
  }
}

// ── Child Admin Card ──────────────────────────────────────────────────────

class _ChildAdminCard extends StatelessWidget {
  final ChildModel child;
  const _ChildAdminCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final therapistName = child.therapistName ?? (child.therapistId.isEmpty ? 'Not assigned' : '…');

    final (sevLabel, sevColor) = switch (child.severity) {
      'mild'         => ('Mild',         AppColors.mintGreen),
      'moderate'     => ('Moderate',     AppColors.warmYellow),
      'high_support' => ('High Support', AppColors.softCoral),
      _              => ('—',            AppColors.textSecondary),
    };

    return AppCard(
      onTap: () => context.push(
        '/center-head/child/${child.id}',
        extra: child,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.centerHeadGradient.colors.first
                    .withValues(alpha: 0.15),
                child: Text(
                  child.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppColors.centerHeadGradient.colors.first,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(child.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(
                      '${child.ageYears} yrs  •  ${child.diagnosis.join(', ')}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sevColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: sevColor.withValues(alpha: 0.3)),
                ),
                child: Text(sevLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sevColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 5),
              Text(
                'Therapist: $therapistName',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios,
                  size: 12, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              const Text('View Report',
                  style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

