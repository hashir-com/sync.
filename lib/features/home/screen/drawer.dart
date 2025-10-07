import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- User Info ---
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => context.push('/profile'),
                              child: Hero(
                                tag: "profile",
                                child: CircleAvatar(
                                  radius: 28.r,
                                  backgroundImage: user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : const AssetImage(
                                              'assets/avatar_placeholder.png',
                                            )
                                            as ImageProvider,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                user?.displayName ??
                                    user?.email?.split('@').first ??
                                    'User',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // --- Drawer Items ---
                        _buildItem(
                          context,
                          Icons.person_outline,
                          'My Profile',
                          '/profile',
                        ),
                        _buildItem(
                          context,
                          Icons.chat_bubble_outline,
                          'Message',
                          '/message',
                        ),
                        _buildItem(
                          context,
                          Icons.calendar_today_outlined,
                          'Calendar',
                          '/calendar',
                        ),
                        _buildItem(
                          context,
                          Icons.favorite_border,
                          'Favorites',
                          '/favorites',
                        ),
                        _buildItem(
                          context,
                          Icons.mail_outline,
                          'Contact Us',
                          '/contact',
                        ),
                        _buildItem(
                          context,
                          Icons.settings_outlined,
                          'Settings',
                          '/settings',
                        ),
                        _buildItem(
                          context,
                          Icons.event_note_outlined,
                          'My Events',
                          '/my-events',
                        ),

                        const Spacer(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.logout,
                            color: Colors.redAccent,
                            size: 22.sp,
                          ),
                          title: Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w500,
                              fontSize: 15.sp,
                            ),
                          ),
                          onTap: () async {
                            final shouldLogout = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                title: Text(
                                  'Confirm Logout',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to log out?',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black87,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.redAccent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      'Logout',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (shouldLogout == true) {
                              await authNotifier.signOut();
                              if (context.mounted) context.go('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Colors.black87, size: 22.sp),
        title: Text(
          label,
          style: TextStyle(color: Colors.black87, fontSize: 15.sp),
        ),
        onTap: () {
          context.push(route);
        },
      ),
    );
  }
}
