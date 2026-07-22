import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/data/services/socket_event_handler.dart';

final socketEventHandlerProvider = Provider((ref) => SocketEventHandler(ref));
