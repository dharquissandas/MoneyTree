import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:money_tree/models/CalculatedSavingsModel.dart';
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
  bool calculate = false;
  bool byAmount = false;
  bool byDate = true;

  int id;
  int savingorder = 0;
  String savingsitem;
  double amountSaved = 0.00;
  double totalAmount;
  String description;

  String goalDate =
      DateTime.now().add(Duration(days: 1)).toIso8601String().substring(0, 10);

  double feasiblePayment;

  int paymentFrequency;

  @override
  void initState() {
    if (widget.s != null) {
      id = widget.s.id;
      savingorder = widget.s.savingOrder;

      amountSaved = widget.s.amountSaved;

      savingsitem = widget.s.savingsItem;
      itemcontroller.text = widget.s.savingsItem;

      totalAmount = widget.s.totalAmount;
      totalAmountController.text = widget.s.totalAmount.toString();
    } else {
      DBProvider.db.getSavings().then((value) {
        if (value.length > 1) {
          setState(() {
            savingorder = value.last.savingOrder + 1;
          });
        }
      });
      _date.value = TextEditingValue(
          text: DateTime.now()
              .add(Duration(days: 1))
              .toIso8601String()
              .substring(0, 10));
    }

    super.initState();
  }

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _date = new TextEditingController();
  TextEditingController itemcontroller = new TextEditingController();
  TextEditingController descriptioncontroller = new TextEditingController();

  var totalAmountController = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  var payableController = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  List<DropdownMenuItem<int>> frequency = [];
  var selectedFrequency;

  void loadFrequency() {
    frequency = [];
    frequency.add(new DropdownMenuItem(
      child: new Text('Daily ~ Every 1 Day'),
      value: 1,
    ));
    frequency.add(new DropdownMenuItem(
      child: new Text('Weekly ~ Every 7 Days'),
      value: 7,
    ));
    frequency.add(new DropdownMenuItem(
      child: new Text('Monthly ~ Every 30 Days'),
      value: 30,
    ));
    frequency.add(new DropdownMenuItem(
      child: new Text('Yearly ~ Every 365 Days'),
      value: 365,
    ));
  }

  calculateDayDifference() {
    int year = int.parse(goalDate.substring(0, 4));
    int month = int.parse(goalDate.substring(5, 7));
    int day = int.parse(goalDate.substring(8, 10));

    DateTime sDate = DateTime(year, month, day);

    DateTime oDate = DateTime(
        int.parse(DateTime.now().toIso8601String().substring(0, 4)),
        int.parse(DateTime.now().toIso8601String().substring(5, 7)),
        int.parse(DateTime.now().toIso8601String().substring(8, 10)));

    Duration dayDifference = sDate.difference(oDate);
    return dayDifference;
  }

  Widget buildFrequency() {
    loadFrequency();
    return DropdownButtonFormField(
      hint: new Text('Select Payment Frequency'),
      items: frequency,
      value: selectedFrequency,
      validator: (value) {
        Duration dayDifference = calculateDayDifference();

        if (paymentFrequency == null) {
          return "Payment Frequancy Required";
        }
        if (paymentFrequency > dayDifference.inDays && byDate) {
          return "Can't Divide Frequency Over End Date Selected";
        }
      },
      onChanged: (value) {
        setState(() {
          selectedFrequency = value;
          paymentFrequency = value;
        });
      },
      isExpanded: true,
    );
  }

  Widget buildSavingsItem() {
    return TextFormField(
      autocorrect: true,
      controller: itemcontroller,
      decoration: InputDecoration(labelText: "Saving Goal"),
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value.isEmpty) {
          return 'Saving Item Required';
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

  Widget buildPayable() {
    return TextFormField(
      controller: payableController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Feasible Payment Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        feasiblePayment = payableController.doubleValue;
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

  Widget buildCalculateSwitch() {
    return SwitchListTile(
      title: Text("Calculate"),
      value: calculate,
      secondary: Icon(Icons.assessment),
      onChanged: (bool value) {
        setState(() {
          calculate = value;
        });
      },
    );
  }

  Widget buildCalculateChoice() {
    return Column(
      children: [
        CheckboxListTile(
          value: byDate,
          onChanged: (value) {
            setState(() {
              if (value) {
                byDate = value;
                byAmount = false;
                feasiblePayment = null;
                payableController.text = "";
              }
            });
          },
          title: new Text("By Date"),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          value: byAmount,
          onChanged: (value) {
            setState(() {
              if (value) {
                byAmount = value;
                byDate = false;
                goalDate = DateTime.now()
                    .add(Duration(days: 1))
                    .toIso8601String()
                    .substring(0, 10);
                _date.text = DateTime.now()
                    .add(Duration(days: 1))
                    .toIso8601String()
                    .substring(0, 10);
              }
            });
          },
          title: new Text("By Amount"),
          controlAffinity: ListTileControlAffinity.leading,
        )
      ],
    );
  }

  Widget buildDescription() {
    return TextFormField(
      autocorrect: true,
      controller: descriptioncontroller,
      decoration: InputDecoration(labelText: "Description"),
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      onSaved: (String value) {
        description = value;
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

              if (byDate && calculate) {
                Duration daydifference = calculateDayDifference();
                double amtperday = totalAmount / daydifference.inDays;
                double amtperperiod = amtperday * paymentFrequency;
                feasiblePayment = double.parse(amtperperiod.toStringAsFixed(2));
              }

              if (byAmount && calculate) {
                int periodtime = totalAmount ~/ feasiblePayment;
                int noDays = periodtime * paymentFrequency;
                if (periodtime < (totalAmount / feasiblePayment)) {
                  noDays = noDays + paymentFrequency;
                }
                goalDate = DateTime.now()
                    .add(Duration(days: noDays))
                    .toIso8601String()
                    .substring(0, 10);
              }

              if (widget.s != null) {
                Saving saving = Saving(
                  id: id,
                  savingOrder: savingorder,
                  savingsItem: savingsitem,
                  amountSaved: amountSaved,
                  totalAmount: totalAmount,
                );

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
                    startDate:
                        DateTime.now().toIso8601String().substring(0, 10),
                    description: description,
                    calculated: calculate ? 1 : 0);

                DBProvider.db.newSaving(saving);

                if (calculate) {
                  DBProvider.db.getSavings().then((value) {
                    CalculatedSaving cs = CalculatedSaving(
                      parentId: value.last.id,
                      goalDate: goalDate,
                      feasiblePayment: feasiblePayment,
                      paymentFrequency: paymentFrequency,
                      savingType: byDate ? 0 : 1,
                    );

                    DBProvider.db.newCalculatedSaving(cs);
                  });
                }

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
                    buildDescription(),
                    buildCalculateSwitch(),
                    calculate ? buildCalculateChoice() : Container(),
                    byDate && calculate ? buildGoalDate() : Container(),
                    byAmount && calculate ? buildPayable() : Container(),
                    calculate ? buildFrequency() : Container(),
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
