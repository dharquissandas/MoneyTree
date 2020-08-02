import 'dart:convert';

IncomeTransaction incomeTransFromJson(String str) =>
    IncomeTransaction.fromJson(json.decode(str));
String incomeTransToJson(IncomeTransaction data) => json.encode(data.toJson());

class IncomeTransaction {
  String name;
  String date;
  String category;
  String amount;
  String reoccur;

  IncomeTransaction(
      {this.name, this.date, this.category, this.amount, this.reoccur});

  factory IncomeTransaction.fromJson(Map<String, dynamic> json) =>
      IncomeTransaction(
        name: json["name"],
        date: json["date"],
        category: json["category"],
        amount: json["amount"],
        reoccur: json["reoccur"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "date": date,
        "category": category,
        "amount": amount,
        "reoccur": reoccur,
      };
}
