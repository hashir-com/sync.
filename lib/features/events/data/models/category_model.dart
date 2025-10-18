
class CategoryModel {
  final String id;
  final String name;
  final String? icon;
  final int order;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    required this.order,
    this.isActive = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: id,
      name: map['name'] ?? '',
      icon: map['icon'],
      order: map['order'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }
}