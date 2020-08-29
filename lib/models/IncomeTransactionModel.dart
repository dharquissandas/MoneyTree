import 'dart:convert';

IncomeTransaction incomeTransactionFromJson(String str) {
  final jsonData = json.decode(str);
  return IncomeTransaction.fromMap(jsonData);
}

String incomeTransactionToJson(IncomeTransaction data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class IncomeTransaction {
  int id;
  String name;
  String date;
  int category;
  double amount;
  int bankCard;
  int reoccur;

  IncomeTransaction({
    this.id,
    this.name,
    this.date,
    this.category,
    this.amount,
    this.bankCard,
    this.reoccur,
  });

  factory IncomeTransaction.fromMap(Map<String, dynamic> json) =>
      new IncomeTransaction(
        id: json["id"],
        name: json["name"],
        date: json["date"],
        category: json["category"],
        amount: json["amount"].toDouble(),
        bankCard: json["bankcard"],
        reoccur: json["reoccur"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "date": date,
        "category": category,
        "amount": amount,
        "bankcard": bankCard,
        "reoccur": reoccur,
      };
}
