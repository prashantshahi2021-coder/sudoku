import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/data/models.dart';
import 'package:sudoku/engine/daily_challenge.dart';
import 'package:sudoku/engine/sudoku_generator.dart';
import 'package:sudoku/engine/sudoku_solver.dart';
import 'package:sudoku/features/game/game_state.dart';

void main() {
  group('Sudoku generator and solver', () {
    test('generates unique-solution puzzles for every difficulty', () {
      final generator = SudokuGenerator(seed: 17);
      final solver = SudokuSolver();

      for (final difficulty in Difficulty.values) {
        final puzzle = generator.generate(difficulty);
        final blanks = puzzle.puzzle
            .expand((row) => row)
            .where((value) => value == 0)
            .length;

        expect(blanks, greaterThanOrEqualTo(difficulty.emptyCells - 2));
        expect(blanks, lessThanOrEqualTo(difficulty.emptyCells + 2));
        expect(solver.countSolutions(puzzle.puzzle, limit: 2), 1);
        expect(solver.solve(puzzle.puzzle), puzzle.solution);
        expect(
          puzzle.rating.logicalScore,
          greaterThanOrEqualTo(difficulty.minimumLogicalScore),
        );
      }
    });

    test('validates moves and returns smart hint explanations', () {
      final generator = SudokuGenerator(seed: 4);
      final puzzle = generator.generate(Difficulty.easy);
      final emptyIndex = _firstEmpty(puzzle.puzzle);
      final hint = SudokuSolver().hintFor(
        puzzle.puzzle,
        puzzle.solution,
        emptyIndex.$1,
        emptyIndex.$2,
      );

      expect(hint.row, emptyIndex.$1);
      expect(hint.col, emptyIndex.$2);
      expect(hint.value, puzzle.solution[emptyIndex.$1][emptyIndex.$2]);
      expect(hint.message, isNotEmpty);
      expect(
        SudokuSolver().isMoveCorrect(
          puzzle.solution,
          emptyIndex.$1,
          emptyIndex.$2,
          hint.value,
        ),
        isTrue,
      );
    });
  });

  group('Game state', () {
    test('tracks notes, hints, mistakes, undo, and auto cleanup', () {
      final game = GameState.newGame(Difficulty.easy, seed: 9);
      final cell = _firstEmpty(game.board);
      final solution = game.solution[cell.$1][cell.$2];
      final wrong = solution == 1 ? 2 : 1;

      game.select(cell.$1, cell.$2);
      game.toggleNotes();
      game.input(solution);
      expect(game.notes[cell.$1][cell.$2], contains(solution));

      game.toggleNotes();
      expect(game.input(wrong), isFalse);
      expect(game.mistakes, 1);
      expect(game.coachMessage, contains('Try'));

      expect(game.input(solution), isTrue);
      expect(game.board[cell.$1][cell.$2], solution);
      expect(game.notes[cell.$1][cell.$2], isEmpty);

      final hint = game.requestHint(HintRequest.smart);
      expect(game.hintsUsed, 1);
      expect(hint.message, isNotEmpty);

      game.undo();
      expect(game.board[cell.$1][cell.$2], 0);
    });

    test('auto notes cleanup setting controls related note removal', () {
      final cleanupGame = GameState.newGame(Difficulty.easy, seed: 9);
      final cleanupCell = _firstEmpty(cleanupGame.board);
      final cleanupValue = cleanupGame.solution[cleanupCell.$1][cleanupCell.$2];
      final cleanupRelated = _relatedEmpty(
        cleanupGame.board,
        cleanupCell.$1,
        cleanupCell.$2,
      );
      cleanupGame.notes[cleanupRelated.$1][cleanupRelated.$2].add(cleanupValue);

      cleanupGame.select(cleanupCell.$1, cleanupCell.$2);
      expect(cleanupGame.input(cleanupValue, autoCleanup: true), isTrue);
      expect(
        cleanupGame.notes[cleanupRelated.$1][cleanupRelated.$2],
        isNot(contains(cleanupValue)),
      );

      final manualGame = GameState.newGame(Difficulty.easy, seed: 9);
      final manualCell = _firstEmpty(manualGame.board);
      final manualValue = manualGame.solution[manualCell.$1][manualCell.$2];
      final manualRelated = _relatedEmpty(
        manualGame.board,
        manualCell.$1,
        manualCell.$2,
      );
      manualGame.notes[manualRelated.$1][manualRelated.$2].add(manualValue);

      manualGame.select(manualCell.$1, manualCell.$2);
      expect(manualGame.input(manualValue, autoCleanup: false), isTrue);
      expect(
        manualGame.notes[manualRelated.$1][manualRelated.$2],
        contains(manualValue),
      );
    });
  });

  test('daily challenge is deterministic per day and difficulty', () {
    final service = DailyChallengeService();
    final day = DateTime(2026, 5, 10);

    final first = service.generateFor(day, Difficulty.medium);
    final second = service.generateFor(day, Difficulty.medium);
    final nextDay = service.generateFor(
      day.add(const Duration(days: 1)),
      Difficulty.medium,
    );

    expect(first.puzzle, second.puzzle);
    expect(first.solution, second.solution);
    expect(first.puzzle, isNot(nextDay.puzzle));
  });
}

(int, int) _relatedEmpty(List<List<int>> board, int row, int col) {
  for (var c = 0; c < 9; c++) {
    if (c != col && board[row][c] == 0) return (row, c);
  }
  for (var r = 0; r < 9; r++) {
    if (r != row && board[r][col] == 0) return (r, col);
  }
  final br = row ~/ 3 * 3;
  final bc = col ~/ 3 * 3;
  for (var r = br; r < br + 3; r++) {
    for (var c = bc; c < bc + 3; c++) {
      if ((r != row || c != col) && board[r][c] == 0) return (r, c);
    }
  }
  throw StateError('No related empty cell found');
}

(int, int) _firstEmpty(List<List<int>> board) {
  for (var row = 0; row < 9; row++) {
    for (var col = 0; col < 9; col++) {
      if (board[row][col] == 0) return (row, col);
    }
  }
  throw StateError('Board has no empty cells');
}
