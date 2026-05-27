import '../data/models.dart';

typedef SudokuBoardData = List<List<int>>;

class SudokuRating {
  const SudokuRating({
    required this.logicalScore,
    required this.maxDepth,
    required this.requiresNotes,
    required this.solvedLogically,
  });

  final int logicalScore;
  final int maxDepth;
  final bool requiresNotes;
  final bool solvedLogically;
}

class SudokuPuzzle {
  const SudokuPuzzle({
    required this.difficulty,
    required this.puzzle,
    required this.solution,
    required this.rating,
    required this.seed,
    this.dailyId,
  });

  final Difficulty difficulty;
  final SudokuBoardData puzzle;
  final SudokuBoardData solution;
  final SudokuRating rating;
  final int seed;
  final String? dailyId;
}

enum HintRequest { beginner, smart, reveal }

enum HintKind {
  beginner,
  nakedSingle,
  hiddenSingle,
  rowFocus,
  columnFocus,
  boxFocus,
  reveal,
}

class SudokuHint {
  const SudokuHint({
    required this.kind,
    required this.row,
    required this.col,
    required this.value,
    required this.message,
    this.relatedRows = const {},
    this.relatedCols = const {},
    this.relatedBoxes = const {},
    this.revealsAnswer = false,
  });

  final HintKind kind;
  final int row;
  final int col;
  final int value;
  final String message;
  final Set<int> relatedRows;
  final Set<int> relatedCols;
  final Set<int> relatedBoxes;
  final bool revealsAnswer;
}

SudokuBoardData cloneBoard(SudokuBoardData board) =>
    board.map((row) => List<int>.from(row)).toList();

String encodeBoardCompact(SudokuBoardData board) =>
    board.expand((row) => row).join();
