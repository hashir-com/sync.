import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sync_event/features/events/data/models/category_model.dart';
import 'package:sync_event/features/events/data/repositories/category_repository.dart';

// Provider for CategoryRepository
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

// Provider for categories stream
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return repository.getActiveCategories();
});
