import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:naivisense/core/theme/app_colors.dart';
import 'package:naivisense/core/utils/date_utils.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/child.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/features/parent/providers/attendance_provider.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SessionCard extends ConsumerStatefulWidget {
  final ChildModel child;
  final SessionModel session;
  final bool showAttendanceButton;
  final bool showMeetingButton;

  const SessionCard({
    super.key,
    required this.child,
    required this.session,
    this.showAttendanceButton = true,
    this.showMeetingButton = true,
  });

  @override
  ConsumerState<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends ConsumerState<SessionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Refresh every 30 seconds so attendance button
    // automatically becomes enabled after session ends.
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _hasMeeting =>
      widget.session.meetingLink != null &&
      widget.session.meetingLink!.trim().isNotEmpty;

  Future<void> _openMeeting(BuildContext context) async {
    if (!_hasMeeting) return;

    try {
      final uri = Uri.parse(widget.session.meetingLink!);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to open Google Meet")),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid meeting link")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final attendanceState = ref.watch(attendanceProvider);

    final session = widget.session;
    final child = widget.child;

    final isLoading = attendanceState.isLoading(session.id);
    debugPrint("Now      : ${DateTime.now()}");
    debugPrint("Start    : ${session.scheduledAt}");
    debugPrint("End      : ${session.endAt}");
    debugPrint("Can Mark : ${session.canMarkAttendanceNow}");

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

                    if (widget.showMeetingButton && _hasMeeting)
                      InkWell(
                        onTap: () => _openMeeting(context),
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: r.w(10),
                            vertical: r.h(6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: .08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: .30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const FaIcon(
                                FontAwesomeIcons.google,
                                color: Colors.green,
                                size: 14,
                              ),
                              r.gapW(6),
                              Text(
                                "Google Meet",
                                style: TextStyle(
                                  fontSize: r.sp(12),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (widget.showAttendanceButton &&
                    session.hasPendingAttendance) ...[
                  r.gapH(14),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: (isLoading || !session.canMarkAttendanceNow)
                          ? null
                          : () async {
                              final ok = await ref
                                  .read(attendanceProvider.notifier)
                                  .markAttendance(child.id, session.id);

                              if (!context.mounted) return;

                              if (ok) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Attendance marked successfully.",
                                    ),
                                  ),
                                );

                                ref.invalidate(
                                  parentUpcomingSessionsProvider(child.id),
                                );

                                ref.invalidate(
                                  parentPendingAttendanceProvider(child.id),
                                );

                                ref.invalidate(
                                  parentSessionsProvider(child.id),
                                );
                              } else {
                                final error = ref
                                    .read(attendanceProvider)
                                    .error;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      error ?? "Failed to mark attendance.",
                                    ),
                                  ),
                                );
                              }
                            },
                      icon: isLoading
                          ? SizedBox(
                              width: r.icon(18),
                              height: r.icon(18),
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.how_to_reg),
                      label: Text(
                        isLoading
                            ? "Marking Attendance..."
                            : session.canMarkAttendanceNow
                            ? "Mark Attendance"
                            : "Attendance Not Available",
                      ),
                    ),
                  ),
                ],
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
