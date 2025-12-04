import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../data/repositories/quiz_repository.dart';
import '../../../core/services/auth_service.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final _authService = AuthService();
  final _quizRepository = QuizRepository();
  String? _classCode;
  int _totalStudents = 0;
  int _activeToday = 0;
  double _avgScore = 0.0;
  Map<String, double> _subjectScores = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user?.classCode != null) {
        _classCode = user!.classCode;
        // In a real app, load actual stats from database
        // For now, use placeholder data
        setState(() {
          _totalStudents = 32;
          _activeToday = 28;
          _avgScore = 85.0;
          _subjectScores = {
            'Math': 88.0,
            'Science': 85.0,
            'English': 82.0,
            'Filipino': 85.0,
          };
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_classCode != null ? 'Class: $_classCode' : 'Teacher Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(AppRoutes.settings),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Students',
                          value: '$_totalStudents',
                          icon: Icons.people,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _StatCard(
                          title: 'Active Today',
                          value: '$_activeToday',
                          icon: Icons.check_circle,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Performance Overview
                  const Text(
                    'Performance Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text(
                            '📈 Avg Score: ${_avgScore.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: BarChart(
                              BarChartData(
                                barGroups: _subjectScores.entries.map((entry) {
                                  final index = _subjectScores.keys.toList().indexOf(entry.key);
                                  return BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value,
                                        color: _getSubjectColor(entry.key),
                                        width: 16,
                                      ),
                                    ],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        final subjects = _subjectScores.keys.toList();
                                        if (value.toInt() < subjects.length) {
                                          return Text(subjects[value.toInt()]);
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Text('${value.toInt()}%');
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Quick Actions
                  const Text(
                    'Quick Actions',
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
                    childAspectRatio: 1.5,
                    children: [
                      _ActionCard(
                        title: 'Create Content',
                        icon: Icons.add_circle,
                        color: AppColors.primary,
                        onTap: () => context.push(AppRoutes.createContent),
                      ),
                      _ActionCard(
                        title: 'Upload File',
                        icon: Icons.upload_file,
                        color: AppColors.secondary,
                        onTap: () => context.push(AppRoutes.uploadFile),
                      ),
                      _ActionCard(
                        title: 'Validation',
                        icon: Icons.verified_user,
                        color: AppColors.warning,
                        onTap: () => context.push(AppRoutes.validation),
                      ),
                      _ActionCard(
                        title: 'Reports',
                        icon: Icons.analytics,
                        color: AppColors.accent,
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.check_circle, color: AppColors.success),
                          title: const Text('Maria completed "Photosynthesis"'),
                          subtitle: const Text('2 hours ago'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.emoji_events, color: AppColors.accent),
                          title: const Text('Juan earned "Scholar" badge'),
                          subtitle: const Text('5 hours ago'),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.warning, color: AppColors.warning),
                          title: const Text('Pedro: No activity (7 days)'),
                          subtitle: const Text('Last active: Nov 27'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getSubjectColor(String subject) {
    switch (subject) {
      case 'Math':
        return AppColors.math;
      case 'Science':
        return AppColors.science;
      case 'English':
        return AppColors.english;
      case 'Filipino':
        return AppColors.filipino;
      default:
        return AppColors.primary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
