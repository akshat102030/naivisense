import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/assessment.dart';
import '../services/api_service.dart';

class AssessmentsRepository {
  final ApiService _api;
  AssessmentsRepository(this._api);

  Future<List<AssessmentModel>> getAssessments(String childId) async {
    final res  = await _api.get<List<dynamic>>('/assessments', params: {'childId': childId});
    final list = res.data ?? [];
    return list.map((e) => AssessmentModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AssessmentModel> getAssessment(String id) async {
    final res = await _api.get<Map<String, dynamic>>('/assessments/$id');
    return AssessmentModel.fromJson(res.data!);
  }

  Future<AssessmentModel> createAssessment(Map<String, dynamic> payload) async {
    final res = await _api.post<Map<String, dynamic>>('/assessments', data: payload);
    return AssessmentModel.fromJson(res.data!);
  }
}

final assessmentsRepositoryProvider = Provider<AssessmentsRepository>(
  (ref) => AssessmentsRepository(ref.read(apiServiceProvider)),
);
