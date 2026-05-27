import 'package:flutter/material.dart';

import '../../app.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ad_widgets.dart';
import '../../shared/widgets/premium_widgets.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});
  static const route = '/themes';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    return PremiumScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Text(
            'Theme store',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            '${app.stats.coins} coins available',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: SudokuTheme.catalog.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final theme = SudokuTheme.catalog.values.elementAt(index);
                final unlocked = app.unlockedThemes.contains(theme.id);
                final active = app.themeId == theme.id;
                return PremiumCard(
                  onTap: () => app.updateTheme(theme.id),
                  child: Row(
                    children: [
                      _Swatch(theme: theme),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              unlocked ? 'Unlocked' : '${theme.price} coins',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        active
                            ? Icons.check_circle_rounded
                            : unlocked
                            ? Icons.lock_open_rounded
                            : Icons.lock_rounded,
                        color: active ? theme.primary : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const PremiumBannerAdSlot(),
          const SizedBox(height: 8),
          const SudokuBottomNav(currentIndex: 3),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.theme});
  final SudokuTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.primary.withValues(alpha: .22)),
      ),
      child: Center(
        child: Wrap(
          spacing: 3,
          runSpacing: 3,
          children:
              [
                    theme.primary,
                    theme.selectedCell,
                    theme.highlightCell,
                    theme.button,
                  ]
                  .map(
                    (c) => Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
