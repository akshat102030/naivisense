import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/scheduled_session_model.dart';
import 'package:naivisense/features/parent/widget/section_header.dart';
import 'package:naivisense/shared/widgets/app_card.dart';
import 'package:naivisense/shared/widgets/state_widgets.dart' as sw;

class ScheduledSessions extends StatelessWidget {
  final AsyncValue<ScheduledSessionModel?> scheduledSession;

  const ScheduledSessions({super.key, required this.scheduledSession});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: "Scheduled Sessions",
          icon: Icons.calendar_month_outlined,
        ),

        r.gapH(12, tablet: 16, desktop: 20),

        scheduledSession.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(),
            ),
          ),

          error: (_, __) => const sw.EmptyWidget(
            message: "Unable to load scheduled session",
            icon: Icons.error_outline,
          ),

          data: (session) {
            if (session == null) {
              return const sw.EmptyWidget(
                message: "No recurring schedule set",
                icon: Icons.calendar_month_outlined,
              );
            }

            return _ScheduleCard(session: session);
          },
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduledSessionModel session;

  const _ScheduleCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return AppCard(
      padding: EdgeInsets.symmetric(
        horizontal: r.w(16, tablet: 18, desktop: 20),
        vertical: r.h(16, tablet: 18, desktop: 20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: r.h(58, tablet: 62, desktop: 64),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          r.gapW(18),

          Expanded(
            child: r.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.therapyType,
                        style: TextStyle(
                          fontSize: r.sp(17),
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),

                      r.gapH(12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _ScheduleInfoChip(
                            icon: Icons.schedule_outlined,
                            text: session.timeLabel,
                          ),
                          _ScheduleInfoChip(
                            icon: Icons.calendar_today_outlined,
                            text: session.daysLabel,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: Text(
                          session.therapyType,
                          style: TextStyle(
                            fontSize: r.sp(18),
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _ScheduleInfoChip(
                            icon: Icons.schedule_outlined,
                            text: session.timeLabel,
                          ),
                          _ScheduleInfoChip(
                            icon: Icons.calendar_today_outlined,
                            text: session.daysLabel,
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

class _ScheduleInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ScheduleInfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(7)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: r.icon(14), color: AppColors.primaryBlue),
          r.gapW(6),
          Text(
            text,
            style: TextStyle(
              fontSize: r.sp(12),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
