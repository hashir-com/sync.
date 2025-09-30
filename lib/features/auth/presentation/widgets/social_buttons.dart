import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Google Sign-In button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
            label: const Text("Continue with Google"),
            onPressed: () {
              // TODO: call Riverpod authNotifier.signInWithGoogle()
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        /// Phone Sign-In button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.phone, color: Colors.green),
            label: const Text("Continue with Phone"),
            onPressed: () {
              // TODO: navigate to phone login screen
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
