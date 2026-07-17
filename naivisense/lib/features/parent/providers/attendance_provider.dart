import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/services/location_service.dart';

import '../../../data/models/child.dart';
import '../../../data/repositories/attendance_repository.dart';

class AttendanceState {
  final bool loading;
  final bool success;
  final String? error;

  const AttendanceState({
    this.loading = false,
    this.success = false,
    this.error,
  });

  AttendanceState copyWith({bool? loading, bool? success, String? error}) {
    return AttendanceState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  bool _isSubmitting = false;

  DateTime? _lastMarkedAt;

  @override
  AttendanceState build() {
    return const AttendanceState();
  }

  Future<void> markAttendanceForChild(ChildModel child) async {
    if (_isSubmitting) return;

    if (_lastMarkedAt != null &&
        DateTime.now().difference(_lastMarkedAt!).inMinutes < 5) {
      return;
    }

    final ok = await markAttendance(child.id);

    if (ok) {
      _lastMarkedAt = DateTime.now();
    }
  }

  Future<bool> markAttendance(String childId) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;

    state = state.copyWith(loading: true, success: false, error: null);

    try {
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        state = state.copyWith(
          loading: false,
          success: false,
          error: 'Unable to get current location.',
        );

        _isSubmitting = false;
        return false;
      }

      await ref
          .read(attendanceRepositoryProvider)
          .markAttendance(
            childId: childId,
            date: DateTime.now(),
            latitude: position.latitude,
            longitude: position.longitude,
          );

      state = state.copyWith(loading: false, success: true);

      _isSubmitting = false;
      return true;
    } catch (e) {
      debugPrint("Attendance Error: $e");

      state = state.copyWith(
        loading: false,
        success: false,
        error: e.toString(),
      );

      _isSubmitting = false;
      return false;
    }
  }

  void reset() {
    state = const AttendanceState();
  }
}

final attendanceProvider =
    NotifierProvider<AttendanceNotifier, AttendanceState>(
      AttendanceNotifier.new,
    );
