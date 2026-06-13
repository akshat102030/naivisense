import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/error_handler_service.dart';
import 'center_head_provider.dart';

class TherapistEnrollmentState {
  final bool loading;
  final String? error;
  final bool success;
  const TherapistEnrollmentState({
    this.loading = false,
    this.error,
    this.success = false,
  });
  TherapistEnrollmentState copyWith({bool? loading, String? error, bool? success}) =>
      TherapistEnrollmentState(
        loading: loading ?? this.loading,
        error: error,
        success: success ?? this.success,
      );
}

class TherapistEnrollmentNotifier extends Notifier<TherapistEnrollmentState> {
  @override
  TherapistEnrollmentState build() => const TherapistEnrollmentState();

  Future<bool> submit({
    required Map<String, dynamic> data,
    XFile? profilePhoto,
    XFile? degreeCert,
    XFile? identityProof,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final api = ref.read(apiServiceProvider);

      // Create therapist account + profile
      final res = await api.post<Map<String, dynamic>>('/users/therapists', data: data);
      final therapistId = (res.data!['user'] as Map<String, dynamic>)['_id'] as String;

      // Upload documents in parallel
      await Future.wait([
        if (profilePhoto  != null) _upload(api, therapistId, 'photo',    profilePhoto),
        if (degreeCert    != null) _upload(api, therapistId, 'degree',   degreeCert),
        if (identityProof != null) _upload(api, therapistId, 'identity', identityProof),
      ]);

      ref.invalidate(therapistsOverviewProvider);
      state = state.copyWith(loading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: ErrorHandlerService.handle(e).message);
      return false;
    }
  }

  Future<void> _upload(ApiService api, String id, String docType, XFile file) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: file.name,
          contentType: DioMediaType.parse(mime)),
    });
    await api.postForm('/users/therapists/$id/$docType', formData);
  }
}

final therapistEnrollmentProvider =
    NotifierProvider<TherapistEnrollmentNotifier, TherapistEnrollmentState>(
  TherapistEnrollmentNotifier.new,
);
