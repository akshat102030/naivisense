import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:naivisense/providers/socket_event_provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/models/api/auth_requests.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../providers/socket_provider.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool loading;
  final String? token;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
    this.token,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? loading,
    String? token,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
      loading: loading ?? this.loading,
      token: token ?? this.token,
    );
  }
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncLoading();

    try {
      final auth = await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(phone: phone, password: password));

      // Connect socket
      await ref
          .read(socketServiceProvider)
          .connect(
            baseUrl: AppConstants.socketUrl,
            token: auth.accessToken,
            userId: auth.user.id,
          );

      // Register all socket listeners after connection
      ref.read(socketEventHandlerProvider).initialize();

      state = AsyncData(
        AuthState(
          status: AuthStatus.authenticated,
          user: auth.user,
          token: auth.accessToken,
        ),
      );
    } catch (e) {
      state = AsyncData(
        AuthState(status: AuthStatus.unauthenticated, error: e.toString()),
      );
    }
  }

  Future<void> logout() async {
    // Remove socket listeners
    ref.read(socketEventHandlerProvider).dispose();

    // Disconnect socket
    ref.read(socketServiceProvider).disconnect();

    // Logout from backend
    await ref.read(authRepositoryProvider).logout();

    state = const AsyncData(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
