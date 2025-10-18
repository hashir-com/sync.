import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/onboarding/controller/onboarding_controler.dart';
import 'package:sync_event/features/onboarding/data/onboarding_items.dart';
import 'package:sync_event/features/onboarding/presentation/widgets/onboarding_card.dart';
import 'package:sync_event/features/onboarding/presentation/widgets/onboarding_bottom_nav.dart';

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
    final size = MediaQuery.of(context).size;
    final currentPage = ref.watch(onboardingProvider);
    final currentItem = onboardingItems[currentPage];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dynamic height for bottom nav
            final bottomNavHeight = constraints.maxHeight < 800
                ? size.height * 0.4
                : constraints.maxWidth > 1200
                ? size.height * 0.3
                : size.height * 0.35;
            return Stack(
              children: [
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SizedBox(
                    height: bottomNavHeight,
                    child: OnboardingBottomNav(
                      controller: _pageController,
                      currentPage: currentPage,
                      totalPages: onboardingItems.length,
                      title: currentItem['title']!,
                      subtitle: currentItem['subtitle']!,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

