import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/SavingsOrganiser.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';

import 'HomeLayout.dart';

class AddSavingGoal extends StatefulWidget {
  final Saving s;
  AddSavingGoal({Key key, @required this.s}) : super(key: key);
  @override
  _AddSavingGoalState createState() => _AddSavingGoalState();
}

class _AddSavingGoalState extends State<AddSavingGoal> {
  int id;
  int savingorder = 0;
  String savingsitem;
  double amountSaved = 0.00;
  double totalAmount;
  String goalDate;

  @override
  void initState() {
    if (widget.s != null) {
      print(widget.s.id);
      id = widget.s.id;
      savingorder = widget.s.savingOrder;

      amountSaved = widget.s.amountSaved;

      savingsitem = widget.s.savingsItem;
      itemcontroller.text = widget.s.savingsItem;

      totalAmount = widget.s.totalAmount;
      totalAmountController.text = widget.s.totalAmount.toString();

      goalDate = widget.s.goalDate;
      _date.text = widget.s.goalDate;
    } else {
      DBProvider.db.getSavings().then((value) {
        if (value.length > 1) {
          setState(() {
            savingorder = value.last.savingOrder + 1;
          });
        }
      });
    }

    super.initState();
  }

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _date = new TextEditingController();
  TextEditingController itemcontroller = new TextEditingController();

  var totalAmountController = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  Widget buildSavingsItem() {
    return TextFormField(
      autocorrect: true,
      controller: itemcontroller,
      decoration: InputDecoration(labelText: "Saving Goal"),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value.isEmpty) {
          return 'Name on Card is Required';
        }
      },
      onSaved: (String value) {
        savingsitem = value;
      },
    );
  }

  Widget buildTotalAmount() {
    return TextFormField(
      controller: totalAmountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Total to Save"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        totalAmount = totalAmountController.doubleValue;
      },
    );
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
        goalDate = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  Widget buildGoalDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Enter Goal Date',
          ),
        ),
      ),
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
          "Add Savings Goal",
          style: TextStyle(color: Colors.black),
        ),
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

              if (widget.s != null) {
                print("updating");
                Saving saving = Saving(
                    id: id,
                    savingOrder: savingorder,
                    savingsItem: savingsitem,
                    amountSaved: amountSaved,
                    totalAmount: totalAmount,
                    goalDate: goalDate);

                print(saving.id);

                DBProvider.db.updateSaving(id, saving);

                Navigator.pushAndRemoveUntil(
                    context,
                    PageTransition(
                        type: PageTransitionType.leftToRight,
                        child: SavingsOrganiser()),
                    (route) => false);
              } else {
                Saving saving = Saving(
                    savingOrder: savingorder,
                    savingsItem: savingsitem,
                    amountSaved: amountSaved,
                    totalAmount: totalAmount,
                    goalDate: goalDate);

                DBProvider.db.newSaving(saving);

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
                    buildSavingsItem(),
                    buildTotalAmount(),
                    buildGoalDate(),
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
