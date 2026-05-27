import 'package:flutter/material.dart';

import '../../shared/widgets/premium_widgets.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen.privacy({super.key})
    : title = 'Privacy Policy',
      body =
          'Sudoku respects your privacy. This app collects limited information only to provide app features, improve performance, support login, show ads, and manage premium access.\n\n'
          'Information We May Collect:\n'
          '- Name, username, email, and profile photo when using Google Sign-In\n'
          '- Game progress, scores, achievements, streaks, and settings\n'
          '- Device and app performance data\n'
          '- Advertising identifiers for showing ads to free users\n\n'
          'How We Use Information:\n'
          '- To save your profile and game progress\n'
          '- To provide leaderboards, friends, and future cloud sync features\n'
          '- To improve app performance and fix crashes\n'
          '- To show rewarded ads, banner ads, and other ads for free users\n'
          '- To manage premium features and remove ads for subscribed users\n\n'
          'Ads:\n'
          'Free users may see banner ads, rewarded video ads, and occasional interstitial ads. Ads may be provided by third-party advertising networks such as Google AdMob.\n\n'
          'Premium:\n'
          'Premium users may receive ad-free gameplay, unlimited hints, premium themes, advanced stats, and other subscription features.\n\n'
          'Google Sign-In:\n'
          'If you use Google Sign-In, we may receive your name, email address, and profile photo from your Google account.\n\n'
          'Data Sharing:\n'
          'We do not sell your personal information. Some data may be shared with trusted services such as authentication, analytics, ads, crash reporting, and payment providers.\n\n'
          'Children:\n'
          'Sudoku is intended for general users. If children use the app, they should do so with parent or guardian permission.\n\n'
          'Data Security:\n'
          'We use reasonable security practices to protect your information.\n\n'
          'Contact:\n'
          'If you have questions about this Privacy Policy, contact us at:\n'
          'your-email@example.com\n\n'
          'Last updated: May 2026';

  const LegalScreen.terms({super.key})
    : title = 'Terms of Use',
      body =
          'Sudoku is provided for closed testing as an offline-first puzzle game. Subscription, restore purchase, cloud sync, online race, and leaderboard flows are prepared for future production services and currently use safe local preview behavior.';

  static const privacyRoute = '/privacy';
  static const termsRoute = '/terms';

  final String title;
  final String body;

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
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: PremiumCard(
                child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
