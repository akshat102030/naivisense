import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';
import '../models/home_plan.dart';

final homePlansRepositoryProvider = Provider<HomePlansRepository>(
  (ref) => HomePlansRepository(ref.read(apiServiceProvider)),
);

class HomePlansRepository {
  final ApiService _api;
  HomePlansRepository(this._api);

  Future<HomePlanModel?> getActivePlan(String childId) async {
    try {
      final res = await _api.get('/home-plans/active', params: {'childId': childId});
      return HomePlanModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      final ex = ErrorHandlerService.handle(e);
      if (ex.code == 'NOT_FOUND' || ex.code == 'FORBIDDEN') return null;
      throw ex;
    }
  }

  Future<HomePlanModel> createPlan(Map<String, dynamic> data) async {
    try {
      final res = await _api.post('/home-plans', data: data);
      return HomePlanModel.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<void> logTask({
    required String planId,
    required String taskId,
    String note = 'Completed',
  }) async {
    try {
      final form = FormData.fromMap({'note': note});
      await _api.postForm('/home-plans/$planId/tasks/$taskId/log', form);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
