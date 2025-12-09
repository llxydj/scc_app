class AppRoutes {
  // Auth
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  
  // Student
  static const String studentHome = '/student/home';
  static const String quiz = '/student/quiz';
  static const String flashcard = '/student/flashcard';
  static const String achievements = '/student/achievements';
  static const String progress = '/student/progress';
  
  // Teacher
  static const String teacherDashboard = '/teacher/dashboard';
  static const String createContent = '/teacher/create-content';
  static const String uploadFile = '/teacher/upload-file';
  static const String validation = '/teacher/validation';
  static const String classProgress = '/teacher/class-progress';
  static const String accessCodes = '/teacher/access-codes';
  
  // Parent
  static const String parentDashboard = '/parent/dashboard';
  static const String childProgress = '/parent/child-progress';
  
  // Shared
  static const String settings = '/settings';
  static const String profile = '/profile';
}