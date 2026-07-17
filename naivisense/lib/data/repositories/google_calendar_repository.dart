import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/services/api_service.dart';

final googleCalendarRepositoryProvider = Provider<GoogleCalendarRepository>((
  ref,
) {
  return GoogleCalendarRepository(ref.read(apiServiceProvider));
});

class GoogleCalendarRepository {
  final ApiService _api;

  GoogleCalendarRepository(this._api);

  Future<String> getGoogleAuthUrl() async {
    final res = await _api.get(
      '/google/auth',
    );

    return res.data['url'] as String;
  }
}
