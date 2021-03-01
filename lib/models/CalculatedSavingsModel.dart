import 'dart:convert';

CalculatedSaving savingFromJson(String str) {
  final jsonData = json.decode(str);
  return CalculatedSaving.fromMap(jsonData);
}

String savingToJson(CalculatedSaving data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class CalculatedSaving {
  int id;
  int parentId;
  String goalDate;
  double feasiblePayment;
  int paymentFrequency;
  int savingType;

  CalculatedSaving(
      {this.id,
      this.parentId,
      this.goalDate,
      this.feasiblePayment,
      this.paymentFrequency,
      this.savingType});

  factory CalculatedSaving.fromMap(Map<String, dynamic> json) =>
      new CalculatedSaving(
          id: json["id"],
          parentId: json["parentid"],
          goalDate: json["goaldate"],
          feasiblePayment: json["feasiblepayment"].toDouble(),
          paymentFrequency: json["paymentfrequency"],
          savingType: json["savingType"]);

  Map<String, dynamic> toMap() => {
        "id": id,
        "parentid": parentId,
        "goaldate": goalDate,
        "feasiblepayment": feasiblePayment,
        "paymentfrequency": paymentFrequency,
        "savingType": savingType
      };
}
