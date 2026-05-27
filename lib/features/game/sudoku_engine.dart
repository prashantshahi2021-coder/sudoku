import 'dart:math';

import '../../data/models.dart';

class PuzzleBundle {
  const PuzzleBundle({required this.solution, required this.puzzle});
  final List<List<int>> solution;
  final List<List<int>> puzzle;
}

class SudokuEngine {
  final Random _random = Random();

  PuzzleBundle generate(Difficulty difficulty) {
    final solution = List.generate(9, (_) => List.filled(9, 0));
    _fill(solution);
    final puzzle = solution.map((row) => List<int>.from(row)).toList();
    final cells = List.generate(81, (i) => i)..shuffle(_random);
    for (final index in cells.take(difficulty.emptyCells)) {
      puzzle[index ~/ 9][index % 9] = 0;
    }
    return PuzzleBundle(solution: solution, puzzle: puzzle);
  }

  bool _fill(List<List<int>> board) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] != 0) continue;
        final values = List.generate(9, (i) => i + 1)..shuffle(_random);
        for (final value in values) {
          if (_isValid(board, r, c, value)) {
            board[r][c] = value;
            if (_fill(board)) return true;
            board[r][c] = 0;
          }
        }
        return false;
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> board, int row, int col, int value) {
    for (var i = 0; i < 9; i++) {
      if (board[row][i] == value || board[i][col] == value) return false;
    }
    final boxRow = row ~/ 3 * 3;
    final boxCol = col ~/ 3 * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        if (board[r][c] == value) return false;
      }
    }
    return true;
  }
}
