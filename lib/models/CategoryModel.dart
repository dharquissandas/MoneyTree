import 'dart:convert';

Category incomeCategoryFromJson(String str) {
  final jsonData = json.decode(str);
  return Category.fromMap(jsonData);
}

String incomeCategoryToJson(Category data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Category {
  int id;
  String name;

  Category({
    this.id,
    this.name,
  });

  factory Category.fromMap(Map<String, dynamic> json) => new Category(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}
