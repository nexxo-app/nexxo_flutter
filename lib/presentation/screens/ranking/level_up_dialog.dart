import 'package:flutter/material.dart';
import '../../../data/models/ranking_models.dart';
import '../../widgets/glass_container.dart';

class LevelUpDialog extends StatefulWidget {
  final RankingLeague previousLeague;
  final RankingLeague newLeague;
  final int xpEarned;
  final VoidCallback? onDismiss;

  const LevelUpDialog({
    super.key,
    required this.previousLeague,
    required this.newLeague,
    required this.xpEarned,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required RankingLeague previousLeague,
    required RankingLeague newLeague,
    required int xpEarned,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(
        previousLeague: previousLeague,
        newLeague: newLeague,
        xpEarned: xpEarned,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  State<LevelUpDialog> createState() => _LevelUpDialogState();
}

class _LevelUpDialogState extends State<LevelUpDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotateAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutBack),
    );

    // Start animations
    _scaleController.forward();
    _rotateController.forward();
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _rotateController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: child,
            ),
          );
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Confetti-like decoration
              Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _confettiController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 200),
                        painter: _ConfettiPainter(
                          progress: _confettiController.value,
                          color: Color(widget.newLeague.color),
                        ),
                      );
                    },
                  ),
                  // League emoji
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.bounceOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text(
                          widget.newLeague.emoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(widget.newLeague.color),
                    Colors.white,
                    Color(widget.newLeague.color),
                  ],
                ).createShader(bounds),
                child: const Text(
                  'SUBIU DE LIGA!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // League transition
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        widget.previousLeague.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      Text(
                        widget.previousLeague.name,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: Color(widget.newLeague.color),
                      size: 32,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        widget.newLeague.emoji,
                        style: const TextStyle(fontSize: 32),
                      ),
                      Text(
                        widget.newLeague.name,
                        style: TextStyle(
                          color: Color(widget.newLeague.color),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // XP earned
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.xpEarned} XP',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description
              Text(
                'Parabéns! Você alcançou a liga ${widget.newLeague.name}!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),

              const SizedBox(height: 24),

              // Continue button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onDismiss?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(widget.newLeague.color),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CONTINUAR',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ConfettiPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final random = [0.1, 0.3, 0.5, 0.7, 0.9, 0.2, 0.4, 0.6, 0.8];
    final colors = [
      color,
      Colors.amber,
      Colors.white,
      color.withValues(alpha: 0.7),
      Colors.amber.withValues(alpha: 0.7),
    ];

    for (int i = 0; i < 20; i++) {
      final x = size.width * random[i % random.length];
      final y =
          (size.height * 0.3) +
          (size.height * 0.4 * (1 - progress)) * (i % 2 == 0 ? 1 : -1) +
          20 * (i % 3);

      paint.color = colors[i % colors.length].withValues(
        alpha: (1 - progress) * 0.8,
      );

      canvas.drawCircle(
        Offset(x + 10 * (i % 3 - 1), y),
        4 + (i % 3) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Mission Complete Dialog
class MissionCompleteDialog extends StatefulWidget {
  final WeeklyMission mission;
  final VoidCallback? onDismiss;

  const MissionCompleteDialog({
    super.key,
    required this.mission,
    this.onDismiss,
  });

  static Future<void> show(
    BuildContext context, {
    required WeeklyMission mission,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          MissionCompleteDialog(mission: mission, onDismiss: onDismiss),
    );
  }

  @override
  State<MissionCompleteDialog> createState() => _MissionCompleteDialogState();
}

class _MissionCompleteDialogState extends State<MissionCompleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final difficultyColor = Color(widget.mission.difficulty.color);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: GlassContainer(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Check icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 64,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Missão Completa!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Text(
                widget.mission.missionType.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),

              const SizedBox(height: 24),

              // XP reward
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      difficultyColor,
                      difficultyColor.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: difficultyColor.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '+${widget.mission.missionType.xpReward} XP',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Continue button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onDismiss?.call();
                },
                child: const Text(
                  'Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
