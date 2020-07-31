class TransactionModel {
  String name;
  String date;
  String amount;

  TransactionModel(this.name, this.date, this.amount);
}

List<TransactionModel> transactions = transactionData
    .map((item) => TransactionModel(item['name'], item['date'], item['amount']))
    .toList();

var transactionData = [
  {"name": "Uber Ride", "date": "1st Apr 2020", "amount": "-\$35.214"},
  {"name": "Nike Outlet", "date": "30th Mar 2020", "amount": "-\$100.00"},
  {"name": "Payment Received", "date": "15th Mar 2020", "amount": "+\$250.00"},
  {"name": "Payment Received", "date": "15th Mar 2020", "amount": "+\$250.00"},
  {"name": "Payment Received", "date": "15th Mar 2020", "amount": "+\$250.00"}
];
