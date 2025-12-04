import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../../core/constants/app_colors.dart';

class SubjectCard extends StatelessWidget {
  final String subject;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double? progress; // 0.0 to 1.0

  const SubjectCard({
    super.key,
    required this.subject,
    required this.icon,
    required this.color,
    required this.onTap,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.5);
    final isHighContrast = MediaQuery.of(context).highContrast;
    
    return Semantics(
      label: '$subject subject card${progress != null ? ', ${(progress! * 100).toInt()}% complete' : ''}',
      button: true,
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isHighContrast
                    ? [color, color]
                    : [
                        color.withOpacity(0.8),
                        color,
                      ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48 * textScaleFactor, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 18 * textScaleFactor,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress! * 100).toInt()}% done',
                    style: TextStyle(
                      fontSize: 12 * textScaleFactor,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
