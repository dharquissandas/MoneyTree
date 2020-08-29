import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/HomeLayout.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';

class AddBankCard extends StatefulWidget {
  @override
  _AddBankCardState createState() => _AddBankCardState();
}

class _AddBankCardState extends State<AddBankCard> {
  int id;
  int cardNumber;
  String cardName;
  String expiryDate;
  double amount;
  String cardType;

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _date = new TextEditingController();
  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  Future<Null> _buildDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(DateTime.now().year + 10, DateTime.now().month,
            DateTime.now().day));

    if (picked != null) {
      setState(() {
        expiryDate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  String selectedCard = "Visa";
  List<DropdownMenuItem<String>> cardNetworks = [];

  void loadCardNetworks() {
    cardNetworks = [];
    cardNetworks.add(new DropdownMenuItem(
      child: new Text('Visa'),
      value: "Visa",
    ));
    cardNetworks.add(new DropdownMenuItem(
      child: new Text('Mastercard'),
      value: "Mastercard",
    ));
    cardNetworks.add(new DropdownMenuItem(
      child: new Text('American Express'),
      value: "American Express",
    ));
    cardNetworks.add(new DropdownMenuItem(
      child: new Text('Discover'),
      value: "Discover",
    ));
  }

  Widget buildNameOnCard() {
    return TextFormField(
      autocorrect: true,
      decoration: InputDecoration(labelText: "Name On Card"),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value.isEmpty) {
          return 'Name on Card is Required';
        }
      },
      onSaved: (String value) {
        cardName = value;
      },
    );
  }

  Widget buildCardNumber() {
    return TextFormField(
      inputFormatters: [
        new LengthLimitingTextInputFormatter(4),
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Last 4 Digits of Card Number"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Card Number is Required';
        }
      },
      onSaved: (String value) {
        cardNumber = int.parse(value);
      },
    );
  }

  Widget buildExpiryDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Expiration Date',
          ),
        ),
      ),
    );
  }

  Widget buildCardNetworkCategory() {
    loadCardNetworks();
    return DropdownButton(
      hint: new Text('Select Card Type'),
      items: cardNetworks,
      value: selectedCard,
      onChanged: (value) {
        setState(() {
          selectedCard = value;
          cardType = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget buildAmount() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Card Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        amount = controller.doubleValue;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Add Bank Card",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 16, right: 16),
              child: Form(
                key: formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    buildNameOnCard(),
                    buildCardNumber(),
                    buildExpiryDate(),
                    buildCardNetworkCategory(),
                    buildAmount(),
                    SizedBox(
                      height: 100,
                    ),
                    RaisedButton(
                      onPressed: () {
                        if (!formkey.currentState.validate()) {
                          return;
                        }
                        formkey.currentState.save();

                        BankCard bankcard = BankCard(
                            cardNumber: cardNumber,
                            cardName: cardName,
                            expiryDate: expiryDate,
                            amount: amount,
                            cardType: cardType);

                        DBProvider.db.newCard(bankcard);

                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                duration: Duration(microseconds: 4),
                                child: Home()));
                      },
                      child: Text(
                        'Add Card',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
