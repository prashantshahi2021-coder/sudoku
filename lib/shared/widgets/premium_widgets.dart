import 'package:flutter/material.dart';

import '../../app.dart';
import '../services/app_feedback.dart';

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 24),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.background,
              Color.lerp(theme.background, theme.primary, .08)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _GridGlowPainter(theme.primary)),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: 1,
      child: Material(
        color: color ?? theme.card,
        borderRadius: BorderRadius.circular(24),
        shadowColor: theme.shadow,
        elevation: 10,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class PillButton extends StatelessWidget {
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return FilledButton.icon(
      onPressed: () {
        AppFeedback.tap();
        onPressed();
      },
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: filled ? theme.button : theme.card,
        foregroundColor: filled ? Colors.white : theme.primary,
        elevation: filled ? 8 : 0,
        shadowColor: theme.button.withValues(alpha: .25),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

class GridyMascot extends StatelessWidget {
  const GridyMascot({super.key, this.mood = 'happy', this.size = 70});

  final String mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [theme.accent.withValues(alpha: .95), theme.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: .32),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(size * .2),
              child: GridView.count(
                crossAxisCount: 3,
                physics: const NeverScrollableScrollPhysics(),
                children: List.generate(
                  9,
                  (index) => Container(
                    margin: EdgeInsets.all(size * .018),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: index.isEven ? .28 : .14,
                      ),
                      borderRadius: BorderRadius.circular(size * .035),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Icon(
            Icons.psychology_alt_rounded,
            color: Colors.white.withValues(alpha: .92),
            size: size * .54,
          ),
          Positioned(
            bottom: size * .18,
            child: Container(
              width: size * .42,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SudokuIconTile extends StatelessWidget {
  const SudokuIconTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.size = 76,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return InkWell(
      onTap: () {
        AppFeedback.tap();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: size,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: active ? theme.primary : theme.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? theme.primary : theme.boardLine),
          boxShadow: [
            BoxShadow(
              color: active
                  ? theme.shadow
                  : theme.shadow.withValues(alpha: .55),
              blurRadius: active ? 18 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: active ? Colors.white : theme.primary, size: 25),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? Colors.white : theme.text,
                fontSize: AppScope.of(context).settings.largeNumbers ? 13 : 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SudokuBottomNav extends StatelessWidget {
  const SudokuBottomNav({super.key, required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    final items = [
      (Icons.home_rounded, 'Home', '/home'),
      (Icons.bar_chart_rounded, 'Stats', '/stats'),
      (Icons.person_rounded, 'Profile', '/profile'),
      (Icons.palette_rounded, 'Theme', '/themes'),
      (Icons.settings_rounded, 'Settings', '/settings'),
    ];
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Center(
                child: InkWell(
                  onTap: () {
                    AppFeedback.tap();
                    if (i != currentIndex) {
                      Navigator.pushReplacementNamed(context, items[i].$3);
                    }
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 170),
                    padding: EdgeInsets.symmetric(
                      horizontal: i == currentIndex ? 10 : 8,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: i == currentIndex
                          ? theme.highlightCell
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            items[i].$1,
                            color: i == currentIndex
                                ? theme.primary
                                : theme.locked,
                            size: 22,
                          ),
                          if (i == currentIndex) ...[
                            const SizedBox(width: 6),
                            Text(
                              items[i].$2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: theme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GridGlowPainter extends CustomPainter {
  const _GridGlowPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .035)
      ..strokeWidth = 1;
    const gap = 42.0;
    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridGlowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.action, this.onAction});

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Row(
      children: [
        Expanded(child: Text(title, style: text.titleLarge)),
        if (action != null)
          TextButton(onPressed: onAction, child: Text(action!)),
      ],
    );
  }
}
