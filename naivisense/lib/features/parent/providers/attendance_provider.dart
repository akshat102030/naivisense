import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/session.dart';
import 'package:naivisense/data/services/location_service.dart';

import '../../../data/models/child.dart';
import '../../../data/repositories/attendance_repository.dart';

class AttendanceState {
  final String? loadingSessionId;
  final bool success;
  final String? error;

  const AttendanceState({
    this.loadingSessionId,
    this.success = false,
    this.error,
  });

  bool isLoading(String sessionId) => loadingSessionId == sessionId;

  AttendanceState copyWith({
    String? loadingSessionId,
    bool? success,
    String? error,
  }) {
    return AttendanceState(
      loadingSessionId: loadingSessionId,
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

  Future<void> markAttendanceForChild(
    ChildModel child,
    SessionModel session,
  ) async {
    if (_isSubmitting) return;

    final ok = await markAttendance(child.id, session.id);

    if (ok) {
      _lastMarkedAt = DateTime.now();
    }
  }

  Future<bool> markAttendance(String childId, String sessionId) async {
    if (_isSubmitting) return false;

    _isSubmitting = true;

    state = state.copyWith(
      loadingSessionId: sessionId,
      success: false,
      error: null,
    );

    try {
      final position = await LocationService.getCurrentLocation();

      if (position == null) {
        state = state.copyWith(
          loadingSessionId: null,
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
            sessionId: sessionId,
            date: DateTime.now(),
            latitude: position.latitude,
            longitude: position.longitude,
          );

      state = state.copyWith(
        loadingSessionId: null,
        success: true,
        error: null,
      );

      _isSubmitting = false;
      return true;
    } catch (e) {
      debugPrint("Attendance Error: $e");

      state = state.copyWith(
        loadingSessionId: null,
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
