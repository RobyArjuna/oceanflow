import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(sessionManagerProvider));
});

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        errorMessage = null;

  const AuthState.loading()
      : status = AuthStatus.loading,
        user = null,
        errorMessage = null;

  const AuthState.authenticated(UserEntity user)
      : status = AuthStatus.authenticated,
        this.user = user,
        errorMessage = null;

  const AuthState.unauthenticated({String? errorMessage})
      : status = AuthStatus.unauthenticated,
        user = null,
        this.errorMessage = errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.tryAutoLogin();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.toString());
    }
  }

  Future<bool> login(String username, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.login(username, password);
      state = AuthState.authenticated(user);
      return true;
    } on AppError catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
      return false;
    } catch (e) {
      state = AuthState.unauthenticated(errorMessage: 'Login failed: $e');
      return false;
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.logout();
    } finally {
      state = const AuthState.unauthenticated();
    }
  }
}
