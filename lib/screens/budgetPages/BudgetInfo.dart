import 'package:flutter/material.dart';
import 'package:money_tree/components/bankcardDisplay.dart';
import 'package:money_tree/components/graphs/budgetOverviewGraph.dart';
import 'package:money_tree/components/graphs/budgetWeeklyGraph.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/components/overviewCard.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:money_tree/utils/Preferences.dart';

class BudgetInfo extends StatefulWidget {
  final BankCard bankCard;
  BudgetInfo({Key key, @required this.bankCard}) : super(key: key);
  @override
  _BudgetInfoState createState() => _BudgetInfoState();
}

class _BudgetInfoState extends State<BudgetInfo> {
  DateTime selectedMonth;
  DateTime currMonth;
  DateTime fromMonth;

  String currency = "";

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    currMonth = DateTime(DateTime.now().year, DateTime.now().month);
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
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView(
          children: <Widget>[
            //Top Month Strip
            FutureBuilder<dynamic>(
                future: DBProvider.db
                    .getFirstTransactionforCard(widget.bankCard.id),
                builder:
                    (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                          setState(() {
                            selectedMonth = v;
                          });
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

            //Bankcard
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: BankCardDisplay(
                height: 199,
                width: 344,
                bc: widget.bankCard,
                clickable: false,
                currency: currency,
              ),
            ),

            //Monthly Budget Analysis Heading
            Heading(
              title: "Monthly Budget Analysis",
              fontSize: 20,
              padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            ),

            // Budget Overview For Card For Selected Month
            FutureBuilder<List<double>>(
              future: Future.wait([
                DBProvider.db.getMonthIncome(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthExpense(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthSavingTrans(widget.bankCard.id, selectedMonth),
              ]),
              builder:
                  (BuildContext context, AsyncSnapshot<List<double>> snapshot) {
                if (snapshot.hasData) {
                  return OverviewCard(
                    currency: currency,
                    total:
                        snapshot.data[0] + snapshot.data[1] + snapshot.data[2],
                    income: snapshot.data[0],
                    expense: snapshot.data[1],
                    saving: snapshot.data[2],
                  );
                } else {
                  return Container();
                }
              },
            ),

            //Budget Overview Piechart
            FutureBuilder<List<double>>(
              future: Future.wait([
                DBProvider.db.getMonthIncome(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthExpense(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getMonthSavingTrans(widget.bankCard.id, selectedMonth)
              ]),
              builder:
                  (BuildContext context, AsyncSnapshot<List<double>> snapshot) {
                if (snapshot.hasData && checkDataTotal(snapshot.data)) {
                  return BudgetOverviewGraph(
                    income: snapshot.data[0],
                    expense: snapshot.data[1],
                    saving: snapshot.data[2],
                    currency: currency,
                  );
                } else {
                  return Container();
                }
              },
            ),

            // Weekly Budget Overview Graph
            FutureBuilder<List<dynamic>>(
              future: Future.wait([
                DBProvider.db
                    .getLineGraphIncomeData(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getLineGraphExpenseData(widget.bankCard.id, selectedMonth),
                DBProvider.db
                    .getLineGraphSavingsData(widget.bankCard.id, selectedMonth),
              ]),
              builder: (BuildContext context,
                  AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.hasData) {
                  return WeeklyBudgetGraph(
                    incomedata: snapshot.data[0],
                    expensedata: snapshot.data[1],
                    savingdata: snapshot.data[2],
                    currency: currency,
                  );
                } else {
                  return Container();
                }
              },
            ),

            //Prevent Bounceback
            SizedBox(
              height: 40,
              width: double.infinity,
            )
          ],
        ),
      ),
    );
  }
}
