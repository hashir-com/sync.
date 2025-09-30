import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String image;
  const OnboardingCard({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
