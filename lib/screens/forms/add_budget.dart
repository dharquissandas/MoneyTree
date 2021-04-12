import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/BudgetModel.dart';
import 'package:money_tree/models/CategoryModel.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:page_transition/page_transition.dart';
import 'package:money_tree/utils/Preferences.dart';

class AddBudget extends StatefulWidget {
  final BankCard bankCard;
  final dynamic budget;
  AddBudget({Key key, @required this.bankCard, @required this.budget})
      : super(key: key);
  @override
  _AddBudgetState createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  double _needLowerValue = 0;
  double _wantLowerValue = 0;
  double _saveLowerValue = 0;

  var dismissedList = new List();
  //Controllers for Categories
  var controller1 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller2 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller3 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller4 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller5 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller6 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller7 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller8 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller9 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller10 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");
  var controller11 = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  @override
  void initState() {
    getCurrency().then((value) {
      controller1 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller2 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller3 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller4 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller5 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller6 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller7 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller8 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller9 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller10 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
      controller11 = CurrencyTextFieldController(
          rightSymbol: value, decimalSymbol: ".", thousandSymbol: ",");
    }).then((v) {
      if (widget.budget != Null) {
        setState(() {
          _needLowerValue = widget.budget.need.toDouble();
          _wantLowerValue = widget.budget.want.toDouble();
          _saveLowerValue = widget.budget.save.toDouble();

          controller1.text =
              FlutterMoneyFormatter(amount: widget.budget.foodamount)
                  .output
                  .nonSymbol;

          controller2.text =
              FlutterMoneyFormatter(amount: widget.budget.sociallifeamount)
                  .output
                  .nonSymbol;

          controller3.text =
              FlutterMoneyFormatter(amount: widget.budget.selfdevamount)
                  .output
                  .nonSymbol;

          controller4.text =
              FlutterMoneyFormatter(amount: widget.budget.cultureamount)
                  .output
                  .nonSymbol;

          controller5.text =
              FlutterMoneyFormatter(amount: widget.budget.householdamount)
                  .output
                  .nonSymbol;

          controller6.text =
              FlutterMoneyFormatter(amount: widget.budget.apperalamount)
                  .output
                  .nonSymbol;

          controller7.text =
              FlutterMoneyFormatter(amount: widget.budget.beautyamount)
                  .output
                  .nonSymbol;

          controller8.text =
              FlutterMoneyFormatter(amount: widget.budget.healthamount)
                  .output
                  .nonSymbol;

          controller9.text =
              FlutterMoneyFormatter(amount: widget.budget.educationamount)
                  .output
                  .nonSymbol;

          controller10.text =
              FlutterMoneyFormatter(amount: widget.budget.giftamount)
                  .output
                  .nonSymbol;

          controller11.text =
              FlutterMoneyFormatter(amount: widget.budget.techamount)
                  .output
                  .nonSymbol;
        });
      }
    });

    super.initState();
  }

  //Get Controller for Interger
  CurrencyTextFieldController getcontroller(int id) {
    if (id == 1) return controller1;
    if (id == 2) return controller2;
    if (id == 3) return controller3;
    if (id == 4) return controller4;
    if (id == 5) return controller5;
    if (id == 6) return controller6;
    if (id == 7) return controller7;
    if (id == 8) return controller8;
    if (id == 9) return controller9;
    if (id == 10) return controller10;
    if (id == 11) return controller11;
  }

  //Check If Card Is Dismissed
  checkDismissed(CurrencyTextFieldController c) {
    for (int i = 0; i < dismissedList.length; i++) {
      if (getcontroller(dismissedList[i]) == c) {
        return 0.00;
      }
    }
    return c.doubleValue;
  }

  //Build Amount
  Widget buildAmount(int id) {
    return Container(
      width: 130,
      child: TextFormField(
        controller: getcontroller(id),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: "Limit Amount"),
        validator: (value) {
          if (value.isEmpty || value == "0.00") {
            value = null;
          }
        },
        onSaved: (value) {},
      ),
    );
  }

  //Build Budget Sliders, Need, Want, Save
  Widget buildBudgetSlider() {
    return BackgroundCard(
      height: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: Text(
              'NEEDS:',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FlutterSlider(
                    handlerHeight: 30,
                    values: [_needLowerValue],
                    min: 0,
                    max: 100,
                    step: FlutterSliderStep(step: 5),
                    tooltip: FlutterSliderTooltip(disabled: true),
                    trackBar: FlutterSliderTrackBar(
                        activeTrackBar: BoxDecoration(color: Colors.green)),
                    onDragging: (handlerIndex, nlowerValue, nupperValue) {
                      _needLowerValue = nlowerValue;
                      setState(() {});
                    },
                  ),
                ),
                Text(_needLowerValue.toInt().toString() + "%")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
            ),
            child: Text(
              'WANTS:',
              style: GoogleFonts.inter(
                  fontSize: 15, fontWeight: FontWeight.w500, color: Colors.red),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FlutterSlider(
                    values: [_wantLowerValue],
                    handlerHeight: 30,
                    max: 100,
                    min: 0,
                    step: FlutterSliderStep(step: 5),
                    tooltip: FlutterSliderTooltip(disabled: true),
                    trackBar: FlutterSliderTrackBar(
                        activeTrackBar: BoxDecoration(color: Colors.red)),
                    onDragging: (handlerIndex, wlowerValue, wupperValue) {
                      _wantLowerValue = wlowerValue;
                      setState(() {});
                    },
                  ),
                ),
                Text(_wantLowerValue.toInt().toString() + "%")
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              'SAVING:',
              style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.teal[300]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: FlutterSlider(
                    values: [_saveLowerValue],
                    handlerHeight: 30,
                    max: 100,
                    min: 0,
                    step: FlutterSliderStep(step: 5),
                    tooltip: FlutterSliderTooltip(disabled: true),
                    trackBar: FlutterSliderTrackBar(
                        activeTrackBar: BoxDecoration(color: Colors.teal[300])),
                    onDragging: (handlerIndex, slowerValue, supperValue) {
                      _saveLowerValue = slowerValue;
                      setState(() {});
                    },
                  ),
                ),
                Text(_saveLowerValue.toInt().toString() + "%")
              ],
            ),
          )
        ],
      ),
    );
  }

  //Build CategoryList with Value Entry
  Widget buildCategoryList() {
    return FutureBuilder<List<Category>>(
      future: DBProvider.db.getExpenseCategories(),
      builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.length,
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              Category c = snapshot.data[index];
              return Dismissible(
                onDismissed: (direction) {
                  dismissedList.add(c.id);
                },
                key: Key(c.id.toString()),
                child: BackgroundCard(
                  height: 70,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 12.0),
                                  child: Text(
                                    c.name,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        buildAmount(c.id)
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  //Add or Update Budget upon Confirmation
  addOrUpdateBudget() {
    if (_needLowerValue + _saveLowerValue + _wantLowerValue != 100) {
      final snackbar = SnackBar(
          duration: Duration(seconds: 2),
          content: Text(
            "Budgeting Ratio Does Not Sum To 100%",
            style: TextStyle(color: Colors.redAccent),
          ));
      Scaffold.of(context).showSnackBar(snackbar);
    } else {
      Budget budget = new Budget(
          bankcard: widget.bankCard.id,
          month: DateTime(DateTime.now().year, DateTime.now().month)
              .toIso8601String(),
          need: _needLowerValue.toInt(),
          want: _wantLowerValue.toInt(),
          save: _saveLowerValue.toInt(),
          foodamount: checkDismissed(controller1),
          sociallifeamount: checkDismissed(controller2),
          selfdevamount: checkDismissed(controller3),
          cultureamount: checkDismissed(controller4),
          householdamount: checkDismissed(controller5),
          apperalamount: checkDismissed(controller6),
          beautyamount: checkDismissed(controller7),
          healthamount: checkDismissed(controller8),
          educationamount: checkDismissed(controller9),
          giftamount: checkDismissed(controller10),
          techamount: checkDismissed(controller11));
      if (widget.budget == Null) {
        DBProvider.db.newBudget(budget);
      } else {
        Budget budget = new Budget(
            id: widget.budget.id,
            bankcard: widget.bankCard.id,
            month: DateTime(DateTime.now().year, DateTime.now().month)
                .toIso8601String(),
            need: _needLowerValue.toInt(),
            want: _wantLowerValue.toInt(),
            save: _saveLowerValue.toInt(),
            foodamount: checkDismissed(controller1),
            sociallifeamount: checkDismissed(controller2),
            selfdevamount: checkDismissed(controller3),
            cultureamount: checkDismissed(controller4),
            householdamount: checkDismissed(controller5),
            apperalamount: checkDismissed(controller6),
            beautyamount: checkDismissed(controller7),
            healthamount: checkDismissed(controller8),
            educationamount: checkDismissed(controller9),
            giftamount: checkDismissed(controller10),
            techamount: checkDismissed(controller11));
        DBProvider.db.updateBudget(budget, widget.budget.id);
      }

      Navigator.push(
        context,
        PageTransition(type: PageTransitionType.upToDown, child: Home()),
      );
    }
  }

  //Paint Widgets To Screen
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
            "Create Monthly Budget",
            style: TextStyle(color: Colors.black),
          ),
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Builder(
            builder: (BuildContext context) {
              return FloatingActionButton.extended(
                icon: Icon(Icons.check),
                backgroundColor: Colors.teal[300],
                elevation: 20,
                label: Text("Confirm"),
                onPressed: () {
                  addOrUpdateBudget();
                },
              );
            },
          ),
        ),
        body: ListView(
          physics: BouncingScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
              child: Text(
                "Select Budgeting Ratio For Income",
              ),
            ),
            buildBudgetSlider(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
              child: Text(
                "Monthly Expense Catagory Limits",
              ),
            ),
            buildCategoryList(),
            SizedBox(
              height: 80,
            )
          ],
        ));
  }
}
