import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/core/util/responsive_util.dart';
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
    final currentPage = ref.watch(onboardingProvider);
    final currentItem = onboardingItems[currentPage];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive bottom nav height
            final bottomNavHeight = ResponsiveUtil.isMobile(context)
                ? constraints.maxHeight * 0.4
                : ResponsiveUtil.isTablet(context)
                    ? constraints.maxHeight * 0.35
                    : constraints.maxHeight * 0.3;

            return ResponsiveUtil.isDesktop(context)
                ? Center(  // Web: Constrain content width
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: ResponsiveUtil.getMaxContentWidth(context)),
                      child: _buildStack(bottomNavHeight, currentPage, currentItem),
                    ),
                  )
                : _buildStack(bottomNavHeight, currentPage, currentItem);
          },
        ),
      ),
    );
  }

  Widget _buildStack(double bottomNavHeight, int currentPage, Map<String, dynamic> currentItem) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: onboardingItems.length,
          onPageChanged: (index) => ref.read(onboardingProvider.notifier).setPage(index),
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
  }
}