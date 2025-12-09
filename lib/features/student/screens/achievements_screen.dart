import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/points_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/widgets/badge_unlock_animation.dart';
import '../../../data/models/badge_model.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _pointsService = PointsService();
  final _authService = AuthService();
  List<Badge> _badges = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBadges();
  }

  Future<void> _loadBadges() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final badges = await _pointsService.getUserBadges(user.id);
        setState(() {
          _badges = badges;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: _badges.isEmpty
          ? const Center(
              child: Text('No badges unlocked yet. Keep learning!'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _badges.length,
              itemBuilder: (context, index) {
                final badge = _badges[index];
                return Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events,
                        size: MediaQuery.of(context).size.width < 360 ? 48 : 64,
                        color: AppColors.accent,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        badge.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          badge.description,
                          style: const TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

