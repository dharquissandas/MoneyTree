import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/Indicator.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/BudgetExceedings.dart';
import 'package:money_tree/models/BudgetModel.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:fl_chart/fl_chart.dart';
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

  final Color leftBarColor = const Color(0xff53fdd7);
  final Color rightBarColor = const Color(0xffff5182);
  final double width = 15;

  int touchedIndex;

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

  buildBudgetChecker() {
    if (currMonthBudget == Null && selectedMonth == currMonth) {
      return Container(
        height: 100,
        margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2.0))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Please Create A Budget",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                    "Press the + on the bottom right of the screen to create a budget for this bankcard for a full budget analysis",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    )),
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  buildTransactionChecker() {
    return Container(
      height: 90,
      margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 2.0))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Please Add Transactions",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                  "Go back to the main dashboard and add some transactions to see your budget populate.",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  pieCategoryColourDictionary(String category) {
    if (category == "Food") {
      return Colors.red;
    } else if (category == "Social Life") {
      return Colors.orange;
    } else if (category == "Self-Development") {
      return Colors.yellow;
    } else if (category == "Culture") {
      return Colors.green;
    } else if (category == "Household") {
      return Colors.blue;
    } else if (category == "Apperal") {
      return Colors.indigo;
    } else if (category == "Beauty") {
      return Colors.purple;
    } else if (category == "Health") {
      return Colors.pink;
    } else if (category == "Education") {
      return Colors.lime;
    } else if (category == "Gift") {
      return Colors.teal;
    } else {
      return Colors.grey;
    }
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

  Map<String, double> zeroBudgetRemoval(data) {
    List<String> toDelete = new List<String>();
    data.entries.forEach((e) {
      if (e.value == 0) {
        toDelete.add(e.key);
      }
    });

    toDelete.forEach((element) {
      data.remove(element);
    });
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
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
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Text('Budgeted & Actual Comparison',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
          ),
          buildBudgetChecker(),
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
                  if (((snapshot.data[0] +
                              snapshot.data[1] +
                              snapshot.data[2]) !=
                          0) ||
                      snapshot.data[3] != Null) {
                    currMonthBudget = snapshot.data[3];
                    return Column(
                      children: [
                        drawBarGraph(snapshot.data[0], snapshot.data[1],
                            snapshot.data[2], snapshot.data[3]),
                      ],
                    );
                  } else {
                    return buildTransactionChecker();
                  }
                } else {
                  return Container();
                }
              }),
          FutureBuilder<Map<String, double>>(
              future: DBProvider.db.getMonthExpenseCategoryList(
                  widget.bankCard.id, selectedMonth),
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, double>> snapshot) {
                if (snapshot.hasData && snapshot.data.values.last != 0) {
                  return Container(
                      height: 400,
                      margin: EdgeInsets.only(
                          top: 8, left: 16, right: 16, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2.0))
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Text(
                              "Expenditure Category Breakdown",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            drawPieChart(snapshot.data),
                          ],
                        ),
                      ));
                } else {
                  return Container();
                }
              }),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(exceeding ? "Budget Exceedings" : "Near Budget Exceedings",
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A3A))),
                RaisedButton(
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
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Container(
              height: 50,
              padding: EdgeInsets.only(top: 12, bottom: 12, right: 22),
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
              child: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Category',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                    Text('Budgeted',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                    Text('Actual',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                    Text('Deficit',
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black)),
                  ],
                ),
              ),
            ),
          ),
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
                  return buildBudgetChecker();
                }
              }),
          SizedBox(height: 80, width: double.infinity),
        ],
      ),
    );
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

  //Pie Chart
  Column drawPieChart(data) {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: PieChart(
                  PieChartData(
                      pieTouchData:
                          PieTouchData(touchCallback: (pieTouchResponse) {
                        setState(() {
                          if (pieTouchResponse.touchInput is FlLongPressEnd ||
                              pieTouchResponse.touchInput is FlPanEnd) {
                            touchedIndex = -1;
                          } else {
                            touchedIndex = pieTouchResponse.touchedSectionIndex;
                          }
                        });
                      }),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: showingSections(data)),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(height: 1, width: 35),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Indicator(
                  color: pieCategoryColourDictionary("Food"),
                  text: 'Food',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Social Life"),
                  text: 'Social Life',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Self-Development"),
                  text: 'Self-Development',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Culture"),
                  text: 'Culture',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Education"),
                  text: 'Education',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Technology"),
                  text: 'Technology',
                  isSquare: false,
                ),
              ],
            ),
            SizedBox(height: 1, width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Indicator(
                  color: pieCategoryColourDictionary("Household"),
                  text: 'Household',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Apperal"),
                  text: 'Apperal',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Beauty"),
                  text: 'Beauty',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Health"),
                  text: 'Health',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: pieCategoryColourDictionary("Gift"),
                  text: 'Gift',
                  isSquare: false,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(Map<String, double> data) {
    data = zeroBudgetRemoval(data);

    return List.generate(data.length - 1, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 18 : 12;
      final double radius = isTouched ? 60 : 50;
      for (var j = 0; j < data.length - 1; j++) {
        if (i.toInt() == j) {
          return PieChartSectionData(
            color: pieCategoryColourDictionary(data.keys.toList()[j]),
            value: data.values.toList()[j] / data.values.last,
            title: ((data.values.toList()[j] / data.values.last) * 100)
                    .toStringAsFixed(2) +
                "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        }
      }
    });
  }

  //BarGraph
  Widget drawBarGraph(want, save, need, budgeted) {
    return Container(
      height: 350,
      margin: EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 2.0))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              "Budgeted vs Actual Budgeting Ratios",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: BarChart(
                  BarChartData(
                    gridData: FlGridData(show: true),
                    maxY: 100,
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 20,
                        getTitles: (double value) {
                          switch (value.toInt()) {
                            case 0:
                              return 'Needs';
                            case 1:
                              return 'Wants';
                            case 2:
                              return 'Savings';
                            default:
                              return '';
                          }
                        },
                      ),
                      leftTitles: SideTitles(
                        showTitles: true,
                        textStyle: TextStyle(
                            color: Color(0xff7589a2),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                        margin: 32,
                        reservedSize: 16,
                        getTitles: (value) {
                          if (value == 0) {
                            return '0%';
                          } else if (value == 50) {
                            return '50%';
                          } else if (value == 100) {
                            return '100%';
                          } else {
                            return '';
                          }
                        },
                      ),
                    ),
                    borderData: FlBorderData(
                      show: false,
                    ),
                    barGroups: makeBarData(want, save, need, budgeted),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Indicator(
                  color: leftBarColor,
                  text: 'Budgeted',
                  isSquare: false,
                ),
                SizedBox(width: 10, height: 1),
                Indicator(
                  color: rightBarColor,
                  text: 'Actual',
                  isSquare: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  makeBarData(want, save, need, budgeted) {
    double budgetneed = 0;
    double budgetwant = 0;
    double budgetsave = 0;

    String needdata = "0";
    String wantdata = "0";
    String savedata = "0";

    if (need + want + save != 0) {
      needdata = ((need / (want + need + save)) * 100).toStringAsFixed(2);
      wantdata = ((want / (want + need + save)) * 100).toStringAsFixed(2);
      savedata = ((save / (want + need + save)) * 100).toStringAsFixed(2);
    }

    if (budgeted != Null) {
      budgetneed = budgeted.need.toDouble();
      budgetwant = budgeted.want.toDouble();
      budgetsave = budgeted.save.toDouble();
    }

    final barGroup1 = makeGroupData(0, budgetneed, double.parse(needdata));
    final barGroup2 = makeGroupData(1, budgetwant, double.parse(wantdata));
    final barGroup3 = makeGroupData(2, budgetsave, double.parse(savedata));

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
    ];

    List<BarChartGroupData> rawBarGroups = items;
    List<BarChartGroupData> showingBarGroups = rawBarGroups;
    return showingBarGroups;
  }

  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(barsSpace: 4, x: x, barRods: [
      BarChartRodData(
        y: y1,
        color: leftBarColor,
        width: width,
      ),
      BarChartRodData(
        y: y2,
        color: rightBarColor,
        width: width,
      ),
    ]);
  }
}
