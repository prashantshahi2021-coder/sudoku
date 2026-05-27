import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../data/models.dart';
import '../../engine/retention_engine.dart';
import '../../engine/sudoku_generator.dart';
import '../../engine/sudoku_solver.dart';

class Move {
  const Move(this.row, this.col, this.previous, this.notes);
  final int row;
  final int col;
  final int previous;
  final Set<int> notes;
}

class GameState extends ChangeNotifier {
  GameState.newGame(
    this.difficulty, {
    int? seed,
    this.mode = GameMode.classic,
  }) {
    final bundle = SudokuGenerator(seed: seed).generate(difficulty);
    solution = bundle.solution;
    givens = cloneBoard(bundle.puzzle);
    board = cloneBoard(bundle.puzzle);
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    logicalScore = bundle.rating.logicalScore;
    dailyId = bundle.dailyId;
  }

  GameState.fromPuzzle(SudokuPuzzle puzzle, {this.mode = GameMode.classic})
    : difficulty = puzzle.difficulty {
    solution = puzzle.solution;
    givens = cloneBoard(puzzle.puzzle);
    board = cloneBoard(puzzle.puzzle);
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    logicalScore = puzzle.rating.logicalScore;
    dailyId = puzzle.dailyId;
  }

  GameState.fromJson(Map<String, dynamic> json)
    : difficulty = Difficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => Difficulty.easy,
      ),
      solution = _decodeBoard(json['solution'] as String),
      givens = _decodeBoard(json['givens'] as String),
      board = _decodeBoard(json['board'] as String),
      seconds = json['seconds'] as int? ?? 0,
      mistakes = json['mistakes'] as int? ?? 0,
      score = json['score'] as int? ?? 0,
      hintsUsed = json['hintsUsed'] as int? ?? 0,
      revealsUsed = json['revealsUsed'] as int? ?? 0,
      logicalScore = json['logicalScore'] as int? ?? 0,
      dailyId = json['dailyId'] as String?,
      mode = GameMode.values.firstWhere(
        (mode) => mode.name == json['mode'],
        orElse: () => GameMode.classic,
      ) {
    notes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    final decodedNotes = json['notes'] as List<dynamic>? ?? [];
    for (var r = 0; r < decodedNotes.length && r < 9; r++) {
      final row = decodedNotes[r] as List<dynamic>;
      for (var c = 0; c < row.length && c < 9; c++) {
        notes[r][c] = (row[c] as List<dynamic>).cast<int>().toSet();
      }
    }
    coachMessage =
        json['coachMessage'] as String? ??
        'Gridy is watching the grid with you.';
    secondsListenable.value = seconds;
  }

  final Difficulty difficulty;
  final GameMode mode;
  late List<List<int>> solution;
  late List<List<int>> givens;
  late List<List<int>> board;
  late List<List<Set<int>>> notes;
  int selectedRow = 0;
  int selectedCol = 0;
  int mistakes = 0;
  int seconds = 0;
  int score = 0;
  int hintsUsed = 0;
  int revealsUsed = 0;
  int logicalScore = 0;
  final ValueNotifier<int> secondsListenable = ValueNotifier<int>(0);
  String? dailyId;
  String coachMessage = 'Gridy is watching the grid with you.';
  SudokuHint? lastHint;
  bool notesMode = false;
  bool paused = false;
  final List<Move> _undo = [];

  bool get complete {
    for (var r = 0; r < 9; r++) {
      for (var c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  bool isGiven(int row, int col) => givens[row][col] != 0;

  void select(int row, int col) {
    selectedRow = row;
    selectedCol = col;
    notifyListeners();
  }

  bool input(int value, {bool autoCleanup = true}) {
    if (isGiven(selectedRow, selectedCol) || paused) return false;
    if (notesMode) {
      final cellNotes = notes[selectedRow][selectedCol];
      cellNotes.contains(value)
          ? cellNotes.remove(value)
          : cellNotes.add(value);
      notifyListeners();
      return false;
    }
    _undo.add(
      Move(
        selectedRow,
        selectedCol,
        board[selectedRow][selectedCol],
        Set.of(notes[selectedRow][selectedCol]),
      ),
    );
    if (solution[selectedRow][selectedCol] == value) {
      board[selectedRow][selectedCol] = value;
      notes[selectedRow][selectedCol].clear();
      score += max(8, 18 - mistakes * 2);
      if (autoCleanup) _cleanupNotes(value);
      coachMessage = _positiveCoach();
      notifyListeners();
      return true;
    }
    mistakes++;
    score = max(0, score - 5);
    coachMessage = _mistakeCoach();
    notifyListeners();
    return false;
  }

  void erase() {
    if (isGiven(selectedRow, selectedCol)) return;
    _undo.add(
      Move(
        selectedRow,
        selectedCol,
        board[selectedRow][selectedCol],
        Set.of(notes[selectedRow][selectedCol]),
      ),
    );
    board[selectedRow][selectedCol] = 0;
    notes[selectedRow][selectedCol].clear();
    notifyListeners();
  }

  void undo() {
    if (_undo.isEmpty) return;
    final move = _undo.removeLast();
    board[move.row][move.col] = move.previous;
    notes[move.row][move.col] = Set.of(move.notes);
    selectedRow = move.row;
    selectedCol = move.col;
    notifyListeners();
  }

  void revealCell() {
    if (isGiven(selectedRow, selectedCol)) return;
    _undo.add(
      Move(
        selectedRow,
        selectedCol,
        board[selectedRow][selectedCol],
        Set.of(notes[selectedRow][selectedCol]),
      ),
    );
    board[selectedRow][selectedCol] = solution[selectedRow][selectedCol];
    notes[selectedRow][selectedCol].clear();
    revealsUsed++;
    hintsUsed++;
    coachMessage =
        'No shame in a reveal. Now use that number to unlock the area.';
    score = max(0, score - 20);
    notifyListeners();
  }

  SudokuHint requestHint(HintRequest request) {
    final hint = SudokuSolver().hintFor(
      board,
      solution,
      selectedRow,
      selectedCol,
      request: request,
    );
    lastHint = hint;
    coachMessage = hint.message;
    if (request == HintRequest.reveal) {
      selectedRow = hint.row;
      selectedCol = hint.col;
      revealCell();
    } else {
      hintsUsed++;
      selectedRow = hint.row;
      selectedCol = hint.col;
      score = max(0, score - (request == HintRequest.beginner ? 4 : 8));
      notifyListeners();
    }
    return hint;
  }

  void toggleNotes() {
    notesMode = !notesMode;
    notifyListeners();
  }

  void togglePause() {
    paused = !paused;
    notifyListeners();
  }

  void tick() {
    if (!paused && mode != GameMode.relax) {
      seconds++;
      secondsListenable.value = seconds;
    }
  }

  String smartHint() =>
      SudokuSolver().hintFor(board, solution, selectedRow, selectedCol).message;

  void _cleanupNotes(int value) {
    for (var i = 0; i < 9; i++) {
      notes[selectedRow][i].remove(value);
      notes[i][selectedCol].remove(value);
    }
    final br = selectedRow ~/ 3 * 3;
    final bc = selectedCol ~/ 3 * 3;
    for (var r = br; r < br + 3; r++) {
      for (var c = bc; c < bc + 3; c++) {
        notes[r][c].remove(value);
      }
    }
  }

  Map<String, Object?> toJson() => {
    'difficulty': difficulty.name,
    'solution': _encodeBoard(solution),
    'givens': _encodeBoard(givens),
    'board': _encodeBoard(board),
    'seconds': seconds,
    'mistakes': mistakes,
    'score': score,
    'hintsUsed': hintsUsed,
    'revealsUsed': revealsUsed,
    'logicalScore': logicalScore,
    'dailyId': dailyId,
    'mode': mode.name,
    'coachMessage': coachMessage,
    'notes': notes
        .map((row) => row.map((cell) => cell.toList()).toList())
        .toList(),
  };

  static String _encodeBoard(List<List<int>> board) => jsonEncode(board);
  static List<List<int>> _decodeBoard(String raw) =>
      (jsonDecode(raw) as List<dynamic>)
          .map((row) => (row as List<dynamic>).cast<int>())
          .toList();

  String _positiveCoach() {
    final messages = [
      'Nice catch!',
      'Clean placement. Gridy likes that logic.',
      'That opened up the board.',
      'Great focus.',
    ];
    return messages[(score + selectedRow + selectedCol) % messages.length];
  }

  String _mistakeCoach() {
    final messages = [
      'Try checking duplicates here.',
      'Try scanning the row, column, and box.',
      'Try notes here before placing the number.',
      'Try again: this number conflicts nearby.',
    ];
    return messages[(mistakes + selectedRow + selectedCol) % messages.length];
  }

  @override
  void dispose() {
    secondsListenable.dispose();
    super.dispose();
  }
}
