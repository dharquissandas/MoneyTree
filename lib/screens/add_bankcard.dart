import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/CardOrganiser.dart';
import 'package:money_tree/screens/HomeLayout.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter/services.dart';
import 'package:card_scanner/card_scanner.dart';
import 'package:money_tree/utils/Preferences.dart';

class AddBankCard extends StatefulWidget {
  final BankCard bc;
  AddBankCard({Key key, @required this.bc}) : super(key: key);
  @override
  _AddBankCardState createState() => _AddBankCardState();
}

class _AddBankCardState extends State<AddBankCard> {
  int id;
  int cardNumber;
  int cardOrder = 0;
  String cardName;
  String expiryDate;
  double amount;
  String cardType;

  CardDetails card;

  String currency = "\$";

  String capitalise(String s) => s[0].toUpperCase() + s.substring(1);

  String dateStringConversion(String s) {
    return "20" + s.substring(3, 5) + "-" + s.substring(0, 2) + "-01";
  }

  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController _date = new TextEditingController();
  TextEditingController cardnamecontroller = new TextEditingController();
  TextEditingController cardnumbercontroller = new TextEditingController();

  Future<void> scanCard() async {
    var cd = await CardScanner.scanCard(
      scanOptions: CardScanOptions(
        scanCardHolderName: true,
        scanCardIssuer: true,
      ),
    );

    if (!mounted) {
      return;
    } else {
      setState(() {
        card = cd;
        cardNumber = int.parse(card.cardNumber.toString().substring(12, 16));
        cardnumbercontroller.text =
            card.cardNumber.toString().substring(12, 16);

        cardName = card.cardHolderName;
        cardnamecontroller.text = card.cardHolderName;

        expiryDate = dateStringConversion(card.expiryDate);
        _date.text = dateStringConversion(card.expiryDate);

        if (card.cardIssuer.substring(11) != "unknown") {
          cardType = capitalise(card.cardIssuer.substring(11));
          selectedCard = capitalise(card.cardIssuer.substring(11));
        }
      });
    }
  }

  @override
  void initState() {
    getCurrency().then((value) {
      controller = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
    });

    if (widget.bc != null) {
      id = widget.bc.id;

      cardNumber = widget.bc.cardNumber;
      cardnumbercontroller.text = widget.bc.cardNumber.toString();

      cardOrder = widget.bc.cardOrder;

      cardName = widget.bc.cardName;
      cardnamecontroller.text = widget.bc.cardName;

      expiryDate = widget.bc.expiryDate;
      _date.text = widget.bc.expiryDate;

      amount = widget.bc.amount;
      controller.text = widget.bc.amount.toString();

      cardType = widget.bc.cardType;
      selectedCard = widget.bc.cardType;
    } else {
      DBProvider.db.getBankCards().then((value) {
        if (value.length > 1) {
          setState(() {
            cardOrder = value.last.cardOrder + 1;
          });
        }
      });
    }
    super.initState();
  }

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

  var selectedCard;
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
      controller: cardnamecontroller,
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
      controller: cardnumbercontroller,
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
      //enabled: widget.bc == null ? true : false,
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
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.camera_alt,
              color: Colors.black,
            ),
            onPressed: () async {
              scanCard();
            },
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
            icon: Icon(Icons.check),
            backgroundColor: Colors.teal[300],
            elevation: 20,
            label: Text("Confirm"),
            onPressed: () {
              if (!formkey.currentState.validate()) {
                return;
              }
              formkey.currentState.save();

              if (widget.bc != null) {
                BankCard bankcard = BankCard(
                    id: id,
                    cardNumber: cardNumber,
                    cardOrder: cardOrder,
                    cardName: cardName,
                    expiryDate: expiryDate,
                    amount: amount,
                    cardType: cardType);

                DBProvider.db.updateBankCard(id, bankcard);
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: CardOrganiser()),
                    (route) => false);
              } else {
                BankCard bankcard = BankCard(
                    cardNumber: cardNumber,
                    cardOrder: cardOrder,
                    cardName: cardName,
                    expiryDate: expiryDate,
                    amount: amount,
                    cardType: cardType);

                DBProvider.db.newCard(bankcard);
                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight, child: Home()),
                    (route) => false);
              }
            }),
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
