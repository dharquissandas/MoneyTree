import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'dart:math';

int savingid = -1;
int paymentaccount;
double paymentamount;
int saving;
String paymentdate = DateTime.now().toIso8601String().substring(0, 10);
bool savingreoccur = false;

BankCard selectedPaymentCard;
Saving selectedSaving;

final GlobalKey<FormState> savingpaymentkey = GlobalKey<FormState>();

class AddSaving extends StatefulWidget {
  final SavingTransaction transaction;
  final Saving saving;
  AddSaving({Key key, @required this.transaction, @required this.saving})
      : super(key: key);
  @override
  _AddSavingState createState() => _AddSavingState();
}

class _AddSavingState extends State<AddSaving> {
  TextEditingController _date = new TextEditingController();
  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  //Check Whether Updating/Adding Saving Transaction
  @override
  void initState() {
    getCurrency().then((value) {
      controller = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      setState(() {});
    }).then((value) {
      controller.text =
          FlutterMoneyFormatter(amount: widget.transaction.paymentamount)
              .output
              .nonSymbol;
    });
    if (widget.transaction != null) {
      savingid = widget.transaction.id;
      paymentaccount = widget.transaction.paymentaccount;
      paymentamount = widget.transaction.paymentamount;
      controller.text =
          FlutterMoneyFormatter(amount: widget.transaction.paymentamount)
              .output
              .nonSymbol;
      saving = widget.transaction.saving;
      paymentdate = widget.transaction.paymentdate;
      _date.text = widget.transaction.paymentdate;
      savingreoccur = widget.transaction.savingreoccur == 0 ? false : true;

      DBProvider.db
          .getBankCardById(widget.transaction.paymentaccount)
          .then((bc) {
        setState(() {
          selectedPaymentCard = bc;
        });

        DBProvider.db.getSavingById(widget.transaction.saving).then((s) {
          setState(() {
            selectedSaving = s;
          });
        });
      });
    } else {
      if (widget.saving != null) {
        selectedSaving = widget.saving;
        saving = widget.saving.id;
      } else {
        saving = null;
        paymentaccount = null;
      }
      setState(() {
        _date.value =
            TextEditingValue(text: DateTime.now().toString().substring(0, 10));
      });
    }
    super.initState();
  }

  //Boolean to Int for database Storage
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
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        paymentdate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  //Build Card Selector
  Widget buildCardCategory() {
    return FutureBuilder<List<BankCard>>(
        future: DBProvider.db.getBankCards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<BankCard>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              hint: new Text("Select Bank Card"),
              value: paymentaccount,
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
                    selectedPaymentCard = bc;
                  });
                });
                setState(() {
                  paymentaccount = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (paymentaccount == null) {
                  return 'Please Select Bank Card';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  //Build Savings Choice
  Widget buildSavingCategory() {
    return FutureBuilder<List<Saving>>(
        future: widget.saving == null && widget.transaction == null
            ? DBProvider.db.getOngoingSavings()
            : DBProvider.db.getSavings(),
        builder: (BuildContext context, AsyncSnapshot<List<Saving>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
              hint: new Text("Select Saving"),
              value: saving,
              items: snapshot.data.map((s) {
                return DropdownMenuItem<int>(
                    child: Text(s.savingsItem), value: s.id);
              }).toList(),
              onChanged: (int value) {
                DBProvider.db.getSavingById(value).then((s) {
                  setState(() {
                    selectedSaving = s;
                  });
                });
                setState(() {
                  saving = value;
                });
              },
              isExpanded: true,
              validator: (value) {
                if (paymentaccount == null) {
                  return 'Please Select Saving';
                }
              },
            );
          } else {
            return Container();
          }
        });
  }

  //Build Savings Amount (With Error Checking)
  Widget buildSavingAmount() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Saving Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
        if (controller.doubleValue > selectedPaymentCard.amount) {
          return 'Insufficiant Funds on Payment Card';
        }
        if (widget.transaction == null) {
          if (controller.doubleValue >
              roundDouble(
                  selectedSaving.totalAmount - selectedSaving.amountSaved, 2)) {
            return 'Payment Surpasses Remaining Savings Amount';
          }
        } else {
          if (controller.doubleValue >
              roundDouble(
                      selectedSaving.totalAmount - selectedSaving.amountSaved,
                      2) +
                  widget.transaction.paymentamount) {
            return 'Payment Surpasses Remaining Savings Amount';
          }
        }
      },
      onSaved: (value) {
        paymentamount = roundDouble(controller.doubleValue, 2);
      },
    );
  }

  //Build Saving Date
  Widget buildDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Date of Payment',
          ),
        ),
      ),
    );
  }

  //Build Reoccur (Deprecated)
  Widget buildReoccur() {
    return CheckboxListTile(
      value: savingreoccur,
      onChanged: (value) {
        setState(() {
          savingreoccur = value;
        });
      },
      title: new Text("Recurring Payment"),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  //Rounding Method
  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  //Paint Fields On Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          "Pay Saving",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 16, right: 16),
        child: Form(
          key: savingpaymentkey,
          child: Column(
            children: <Widget>[
              buildSavingCategory(),
              buildCardCategory(),
              buildDate(),
              buildSavingAmount(),
            ],
          ),
        ),
      ),
    );
  }
}
