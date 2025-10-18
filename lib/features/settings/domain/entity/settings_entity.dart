class UserSettingsEntity {
  final bool isDarkMode;
  final String userId;

  const UserSettingsEntity({
    required this.isDarkMode,
    required this.userId,
  });

  UserSettingsEntity copyWith({
    bool? isDarkMode,
    String? userId,
  }) {
    return UserSettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      userId: userId ?? this.userId,
    );
  }
}