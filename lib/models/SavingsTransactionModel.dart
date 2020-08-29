import 'dart:convert';

SavingTransaction savingtransactionFromJson(String str) {
  final jsonData = json.decode(str);
  return SavingTransaction.fromMap(jsonData);
}

String savingtransactionToJson(SavingTransaction data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class SavingTransaction {
  int id;
  int paymentaccount;
  double paymentamount;
  int saving;
  String paymentdate;
  int savingreoccur;

  SavingTransaction(
      {this.id,
      this.paymentaccount,
      this.paymentamount,
      this.saving,
      this.paymentdate,
      this.savingreoccur});

  factory SavingTransaction.fromMap(Map<String, dynamic> json) =>
      new SavingTransaction(
          id: json["id"],
          paymentaccount: json["paymentaccount"],
          paymentamount: json["paymentamount"].toDouble(),
          saving: json["saving"],
          paymentdate: json["paymentdate"],
          savingreoccur: json["savingreoccur"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "paymentaccount": paymentaccount,
        "paymentamount": paymentamount,
        "saving": saving,
        "paymentdate": paymentdate,
        "savingreoccur": savingreoccur
      };
}
