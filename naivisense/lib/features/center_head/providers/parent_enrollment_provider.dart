import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/error_handler_service.dart';
import 'center_head_provider.dart';
import 'enrollment_provider.dart';

class ParentEnrollmentState {
  final bool loading;
  final String? error;
  final bool success;
  const ParentEnrollmentState({
    this.loading = false,
    this.error,
    this.success = false,
  });
  ParentEnrollmentState copyWith({bool? loading, String? error, bool? success}) =>
      ParentEnrollmentState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class ParentEnrollmentNotifier extends Notifier<ParentEnrollmentState> {
  @override
  ParentEnrollmentState build() => const ParentEnrollmentState();

  Future<bool> submit(Map<String, dynamic> data) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);
      await api.post<Map<String, dynamic>>('/users/parents', data: data);
      ref.invalidate(parentsProvider);
      ref.invalidate(allParentsProvider);
      state = state.copyWith(loading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: ErrorHandlerService.handle(e).message);
      return false;
    }
  }
}

final parentEnrollmentProvider =
    NotifierProvider<ParentEnrollmentNotifier, ParentEnrollmentState>(
  ParentEnrollmentNotifier.new,
);
