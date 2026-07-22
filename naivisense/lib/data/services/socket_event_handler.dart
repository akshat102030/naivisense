import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/features/assessments/providers/assessment_provider.dart';
import 'package:naivisense/features/center_head/providers/center_head_provider.dart';
import 'package:naivisense/features/center_head/providers/enrollment_provider.dart';
import 'package:naivisense/features/clinical_psychologist/providers/clinical_psychologist_provider.dart';
import 'package:naivisense/features/dietician/providers/dietician_provider.dart';
import 'package:naivisense/features/lead_therapist/providers/lead_therapist_provider.dart';
import 'package:naivisense/features/parent/providers/parent_provider.dart';
import 'package:naivisense/features/reports/providers/reports_provider.dart';
import 'package:naivisense/features/therapist/providers/therapist_provider.dart';

import '../../providers/socket_provider.dart';

class SocketEventHandler {
  final Ref ref;

  SocketEventHandler(this.ref);

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    final socket = ref.read(socketServiceProvider);

    // ====================== Sessions ======================

    socket.on("sessionUpdated", (data) {
      final childId = data["childId"];

      // Parent
      ref.invalidate(parentUpcomingSessionsProvider(childId));
      ref.invalidate(parentSessionsProvider(childId));
      ref.invalidate(parentScheduledSessionProvider(childId));

      // Therapist
      ref.invalidate(therapistSessionsProvider);
      ref.invalidate(therapistChildrenProvider);
      ref.invalidate(therapistChildSessionsProvider(childId));
      ref.invalidate(therapistChildNextSessionProvider(childId));

      // Admin
      ref.invalidate(adminChildSessionsProvider(childId));

      // Reports
      ref.invalidate(progressReportProvider);
    });

    // ====================== Attendance ======================

    socket.on("attendanceUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentPendingAttendanceProvider(childId));
      ref.invalidate(parentUpcomingSessionsProvider(childId));
      ref.invalidate(parentSessionsProvider(childId));
      ref.invalidate(parentScheduledSessionProvider(childId));

      ref.invalidate(adminChildSessionsProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Goals ======================

    socket.on("goalUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentGoalsProvider(childId));
      ref.invalidate(therapistChildGoalsProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Alerts ======================

    socket.on("alertUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentAlertsProvider(childId));
      ref.invalidate(adminChildAlertsProvider(childId));
    });

    // ====================== Reviews ======================

    socket.on("reviewUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentReviewsProvider(childId));
      ref.invalidate(therapistChildReviewsProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Videos ======================

    socket.on("videoUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentVideosProvider(childId));
      ref.invalidate(therapistChildVideosProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Diet ======================

    socket.on("dietUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentDietPlanProvider(childId));
      ref.invalidate(adminChildDietPlanProvider(childId));
      ref.invalidate(dieticianChildDietPlanProvider(childId));
      ref.invalidate(therapistChildDietPlanProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Home Plan ======================

    socket.on("homePlanUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(parentActivePlanProvider(childId));
      ref.invalidate(adminChildPlanProvider(childId));
      ref.invalidate(therapistChildPlanProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    // ====================== Assessments ======================

    socket.on("assessmentUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(childAssessmentsProvider(childId));

      ref.invalidate(progressReportProvider);
    });

    socket.on("assessmentDetailUpdated", (data) {
      ref.invalidate(assessmentDetailProvider(data["assessmentId"]));
    });

    // ====================== Children ======================

    socket.on("childUpdated", (data) {
      ref.invalidate(centerChildrenProvider);
      ref.invalidate(cpChildrenProvider);
      ref.invalidate(dieticianChildrenProvider);
      ref.invalidate(ltChildrenProvider);
      ref.invalidate(therapistChildrenProvider);

      // Change to data["userId"] if backend sends userId.
      if (data["userId"] != null) {
        ref.invalidate(adminUserProvider(data["userId"]));
      }
    });

    // ====================== Therapists ======================

    socket.on("therapistUpdated", (_) {
      ref.invalidate(therapistsOverviewProvider);
      ref.invalidate(therapistsProvider);
    });

    // ====================== Parents ======================

    socket.on("parentUpdated", (_) {
      ref.invalidate(allParentsProvider);
      ref.invalidate(parentsProvider);
    });

    // ====================== Users ======================

    socket.on("userUpdated", (data) {
      ref.invalidate(adminUserProvider(data["userId"]));
    });

    // ====================== Concerns ======================

    socket.on("concernUpdated", (data) {
      final childId = data["childId"];

      ref.invalidate(cpChildConcernsProvider(childId));
      ref.invalidate(ltAllOpenConcernsProvider(childId));
    });

    // ====================== Diet Requests ======================

    socket.on("dietRequestUpdated", (_) {
      ref.invalidate(dieticianRequestsProvider);
    });

    // ====================== Session Notes ======================

    socket.on("sessionNotesUpdated", (data) {
      final sessionId = data["sessionId"];

      ref.invalidate(therapistSessionNotesProvider(sessionId));
      ref.invalidate(parentSessionNotesProvider(sessionId));
    });

    // ====================== AI Drafts ======================

    socket.on("aiDraftUpdated", (data) {
      ref.invalidate(therapistAiDraftsProvider(data["childId"]));
    });

    // ====================== Verification ======================

    socket.on("verificationUpdated", (_) {
      ref.invalidate(therapistPendingVerificationsProvider);
    });
  }

  void dispose() {
    ref.read(socketServiceProvider).removeAllListeners();
    _initialized = false;
  }
}
