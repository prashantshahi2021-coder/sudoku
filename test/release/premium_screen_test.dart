import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/app.dart';
import 'package:sudoku/data/app_controller.dart';
import 'package:sudoku/features/legal/legal_screen.dart';
import 'package:sudoku/features/premium/premium_screen.dart';

void main() {
  testWidgets('Premium screen is scrollable on small Android screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      AppScope(
        controller: AppController(),
        child: MaterialApp(
          routes: {
            LegalScreen.privacyRoute: (_) => const LegalScreen.privacy(),
            LegalScreen.termsRoute: (_) => const LegalScreen.terms(),
          },
          home: const PremiumScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sudoku Premium'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
