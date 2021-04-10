import 'dart:convert';

Budget budgetFromJson(String str) {
  final jsonData = json.decode(str);
  return Budget.fromMap(jsonData);
}

String budgetToJson(Budget data) {
  final dyn = data.toMap();
  return json.encode(dyn);
}

class Budget {
  int id;
  int bankcard;
  String month;
  int need;
  int want;
  int save;
  double foodamount;
  double sociallifeamount;
  double selfdevamount;
  double cultureamount;
  double householdamount;
  double apperalamount;
  double beautyamount;
  double healthamount;
  double educationamount;
  double giftamount;
  double techamount;

  Budget(
      {this.id,
      this.bankcard,
      this.month,
      this.need,
      this.want,
      this.save,
      this.foodamount,
      this.sociallifeamount,
      this.selfdevamount,
      this.cultureamount,
      this.householdamount,
      this.apperalamount,
      this.beautyamount,
      this.healthamount,
      this.educationamount,
      this.giftamount,
      this.techamount});

  factory Budget.fromMap(Map<String, dynamic> json) => new Budget(
        id: json["id"],
        bankcard: json["bankcard"],
        month: json["month"],
        need: json["need"],
        want: json["want"],
        save: json["save"],
        foodamount: json["foodamount"].toDouble(),
        sociallifeamount: json["sociallifeamount"].toDouble(),
        selfdevamount: json["selfdevamount"].toDouble(),
        cultureamount: json["cultureamount"].toDouble(),
        householdamount: json["householdamount"].toDouble(),
        apperalamount: json["apperalamount"].toDouble(),
        beautyamount: json["beautyamount"].toDouble(),
        healthamount: json["healthamount"].toDouble(),
        educationamount: json["educationamount"].toDouble(),
        giftamount: json["giftamount"].toDouble(),
        techamount: json["techamount"].toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "bankcard": bankcard,
        "month": month,
        "need": need,
        "want": want,
        "save": save,
        "foodamount": foodamount,
        "sociallifeamount": sociallifeamount,
        "selfdevamount": selfdevamount,
        "cultureamount": cultureamount,
        "householdamount": householdamount,
        "apperalamount": apperalamount,
        "beautyamount": beautyamount,
        "healthamount": healthamount,
        "educationamount": educationamount,
        "giftamount": giftamount,
        "techamount": techamount,
      };
}
