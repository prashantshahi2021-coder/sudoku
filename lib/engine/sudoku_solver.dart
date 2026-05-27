import 'dart:math';

import 'sudoku_types.dart';

export 'sudoku_types.dart';

class SudokuSolver {
  SudokuBoardData? solve(SudokuBoardData puzzle) {
    final board = cloneBoard(puzzle);
    return _search(board, 1).isEmpty ? null : board;
  }

  int countSolutions(SudokuBoardData puzzle, {int limit = 2}) {
    final board = cloneBoard(puzzle);
    return _search(board, limit).length;
  }

  bool isMoveCorrect(SudokuBoardData solution, int row, int col, int value) =>
      solution[row][col] == value;

  Set<int> candidatesFor(SudokuBoardData board, int row, int col) {
    if (board[row][col] != 0) return {};
    final used = <int>{};
    for (var i = 0; i < 9; i++) {
      used.add(board[row][i]);
      used.add(board[i][col]);
    }
    final boxRow = row ~/ 3 * 3;
    final boxCol = col ~/ 3 * 3;
    for (var r = boxRow; r < boxRow + 3; r++) {
      for (var c = boxCol; c < boxCol + 3; c++) {
        used.add(board[r][c]);
      }
    }
    return {
      for (var n = 1; n <= 9; n++)
        if (!used.contains(n)) n,
    };
  }

  SudokuHint hintFor(
    SudokuBoardData board,
    SudokuBoardData solution,
    int preferredRow,
    int preferredCol, {
    HintRequest request = HintRequest.smart,
  }) {
    if (request == HintRequest.reveal &&
        board[preferredRow][preferredCol] == 0) {
      return SudokuHint(
        kind: HintKind.reveal,
        row: preferredRow,
        col: preferredCol,
        value: solution[preferredRow][preferredCol],
        message: 'Gridy can reveal this cell when you want a direct answer.',
        relatedRows: {preferredRow},
        relatedCols: {preferredCol},
        relatedBoxes: {_boxIndex(preferredRow, preferredCol)},
        revealsAnswer: true,
      );
    }

    if (board[preferredRow][preferredCol] == 0) {
      final candidates = candidatesFor(board, preferredRow, preferredCol);
      if (candidates.length == 1) {
        return SudokuHint(
          kind: HintKind.nakedSingle,
          row: preferredRow,
          col: preferredCol,
          value: solution[preferredRow][preferredCol],
          message:
              'Nice catch: this selected cell has only one legal candidate.',
          relatedRows: {preferredRow},
          relatedCols: {preferredCol},
          relatedBoxes: {_boxIndex(preferredRow, preferredCol)},
        );
      }
      if (request == HintRequest.beginner) {
        return SudokuHint(
          kind: HintKind.beginner,
          row: preferredRow,
          col: preferredCol,
          value: solution[preferredRow][preferredCol],
          message:
              'Try checking this cell against its row, column, and 3x3 box.',
          relatedRows: {preferredRow},
          relatedCols: {preferredCol},
          relatedBoxes: {_boxIndex(preferredRow, preferredCol)},
        );
      }
      return _focusHintFor(board, solution, preferredRow, preferredCol);
    }

    final logical = _findLogicalHint(board, solution);
    if (logical != null && request == HintRequest.smart) return logical;

    final target = board[preferredRow][preferredCol] == 0
        ? (preferredRow, preferredCol)
        : _firstEmpty(board);
    return _focusHintFor(board, solution, target.$1, target.$2);
  }

  SudokuHint _focusHintFor(
    SudokuBoardData board,
    SudokuBoardData solution,
    int row,
    int col,
  ) {
    final rowBlanks = board[row].where((value) => value == 0).length;
    final colBlanks = List.generate(
      9,
      (r) => board[r][col],
    ).where((value) => value == 0).length;
    final boxBlanks = _boxCells(
      board,
      row,
      col,
    ).where((value) => value == 0).length;
    if (boxBlanks <= rowBlanks && boxBlanks <= colBlanks) {
      return SudokuHint(
        kind: HintKind.boxFocus,
        row: row,
        col: col,
        value: solution[row][col],
        message:
            'This 3x3 box is getting tight. Check which numbers are missing here.',
        relatedBoxes: {_boxIndex(row, col)},
      );
    }
    if (rowBlanks <= colBlanks) {
      return SudokuHint(
        kind: HintKind.rowFocus,
        row: row,
        col: col,
        value: solution[row][col],
        message:
            'This row is almost complete. Scan it for the missing number pattern.',
        relatedRows: {row},
      );
    }
    return SudokuHint(
      kind: HintKind.columnFocus,
      row: row,
      col: col,
      value: solution[row][col],
      message: 'Try this column. The existing numbers narrow the options.',
      relatedCols: {col},
    );
  }

  SudokuRating rate(SudokuBoardData puzzle, SudokuBoardData solution) {
    final board = cloneBoard(puzzle);
    var score = 0;
    var maxDepth = 0;
    var requiresNotes = false;
    var guard = 0;
    while (!_isComplete(board) && guard++ < 100) {
      final move = _findLogicalMove(board, solution);
      if (move == null) {
        final target = _bestCell(board);
        if (target == null) break;
        board[target.$1][target.$2] = solution[target.$1][target.$2];
        score += 4 + min(4, candidatesFor(board, target.$1, target.$2).length);
        maxDepth = max(maxDepth, 4);
        requiresNotes = true;
      } else {
        board[move.$1][move.$2] = move.$3;
        score += move.$4;
        maxDepth = max(maxDepth, move.$4);
        requiresNotes = requiresNotes || move.$4 > 1;
      }
    }
    final blanks = puzzle
        .expand((row) => row)
        .where((value) => value == 0)
        .length;
    return SudokuRating(
      logicalScore: max(maxDepth, score ~/ max(1, blanks ~/ 8)),
      maxDepth: maxDepth,
      requiresNotes: requiresNotes,
      solvedLogically: _isComplete(board),
    );
  }

  List<SudokuBoardData> _search(SudokuBoardData board, int limit) {
    final result = <SudokuBoardData>[];
    void dfs() {
      if (result.length >= limit) return;
      final cell = _bestCell(board);
      if (cell == null) {
        result.add(cloneBoard(board));
        return;
      }
      final values = candidatesFor(board, cell.$1, cell.$2).toList();
      if (values.isEmpty) return;
      for (final value in values) {
        board[cell.$1][cell.$2] = value;
        dfs();
        board[cell.$1][cell.$2] = 0;
        if (result.length >= limit) return;
      }
    }

    dfs();
    if (result.isNotEmpty) {
      for (var r = 0; r < 9; r++) {
        for (var c = 0; c < 9; c++) {
          board[r][c] = result.first[r][c];
        }
      }
    }
    return result;
  }

  (int, int)? _bestCell(SudokuBoardData board) {
    (int, int)? best;
    var bestCount = 10;
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] != 0) continue;
        final count = candidatesFor(board, r, c).length;
        if (count < bestCount) {
          best = (r, c);
          bestCount = count;
          if (count == 1) return best;
        }
      }
    }
    return best;
  }

  (int, int, int, int)? _findLogicalMove(
    SudokuBoardData board,
    SudokuBoardData solution,
  ) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] == 0) {
          final candidates = candidatesFor(board, r, c);
          if (candidates.length == 1) return (r, c, candidates.first, 1);
        }
      }
    }
    for (var unit = 0; unit < 27; unit++) {
      final cells = _unitCells(unit);
      for (var value = 1; value <= 9; value++) {
        final places = cells
            .where(
              (cell) =>
                  board[cell.$1][cell.$2] == 0 &&
                  candidatesFor(board, cell.$1, cell.$2).contains(value),
            )
            .toList();
        if (places.length == 1) {
          return (places.first.$1, places.first.$2, value, unit < 9 ? 2 : 3);
        }
      }
    }
    return null;
  }

  SudokuHint? _findLogicalHint(
    SudokuBoardData board,
    SudokuBoardData solution,
  ) {
    final move = _findLogicalMove(board, solution);
    if (move == null) return null;
    final kind = move.$4 == 1 ? HintKind.nakedSingle : HintKind.hiddenSingle;
    return SudokuHint(
      kind: kind,
      row: move.$1,
      col: move.$2,
      value: solution[move.$1][move.$2],
      message: kind == HintKind.nakedSingle
          ? 'Nice spot: this cell has only one legal candidate.'
          : 'There is a hidden single nearby. One number has only one possible place.',
      relatedRows: {move.$1},
      relatedCols: {move.$2},
      relatedBoxes: {_boxIndex(move.$1, move.$2)},
    );
  }

  bool _isComplete(SudokuBoardData board) =>
      board.every((row) => row.every((value) => value != 0));

  (int, int) _firstEmpty(SudokuBoardData board) {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] == 0) return (r, c);
      }
    }
    return (0, 0);
  }

  Iterable<int> _boxCells(SudokuBoardData board, int row, int col) sync* {
    final br = row ~/ 3 * 3;
    final bc = col ~/ 3 * 3;
    for (var r = br; r < br + 3; r++) {
      for (var c = bc; c < bc + 3; c++) {
        yield board[r][c];
      }
    }
  }

  int _boxIndex(int row, int col) => row ~/ 3 * 3 + col ~/ 3;

  List<(int, int)> _unitCells(int unit) {
    if (unit < 9) return [for (var c = 0; c < 9; c++) (unit, c)];
    if (unit < 18) return [for (var r = 0; r < 9; r++) (r, unit - 9)];
    final box = unit - 18;
    final br = box ~/ 3 * 3;
    final bc = box % 3 * 3;
    return [
      for (var r = br; r < br + 3; r++)
        for (var c = bc; c < bc + 3; c++) (r, c),
    ];
  }
}
