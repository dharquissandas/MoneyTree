import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/organisers/CardOrganiser.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
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

  String currency = "";
  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();

  TextEditingController _date = new TextEditingController();
  TextEditingController cardnamecontroller = new TextEditingController();
  TextEditingController cardnumbercontroller = new TextEditingController();

  var selectedCard;
  List<DropdownMenuItem<String>> cardNetworks = [];

  //Card Scanning Option
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

  // Card Scanning Helper Methods
  String capitalise(String s) => s[0].toUpperCase() + s.substring(1);

  String dateStringConversion(String s) {
    return "20" + s.substring(3, 5) + "-" + s.substring(0, 2) + "-01";
  }

  //Check if Updating or Creating new BankCard
  @override
  void initState() {
    getCurrency().then((value) {
      controller = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
    }).then((value) {
      controller.text = widget.bc.amount.toString();
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

  //Build Date
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

  //Build Card Networks
  void loadCardNetworks() {
    cardNetworks = [];
    cardNetworks.add(new DropdownMenuItem(
      key: Key("Visa"),
      child: new Text('Visa'),
      value: "Visa",
    ));
    cardNetworks.add(new DropdownMenuItem(
      key: Key("Mastercard"),
      child: new Text('Mastercard'),
      value: "Mastercard",
    ));
    cardNetworks.add(new DropdownMenuItem(
      key: Key("American Express"),
      child: new Text('American Express'),
      value: "American Express",
    ));
    cardNetworks.add(new DropdownMenuItem(
      key: Key("Discover"),
      child: new Text('Discover'),
      value: "Discover",
    ));
  }

  //Build Name On Card Field
  Widget buildNameOnCard() {
    return TextFormField(
      key: Key("cardName"),
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

  //Build Card Number Field
  Widget buildCardNumber() {
    return TextFormField(
      key: Key("cardNumber"),
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
        if (value.length != 4) {
          return 'Please Enter the Last 4 Digits';
        }
      },
      onSaved: (String value) {
        cardNumber = int.parse(value);
      },
    );
  }

  //Build Expiry Date Field
  Widget buildExpiryDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          key: Key("cardDate"),
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Expiration Date',
          ),
        ),
      ),
    );
  }

  //Build CardNetwork Dropdown
  Widget buildCardNetworkCategory() {
    loadCardNetworks();
    return DropdownButton(
      key: Key("cardType"),
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

  //Build Amount field
  Widget buildAmount() {
    return TextFormField(
      key: Key("cardAmount"),
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

  // Database Connection to Add or Update Bankcard
  addorUpdateBankCard() {
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
              type: PageTransitionType.leftToRight, child: CardOrganiser()),
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
          PageTransition(type: PageTransitionType.leftToRight, child: Home()),
          (route) => false);
    }
  }

  //Paint Fields on Page
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
              addorUpdateBankCard();
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
