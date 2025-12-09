import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/services/notification_service.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/student/screens/home_screen.dart';
import 'features/student/screens/quiz_screen.dart';
import 'features/student/screens/flashcard_screen.dart';
import 'features/student/screens/achievements_screen.dart';
import 'features/teacher/screens/dashboard_screen.dart';
import 'features/teacher/screens/create_content_screen.dart';
import 'features/teacher/screens/upload_file_screen.dart';
import 'features/teacher/screens/validation_screen.dart';
import 'features/teacher/screens/assign_module_screen.dart';
import 'features/teacher/screens/access_codes_screen.dart';
import 'features/parent/screens/dashboard_screen.dart';
import 'features/shared/screens/settings_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      navigatorKey: NotificationService.navigatorKey,
      title: 'SCC Learning App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.surface,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: AppRoutes.login,
  routes: [
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.studentHome,
      builder: (context, state) => const StudentHomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.quiz,
      builder: (context, state) {
        final quizId = state.uri.queryParameters['quizId'] ?? '';
        final subject = state.uri.queryParameters['subject'] ?? '';
        return QuizScreen(quizId: quizId, subject: subject);
      },
    ),
    GoRoute(
      path: AppRoutes.flashcard,
      builder: (context, state) {
        final subject = state.uri.queryParameters['subject'] ?? '';
        return FlashcardScreen(subject: subject);
      },
    ),
    GoRoute(
      path: AppRoutes.achievements,
      builder: (context, state) => const AchievementsScreen(),
    ),
    GoRoute(
      path: AppRoutes.teacherDashboard,
      builder: (context, state) => const TeacherDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.createContent,
      builder: (context, state) => const CreateContentScreen(),
    ),
    GoRoute(
      path: AppRoutes.uploadFile,
      builder: (context, state) => const UploadFileScreen(),
    ),
    GoRoute(
      path: AppRoutes.validation,
      builder: (context, state) => const ValidationScreen(),
    ),
    GoRoute(
      path: AppRoutes.accessCodes,
      builder: (context, state) => const AccessCodesScreen(),
    ),
    GoRoute(
      path: '/teacher/assign-module',
      builder: (context, state) {
        final moduleId = state.uri.queryParameters['moduleId'] ?? '';
        final moduleType = state.uri.queryParameters['moduleType'] ?? 'quiz';
        return AssignModuleScreen(moduleId: moduleId, moduleType: moduleType);
      },
    ),
    GoRoute(
      path: AppRoutes.parentDashboard,
      builder: (context, state) => const ParentDashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

