import 'app_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithGoogle({
    required String displayName,
    required String username,
  });

  Future<AppUser> updateProfile(AppUser user);
}

class LocalFirebaseReadyAuthRepository implements AuthRepository {
  @override
  Future<AppUser> signInWithGoogle({
    required String displayName,
    required String username,
  }) async {
    final normalizedUsername = username.trim().toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9_]+'),
      '_',
    );
    final uid =
        'local_google_${normalizedUsername}_${DateTime.now().millisecondsSinceEpoch}';
    return AppUser(
      uid: uid,
      displayName: displayName.trim().isEmpty
          ? 'Sudoku Player'
          : displayName.trim(),
      username: normalizedUsername.isEmpty
          ? 'sudoku_player'
          : normalizedUsername,
      email:
          '${normalizedUsername.isEmpty ? 'player' : normalizedUsername}@mock.google.local',
      photoUrl: '',
      level: 1,
      xp: 0,
      coins: 120,
      premiumStatus: false,
      createdAt: DateTime.now(),
      friendsList: const [],
    );
  }

  @override
  Future<AppUser> updateProfile(AppUser user) async => user;
}
