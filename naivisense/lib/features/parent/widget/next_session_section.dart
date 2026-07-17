import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';

class NextSessionSection extends StatelessWidget {
  final AsyncValue<List<SessionModel>> upcomingSessions;

  const NextSessionSection({super.key, required this.upcomingSessions});

  @override
  Widget build(BuildContext context) {
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
          const SectionHeader(
            title: "Upcoming Sessions",
            icon: Icons.calendar_month_outlined,
          ),

          r.gapH(16),

          upcomingSessions.when(
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
                  const Expanded(
                    child: Text("Unable to load upcoming sessions"),
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
                          "No upcoming sessions scheduled",
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

              return Column(
                children: List.generate(sessions.length, (index) {
                  final session = sessions[index];

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == sessions.length - 1 ? 0 : r.h(14),
                    ),
                    child: _SessionCard(session: session),
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

class _SessionCard extends StatelessWidget {
  final SessionModel session;

  const _SessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.all(r.w(16, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: r.borderRadius(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(r.w(10)),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              color: AppColors.primaryBlue,
              size: r.icon(22),
            ),
          ),

          r.gapW(16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.typeLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(16, tablet: 17, desktop: 18),
                  ),
                ),

                r.gapH(10),

                Wrap(
                  spacing: r.w(10),
                  runSpacing: r.h(8),
                  children: [
                    _InfoChip(
                      icon: Icons.calendar_today_outlined,
                      text: AppDateUtils.formatDate(session.scheduledAt),
                    ),
                    _InfoChip(
                      icon: Icons.access_time_outlined,
                      text: AppDateUtils.formatTime(session.scheduledAt),
                    ),
                    _InfoChip(
                      icon: Icons.timelapse_outlined,
                      text: "${session.durationMin} min",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(6)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.icon(14), color: AppColors.primaryBlue),
          r.gapW(6),
          Text(text, style: TextStyle(fontSize: r.sp(12))),
        ],
      ),
    );
  }
}
