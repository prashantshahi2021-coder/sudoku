import 'package:flutter/material.dart';

class SudokuTheme {
  const SudokuTheme({
    required this.id,
    required this.name,
    required this.background,
    required this.primary,
    required this.selectedCell,
    required this.highlightCell,
    required this.button,
    required this.number,
    required this.card,
    required this.text,
    required this.accent,
    required this.locked,
    required this.success,
    required this.warning,
    required this.danger,
    required this.boardLine,
    required this.boardBoldLine,
    required this.shadow,
    this.dark = false,
    this.price = 0,
  });

  final String id;
  final String name;
  final Color background;
  final Color primary;
  final Color selectedCell;
  final Color highlightCell;
  final Color button;
  final Color number;
  final Color card;
  final Color text;
  final Color accent;
  final Color locked;
  final Color success;
  final Color warning;
  final Color danger;
  final Color boardLine;
  final Color boardBoldLine;
  final Color shadow;
  final bool dark;
  final int price;

  static const catalog = {
    'sky': SudokuTheme(
      id: 'sky',
      name: 'Ocean Blue',
      background: Color(0xFFEAF7FF),
      primary: Color(0xFF1683FF),
      selectedCell: Color(0xFFBFE7FF),
      highlightCell: Color(0xFFDDF3FF),
      button: Color(0xFF126BFF),
      number: Color(0xFF102A56),
      card: Colors.white,
      text: Color(0xFF0C1F3F),
      accent: Color(0xFF23C6B7),
      locked: Color(0xFF415B76),
      success: Color(0xFF19B883),
      warning: Color(0xFFFFB020),
      danger: Color(0xFFFF5E6C),
      boardLine: Color(0xFFD6E2EE),
      boardBoldLine: Color(0xFF7789A3),
      shadow: Color(0x332766DD),
    ),
    'forest': SudokuTheme(
      id: 'forest',
      name: 'Forest Green',
      background: Color(0xFFEFF8EF),
      primary: Color(0xFF1F8D5A),
      selectedCell: Color(0xFFBFEBD3),
      highlightCell: Color(0xFFDFF4E7),
      button: Color(0xFF14734A),
      number: Color(0xFF123B2C),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF10251D),
      accent: Color(0xFFE1B84D),
      locked: Color(0xFF496558),
      success: Color(0xFF1F8D5A),
      warning: Color(0xFFE4A72C),
      danger: Color(0xFFE45E57),
      boardLine: Color(0xFFD7E8DD),
      boardBoldLine: Color(0xFF6D8F7D),
      shadow: Color(0x331F8D5A),
      price: 90,
    ),
    'sakura': SudokuTheme(
      id: 'sakura',
      name: 'Sakura Pink',
      background: Color(0xFFFFEFF5),
      primary: Color(0xFFE9548E),
      selectedCell: Color(0xFFFFC7DD),
      highlightCell: Color(0xFFFFE0EC),
      button: Color(0xFFDA3D7D),
      number: Color(0xFF4A1830),
      card: Color(0xFFFFFFFF),
      text: Color(0xFF341224),
      accent: Color(0xFF52B6E8),
      locked: Color(0xFF735568),
      success: Color(0xFF20B887),
      warning: Color(0xFFFFB65C),
      danger: Color(0xFFE9546B),
      boardLine: Color(0xFFF1CCD9),
      boardBoldLine: Color(0xFFA9798E),
      shadow: Color(0x33E9548E),
      price: 130,
    ),
    'midnight': SudokuTheme(
      id: 'midnight',
      name: 'Midnight Dark',
      background: Color(0xFF0C1220),
      primary: Color(0xFF7CB7FF),
      selectedCell: Color(0xFF1E4774),
      highlightCell: Color(0xFF17283F),
      button: Color(0xFF348BFF),
      number: Color(0xFFEAF5FF),
      card: Color(0xFF141D2E),
      text: Color(0xFFF1F7FF),
      accent: Color(0xFFFFC766),
      locked: Color(0xFFB9C8D8),
      success: Color(0xFF3ADFA5),
      warning: Color(0xFFFFC766),
      danger: Color(0xFFFF6F7F),
      boardLine: Color(0xFF26344A),
      boardBoldLine: Color(0xFF6D7F9D),
      shadow: Color(0x66000000),
      dark: true,
      price: 180,
    ),
    'gold': SudokuTheme(
      id: 'gold',
      name: 'Gold Elite',
      background: Color(0xFFFFF8E7),
      primary: Color(0xFFB8860B),
      selectedCell: Color(0xFFFFE6A8),
      highlightCell: Color(0xFFFFF0C9),
      button: Color(0xFFD59A12),
      number: Color(0xFF3A2A0A),
      card: Color(0xFFFFFDF6),
      text: Color(0xFF2C210C),
      accent: Color(0xFF1B9AAA),
      locked: Color(0xFF6E5B2C),
      success: Color(0xFF209B68),
      warning: Color(0xFFE3A51C),
      danger: Color(0xFFD94F45),
      boardLine: Color(0xFFEADCB3),
      boardBoldLine: Color(0xFF9C8450),
      shadow: Color(0x33B8860B),
      price: 260,
    ),
    'white': SudokuTheme(
      id: 'white',
      name: 'Minimal White',
      background: Color(0xFFFAFBFD),
      primary: Color(0xFF30343F),
      selectedCell: Color(0xFFDCE7F5),
      highlightCell: Color(0xFFF0F4FA),
      button: Color(0xFF2F6FED),
      number: Color(0xFF151922),
      card: Colors.white,
      text: Color(0xFF111827),
      accent: Color(0xFFFFB000),
      locked: Color(0xFF667085),
      success: Color(0xFF16A36D),
      warning: Color(0xFFFFB000),
      danger: Color(0xFFE5484D),
      boardLine: Color(0xFFE4E7EC),
      boardBoldLine: Color(0xFF98A2B3),
      shadow: Color(0x1F344054),
      price: 70,
    ),
  };

  ThemeData toThemeData() {
    final scheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: dark ? Brightness.dark : Brightness.light,
      surface: card,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: dark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: scheme.copyWith(
        primary: primary,
        secondary: accent,
        surface: card,
      ),
      fontFamily: 'Roboto',
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          color: text,
          height: .98,
        ),
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w900,
          color: text,
          height: 1.04,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: text,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: text,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: text,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: text,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: text.withValues(alpha: .74),
        ),
        labelLarge: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: text.withValues(alpha: .76),
        ),
      ),
    );
  }
}
