/// Route isimleri - tum navigasyonda kullanilir
class RouteNames {
  RouteNames._();

  static const String splash = 'splash';
  static const String login = 'login';
  static const String shell = 'shell';
  static const String home = 'home';
  static const String workOrders = 'work-orders';
  static const String workOrderDetail = 'work-order-detail';
  static const String workOrderCreate = 'work-order-create';
  static const String notifications = 'notifications';
  static const String profile = 'profile';
}

/// Route path'leri
class RoutePaths {
  RoutePaths._();

  static const String splash = '/splash';
  static const String login = '/login';
  static const String home = '/home';
  static const String workOrders = '/work-orders';
  static String workOrderDetail(String id) => '/work-orders/$id';
  static const String workOrderCreate = '/work-orders/create';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
}
