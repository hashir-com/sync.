
import 'package:flutter_riverpod/flutter_riverpod.dart';


final onboardingProvider = StateNotifierProvider<OnboardingController, int>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<int> {
  OnboardingController() : super(0);

  void setPage(int index) => state = index;

  void nextPage(int totalPages) {
    if (state < totalPages - 1) {
      state++;
    }
  }
}
