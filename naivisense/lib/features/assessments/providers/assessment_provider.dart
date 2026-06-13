import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/assessment.dart';
import '../../../data/repositories/assessments_repository.dart';
import '../../../data/services/error_handler_service.dart';

final childAssessmentsProvider =
    FutureProvider.family<List<AssessmentModel>, String>((ref, childId) async {
  try {
    return ref.read(assessmentsRepositoryProvider).getAssessments(childId);
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

final assessmentDetailProvider =
    FutureProvider.family<AssessmentModel, String>((ref, id) async {
  try {
    return ref.read(assessmentsRepositoryProvider).getAssessment(id);
  } catch (e) {
    throw ErrorHandlerService.handle(e);
  }
});

class AssessmentSubmitState {
  final bool loading;
  final String? error;
  final AssessmentModel? result;
  const AssessmentSubmitState({this.loading = false, this.error, this.result});
  AssessmentSubmitState copyWith({
    bool? loading,
    String? error,
    AssessmentModel? result,
  }) =>
      AssessmentSubmitState(
        loading: loading ?? this.loading,
        error:   error,
        result:  result ?? this.result,
      );
}

class AssessmentSubmitNotifier extends Notifier<AssessmentSubmitState> {
  @override
  AssessmentSubmitState build() => const AssessmentSubmitState();

  Future<AssessmentModel?> submit(Map<String, dynamic> payload, String childId) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final result = await ref
          .read(assessmentsRepositoryProvider)
          .createAssessment(payload);
      ref.invalidate(childAssessmentsProvider(childId));
      state = state.copyWith(loading: false, result: result);
      return result;
    } catch (e) {
      state = state.copyWith(
          loading: false, error: ErrorHandlerService.handle(e).message);
      return null;
    }
  }
}

final assessmentSubmitProvider =
    NotifierProvider<AssessmentSubmitNotifier, AssessmentSubmitState>(
  AssessmentSubmitNotifier.new,
);
