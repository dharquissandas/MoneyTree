import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/CategoryModel.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:money_tree/utils/Preferences.dart';

GlobalKey<FormState> expenseformkey = GlobalKey<FormState>();

int expenseid = -1;
String expensename;
String expensedate = DateTime.now().toIso8601String().substring(0, 10);
int expensecategory;
int expensebankcard;
double expenseamount;
bool expensereoccur = false;
BankCard selectedExpenseCard;
bool need = true;
bool want = false;

class AddExpense extends StatefulWidget {
  final ExpenseTransaction transaction;
  AddExpense({Key key, @required this.transaction}) : super(key: key);
  @override
  _AddExpenseState createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpense> {
  TextEditingController _date = new TextEditingController();
  TextEditingController namecontroller = new TextEditingController();
  var currencycontroller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  @override
  void initState() {
    getCurrency().then((value) {
      currencycontroller = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      setState(() {});
    });

    super.initState();
    if (widget.transaction != null) {
      expenseid = widget.transaction.id;
      expensename = widget.transaction.name;
      namecontroller.text = widget.transaction.name;

      expensedate = widget.transaction.date;
      _date.text = widget.transaction.date;

      DBProvider.db
          .getBankCardById(widget.transaction.bankCard)
          .then((value) => selectedExpenseCard = value);

      expensebankcard = widget.transaction.bankCard;
      expensecategory = widget.transaction.category;

      expenseamount = widget.transaction.amount;
      currencycontroller.text =
          FlutterMoneyFormatter(amount: widget.transaction.amount)
              .output
              .nonSymbol;

      need = widget.transaction.need == 1 ? true : false;
      want = widget.transaction.need == 0 ? true : false;
      expensereoccur = widget.transaction.reoccur == 0 ? false : true;
    } else {
      setState(() {
        expensebankcard = null;
        expensecategory = null;
        need = true;
        want = false;
        expenseid = -1;
        _date.value =
            TextEditingValue(text: DateTime.now().toString().substring(0, 10));
      });
    }
  }

  Future<Null> _buildDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime.now());

    if (picked != null) {
      setState(() {
        expensedate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  Widget buildName() {
    return TextFormField(
      autocorrect: true,
      controller: namecontroller,
      decoration: InputDecoration(labelText: "Expense Source"),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value.isEmpty) {
          return 'Source is Required';
        }
      },
      onSaved: (String value) {
        expensename = value;
      },
    );
  }

  Widget buildDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Date of Expense',
          ),
        ),
      ),
    );
  }

  Widget buildCategory() {
    return FutureBuilder<List<Category>>(
        future: DBProvider.db.getExpenseCategories(),
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              hint: new Text("Select Category"),
              value: expensecategory,
              items: snapshot.data
                  .map((cat) => DropdownMenuItem<int>(
                      child: Text(cat.name), value: cat.id))
                  .toList(),
              onChanged: (int value) {
                setState(() {
                  expensecategory = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (expensecategory == null) {
                  return 'Please Select Expense Category';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildCardCategory() {
    return FutureBuilder<List<BankCard>>(
        future: DBProvider.db.getBankCards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<BankCard>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              hint: new Text("Select Bank Card"),
              value: expensebankcard,
              items: snapshot.data.map((cat) {
                return DropdownMenuItem<int>(
                    child: Text(cat.cardType +
                        ": **** **** **** " +
                        cat.cardNumber.toString()),
                    value: cat.id);
              }).toList(),
              onChanged: (int value) {
                DBProvider.db.getBankCardById(value).then((bc) {
                  setState(() {
                    selectedExpenseCard = bc;
                  });
                });
                setState(() {
                  expensebankcard = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (expensebankcard == null) {
                  return 'Please Select Bank Card';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildAmount() {
    return TextFormField(
      controller: currencycontroller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Expense Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
        if (currencycontroller.doubleValue > selectedExpenseCard.amount) {
          return 'Insufficiant Funds to Add Transaction';
        }
      },
      onSaved: (value) {
        expenseamount = currencycontroller.doubleValue;
      },
    );
  }

  Widget buildReoccur() {
    return CheckboxListTile(
      value: expensereoccur,
      onChanged: (value) {
        setState(() {
          expensereoccur = value;
        });
      },
      title: new Text("Recurring Expense"),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget buildNeedChoice() {
    return Column(
      children: [
        CheckboxListTile(
          value: need,
          onChanged: (value) {
            setState(() {
              if (value) {
                need = true;
                want = false;
              }
            });
          },
          title: new Text("Need"),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: want,
          onChanged: (value) {
            setState(() {
              if (value) {
                want = true;
                need = false;
              }
            });
          },
          title: new Text("Want"),
          controlAffinity: ListTileControlAffinity.leading,
        )
      ],
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
          "Add Expense",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: expenseformkey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              buildName(),
              buildCardCategory(),
              buildCategory(),
              buildDate(),
              buildAmount(),
              buildNeedChoice(),
            ],
          ),
        ),
      ),
    );
  }
}
