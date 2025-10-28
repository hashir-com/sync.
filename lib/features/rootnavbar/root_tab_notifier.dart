import 'package:flutter_riverpod/flutter_riverpod.dart';

class RootTabNotifier extends StateNotifier<int> {
  RootTabNotifier() : super(0); // Initial selected index is 0 (Home)

  void selectTab(int index) {
    state = index;
  }
}

final rootTabProvider = StateNotifierProvider<RootTabNotifier, int>(
  (ref) => RootTabNotifier(),
);