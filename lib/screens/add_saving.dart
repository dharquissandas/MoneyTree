import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/utils/Database.dart';

int paymentaccount;
double paymentamount;
int saving;
String paymentdate = DateTime.now().toIso8601String();
bool savingreoccur = false;

final GlobalKey<FormState> savingpaymentkey = GlobalKey<FormState>();

class AddSaving extends StatefulWidget {
  @override
  _AddSavingState createState() => _AddSavingState();
}

class _AddSavingState extends State<AddSaving> {
  int boolcheck(bool reoccur) {
    if (reoccur) {
      return 1;
    }
    return 0;
  }

  TextEditingController _date = new TextEditingController();
  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  Future<Null> _buildDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime.now());

    if (picked != null) {
      setState(() {
        paymentdate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  Widget buildCardCategory() {
    return FutureBuilder<List<BankCard>>(
        future: DBProvider.db.getBankCards(),
        builder:
            (BuildContext context, AsyncSnapshot<List<BankCard>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButton<int>(
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
                setState(() {
                  paymentaccount = value;
                });
              },
              isExpanded: true,
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildSavingCategory() {
    return FutureBuilder<List<Saving>>(
        future: DBProvider.db.getSavings(),
        builder: (BuildContext context, AsyncSnapshot<List<Saving>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButton<int>(
              hint: new Text("Select Saving"),
              value: saving,
              items: snapshot.data.map((s) {
                return DropdownMenuItem<int>(
                    child: Text(s.savingsItem), value: s.id);
              }).toList(),
              onChanged: (int value) {
                setState(() {
                  saving = value;
                });
              },
              isExpanded: true,
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildSavingAmount() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Saving Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        paymentamount = controller.doubleValue;
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
            labelText: 'Date of Payment',
          ),
        ),
      ),
    );
  }

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
              buildSavingAmount(),
              buildDate(),
              buildReoccur()
            ],
          ),
        ),
      ),
    );
  }
}
