import 'dart:convert';

Saving savingFromJson(String str) {
  final jsonData = json.decode(str);
  return Saving.fromMap(jsonData);
}

String savingToJson(Saving data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Saving {
  int id;
  int savingOrder;
  String savingsItem;
  double amountSaved;
  double totalAmount;
  String goalDate;

  Saving(
      {this.id,
      this.savingOrder,
      this.savingsItem,
      this.amountSaved,
      this.totalAmount,
      this.goalDate});

  factory Saving.fromMap(Map<String, dynamic> json) => new Saving(
        id: json["id"],
        savingOrder: json["savingorder"],
        savingsItem: json["savingsitem"],
        amountSaved: json["amountsaved"].toDouble(),
        totalAmount: json["totalamount"].toDouble(),
        goalDate: json["goaldate"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "savingorder": savingOrder,
        "savingsitem": savingsItem,
        "amountsaved": amountSaved,
        "totalamount": totalAmount,
        "goalDate": goalDate,
      };
}
