import 'dart:convert';

BankCard bankCardFromJson(String str) {
  final jsonData = json.decode(str);
  return BankCard.fromMap(jsonData);
}

String bankCardToJson(BankCard data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class BankCard {
  int id;
  int cardNumber;
  String cardName;
  String expiryDate;
  double amount;
  String cardType;

  BankCard({
    this.id,
    this.cardNumber,
    this.cardName,
    this.expiryDate,
    this.amount,
    this.cardType,
  });

  factory BankCard.fromMap(Map<String, dynamic> json) => new BankCard(
        id: json["id"],
        cardNumber: json["cardnumber"],
        cardName: json["cardname"],
        expiryDate: json["expirydate"],
        amount: json["amount"].toDouble(),
        cardType: json["cardtype"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "cardnumber": cardNumber,
        "cardname": cardName,
        "expirydate": expiryDate,
        "amount": amount,
        "cardtype": cardType,
      };
}
