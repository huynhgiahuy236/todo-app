class ApiEndpoints {
  // Local development URL: 10.0.2.2 for Android Emulator, localhost for iOS/Web/Desktop
  // Can be easily overridden via Environment variable or Settings
  static const String defaultBaseUrl = 'http://10.0.2.2:5000/api';
  static const String defaultLocalhostUrl = 'http://localhost:5000/api';

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
