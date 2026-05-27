import 'package:flutter/material.dart';

import '../../app.dart';
import '../../data/app_controller.dart';
import '../../data/models.dart';
import '../../shared/widgets/ad_widgets.dart';
import '../../shared/widgets/premium_widgets.dart';
import '../legal/legal_screen.dart';
import '../premium/premium_screen.dart';
import '../themes/theme_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const route = '/settings';

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final settings = app.settings;
    return PremiumScaffold(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  PremiumCard(
                    child: Column(
                      children: [
                        _SwitchRow(
                          title: 'Sound',
                          icon: Icons.volume_up_rounded,
                          value: settings.sound,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(sound: v)),
                        ),
                        _SwitchRow(
                          title: 'Haptics',
                          icon: Icons.vibration_rounded,
                          value: settings.haptics,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(haptics: v)),
                        ),
                        _SwitchRow(
                          title: 'Mistake limit',
                          icon: Icons.warning_rounded,
                          value: settings.mistakeLimit,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(mistakeLimit: v)),
                        ),
                        _SwitchRow(
                          title: 'Auto notes cleanup',
                          icon: Icons.auto_fix_high_rounded,
                          value: settings.autoNotesCleanup,
                          onChanged: (v) => _save(
                            app,
                            settings.copyWith(autoNotesCleanup: v),
                          ),
                        ),
                        _SwitchRow(
                          title: 'Large number mode',
                          icon: Icons.format_size_rounded,
                          value: settings.largeNumbers,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(largeNumbers: v)),
                        ),
                        _SwitchRow(
                          title: 'Colorblind-safe highlights',
                          icon: Icons.contrast_rounded,
                          value: settings.colorblindSafe,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(colorblindSafe: v)),
                        ),
                        _SwitchRow(
                          title: 'Left-handed mode',
                          icon: Icons.back_hand_rounded,
                          value: settings.leftHandedMode,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(leftHandedMode: v)),
                        ),
                        _SwitchRow(
                          title: 'Relax ambient sounds',
                          icon: Icons.music_note_rounded,
                          value: settings.ambientSounds,
                          onChanged: (v) =>
                              _save(app, settings.copyWith(ambientSounds: v)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PremiumCard(
                    onTap: () =>
                        Navigator.pushNamed(context, PremiumScreen.route),
                    child: Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: app.activeTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Premium',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                settings.premium
                                    ? 'Active subscription preview'
                                    : 'Plans, benefits, and subscription prep',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PremiumCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notification prep',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          app.notificationPrep.dailyChallengeMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          app.notificationPrep.streakReminderMessage,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PremiumCard(
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_rounded,
                          color: app.activeTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Legal',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            LegalScreen.privacyRoute,
                          ),
                          child: const Text('Privacy'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(
                            context,
                            LegalScreen.termsRoute,
                          ),
                          child: const Text('Terms'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PremiumCard(
                    onTap: () => Navigator.pushNamed(
                      context,
                      ThemeSelectionScreen.route,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.palette_rounded,
                          color: app.activeTheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Theme',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            app.activeTheme.name,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'Sudoku 1.0.0',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const PremiumBannerAdSlot(),
          const SizedBox(height: 10),
          const SudokuBottomNav(currentIndex: 4),
        ],
      ),
    );
  }

  void _save(AppController app, SettingsState settings) =>
      app.updateSettings(settings);
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
  });
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: theme.primary),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      value: value,
      onChanged: onChanged,
    );
  }
}
