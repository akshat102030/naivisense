import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/children_repository.dart';
import '../../../data/services/api_service.dart';
import 'center_head_provider.dart';

// Fetch therapists for dropdown
final therapistsProvider = FutureProvider<List<UserModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/users/staff', params: {'role': 'therapist'});
  final list = res.data as List<dynamic>;
  return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
});

// Fetch parents for dropdown
final parentsProvider = FutureProvider<List<UserModel>>((ref) async {
  final api = ref.read(apiServiceProvider);
  final res = await api.get('/users/staff', params: {'role': 'parent'});
  final list = res.data as List<dynamic>;
  return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
});

class EnrollmentState {
  final bool loading;
  final String? error;
  final bool success;
  const EnrollmentState({this.loading = false, this.error, this.success = false});
  EnrollmentState copyWith({bool? loading, String? error, bool? success}) =>
      EnrollmentState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class EnrollmentNotifier extends Notifier<EnrollmentState> {
  @override
  EnrollmentState build() => const EnrollmentState();

  Future<bool> submit(Map<String, dynamic> payload) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await ref.read(childrenRepositoryProvider).createChild(payload);
      state = state.copyWith(loading: false, success: true);
      ref.invalidate(centerChildrenProvider);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }
}

final enrollmentProvider = NotifierProvider<EnrollmentNotifier, EnrollmentState>(
  EnrollmentNotifier.new,
);
