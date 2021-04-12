import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/components/graphs/budgetComparisonGraph.dart';
import 'package:money_tree/components/graphs/budgetExpenseGraph.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/BudgetExceedings.dart';
import 'package:money_tree/models/BudgetModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Messages.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:flutter/gestures.dart';
import 'package:money_tree/utils/Preferences.dart';

class BudgetPlanner extends StatefulWidget {
  final BankCard bankCard;
  final dynamic monthBudget;
  BudgetPlanner({Key key, @required this.bankCard, @required this.monthBudget})
      : super(key: key);
  @override
  _BudgetPlannerState createState() => _BudgetPlannerState();
}

class _BudgetPlannerState extends State<BudgetPlanner> {
  DateTime selectedMonth;
  DateTime currMonth;
  DateTime fromMonth;
  dynamic currMonthBudget;

  bool exceeding = true;

  String currency = "";

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    currMonth = DateTime(DateTime.now().year, DateTime.now().month);
    buildSelectedMonthBudget();
  }

  buildSelectedMonthBudget() {
    DBProvider.db.getBudget(widget.bankCard.id).then((value) {
      setState(() {
        currMonthBudget = value;
      });
    });
  }

  //Exceeding lists
  buildExceedingList(List<BudgetExeedings> data) {
    return ListView.builder(
      itemCount: data.length,
      padding: EdgeInsets.only(left: 16, right: 16),
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        BudgetExeedings be = data[index];
        return Container(
          margin: EdgeInsets.only(bottom: 13),
          child: Container(
            height: 70,
            padding: EdgeInsets.only(left: 24, top: 12, bottom: 12, right: 22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2.0),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          be.category,
                          style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black),
                        ),
                        Text(
                          selectedMonth.month.toString() +
                              "/" +
                              selectedMonth.year.toString(),
                          style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Text(
                      currency +
                          FlutterMoneyFormatter(amount: be.budgeted)
                              .output
                              .nonSymbol,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal[300]),
                    ),
                    SizedBox(height: 1, width: 5),
                    Text(
                      currency +
                          FlutterMoneyFormatter(amount: be.actual)
                              .output
                              .nonSymbol,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.teal[300]),
                    ),
                    SizedBox(height: 1, width: 5),
                    Text(
                      currency +
                          FlutterMoneyFormatter(
                                  amount: (be.budgeted - be.actual))
                              .output
                              .nonSymbol,
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: exceeding ? Colors.red : Colors.green),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  budgetComparisons(Map<String, double> actualData, Budget budget) {
    double nearAmount = 50;
    List<double> values = actualData.values.toList();
    List<String> keys = actualData.keys.toList();
    List<BudgetExeedings> exceedinglist = new List<BudgetExeedings>();
    List<BudgetExeedings> nearlist = new List<BudgetExeedings>();
    if (values[0] > budget.foodamount - nearAmount) {
      if (values[0] > budget.foodamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[0], actual: values[0], budgeted: budget.foodamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[0], actual: values[0], budgeted: budget.foodamount));
      }
    }
    if (values[1] > budget.sociallifeamount - nearAmount) {
      if (values[1] > budget.sociallifeamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[1],
            actual: values[1],
            budgeted: budget.sociallifeamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[1],
            actual: values[1],
            budgeted: budget.sociallifeamount));
      }
    }
    if (values[2] > budget.selfdevamount - nearAmount) {
      if (values[2] > budget.selfdevamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[2],
            actual: values[2],
            budgeted: budget.selfdevamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[2],
            actual: values[2],
            budgeted: budget.selfdevamount));
      }
    }
    if (values[3] > budget.cultureamount - nearAmount) {
      if (values[3] > budget.cultureamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[3],
            actual: values[3],
            budgeted: budget.cultureamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[3],
            actual: values[3],
            budgeted: budget.cultureamount));
      }
    }
    if (values[4] > budget.householdamount - nearAmount) {
      if (values[4] > budget.householdamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[4],
            actual: values[4],
            budgeted: budget.householdamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[4],
            actual: values[4],
            budgeted: budget.householdamount));
      }
    }
    if (values[5] > budget.apperalamount - nearAmount) {
      if (values[5] > budget.apperalamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[5], actual: values[5], budgeted: budget.foodamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[5],
            actual: values[5],
            budgeted: budget.apperalamount));
      }
    }
    if (values[6] > budget.beautyamount - nearAmount) {
      if (values[6] > budget.beautyamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[6],
            actual: values[6],
            budgeted: budget.beautyamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[6],
            actual: values[6],
            budgeted: budget.beautyamount));
      }
    }
    if (values[7] > budget.healthamount - nearAmount) {
      if (values[7] > budget.healthamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[7],
            actual: values[7],
            budgeted: budget.healthamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[7],
            actual: values[7],
            budgeted: budget.healthamount));
      }
    }
    if (values[8] > budget.educationamount - nearAmount) {
      if (values[8] > budget.educationamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[8],
            actual: values[8],
            budgeted: budget.educationamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[8],
            actual: values[8],
            budgeted: budget.educationamount));
      }
    }
    if (values[9] > budget.giftamount - nearAmount) {
      if (values[9] > budget.giftamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[9], actual: values[9], budgeted: budget.giftamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[9], actual: values[9], budgeted: budget.foodamount));
      }
    }
    if (values[10] > budget.techamount - nearAmount) {
      if (values[10] > budget.techamount) {
        exceedinglist.add(new BudgetExeedings(
            category: keys[10],
            actual: values[10],
            budgeted: budget.techamount));
      } else {
        nearlist.add(new BudgetExeedings(
            category: keys[10],
            actual: values[10],
            budgeted: budget.techamount));
      }
    }
    return [nearlist, exceedinglist];
  }

  bool checkDataTotal(List<double> data) {
    if (data[0] + data[1] + data[2] == 0) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          //Month List Builder
          FutureBuilder<dynamic>(
              future:
                  DBProvider.db.getFirstTransactionforCard(widget.bankCard.id),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData && snapshot.data != Null) {
                  return Container(
                    color: Colors.white,
                    child: MonthStrip(
                      format: 'MMM yyyy',
                      from: snapshot.data,
                      to: currMonth,
                      initialMonth: selectedMonth,
                      height: 48,
                      viewportFraction: 0.25,
                      onMonthChanged: (v) {
                        selectedMonth = v;
                        buildSelectedMonthBudget();
                        setState(() {});
                      },
                    ),
                  );
                } else {
                  return Container();
                }
              }),

          //Seperator
          Divider(
            height: 1.0,
          ),

          //Comparison Heading
          Heading(
              title: "Budgeted & Actual Comparison",
              fontSize: 20,
              padding: EdgeInsets.only(
                left: 16,
                top: 8,
                right: 16,
                bottom: 8,
              )),

          //Display If No Budget Created
          buildBudgetChecker(currMonthBudget, selectedMonth, currMonth),

          //Budget vs Actual Comparison Graph
          FutureBuilder<List<dynamic>>(
              future: Future.wait([
                DBProvider.db
                    .getMonthWantExpense(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthSavingTrans(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthNeedExpense(widget.bankCard.id, selectedMonth),
                DBProvider.db.getMonthBudget(widget.bankCard.id, selectedMonth),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  if (checkDataTotal([
                        snapshot.data[0],
                        snapshot.data[1],
                        snapshot.data[2]
                      ]) ||
                      snapshot.data[3] != Null) {
                    currMonthBudget = snapshot.data[3];
                    return BudgetComparisonGraph(
                        want: snapshot.data[0],
                        save: snapshot.data[1],
                        need: snapshot.data[2],
                        budgeted: snapshot.data[3]);
                  } else {
                    return buildTransactionChecker();
                  }
                } else {
                  return Container();
                }
              }),

          //Expense Category Pie Chart
          FutureBuilder<Map<String, double>>(
              future: DBProvider.db.getMonthExpenseCategoryList(
                  widget.bankCard.id, selectedMonth),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, double>> snapshot) {
                if (snapshot.hasData && snapshot.data.values.last != 0) {
                  return BudgetExpenseGraph(
                    data: snapshot.data,
                  );
                } else {
                  return Container();
                }
              }),

          //Exceeding Categories Heading
          Heading(
            title: exceeding ? "Budget Exceedings" : "Near Budget Exceedings",
            fontSize: 20,
            padding: EdgeInsets.only(
              left: 16,
              top: 0,
              right: 16,
              bottom: 8,
            ),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.teal[300])),
              onPressed: () {
                setState(() {
                  if (exceeding) {
                    exceeding = false;
                  } else {
                    exceeding = true;
                  }
                });
              },
              color: Colors.teal[300],
              textColor: Colors.white,
              child: Text(exceeding ? "Near" : "Exceeding",
                  style: TextStyle(fontSize: 12)),
            ),
          ),

          //Exceeding List Headings
          BackgroundCard(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Category',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  Text('Budgeted',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  Text('Actual',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                  Text('Deficit',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ],
              ),
            ),
          ),

          //Dynamic Exceeding List
          FutureBuilder<List<dynamic>>(
              future: Future.wait([
                DBProvider.db.getMonthExpenseCategoryList(
                    widget.bankCard.id, selectedMonth),
                DBProvider.db.getMonthBudget(widget.bankCard.id, selectedMonth),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData && snapshot.data[1] != Null) {
                  dynamic lists =
                      budgetComparisons(snapshot.data[0], snapshot.data[1]);
                  return exceeding
                      ? buildExceedingList(lists[1])
                      : buildExceedingList(lists[0]);
                } else {
                  return buildBudgetChecker(
                      currMonthBudget, selectedMonth, currMonth);
                }
              }),

          //Tailing Space
          SizedBox(
            height: 80,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}
