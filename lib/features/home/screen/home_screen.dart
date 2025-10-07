// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

// // class HomeScreen extends ConsumerWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final authNotifier = ref.read(authNotifierProvider.notifier);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Home'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.logout),
// //             onPressed: () async {
// //               await authNotifier.signOut(); // Sign out Firebase & Google
// //               if (context.mounted) {
// //                 context.go('/login'); // Navigate to login page
// //               }
// //             },
// //           ),
// //         ],
// //       ),
// //       body: Center(
// //         child: Text(
// //           'Welcome!',
// //           style: Theme.of(context).textTheme.headlineMedium,
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';

// // class HomeScreen extends ConsumerWidget {
// //   const HomeScreen({super.key});

// //   @override
// //   Widget build(BuildContext context, WidgetRef ref) {
// //     final authNotifier = ref.read(authNotifierProvider.notifier);

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Home'),
// //       ),
// //       drawer: Drawer(
// //         child: ListView(
// //           padding: EdgeInsets.zero,
// //           children: [
// //             const DrawerHeader(
// //               decoration: BoxDecoration(color: Colors.blue),
// //               child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 20)),
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.person),
// //               title: const Text('Profile'),
// //               onTap: () {
// //                 context.push('/profile'); // navigate to profile screen
// //               },
// //             ),
// //             ListTile(
// //               leading: const Icon(Icons.logout),
// //               title: const Text('Sign Out'),
// //               onTap: () async {
// //                 await authNotifier.signOut();
// //                 if (context.mounted) {
// //                   context.go('/login');
// //                 }
// //               },
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: const Center(
// //         child: Text('Welcome!', style: TextStyle(fontSize: 24)),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import 'package:sync_event/features/auth/presentation/providers/auth_notifier.dart';
// import '../widgets/category_chip.dart';
// import '../widgets/event_card.dart';
// import '../widgets/invite_banner.dart';

// class HomeScreen extends ConsumerStatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   ConsumerState<HomeScreen> createState() => HomeScreenState();
// }

// class HomeScreenState extends ConsumerState<HomeScreen> {
//   final categories = [
//     {'label': 'Sports', 'color': Color(0xFFFF6B6B)},
//     {'label': 'Music', 'color': Color(0xFFFFA500)},
//     {'label': 'Food', 'color': Color(0xFF00C853)},
//     {'label': 'Art', 'color': Color(0xFF00B0FF)},
//   ];

//   final upcoming = List.generate(
//     6,
//     (i) => {
//       'date': '10\nJUN',
//       'title': i % 2 == 0 ? 'International Band Mu...' : 'Jo Malone Launch',
//       'location': i % 2 == 0 ? '36 Guild Street London, UK' : 'Radius Gallery',
//     },
//   );

//   @override
//   Widget build(BuildContext context) {
//     final authNotifier = ref.read(authNotifierProvider.notifier);

//     return Scaffold(
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             const DrawerHeader(
//               decoration: BoxDecoration(
//                 color: Color.fromARGB(255, 255, 255, 255),
//               ),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(
//                   color: Color.fromARGB(255, 0, 19, 123),
//                   fontSize: 20,
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person),
//               title: const Text('Profile'),
//               onTap: () {
//                 Navigator.pop(context); // close drawer
//                 context.push('/profile');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Sign Out'),
//               onTap: () async {
//                 await authNotifier.signOut();
//                 if (context.mounted) {
//                   context.go('/login');
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTopPurple(context),
//             SizedBox(height: 12),
//             _buildCategoryRow(),
//             SizedBox(height: 14),
//             Expanded(child: _buildScrollableContent(context)),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- TOP PURPLE HEADER -----------------
//   Widget _buildTopPurple(BuildContext context) {
//     return Container(
//       height: 170,
//       decoration: BoxDecoration(
//         color: Color(0xFF5E47FF),
//         borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
//       ),
//       padding: EdgeInsets.fromLTRB(16, 44, 16, 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top row: menu, location, bell
//           Row(
//             children: [
//               Builder(
//                 builder: (context) => IconButton(
//                   icon: Icon(Icons.menu, color: Colors.white),
//                   onPressed: () => Scaffold.of(context).openDrawer(),
//                 ),
//               ),
//               SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Current Location',
//                       style: TextStyle(color: Colors.white70, fontSize: 12),
//                     ),
//                     Text(
//                       'Bangalore, INDIA',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Icon(Icons.notifications_none, color: Colors.white),
//             ],
//           ),
//           SizedBox(height: 14),
//           // Search bar + filter
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 46,
//                   padding: EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.search, color: Colors.white70),
//                       SizedBox(width: 10),
//                       Expanded(
//                         child: TextField(
//                           style: TextStyle(color: Colors.white),
//                           decoration: InputDecoration.collapsed(
//                             hintText: 'Search...',
//                             hintStyle: TextStyle(color: Colors.white70),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               Container(
//                 height: 46,
//                 width: 46,
//                 decoration: BoxDecoration(
//                   color: Colors.white24,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: IconButton(
//                   icon: Icon(Icons.filter_list, color: Colors.white),
//                   onPressed: () => ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text('Filters tapped'))),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // ---------------- CATEGORY CHIPS -----------------
//   Widget _buildCategoryChip(
//     String label,
//     int index,
//     IconData icon,
//     Color color,
//   ) {
//     final isSelected = _selectedCategory == index;
//     return InkWell(
//       onTap: () {
//         setState(() {
//           _selectedCategory = index;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//         decoration: BoxDecoration(
//           color: isSelected ? color : color.withOpacity(0.15),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Row(
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : color, size: 18),
//             const SizedBox(width: 6),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : color,
//                 fontWeight: FontWeight.w500,
//                 fontSize: 14,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ---------------- SCROLLABLE CONTENT -----------------
//   Widget _buildScrollableContent(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Upcoming Events header
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Upcoming Events',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//               TextButton(onPressed: () {}, child: Text('See All')),
//             ],
//           ),
//           SizedBox(height: 8),
//           // carousel of event cards
//           SizedBox(
//             height: 180,
//             child: ListView.separated(
//               scrollDirection: Axis.horizontal,
//               itemCount: upcoming.length,
//               itemBuilder: (ctx, i) => EventCard(
//                 date: upcoming[i]['date']!,
//                 title: upcoming[i]['title']!,
//                 location: upcoming[i]['location']!,
//                 onTap: () => Navigator.of(context).push(
//                   MaterialPageRoute(
//                     builder: (_) => DummyEventDetails(upcoming[i]['title']!),
//                   ),
//                 ),
//               ),
//               separatorBuilder: (_, __) => SizedBox(width: 12),
//             ),
//           ),
//           SizedBox(height: 16),
//           InviteBanner(
//             onInvite: () => ScaffoldMessenger.of(
//               context,
//             ).showSnackBar(SnackBar(content: Text('Invite pressed'))),
//           ),
//           SizedBox(height: 18),
//           Text(
//             'Nearby You',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           SizedBox(height: 12),
//           // Some sample list below
//           Column(
//             children: List.generate(4, (i) {
//               return Card(
//                 margin: EdgeInsets.symmetric(vertical: 8),
//                 child: ListTile(
//                   leading: CircleAvatar(child: Icon(Icons.place)),
//                   title: Text('Place ${i + 1}'),
//                   subtitle: Text('1.2 km away'),
//                   trailing: Icon(Icons.chevron_right),
//                   onTap: () {},
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ---------------- DUMMY DETAILS SCREEN -----------------
// class DummyEventDetails extends StatelessWidget {
//   final String title;
//   const DummyEventDetails(this.title, {super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Event')),
//       body: Center(child: Text('Details for $title')),
//     );
//   }
// }
