import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/repositories/google_calendar_repository.dart';
// import 'package:naivisense/features/admin/providers/admin_provider.dart';
import 'package:naivisense/features/admin/widgets/center_heads_section.dart';
import 'package:naivisense/features/center_head/widgets/children_section.dart';
import 'package:naivisense/features/center_head/widgets/dashboard_stats.dart';
import 'package:naivisense/features/center_head/widgets/gradient_header.dart';
import 'package:naivisense/features/center_head/widgets/parents_section.dart';
import 'package:naivisense/features/center_head/widgets/therapists_section.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/auth/providers/auth_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    final user = ref.watch(authProvider).valueOrNull?.user;

    // final children = ref.watch(centerChildrenProvider);
    // final therapists = ref.watch(therapistsOverviewProvider);
    // final parents = ref.watch(allParentsProvider);
    // final centerHeads = ref.watch(centerHeadsProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: Text(
              user?.name ?? 'Admin',
              style: TextStyle(fontSize: r.sp(20, tablet: 22, desktop: 24)),
            ),
            backgroundColor: AppColors.surface,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(
                  Icons.calendar_month_outlined,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                tooltip: 'Google Calendar',
                onPressed: () async {
                  try {
                    final repo = ref.read(googleCalendarRepositoryProvider);

                    final url = await repo.getGoogleAuthUrl();

                    final uri = Uri.parse(url);

                    if (!await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    )) {
                      throw Exception(
                        'Could not open Google authentication page.',
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Failed to connect Google Calendar.\n$e',
                          ),
                        ),
                      );
                    }
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.payments_outlined,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                tooltip: 'Payments',
                onPressed: () => context.push('/admin/payments'),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                tooltip: 'Settings',
                onPressed: () => context.push('/admin/settings'),
              ),
              IconButton(
                icon: Icon(
                  Icons.logout,
                  size: r.icon(24, tablet: 26, desktop: 28),
                ),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'enroll_center_head',
            onPressed: () => context.push('/admin/enroll-center-head'),
            backgroundColor: AppColors.primaryBlue,
            icon: Icon(
              Icons.admin_panel_settings_outlined,
              color: Colors.white,
              size: r.icon(22, tablet: 24, desktop: 26),
            ),
            label: Text(
              'Enroll Center Head',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: r.sp(14, tablet: 15, desktop: 16),
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: r.isDesktop ? 1200 : r.maxWidth,
              ),
              // child: RefreshIndicator(
              //   onRefresh: () async {
              //     ref.invalidate(centerChildrenProvider);
              //     ref.invalidate(therapistsOverviewProvider);
              //     ref.invalidate(allParentsProvider);
              //     ref.invalidate(centerHeadsProvider);
              //   },
              //   child: CustomScrollView(
              //     slivers: [
              //       SliverPadding(
              //         padding: EdgeInsets.symmetric(
              //           horizontal: r.horizontalPadding,
              //           vertical: r.verticalPadding,
              //         ),
              //         sliver: SliverList(
              //           delegate: SliverChildListDelegate([
              //             GradientHeader(name: user?.name ?? ''),

              //             r.gapH(20, tablet: 24, desktop: 28),

              //             DashboardStats(
              //               children: children,
              //               therapists: therapists,
              //               parents: parents,
              //             ),

              //             r.gapH(24, tablet: 28, desktop: 32),

              //             CenterHeadsSection(centerHeads: centerHeads),

              //             r.gapH(24, tablet: 28, desktop: 32),

              //             TherapistsSection(therapists: therapists),

              //             r.gapH(24, tablet: 28, desktop: 32),

              //             ParentsSection(parents: parents, children: children),

              //             r.gapH(24, tablet: 28, desktop: 32),

              //             ChildrenSection(children: children),

              //             r.gapH(24, tablet: 28, desktop: 32),
              //           ]),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ),
          ),
        );
      },
    );
  }
}
