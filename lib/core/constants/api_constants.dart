/// API endpoint sabitleri
/// Backend: ASP.NET Core 10 + OpenIddict
class ApiConstants {
  ApiConstants._();

  // Auth endpoints
  static const String tokenEndpoint = '/connect/token';
  static const String logoutEndpoint = '/connect/logout';
  static const String userInfoEndpoint = '/connect/userinfo';
  static const String authMe = '/Auth/me'; // oturum: employeeId + memberships (org+rol+isFieldTeam)

  // User endpoints
  static const String users = '/User';
  static String userById(String id) => '/User/$id';

  // Menü (platforma göre kullanıcı menüleri) — mobil yetki gösterimi
  static const String menusForUser = '/Menus/for-user'; // ?organizationId=&platform=2 (Mobile)

  // Work (BMS) — mobil iş listeleri (3 grup)
  static const String mobileAssignedToMe = '/Work/mobile/assigned-to-me'; // ?employeeId=
  static const String mobileTeamWorks = '/Work/mobile/team'; // ?organizationIds=
  static const String mobileUnitPending = '/Work/mobile/unit-pending'; // ?organizationIds=
  static const String mobileStats = '/Work/mobile/stats'; // ?employeeId=|organizationIds=|useActiveOrgScope= &period=

  // Harita / OSRM (araç rotası) — on-prem proxy
  static const String mapConfig = '/Map/config'; // OSRM kullanılabilir mi
  static const String mapRouteMatrix = '/Map/route-matrix'; // ?originLat=&originLng=&destinations=lat,lng;...
  static const String mapOptimize = '/Map/optimize'; // ?points=lat,lng;...&roundTrip=false

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

  // Core endpoints
  static const String citizens = '/Citizens/all';
  static const String menus = '/Menus';
  static const String menuPermissions = '/MenuPermissions/menu-tree';

  // Reference endpoints
  static const String references = '/Reference';
}
