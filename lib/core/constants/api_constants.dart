/// API endpoint sabitleri
/// Backend: ASP.NET Core 10 + OpenIddict
class ApiConstants {
  ApiConstants._();

  // Auth endpoints
  static const String tokenEndpoint = '/connect/token';
  static const String logoutEndpoint = '/connect/logout';
  static const String userInfoEndpoint = '/connect/userinfo';

  // User endpoints
  static const String users = '/User';
  static String userById(String id) => '/User/$id';

  // Work (BMS) endpoints
  static const String works = '/Work/all';
  static String workById(String id) => '/Work/$id';
  static const String createWork = '/Work';
  static String updateWork(String id) => '/Work/$id';
  static String changeWorkStatus(String id) => '/Work/$id/status';
  static String changeWorkStep(String id) => '/Work/$id/step';
  static String assignWork(String id) => '/Work/$id/assign';
  static String forwardWork(String id) => '/Work/$id/forward';
  static const String workStatistics = '/Work/statistics';

  // Work Type endpoints
  static const String workTypes = '/WorkType';

  // Organization (OMS) endpoints
  static const String organizations = '/Organizations';
  static const String employees = '/Employees';

  // Notification (NMS) endpoints
  static const String notifications = '/Notification';
  static String notificationById(String id) => '/Notification/$id';
  static const String registerDevice = '/Notification/device';

  // Core endpoints
  static const String citizens = '/Citizens/all';
  static const String menus = '/Menus';
  static const String menuPermissions = '/MenuPermissions/menu-tree';

  // Reference endpoints
  static const String references = '/Reference';
}
