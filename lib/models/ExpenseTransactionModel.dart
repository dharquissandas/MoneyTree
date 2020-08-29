import 'dart:convert';

ExpenseTransaction expenseTransactionFromJson(String str) {
  final jsonData = json.decode(str);
  return ExpenseTransaction.fromMap(jsonData);
}

String expenseTransactionToJson(ExpenseTransaction data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class ExpenseTransaction {
  int id;
  String name;
  String date;
  int category;
  double amount;
  int bankCard;
  int reoccur;

  ExpenseTransaction({
    this.id,
    this.name,
    this.date,
    this.category,
    this.amount,
    this.bankCard,
    this.reoccur,
  });

  factory ExpenseTransaction.fromMap(Map<String, dynamic> json) =>
      new ExpenseTransaction(
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
