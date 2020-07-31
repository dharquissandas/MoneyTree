class CardModel {
  String user;
  String cardNumber;
  String cardExpired;
  String cardType;
  int cardBackground;
  int cardForeground;

  CardModel(this.user, this.cardNumber, this.cardExpired, this.cardType,
      this.cardBackground, this.cardForeground);
}

List<CardModel> cards = cardData
    .map(
      (item) => CardModel(item['user'], item['cardNumber'], item['cardExpired'],
          item['cardType'], item['cardBackground'], item['cardForeground']),
    )
    .toList();

var cardData = [
  {
    "user": "Deep Harquissandas",
    "cardNumber": "**** **** **** 1015",
    "cardExpired": "03-01-2023",
    "cardType": "assets/images/Mastercard.png",
    "cardBackground": 0xFFFF80A4,
    "cardForeground": 0xFF1B239F,
  },
  {
    "user": "Deep Harquissandas",
    "cardNumber": "**** **** **** 3045",
    "cardExpired": "03-01-2021",
    "cardType": "assets/images/Mastercard.png",
    "cardBackground": 0xFF1B239F,
    "cardForeground": 0xFFFF80A4,
  }
];
