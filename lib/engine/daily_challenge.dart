import '../data/models.dart';
import 'sudoku_generator.dart';

class DailyChallengeService {
  SudokuPuzzle generateFor(DateTime date, Difficulty difficulty) {
    final normalized = DateTime(date.year, date.month, date.day);
    final seed =
        normalized.year * 10000 +
        normalized.month * 100 +
        normalized.day +
        difficulty.index * 997;
    final puzzle = SudokuGenerator(seed: seed).generate(difficulty);
    return SudokuPuzzle(
      difficulty: puzzle.difficulty,
      puzzle: puzzle.puzzle,
      solution: puzzle.solution,
      rating: puzzle.rating,
      seed: seed,
      dailyId:
          '${normalized.year}-${normalized.month.toString().padLeft(2, '0')}-${normalized.day.toString().padLeft(2, '0')}-${difficulty.name}',
    );
  }
}
