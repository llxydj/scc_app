import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

class AnswerFeedback extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback? onAnimationComplete;

  const AnswerFeedback({
    super.key,
    required this.isCorrect,
    this.onAnimationComplete,
  });

  @override
  State<AnswerFeedback> createState() => _AnswerFeedbackState();
}

class _AnswerFeedbackState extends State<AnswerFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    if (widget.isCorrect) {
      // Correct: Fade in with slide
      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeIn),
      );
      _slideAnimation = Tween<Offset>(
        begin: const Offset(0, -0.5),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ));
      HapticFeedback.mediumImpact();
    } else {
      // Incorrect: Shake animation
      _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
      );
      HapticFeedback.lightImpact();
    }

    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        widget.onAnimationComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCorrect) {
      return FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: const Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: 64,
          ),
        ),
      );
    } else {
      return AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              math.sin(_shakeAnimation.value * 2 * math.pi * 3) * 10,
              0,
            ),
            child: const Icon(
              Icons.cancel,
              color: AppColors.error,
              size: 64,
            ),
          );
        },
      );
    }
  }
}

