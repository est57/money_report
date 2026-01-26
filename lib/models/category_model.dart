class CategoryModel {
  final int? id;
  final String name;
  final String type; // 'Income' or 'Expense'
  final String iconKey;
  final int color; // Store color as int (ARGB)

  CategoryModel({
    this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'iconKey': iconKey,
      'color': color,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      iconKey: map['iconKey'],
      color: map['color'],
    );
  }
}
