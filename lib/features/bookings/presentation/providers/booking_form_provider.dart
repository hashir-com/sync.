import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingFormProvider =
    StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
      (ref) => BookingFormNotifier(),
    );

class BookingFormState {
  final String selectedCategory;
  final int quantity;
  final bool useWallet;

  BookingFormState({
    required this.selectedCategory,
    this.quantity = 1,
    this.useWallet = false,
  });

  BookingFormState copyWith({
    String? selectedCategory,
    int? quantity,
    bool? useWallet,
  }) {
    return BookingFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      quantity: quantity ?? this.quantity,
      useWallet: useWallet ?? this.useWallet,
    );
  }
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(BookingFormState(selectedCategory: ''));

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category, quantity: 1);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void toggleUseWallet(bool value) {
    state = state.copyWith(useWallet: value);
  }
}