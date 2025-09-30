import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/constants/app_colors.dart';
import 'package:sync_event/features/onboarding/controller/onboarding_controler.dart';
import 'package:sync_event/features/onboarding/data/onboarding_items.dart';
import '../widgets/onboarding_card.dart';
import '../widgets/onboarding_bottom_nav.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPage = ref.watch(onboardingProvider);
    final currentItem = onboardingItems[currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Onboarding Images
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingItems.length,
            onPageChanged: (index) =>
                ref.read(onboardingProvider.notifier).setPage(index),
            itemBuilder: (_, index) {
              final item = onboardingItems[index];
              return OnboardingCard(image: item['image']!);
            },
          ),

          // Bottom Navigation with text & controls
          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardingBottomNav(
              controller: _pageController,
              currentPage: currentPage,
              totalPages: onboardingItems.length,
              title: currentItem['title']!,
              subtitle: currentItem['subtitle']!,
            ),
          ),
        ],
      ),
    );
  }
}
