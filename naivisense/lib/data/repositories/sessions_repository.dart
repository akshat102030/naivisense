import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/models/scheduled_session_model.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/session.dart';

final sessionsRepositoryProvider = Provider<SessionsRepository>(
  (ref) => SessionsRepository(ref.read(apiServiceProvider)),
);

class SessionsRepository {
  final ApiService _api;
  SessionsRepository(this._api);

  Future<List<SessionModel>> getUpcoming() async {
    try {
      final res = await _api.get('/sessions/upcoming');
      final list = res.data as List<dynamic>;
      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<SessionModel>> getSessions({required String childId}) async {
    try {
      final res = await _api.get('/sessions', params: {'childId': childId});
      final list = res.data as List<dynamic>;
      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> updateSession(
    String sessionId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _api.patch('/sessions/$sessionId', data: payload);

      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> createSession(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/sessions', data: data);
      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> submitNotes(
    String sessionId,
    Map<String, dynamic> notes,
  ) async {
    try {
      final res = await _api.post(
        '/session-notes/$sessionId/notes',
        data: notes,
      );
      return SessionModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel> updateNotes(
    String sessionId,
    Map<String, dynamic> notes,
  ) async {
    try {
      final res = await _api.patch(
        '/session-notes/$sessionId/notes',
        data: notes,
      );
      return SessionModel.fromJson(res.data['data']);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<SessionModel>> getPendingAttendanceSessions({
    required String childId,
  }) async {
    try {
      final res = await _api.get(
        '/parent/child/$childId/sessions/pending-attendance', //  Change this.
      );

      final list = res.data as List<dynamic>;

      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionModel?> getNextSession({required String childId}) async {
    try {
      final res = await _api.get(
        '/sessions/next',
        params: {'childId': childId},
      );
      print('SessionsRepository.getNextSession: ${res.data}');
      if (res.data == null) return null;
      return SessionModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<SessionModel>> getUpcomingSessions({
    required String childId,
  }) async {
    try {
      final res = await _api.get('/parent/child/$childId/sessions/upcoming');
      final list = res.data as List<dynamic>;
      print('SessionsRepository.getUpcomingSessions: ${res.data}');
      return list
          .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<List<ScheduledSessionModel>> getScheduledSession({
    required String childId,
  }) async {
    try {
      final res = await _api.get('/parent/child/$childId/sessions/history');

      if (res.data == null) return [];
      print('SessionsRepository.getScheduledSession: ${res.data}');

      return (res.data as List)
          .map((e) => ScheduledSessionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<SessionNotes?> getSessionNotes(String sessionId) async {
    try {
      final res = await _api.get('/session-notes/$sessionId/notes');

      final data = res.data as Map<String, dynamic>;

      if (data['data'] == null) {
        return null;
      }

      return SessionNotes.fromJson(data['data'] as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
