import 'dart:convert';

IncomeCategory incomeCategoryFromJson(String str) {
  final jsonData = json.decode(str);
  return IncomeCategory.fromMap(jsonData);
}

String incomeCategoryToJson(IncomeCategory data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class IncomeCategory {
  int id;
  String name;

  IncomeCategory({
    this.id,
    this.name,
  });

  factory IncomeCategory.fromMap(Map<String, dynamic> json) =>
      new IncomeCategory(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };
}
