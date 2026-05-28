import 'dart:async';
import 'dart:math';
import '../../../../core/auth/auth_state.dart';
import '../../../../core/auth/session_manager.dart';
import '../../../../core/error/app_error.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SessionManager _sessionManager;
  final Random _random = Random();

  AuthRepositoryImpl(this._sessionManager);

  // Simulated latency
  Future<void> _simulateLatency() async {
    final delay = 400 + _random.nextInt(600); // 400ms to 1000ms latency
    await Future<void>.delayed(Duration(milliseconds: delay));
  }

  // Simulated random failures (e.g. 5% transient error rate)
  void _maybeThrowTransientError() {
    if (_random.nextDouble() < 0.05) {
      throw const NetworkError(
        message: 'Transient connection error. Please retry.',
      );
    }
  }

  @override
  Future<UserEntity> login(String username, String password) async {
    await _simulateLatency();
    _maybeThrowTransientError();

    // Verify credentials
    final user = _mockAuthDB[username.toLowerCase().trim()];
    if (user == null || password != 'password123') {
      throw const AuthError(
        message: 'Invalid username or password. (Hint: Use any of: admin, supervisor, operator, driver with password123)',
      );
    }

    // Save tokens and session details
    await _sessionManager.saveSession(
      user: user,
      accessToken: 'jwt_access_token_for_${user.username}',
      refreshToken: 'jwt_refresh_token_for_${user.username}',
      expiry: DateTime.now().add(const Duration(hours: 8)),
    );

    return user;
  }

  @override
  Future<void> logout() async {
    await _simulateLatency();
    await _sessionManager.clearSession();
  }

  @override
  Future<UserEntity?> tryAutoLogin() async {
    await _simulateLatency();
    final isValid = await _sessionManager.isSessionValid;
    if (!isValid) return null;
    return await _sessionManager.getCurrentUser();
  }

  // Pre-configured enterprise mock roles database
  static const Map<String, UserEntity> _mockAuthDB = {
    'admin': UserEntity(
      id: 'usr_admin_001',
      username: 'admin',
      email: 'admin@oceanflow.io',
      role: UserRole.admin,
      displayName: 'Sarah Jenkins (Sys Admin)',
    ),
    'supervisor': UserEntity(
      id: 'usr_super_002',
      username: 'supervisor',
      email: 'j.muller@oceanflow.io',
      role: UserRole.supervisor,
      displayName: 'Captain John Muller',
    ),
    'operator': UserEntity(
      id: 'usr_op_003',
      username: 'operator',
      email: 'l.chen@oceanflow.io',
      role: UserRole.operator,
      displayName: 'Lin Chen (Dock Operator)',
    ),
    'driver': UserEntity(
      id: 'usr_drv_004',
      username: 'driver',
      email: 'r.kovacs@oceanflow.io',
      role: UserRole.driver,
      displayName: 'Robert Kovacs (Logistics Driver)',
    ),
  };
}
