import 'dart:math';

import '../data/models.dart';
import 'sudoku_solver.dart';

export 'sudoku_types.dart';

class SudokuGenerator {
  SudokuGenerator({int? seed})
    : _random = Random(seed),
      _seed = seed ?? DateTime.now().microsecondsSinceEpoch;

  final Random _random;
  final int _seed;
  final SudokuSolver _solver = SudokuSolver();

  SudokuPuzzle generate(Difficulty difficulty) {
    SudokuPuzzle? best;
    for (var attempt = 0; attempt < 8; attempt++) {
      final solution = _solutionBoard();
      final puzzle = cloneBoard(solution);
      final cells = List.generate(81, (i) => i)..shuffle(_random);
      var removed = 0;
      for (final index in cells) {
        if (removed >= difficulty.emptyCells) break;
        final row = index ~/ 9;
        final col = index % 9;
        if (puzzle[row][col] == 0) continue;
        final old = puzzle[row][col];
        puzzle[row][col] = 0;
        if (_solver.countSolutions(puzzle, limit: 2) == 1) {
          removed++;
        } else {
          puzzle[row][col] = old;
        }
      }
      final rating = _solver.rate(puzzle, solution);
      final candidate = SudokuPuzzle(
        difficulty: difficulty,
        puzzle: puzzle,
        solution: solution,
        rating: rating,
        seed: _seed + attempt,
      );
      best ??= candidate;
      if (_blankCount(candidate.puzzle) > _blankCount(best.puzzle)) {
        best = candidate;
      }
      if ((_blankCount(candidate.puzzle) - difficulty.emptyCells).abs() <= 2 &&
          rating.logicalScore >= difficulty.minimumLogicalScore) {
        return candidate;
      }
    }
    return best!;
  }

  SudokuBoardData _solutionBoard() {
    final rows = _shuffledBands();
    final cols = _shuffledBands();
    final nums = List.generate(9, (i) => i + 1)..shuffle(_random);
    return List.generate(9, (r) {
      return List.generate(9, (c) {
        final pattern = (rows[r] * 3 + rows[r] ~/ 3 + cols[c]) % 9;
        return nums[pattern];
      });
    });
  }

  List<int> _shuffledBands() {
    final bands = [0, 1, 2]..shuffle(_random);
    final result = <int>[];
    for (final band in bands) {
      final inner = [0, 1, 2]..shuffle(_random);
      result.addAll(inner.map((i) => band * 3 + i));
    }
    return result;
  }

  int _blankCount(SudokuBoardData board) =>
      board.expand((row) => row).where((value) => value == 0).length;
}
