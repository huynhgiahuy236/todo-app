class ApiEndpoints {
  static const String defaultBaseUrl = 'https://todo-app-1-bcqv.onrender.com/api';
  static const String defaultLocalhostUrl = 'https://todo-app-1-bcqv.onrender.com/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String getMe = '/auth/me';

  // Schedules
  static const String schedules = '/schedules';
  static String scheduleDetail(String id) => '/schedules/$id';
  static String scheduleOccurrence(String id) => '/schedules/$id/occurrence';
  static String scheduleFuture(String id) => '/schedules/$id/future';
  static String scheduleSeries(String id) => '/schedules/$id/series';

  // Tasks
  static const String tasks = '/tasks';
  static String taskDetail(String id) => '/tasks/$id';
  static String taskToggle(String id) => '/tasks/$id/toggle';

  // Notes
  static const String notes = '/notes';
  static String noteDetail(String id) => '/notes/$id';
  static String notePin(String id) => '/notes/$id/pin';
}
