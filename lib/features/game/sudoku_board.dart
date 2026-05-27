import 'package:flutter/material.dart';

import '../../app.dart';
import '../../shared/services/app_feedback.dart';
import 'game_state.dart';

class SudokuBoard extends StatelessWidget {
  const SudokuBoard({super.key, required this.game});
  final GameState game;

  @override
  Widget build(BuildContext context) {
    final theme = AppScope.of(context).activeTheme;
    final settings = AppScope.of(context).settings;
    final highlight = settings.colorblindSafe
        ? const Color(0xFFFFF3A3)
        : theme.highlightCell;
    final selectedColor = settings.colorblindSafe
        ? const Color(0xFFFFB000)
        : theme.selectedCell;
    final sameNumberColor = settings.colorblindSafe
        ? const Color(0xFF00A6A6).withValues(alpha: .34)
        : theme.accent.withValues(alpha: .28);
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: theme.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: .16),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemCount: 81,
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final selected = row == game.selectedRow && col == game.selectedCol;
            final sameUnit =
                row == game.selectedRow ||
                col == game.selectedCol ||
                (row ~/ 3 == game.selectedRow ~/ 3 &&
                    col ~/ 3 == game.selectedCol ~/ 3);
            final selectedValue =
                game.board[game.selectedRow][game.selectedCol];
            final sameNumber =
                selectedValue != 0 && game.board[row][col] == selectedValue;
            final value = game.board[row][col];
            final notes = game.notes[row][col].toList()..sort();
            return AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                color: selected
                    ? selectedColor
                    : sameNumber
                    ? sameNumberColor
                    : sameUnit
                    ? highlight
                    : theme.card,
                border: Border(
                  right: BorderSide(
                    width: col == 2 || col == 5 ? 2.2 : .6,
                    color: col == 2 || col == 5
                        ? theme.boardBoldLine
                        : theme.boardLine,
                  ),
                  bottom: BorderSide(
                    width: row == 2 || row == 5 ? 2.2 : .6,
                    color: row == 2 || row == 5
                        ? theme.boardBoldLine
                        : theme.boardLine,
                  ),
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  AppFeedback.tap();
                  game.select(row, col);
                },
                child: Center(
                  child: value == 0
                      ? Wrap(
                          spacing: 3,
                          runSpacing: 1,
                          alignment: WrapAlignment.center,
                          children: notes
                              .map(
                                (n) => Text(
                                  '$n',
                                  style: TextStyle(
                                    fontSize: settings.largeNumbers ? 11 : 9,
                                    color: settings.colorblindSafe
                                        ? const Color(0xFF111827)
                                        : theme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                              .toList(),
                        )
                      : Text(
                          '$value',
                          style: TextStyle(
                            color: game.isGiven(row, col)
                                ? theme.locked
                                : theme.number,
                            fontSize: settings.largeNumbers ? 30 : 22,
                            fontWeight: game.isGiven(row, col)
                                ? FontWeight.w800
                                : FontWeight.w900,
                          ),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
