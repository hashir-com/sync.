import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/theme/app_theme.dart';

import '../../../map/presentation/provider/map_providers.dart';

class CreateEventAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const CreateEventAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final colors = AppColors(isDark);
    return AppBar(
      title: Text(
        'CREATE NEW EVENT',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      backgroundColor: colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.more_vert, color: colors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }
}

