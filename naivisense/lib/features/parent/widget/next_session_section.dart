import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/features/parent/widget/session_card.dart';

class NextSessionSection extends ConsumerWidget {
  final String title;
  final ChildModel child;
  final bool showOnlyFirstPendingAttendance;
  final AsyncValue<List<SessionModel>> sessions;

  const NextSessionSection({
    super.key,
    required this.title,
    required this.child,
    this.showOnlyFirstPendingAttendance = false,
    required this.sessions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.all(r.w(18, tablet: 20, desktop: 24)),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: r.borderRadius(16, tablet: 18, desktop: 20),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, icon: Icons.calendar_month_outlined),

          r.gapH(16),

          sessions.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(),
              ),
            ),

            error: (_, __) => Container(
              padding: EdgeInsets.all(r.w(16)),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: r.borderRadius(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: r.icon(22),
                  ),
                  r.gapW(10),
                  Expanded(
                    child: Text("Unable to load ${title.toLowerCase()}"),
                  ),
                ],
              ),
            ),

            data: (sessions) {
              if (sessions.isEmpty) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.w(16),
                    vertical: r.h(14),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: r.borderRadius(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        color: AppColors.textSecondary,
                        size: r.icon(22),
                      ),
                      r.gapW(12),
                      Expanded(
                        child: Text(
                          "No ${title.toLowerCase()} scheduled",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: r.sp(13),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Find the first pending attendance session
              final firstPendingIndex = sessions.indexWhere(
                (session) => session.hasPendingAttendance,
              );

              return Column(
                children: List.generate(sessions.length, (index) {
                  final session = sessions[index];

                  final showAttendanceButton = showOnlyFirstPendingAttendance
                      ? (session.hasPendingAttendance &&
                            index == firstPendingIndex)
                      : session.hasPendingAttendance;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == sessions.length - 1 ? 0 : r.h(14),
                    ),
                    child: SessionCard(
                      child: child,
                      session: session,
                      showAttendanceButton: showAttendanceButton,
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }
}
