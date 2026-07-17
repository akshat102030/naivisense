import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/core/utils/responsive.dart';
import 'package:naivisense/data/models/scheduled_session_model.dart';
import 'package:naivisense/features/parent/providers/attendance_provider.dart';
import 'package:naivisense/features/parent/widget/accepted_goals_section.dart';
import 'package:naivisense/features/parent/widget/child_detail_app_bar.dart';
import 'package:naivisense/features/parent/widget/diet_plan_section.dart';
import 'package:naivisense/features/parent/widget/home_plan.dart';
import 'package:naivisense/features/parent/widget/improvement_videos_section.dart';
import 'package:naivisense/features/parent/widget/last_session_notes_section.dart';
import 'package:naivisense/features/parent/widget/next_session_section.dart';
import 'package:naivisense/features/parent/widget/open_alerts_section.dart';
import 'package:naivisense/features/parent/widget/progress_section.dart';
import 'package:naivisense/features/parent/widget/published_reviews_section.dart';
import 'package:naivisense/features/parent/widget/raise_alert_card.dart';
import 'package:naivisense/features/parent/widget/scheduled_sessions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/goal.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/review.dart';
import '../../../data/models/video_item.dart';
import '../../../data/models/session.dart';
import '../providers/parent_provider.dart';

class ChildDetailScreen extends ConsumerStatefulWidget {
  final ChildModel child;

  const ChildDetailScreen({super.key, required this.child});

  @override
  ConsumerState<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends ConsumerState<ChildDetailScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(attendanceProvider.notifier)
          .markAttendanceForChild(widget.child);
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);

    final sessions = ref.watch(parentSessionsProvider(widget.child.id));
    final upcomingSessions = ref.watch(
      parentUpcomingSessionsProvider(widget.child.id),
    );
    final scheduledSession = ref.watch(
      parentScheduledSessionProvider(widget.child.id),
    );
    final plan = ref.watch(parentActivePlanProvider(widget.child.id));
    final dietPlan = ref.watch(parentDietPlanProvider(widget.child.id));
    final alerts = ref.watch(parentAlertsProvider(widget.child.id));
    final goals = ref.watch(parentGoalsProvider(widget.child.id));
    final reviews = ref.watch(parentReviewsProvider(widget.child.id));
    final videos = ref.watch(parentVideosProvider(widget.child.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(parentSessionsProvider(widget.child.id));
          ref.invalidate(parentUpcomingSessionsProvider(widget.child.id));
          ref.invalidate(parentScheduledSessionProvider(widget.child.id));
          ref.invalidate(parentActivePlanProvider(widget.child.id));
          ref.invalidate(parentDietPlanProvider(widget.child.id));
          ref.invalidate(parentAlertsProvider(widget.child.id));
          ref.invalidate(parentGoalsProvider(widget.child.id));
          ref.invalidate(parentReviewsProvider(widget.child.id));
          ref.invalidate(parentVideosProvider(widget.child.id));
        },
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            ChildDetailAppBar(child: widget.child),

            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: r.horizontalPadding,
                vertical: r.verticalPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: r.maxWidth),
                    child: _buildContent(
                      context,
                      ref,
                      sessions,
                      upcomingSessions,
                      scheduledSession,
                      plan,
                      dietPlan,
                      alerts,
                      goals,
                      reviews,
                      videos,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<SessionModel>> sessions,
    AsyncValue<List<SessionModel>> upcomingSessions,
    AsyncValue<ScheduledSessionModel?> scheduledSession,
    AsyncValue<HomePlanModel?> plan,
    AsyncValue<DietPlanModel?> dietPlan,
    AsyncValue<List<AlertModel>> alerts,
    AsyncValue<List<GoalModel>> goals,
    AsyncValue<List<ReviewModel>> reviews,
    AsyncValue<List<VideoItemModel>> videos,
  ) {
    final r = Responsive(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProgressSection(
          childId: widget.child.id,
          childName: widget.child.name,
          sessions: sessions,
        ),

        SizedBox(height: r.sectionSpacing),

        NextSessionSection(upcomingSessions: upcomingSessions),

        SizedBox(height: r.sectionSpacing),

        ScheduledSessions(scheduledSession: scheduledSession),

        SizedBox(height: r.sectionSpacing),

        HomePlanSection(plan: plan),

        SizedBox(height: r.sectionSpacing),

        DietPlanSection(dietPlan: dietPlan),

        SizedBox(height: r.sectionSpacing),

        LastSessionNotesSection(sessions: sessions),

        SizedBox(height: r.sectionSpacing),

        OpenAlertsSection(alerts: alerts),

        SizedBox(height: r.sectionSpacing),

        AcceptedGoalsSection(goals: goals),

        SizedBox(height: r.sectionSpacing),

        PublishedReviewsSection(reviews: reviews),

        ImprovementVideosSection(childId: widget.child.id, videos: videos),

        SizedBox(height: r.sectionSpacing),

        RaiseAlertCard(child: widget.child),

        SizedBox(height: r.verticalPadding),
      ],
    );
  }
}
