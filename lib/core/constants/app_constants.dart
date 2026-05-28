abstract final class AppConstants {
  AppConstants._();

  static const appName = 'OceanFlow';
  static const appVersion = '1.0.0';

  // Pagination
  static const defaultPageSize = 20;
  static const maxPageSize = 100;

  // Cache
  static const shipmentCacheTtlHours = 24;
  static const dashboardCacheTtlMinutes = 30;

  // File upload
  static const maxProofImageSizeMb = 10;
  static const allowedImageExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  // Session
  static const sessionTimeoutMinutes = 480; // 8 hours
  static const tokenRefreshThresholdMinutes = 5;
}
