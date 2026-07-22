
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/socket_service.dart';

final socketServiceProvider =
    Provider<SocketService>((ref) {
  return SocketService.instance;
});