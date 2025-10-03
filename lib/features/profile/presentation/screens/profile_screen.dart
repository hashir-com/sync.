import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.photoURL != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(user.photoURL!),
                      radius: 40,
                    ),
                  const SizedBox(height: 20),
                  Text("Name: ${user.displayName ?? 'N/A'}"),
                  Text("Email: ${user.email ?? 'N/A'}"),
                  Text("Phone: ${user.phoneNumber ?? 'N/A'}"),
                  Text("UID: ${user.uid}"),
                ],
              ),
            ),
    );
  }
}
