import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/streak_flame.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../data/repositories/assignment_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/points_service.dart';
import '../../../core/services/sync_service.dart';
import '../../../core/services/subject_progress_service.dart';
import '../widgets/subject_card.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final _authService = AuthService();
  final _pointsService = PointsService();
  final _syncService = SyncService();
  final _quizRepository = QuizRepository();
  final _assignmentRepository = AssignmentRepository();
  final _subjectProgressService = SubjectProgressService();
  
  UserModel? _currentUser;
  bool _isLoading = true;
  int _selectedIndex = 0;
  Map<String, double> _subjectProgress = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _syncData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        // Try to get from local storage or redirect to login
        if (mounted) {
          context.go(AppRoutes.login);
        }
        return;
      }
      
      // Load subject progress
      final progress = await _subjectProgressService.getSubjectProgress(user.id);
      
      setState(() {
        _currentUser = user;
        _subjectProgress = progress;
        _isLoading = false;
      });
      
      // Update streak
      await _pointsService.updateStreak(user.id);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _syncData() async {
    try {
      if (await _syncService.isOnline()) {
        await _syncService.syncAll();
        await _syncService.pullFromCloud();
      }
    } catch (e) {
      // Handle sync error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${_currentUser!.name.split(' ').first}!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomeTab(),
          _buildProgressTab(),
          _buildAchievementsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Achievements'),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points and Streak Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Icon(Icons.stars, color: AppColors.accent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        Formatters.formatPoints(_currentUser!.points),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('Points'),
                    ],
                  ),
                  Container(width: 1, height: 50, color: AppColors.divider),
                  Column(
                    children: [
                      if (_currentUser!.streak > 0)
                        StreakFlame(streak: _currentUser!.streak)
                      else
                        const Icon(Icons.local_fire_department, color: AppColors.warning, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${_currentUser!.streak}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('${_currentUser!.streak} day${_currentUser!.streak != 1 ? 's' : ''}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Assigned Tasks Section
          FutureBuilder(
            future: _currentUser != null && _currentUser!.classCode != null
                ? _assignmentRepository.getAssignmentsForStudent(
                    _currentUser!.id,
                    _currentUser!.classCode!,
                  )
                : Future.value([]),
            builder: (context, snapshot) {
              final assignments = snapshot.data ?? [];
              if (assignments.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📋 Assigned Tasks',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...assignments.take(3).map((assignment) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(assignment.title),
                          subtitle: Text(
                            assignment.dueDate != null
                                ? 'Due: ${Formatters.formatDate(assignment.dueDate!)}'
                                : 'No due date',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            // Navigate to assignment
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Subjects Section
          const Text(
            'Continue Learning',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              SubjectCard(
                subject: 'Math',
                icon: Icons.calculate,
                color: AppColors.math,
                progress: _subjectProgress['Math'],
                onTap: () => _navigateToSubject('Math'),
              ),
              SubjectCard(
                subject: 'Science',
                icon: Icons.science,
                color: AppColors.science,
                progress: _subjectProgress['Science'],
                onTap: () => _navigateToSubject('Science'),
              ),
              SubjectCard(
                subject: 'English',
                icon: Icons.menu_book,
                color: AppColors.english,
                progress: _subjectProgress['English'],
                onTap: () => _navigateToSubject('English'),
              ),
              SubjectCard(
                subject: 'Filipino',
                icon: Icons.language,
                color: AppColors.filipino,
                progress: _subjectProgress['Filipino'],
                onTap: () => _navigateToSubject('Filipino'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return FutureBuilder(
      future: _quizRepository.getUserResults(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data ?? [];

        if (results.isEmpty) {
          return const Center(
            child: Text('No quiz results yet. Start taking quizzes!'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            final percentage = result.score / result.totalQuestions;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Quiz ${index + 1}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text('Score: ${result.score}/${result.totalQuestions}'),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 0.7 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.formatDateTime(result.completedAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                trailing: Icon(
                  result.isVerified == 1
                      ? Icons.check_circle
                      : result.isVerified == -1
                          ? Icons.error
                          : Icons.pending,
                  color: result.isVerified == 1
                      ? AppColors.verified
                      : result.isVerified == -1
                          ? AppColors.failed
                          : AppColors.flagged,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementsTab() {
    return FutureBuilder(
      future: _pointsService.getUserBadges(_currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final badges = snapshot.data ?? [];

        if (badges.isEmpty) {
          return const Center(
            child: Text('No badges unlocked yet. Keep learning!'),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final badge = badges[index];
            return Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, size: 48, color: AppColors.accent),
                  const SizedBox(height: 8),
                  Text(
                    badge.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    badge.description,
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToSubject(String subject) {
    // Navigate to subject detail or quiz selection
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$subject Options',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.quiz),
              title: const Text('Take Quiz'),
              onTap: () {
                Navigator.pop(context);
                context.push('${AppRoutes.quiz}?subject=$subject');
              },
            ),
            ListTile(
              leading: const Icon(Icons.style),
              title: const Text('Review Flashcards'),
              onTap: () {
                Navigator.pop(context);
                context.push('${AppRoutes.flashcard}?subject=$subject');
              },
            ),
          ],
        ),
      ),
    );
  }
}

