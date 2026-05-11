import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/alert.dart';
import '../../../data/models/child.dart';
import '../../../data/models/home_plan.dart';
import '../../../data/models/session.dart';
import '../../../data/repositories/alerts_repository.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/repositories/home_plans_repository.dart';
import '../../../data/repositories/sessions_repository.dart';

final parentChildrenProvider = FutureProvider<List<ChildModel>>(
  (ref) => ref.read(childrenRepositoryProvider).getChildren(),
);

final parentActivePlanProvider =
    FutureProvider.family<HomePlanModel?, String>((ref, childId) =>
        ref.read(homePlansRepositoryProvider).getActivePlan(childId));

final parentSessionsProvider =
    FutureProvider.family<List<SessionModel>, String>((ref, childId) =>
        ref.read(sessionsRepositoryProvider).getSessions(childId: childId));

final parentAlertsProvider =
    FutureProvider.family<List<AlertModel>, String>((ref, childId) =>
        ref.read(alertsRepositoryProvider).getAlerts(childId));

// ── Task log state ─────────────────────────────────────────────────────────

class TaskLogState {
  final bool loading;
  final String? error;
  final bool success;
  const TaskLogState({this.loading = false, this.error, this.success = false});
  TaskLogState copyWith({bool? loading, String? error, bool? success}) =>
      TaskLogState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class TaskLogNotifier extends Notifier<TaskLogState> {
  @override
  TaskLogState build() => const TaskLogState();

  Future<bool> logTask({
    required String planId,
    required String taskId,
    String note = 'Completed',
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(homePlansRepositoryProvider).logTask(
            planId: planId,
            taskId: taskId,
            note:   note,
          );
      state = state.copyWith(loading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final taskLogProvider = NotifierProvider<TaskLogNotifier, TaskLogState>(TaskLogNotifier.new);

// ── Alert creation state ───────────────────────────────────────────────────

class AlertState {
  final bool loading;
  final String? error;
  final bool success;
  const AlertState({this.loading = false, this.error, this.success = false});
  AlertState copyWith({bool? loading, String? error, bool? success}) =>
      AlertState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class AlertNotifier extends Notifier<AlertState> {
  @override
  AlertState build() => const AlertState();

  Future<bool> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(alertsRepositoryProvider).createAlert(payload);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(parentAlertsProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final alertProvider = NotifierProvider<AlertNotifier, AlertState>(AlertNotifier.new);
