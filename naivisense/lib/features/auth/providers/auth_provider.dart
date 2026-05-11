import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/user.dart';
import '../../../data/models/api/auth_requests.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;
  final bool loading;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.loading = false,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
    bool? loading,
  }) =>
      AuthState(
        status:  status  ?? this.status,
        user:    user    ?? this.user,
        error:   error,
        loading: loading ?? this.loading,
      );
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final token = await StorageService.instance.getAccessToken();
    if (token == null) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
    try {
      final user = await ref.read(authRepositoryProvider).getMe();
      return AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      return const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String phone, String password) async {
    state = const AsyncValue.loading();
    try {
      final auth = await ref
          .read(authRepositoryProvider)
          .login(LoginRequest(phone: phone, password: password));
      state = AsyncValue.data(AuthState(
        status: AuthStatus.authenticated,
        user:   auth.user,
      ));
    } catch (e) {
      state = AsyncValue.data(AuthState(
        status: AuthStatus.unauthenticated,
        error:  e.toString(),
      ));
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
