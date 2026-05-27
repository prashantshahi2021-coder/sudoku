import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/models.dart';
import '../../shared/services/app_feedback.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../game/game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});
  static const route = '/difficulty';

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            'Pick your pace',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Each level has its own Gridy mood.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 860
                    ? 3
                    : constraints.maxWidth >= 560
                    ? 2
                    : 1;
                return GridView.builder(
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: Difficulty.values.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: crossAxisCount == 1 ? 1.12 : .86,
                  ),
                  itemBuilder: (context, index) => _DifficultyCard(
                    difficulty: Difficulty.values[index],
                    meta: _meta[index],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static const _meta = [
    _DifficultyMeta(
      'assets/difficulty/easy.png',
      'Relaxed play',
      Color(0xFF55D21B),
    ),
    _DifficultyMeta(
      'assets/difficulty/medium.png',
      'Balanced challenge',
      Color(0xFFFFB51C),
    ),
    _DifficultyMeta(
      'assets/difficulty/hard.png',
      'Brain workout',
      Color(0xFFFF5A1F),
    ),
    _DifficultyMeta(
      'assets/difficulty/expert.png',
      'Serious logic',
      Color(0xFF199BFF),
    ),
    _DifficultyMeta(
      'assets/difficulty/master.png',
      'Elite solving',
      Color(0xFFC441F4),
    ),
    _DifficultyMeta(
      'assets/difficulty/extreme.png',
      'Only for masters',
      Color(0xFFFF2B20),
    ),
  ];
}

class _DifficultyCard extends StatefulWidget {
  const _DifficultyCard({required this.difficulty, required this.meta});
  final Difficulty difficulty;
  final _DifficultyMeta meta;

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard>
    with SingleTickerProviderStateMixin {
  bool hovering = false;
  bool pressed = false;
  bool selected = false;
  late final AnimationController pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..repeat(reverse: true);

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    final meta = widget.meta;
    return AnimatedBuilder(
      animation: pulse,
      builder: (context, child) {
        final glow = selected
            ? .42 + pulse.value * .24
            : hovering
            ? .34
            : .22;
        final scale = selected
            ? 1.035
            : pressed
            ? .97
            : hovering
            ? 1.015
            : 1.0;
        return AnimatedScale(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: meta.color.withValues(alpha: glow),
                  blurRadius: selected ? 34 : 24,
                  spreadRadius: selected ? 2 : 0,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => hovering = true),
        onExit: (_) => setState(() {
          hovering = false;
          pressed = false;
        }),
        child: GestureDetector(
          onTapDown: (_) => setState(() => pressed = true),
          onTapCancel: () => setState(() => pressed = false),
          onTapUp: (_) => setState(() => pressed = false),
          onTap: _selectDifficulty,
          child: Material(
            color: Color.lerp(theme.card, meta.color, .08),
            borderRadius: BorderRadius.circular(26),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: meta.color.withValues(alpha: selected ? .72 : .28),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(theme.card, meta.color, .10)!,
                    theme.card,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: meta.color.withValues(alpha: .18),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          meta.asset,
                          cacheWidth: 512,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.difficulty.label,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      meta.subtitle,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: meta.color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.grid_3x3_rounded,
                          color: theme.locked,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${81 - widget.difficulty.emptyCells} clues',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: meta.color,
                          size: 18,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDifficulty() async {
    if (selected) return;
    setState(() => selected = true);
    await AppFeedback.tap();
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    await AppScope.of(context).startGame(widget.difficulty);
    if (mounted) {
      Navigator.pushReplacementNamed(context, GameScreen.route);
    }
  }
}

class _DifficultyMeta {
  const _DifficultyMeta(this.asset, this.subtitle, this.color);
  final String asset;
  final String subtitle;
  final Color color;
}
