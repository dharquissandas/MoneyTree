import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/CategoryModel.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';

int incomeid = -1;
String incomename;
String incomedate = DateTime.now().toIso8601String().substring(0, 10);
int incomebankcard;
int incomecategory;
double incomeamount;
bool incomereoccur = false;

final GlobalKey<FormState> incomeformkey = GlobalKey<FormState>();

class AddIncome extends StatefulWidget {
  final IncomeTransaction transaction;
  AddIncome({Key key, @required this.transaction}) : super(key: key);

  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  TextEditingController _date = new TextEditingController();
  TextEditingController namecontroller = new TextEditingController();
  var currencycontroller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  //Check Whether Updating/Adding New Income
  @override
  void initState() {
    super.initState();
    getCurrency().then((value) {
      currencycontroller = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      setState(() {});
    }).then((value) {
      try {
        currencycontroller.text =
            FlutterMoneyFormatter(amount: widget.transaction.amount)
                .output
                .nonSymbol;
      } catch (e) {}
    });
    if (widget.transaction != null) {
      incomeid = widget.transaction.id;
      incomename = widget.transaction.name;
      namecontroller.text = widget.transaction.name;

      incomedate = widget.transaction.date;
      _date.text = widget.transaction.date;

      incomebankcard = widget.transaction.bankCard;
      incomecategory = widget.transaction.category;

      incomeamount = widget.transaction.amount;
      currencycontroller.text =
          FlutterMoneyFormatter(amount: widget.transaction.amount)
              .output
              .nonSymbol;

      incomereoccur = widget.transaction.reoccur == 0 ? false : true;
    } else {
      setState(() {
        incomebankcard = null;
        incomecategory = null;
        incomeid = -1;
        _date.value =
            TextEditingValue(text: DateTime.now().toString().substring(0, 10));
      });
    }
  }

  //Convert Bool to Value for Database Storage
  int boolcheck(bool reoccur) {
    if (reoccur) {
      return 1;
    }
    return 0;
  }

  //Build Date Data
  Future<Null> _buildDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime.now());

    if (picked != null) {
      setState(() {
        incomedate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  //Build Income Source
  Widget buildName() {
    return TextFormField(
      key: Key("incomeName"),
      autocorrect: true,
      controller: namecontroller,
      decoration: InputDecoration(labelText: "Income Source"),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value.isEmpty) {
          return 'Source is Required';
        }
      },
      onSaved: (String value) {
        incomename = value;
      },
    );
  }

  //Build Date Field
  Widget buildDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          key: Key("incomeDate"),
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Date of Income',
          ),
        ),
      ),
    );
  }

  //Build Income Categories
  Widget buildCategory() {
    return FutureBuilder<List<Category>>(
        future: DBProvider.db.getIncomeCategories(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              key: Key("incomeType"),
              hint: new Text("Select Category"),
              value: incomecategory,
              items: snapshot.data
                  .map((cat) => DropdownMenuItem<int>(
                      key: Key(cat.id.toString()),
                      child: Text(cat.name),
                      value: cat.id))
                  .toList(),
              onChanged: (int value) {
                setState(() {
                  incomecategory = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (incomecategory == null) {
                  return 'Please Select Income Category';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  //Build Bankcard Selector
  Widget buildCardCategory() {
    return FutureBuilder<List<BankCard>>(
        future: DBProvider.db.getBankCards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<BankCard>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              key: Key("incomeCard"),
              hint: new Text("Select Bank Card"),
              value: incomebankcard,
              items: snapshot.data.map((cat) {
                return DropdownMenuItem<int>(
                    key: Key(cat.id.toString()),
                    child: Text(cat.cardType +
                        ": **** **** **** " +
                        cat.cardNumber.toString()),
                    value: cat.id);
              }).toList(),
              onChanged: (int value) {
                setState(() {
                  incomebankcard = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (incomebankcard == null) {
                  return 'Please Select Bank Card';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  //Build Income Amount
  Widget buildAmount() {
    return TextFormField(
      key: Key("incomeAmount"),
      controller: currencycontroller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Income Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        incomeamount = currencycontroller.doubleValue;
      },
    );
  }

  //Build Reoccur Checkbox (Deprecated)
  Widget buildReoccur() {
    return CheckboxListTile(
      value: incomereoccur,
      onChanged: (value) {
        setState(() {
          incomereoccur = value;
        });
      },
      title: new Text("Recurring Income"),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  //Paint Fields on Screen
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
          "Add Income",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: incomeformkey,
          child: Column(
            children: <Widget>[
              buildName(),
              buildCardCategory(),
              buildCategory(),
              buildDate(),
              buildAmount(),
            ],
          ),
        ),
      ),
    );
  }
}
