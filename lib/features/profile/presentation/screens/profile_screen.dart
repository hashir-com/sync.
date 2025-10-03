import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       appBar: AppBar(title: const Text("Profile")),
//       body: user == null
//           ? const Center(child: Text("No user logged in"))
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (user.photoURL != null)
//                     CircleAvatar(
//                       backgroundImage: NetworkImage(user.photoURL!),
//                       radius: 40,
//                     ),
//                   const SizedBox(height: 20),
//                   Text("Name: ${user.displayName ?? 'N/A'}"),
//                   Text("Email: ${user.email ?? 'N/A'}"),
//                   Text("Phone: ${user.phoneNumber ?? 'N/A'}"),
//                   Text("UID: ${user.uid}"),
//                 ],
//               ),
//             ),
//     );
//   }
// }

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 4,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE0F7FA)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: user == null
            ? const Center(
                child: Text(
                  "No user logged in",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: user.photoURL != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL!),
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  child: const CircleAvatar(
                                    radius: 48,
                                    backgroundColor: Colors.transparent,
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.grey,
                                  child: Icon(Icons.person, size: 40),
                                ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Name: ${user.displayName ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Email: ${user.email ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Phone: ${user.phoneNumber ?? 'N/A'}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "UID: ${user.uid}",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
