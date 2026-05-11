import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>(
  (ref) => ReportsRepository(ref.read(apiServiceProvider)),
);

class ProgressReport {
  final String childId;
  final List<Map<String, dynamic>> sessions;
  final double compliancePct;
  final int totalSessions;
  final double avgRating;

  const ProgressReport({
    required this.childId,
    required this.sessions,
    required this.compliancePct,
    required this.totalSessions,
    required this.avgRating,
  });

  factory ProgressReport.fromJson(Map<String, dynamic> j) => ProgressReport(
        childId:       j['child_id'] as String? ?? '',
        sessions:      (j['sessions'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [],
        compliancePct: (j['compliance_pct'] as num?)?.toDouble() ?? 0.0,
        totalSessions: j['total_sessions'] as int? ?? 0,
        avgRating:     (j['avg_rating'] as num?)?.toDouble() ?? 0.0,
      );
}

class ReportsRepository {
  final ApiService _api;
  ReportsRepository(this._api);

  Future<ProgressReport> getProgress({
    required String childId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final res = await _api.get('/reports/progress', params: {
        'childId': childId,
        'from':    from.toUtc().toIso8601String().substring(0, 10),
        'to':      to.toUtc().toIso8601String().substring(0, 10),
      });
      return ProgressReport.fromJson(res.data as Map<String, dynamic>);
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
