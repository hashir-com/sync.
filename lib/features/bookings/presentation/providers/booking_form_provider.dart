import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingFormProvider =
    StateNotifierProvider.autoDispose<BookingFormNotifier, BookingFormState>(
      (ref) => BookingFormNotifier(),
    );

class BookingFormState {
  final String selectedCategory;
  final int quantity;

  BookingFormState({
    required this.selectedCategory,
    this.quantity = 1,
  });

  BookingFormState copyWith({
    String? selectedCategory,
    int? quantity,
  }) {
    return BookingFormState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      quantity: quantity ?? this.quantity,
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
}