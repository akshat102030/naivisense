import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/child.dart';
import '../../../data/models/diet_plan.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/diet_plans_repository.dart';
import '../../../data/repositories/home_plans_repository.dart';
import '../../../data/repositories/sessions_repository.dart';
import '../../../data/repositories/verification_repository.dart';

final therapistChildrenProvider = FutureProvider<List<ChildModel>>((ref) =>
    ref.read(childrenRepositoryProvider).getChildren());

final therapistChildSessionsProvider =
    FutureProvider.family<List<SessionModel>, String>(
  (ref, childId) =>
      ref.read(sessionsRepositoryProvider).getSessions(childId: childId),
);

final therapistChildPlanProvider =
    FutureProvider.family<HomePlanModel?, String>(
  (ref, childId) =>
      ref.read(homePlansRepositoryProvider).getActivePlan(childId),
);

final therapistChildDietPlanProvider =
    FutureProvider.family<DietPlanModel?, String>(
  (ref, childId) =>
      ref.read(dietPlansRepositoryProvider).getActivePlan(childId),
);

// Therapist home uses /sessions/upcoming (no childId required)
final therapistSessionsProvider = FutureProvider<List<SessionModel>>((ref) =>
    ref.read(sessionsRepositoryProvider).getUpcoming());

final therapistPendingVerificationsProvider =
    FutureProvider<List<VerificationItem>>((ref) =>
        ref.read(verificationRepositoryProvider).getPending());

class SessionNotesState {
  final bool loading;
  final String? error;
  final bool success;

  const SessionNotesState({
    this.loading = false,
    this.error,
    this.success = false,
  });
}

class SessionNotesNotifier extends Notifier<SessionNotesState> {
  @override
  SessionNotesState build() => const SessionNotesState();

  Future<void> submit(String sessionId, Map<String, dynamic> notes) async {
    state = const SessionNotesState(loading: true);
    try {
      await ref.read(sessionsRepositoryProvider).submitNotes(sessionId, notes);
      state = const SessionNotesState(success: true);
      ref.invalidate(therapistSessionsProvider);
    } catch (e) {
      state = SessionNotesState(error: e.toString());
    }
  }
}

final sessionNotesProvider =
    NotifierProvider<SessionNotesNotifier, SessionNotesState>(
        SessionNotesNotifier.new);

// ── Create Session ─────────────────────────────────────────────────────────

class CreateSessionState {
  final bool loading;
  final String? error;
  final bool success;
  const CreateSessionState({this.loading = false, this.error, this.success = false});
  CreateSessionState copyWith({bool? loading, String? error, bool? success}) =>
      CreateSessionState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class CreateSessionNotifier extends Notifier<CreateSessionState> {
  @override
  CreateSessionState build() => const CreateSessionState();

  Future<bool> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(sessionsRepositoryProvider).createSession(payload);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(therapistSessionsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final createSessionProvider =
    NotifierProvider<CreateSessionNotifier, CreateSessionState>(
        CreateSessionNotifier.new);
