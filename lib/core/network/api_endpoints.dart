/// Centralized API endpoint constants.
/// All paths are relative to FlavorConfig.baseUrl.
abstract final class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const login = '/auth/login';
  static const logout = '/auth/logout';
  static const refreshToken = '/auth/refresh';
  static const me = '/auth/me';

  // Shipments
  static const shipments = '/shipments';
  static String shipmentById(String id) => '/shipments/$id';
  static String shipmentTimeline(String id) => '/shipments/$id/timeline';

  // Tracking
  static const trackingUpdate = '/tracking/update';
  static const checkpoints = '/tracking/checkpoints';

  // Sync
  static const syncPending = '/sync/pending';
  static const syncBatch = '/sync/batch';

  // Dashboard
  static const dashboardMetrics = '/dashboard';

  // Notifications
  static const notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';

  // AI
  static const aiChat = '/ai/chat';
}
