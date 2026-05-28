abstract final class RouteNames {
  RouteNames._();

  static const splash = '/';
  static const login = '/login';
  
  // Tab shell routes
  static const dashboard = '/dashboard';
  static const shipments = '/shipments';
  static const sync = '/sync';
  static const aiAssistant = '/ai-assistant';
  static const notifications = '/notifications';

  // Details
  static const shipmentDetail = 'detail/:id';
  static const trackingUpdate = 'tracking-update';
  
  // Aux routes
  static const settings = '/settings';
  static const profile = '/profile';
  static const unauthorized = '/unauthorized';
}
