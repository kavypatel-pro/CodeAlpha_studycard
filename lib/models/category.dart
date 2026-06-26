class Category {
  final String id;
  final String name;
  final int iconCode; // Store IconData.codePoint
  final int colorValue; // Store Color.value

  Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
      'colorValue': colorValue,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
      colorValue: json['colorValue'] as int,
    );
  }

  Category copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
