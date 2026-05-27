class AppUser {
  const AppUser({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.email,
    required this.photoUrl,
    required this.level,
    required this.xp,
    required this.coins,
    required this.premiumStatus,
    required this.createdAt,
    required this.friendsList,
  });

  final String uid;
  final String displayName;
  final String username;
  final String email;
  final String photoUrl;
  final int level;
  final int xp;
  final int coins;
  final bool premiumStatus;
  final DateTime createdAt;
  final List<String> friendsList;

  AppUser copyWith({
    String? displayName,
    String? username,
    String? email,
    String? photoUrl,
    int? level,
    int? xp,
    int? coins,
    bool? premiumStatus,
    List<String>? friendsList,
  }) {
    return AppUser(
      uid: uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      createdAt: createdAt,
      friendsList: friendsList ?? this.friendsList,
    );
  }

  Map<String, Object> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'username': username,
    'email': email,
    'photoUrl': photoUrl,
    'level': level,
    'xp': xp,
    'coins': coins,
    'premiumStatus': premiumStatus,
    'createdAt': createdAt.toIso8601String(),
    'friendsList': friendsList,
  };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
    uid: json['uid'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
    username: json['username'] as String? ?? '',
    email: json['email'] as String? ?? '',
    photoUrl: json['photoUrl'] as String? ?? '',
    level: json['level'] as int? ?? 1,
    xp: json['xp'] as int? ?? 0,
    coins: json['coins'] as int? ?? 120,
    premiumStatus: json['premiumStatus'] as bool? ?? false,
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    friendsList:
        (json['friendsList'] as List<dynamic>?)?.cast<String>() ?? const [],
  );
}
