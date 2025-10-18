import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
import 'package:sync_event/features/settings/domain/entity/settings_entity.dart';

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, UserSettingsEntity>((ref) {
  final userId = ref.watch(authStateProvider).value?.uid ?? '';
  return SettingsNotifier(userId);
});

class SettingsNotifier extends StateNotifier<UserSettingsEntity> {
  SettingsNotifier(String userId)
      : super(
          UserSettingsEntity(
            isDarkMode: false,
            userId: userId,
          ),
        );

  void toggleTheme(bool isDark) {
    state = state.copyWith(isDarkMode: isDark);
  }

  void updateSettings(UserSettingsEntity newSettings) {
    state = newSettings;
  }
}