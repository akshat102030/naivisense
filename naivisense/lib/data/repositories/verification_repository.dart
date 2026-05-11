import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/error_handler_service.dart';

final verificationRepositoryProvider = Provider<VerificationRepository>(
  (ref) => VerificationRepository(ref.read(apiServiceProvider)),
);

class VerificationItem {
  final String id;
  final String childId;
  final String type;   // home_task | meal
  final String status; // pending | approved | rejected
  final String? mediaUrl;
  final String? note;
  final DateTime createdAt;

  const VerificationItem({
    required this.id,
    required this.childId,
    required this.type,
    required this.status,
    this.mediaUrl,
    this.note,
    required this.createdAt,
  });

  factory VerificationItem.fromJson(Map<String, dynamic> j) => VerificationItem(
        id:        j['_id'] as String,
        childId:   j['child_id'] as String? ?? '',
        type:      j['type'] as String? ?? 'home_task',
        status:    j['status'] as String,
        mediaUrl:  j['media_url'] as String?,
        note:      j['note'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

class VerificationRepository {
  final ApiService _api;
  VerificationRepository(this._api);

  Future<List<VerificationItem>> getPending() async {
    try {
      final res = await _api.get('/verification/pending');
      final list = res.data as List<dynamic>;
      return list.map((e) => VerificationItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }

  Future<void> verify({
    required String logId,
    required String status, // approved | rejected
    String? feedback,
  }) async {
    try {
      await _api.post('/verification/$logId', data: {
        'status':   status,
        'feedback': ?feedback,
      });
    } catch (e) {
      throw ErrorHandlerService.handle(e);
    }
  }
}
