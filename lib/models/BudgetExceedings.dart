import 'dart:convert';

BudgetExeedings budgetExceedingsFromJson(String str) {
  final jsonData = json.decode(str);
  return BudgetExeedings.fromMap(jsonData);
}

String budgetExceedingsToJson(BudgetExeedings data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class BudgetExeedings {
  String category;
  double actual;
  double budgeted;

  BudgetExeedings({this.category, this.actual, this.budgeted});

  factory BudgetExeedings.fromMap(Map<String, dynamic> json) =>
      new BudgetExeedings(
          category: json["category"],
          actual: json["actual"],
          budgeted: json["budgeted"]);

  Map<String, dynamic> toMap() =>
      {"category": category, "actual": actual, "budgeted": budgeted};
}
