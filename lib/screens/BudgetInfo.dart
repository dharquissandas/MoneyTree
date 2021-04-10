import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/Indicator.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'dart:math';
import 'package:money_tree/utils/Preferences.dart';

class BudgetInfo extends StatefulWidget {
  final BankCard bankCard;
  BudgetInfo({Key key, @required this.bankCard}) : super(key: key);
  @override
  _BudgetInfoState createState() => _BudgetInfoState();
}

class _BudgetInfoState extends State<BudgetInfo> {
  int touchedIndex;

  DateTime selectedMonth;
  DateTime currMonth;
  DateTime fromMonth;

  double incomeAmount = 1;
  double expenseAmount = 1;
  double savingsAmount = 1;
  double totalAmount = 1;

  String currency = "";

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    currMonth = DateTime(DateTime.now().year, DateTime.now().month);

    DBProvider.db
        .getMonthIncome(widget.bankCard.id, selectedMonth)
        .then((income) {
      DBProvider.db
          .getMonthExpense(widget.bankCard.id, selectedMonth)
          .then((expense) {
        DBProvider.db
            .getMonthSavingTrans(widget.bankCard.id, selectedMonth)
            .then((savings) {
          setState(() {
            incomeAmount = income;
            expenseAmount = expense;
            savingsAmount = savings;
            totalAmount = income + expense + savings;
          });
        });
      });
    });
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
          Divider(
            height: 1.0,
          ),
          Container(
            height: 199,
            width: 344,
            margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: Offset(0, 2.0),
                )
              ],
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFFFF80A4),
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -60,
                  right: 229,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF1B239F)),
                  ),
                ),
                Positioned(
                  bottom: -100,
                  right: 15,
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Color(0xFF1B239F)),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 78,
                  child: Text(
                    "CARD NUMBER",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 98,
                  child: Text(
                    "**** **** **** " + widget.bankCard.cardNumber.toString(),
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                    right: 10,
                    top: 15,
                    child: Image.asset(
                      "assets/images/Mastercard.png",
                      width: 40,
                      height: 40,
                    )),
                Positioned(
                  left: 20,
                  bottom: 45,
                  child: Text(
                    "CARDHOLDER NAME",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 15,
                  child: Text(
                    "CARD BALANCE",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 20,
                  top: 35,
                  child: Text(
                    currency +
                        FlutterMoneyFormatter(amount: widget.bankCard.amount)
                            .output
                            .nonSymbol,
                    style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 21,
                  child: Text(
                    widget.bankCard.cardName,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 225,
                  bottom: 45,
                  child: Text(
                    "EXPIRY DATE",
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  ),
                ),
                Positioned(
                  left: 225,
                  bottom: 21,
                  child: Text(
                    widget.bankCard.expiryDate,
                    style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, top: 8, right: 16, bottom: 8),
            child: Text('Monthly Budget Analysis',
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
          ),
          Container(
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
            child: Container(
              margin: EdgeInsets.only(right: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("Total Budget",
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3A3A3A))),
                        Text(
                            currency +
                                FlutterMoneyFormatter(amount: totalAmount)
                                    .output
                                    .nonSymbol,
                            style: GoogleFonts.inter(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF3A3A3A),
                            ))
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Income:",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green)),
                              FutureBuilder<double>(
                                future: DBProvider.db.getMonthIncome(
                                    widget.bankCard.id, selectedMonth),
                                builder: (BuildContext context,
                                    AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasData) {
                                    incomeAmount = snapshot.data;
                                    return Text(
                                        currency +
                                            FlutterMoneyFormatter(
                                                    amount: snapshot.data)
                                                .output
                                                .nonSymbol,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF3A3A3A)));
                                  } else {
                                    return Container();
                                  }
                                },
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Expense:",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red)),
                              FutureBuilder<double>(
                                future: DBProvider.db.getMonthExpense(
                                    widget.bankCard.id, selectedMonth),
                                builder: (BuildContext context,
                                    AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasData) {
                                    expenseAmount = snapshot.data;
                                    return Text(
                                        currency +
                                            FlutterMoneyFormatter(
                                                    amount: snapshot.data)
                                                .output
                                                .nonSymbol,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF3A3A3A)));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text("Savings:",
                                  style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.teal[300])),
                              FutureBuilder<double>(
                                future: DBProvider.db.getMonthSavingTrans(
                                    widget.bankCard.id, selectedMonth),
                                builder: (BuildContext context,
                                    AsyncSnapshot<double> snapshot) {
                                  if (snapshot.hasData) {
                                    savingsAmount = snapshot.data;
                                    totalAmount = savingsAmount +
                                        incomeAmount +
                                        expenseAmount;
                                    return Text(
                                        currency +
                                            FlutterMoneyFormatter(
                                                    amount: snapshot.data)
                                                .output
                                                .nonSymbol,
                                        style: GoogleFonts.inter(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF3A3A3A)));
                                  } else {
                                    return Container();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              DBProvider.db.getMonthIncome(widget.bankCard.id, selectedMonth),
              DBProvider.db.getMonthExpense(widget.bankCard.id, selectedMonth),
              DBProvider.db
                  .getMonthSavingTrans(widget.bankCard.id, selectedMonth)
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData &&
                  (snapshot.data[0] + snapshot.data[1] + snapshot.data[2]) !=
                      0) {
                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 8, right: 16, left: 16),
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: 30, left: 16, top: 16, bottom: 12),
                        child: Column(
                          children: [
                            Text(
                              "Budget Breakdown",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: drawPieChart(snapshot.data[0],
                                        snapshot.data[1], snapshot.data[2])),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            },
          ),
          FutureBuilder<List<dynamic>>(
            future: Future.wait([
              DBProvider.db
                  .getLineGraphIncomeData(widget.bankCard.id, selectedMonth),
              DBProvider.db
                  .getLineGraphExpenseData(widget.bankCard.id, selectedMonth),
              DBProvider.db
                  .getLineGraphSavingsData(widget.bankCard.id, selectedMonth),
            ]),
            builder:
                (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: drawLineGraph(
                      snapshot.data[0], snapshot.data[1], snapshot.data[2]),
                );
              } else {
                return Container();
              }
            },
          ),
          SizedBox(
            height: 40,
            width: double.infinity,
          )
        ],
      ),
    );
  }

//Pie Chart
  Row drawPieChart(income, expense, saving) {
    return Row(
      children: <Widget>[
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (pieTouchResponse) {
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
                  sections: showingSections(income, expense, saving)),
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const <Widget>[
            Indicator(
              color: Colors.green,
              text: 'Income',
              isSquare: false,
            ),
            SizedBox(
              height: 4,
            ),
            Indicator(
              color: Colors.red,
              text: 'Expense',
              isSquare: false,
            ),
            SizedBox(
              height: 4,
            ),
            Indicator(
              color: Colors.teal,
              text: 'Saving',
              isSquare: false,
            ),
          ],
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections(income, expense, saving) {
    double total = income + expense + saving;
    return List.generate(3, (i) {
      final isTouched = i == touchedIndex;
      final double fontSize = isTouched ? 18 : 12;
      final double radius = isTouched ? 60 : 50;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green,
            value: income / total,
            title: ((income / total) * 100).toStringAsFixed(2) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.red,
            value: expense / total,
            title: ((expense / total) * 100).toStringAsFixed(2) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.teal[300],
            value: saving / total,
            title: ((saving / total) * 100).toStringAsFixed(2) + "%",
            radius: radius,
            titleStyle: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff)),
          );
        default:
          return null;
      }
    });
  }

//Line Graph
  AspectRatio drawLineGraph(
      List<double> data, List<double> data1, List<double> data2) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                spreadRadius: 1,
                offset: Offset(0, 2.0),
              )
            ],
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            color: Colors.white),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
                  child: Text(
                    "Weekly Budget Average",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 16.0, left: 16.0, top: 8, bottom: 16),
                    child: LineChart(getData(data, data1, data2)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  LineChartData getData(
      List<double> data, List<double> data1, List<double> data2) {
    List<double> totaldata = [];
    totaldata.addAll(data);
    totaldata.addAll(data1);
    totaldata.addAll(data2);
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.white.withOpacity(0.8),
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(
        show: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          textStyle: TextStyle(
            color: Color(0xff72719b),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return "Week 1";
              case 5:
                return 'Week 2';
              case 9:
                return 'Week 3';
              case 13:
                return 'Week 4';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: false,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color(0xff4e4965),
            width: 2,
          ),
          left: BorderSide(
            color: Colors.transparent,
          ),
          right: BorderSide(
            color: Colors.transparent,
          ),
          top: BorderSide(
            color: Colors.transparent,
          ),
        ),
      ),
      minX: 0,
      maxX: 14,
      maxY: totaldata.reduce(max) + 10,
      minY: 0,
      lineBarsData: linesBarData1(data, data1, data2),
    );
  }

  List<LineChartBarData> linesBarData1(
      List<double> data, List<double> data1, List<double> data2) {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        FlSpot(1, data[0]),
        FlSpot(5, data[1]),
        FlSpot(9, data[2]),
        FlSpot(13, data[3]),
      ],
      isCurved: false,
      colors: [
        Colors.green,
      ],
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    final LineChartBarData lineChartBarData2 = LineChartBarData(
      spots: [
        FlSpot(1, data1[0]),
        FlSpot(5, data1[1]),
        FlSpot(9, data1[2]),
        FlSpot(13, data1[3]),
      ],
      isCurved: false,
      colors: [
        Colors.red,
      ],
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(show: false, colors: [
        const Color(0x00aa4cfc),
      ]),
    );
    final LineChartBarData lineChartBarData3 = LineChartBarData(
      spots: [
        FlSpot(1, data2[0]),
        FlSpot(5, data2[1]),
        FlSpot(9, data2[2]),
        FlSpot(13, data2[3]),
      ],
      isCurved: false,
      colors: [
        Colors.teal[300],
      ],
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );
    return [
      lineChartBarData1,
      lineChartBarData2,
      lineChartBarData3,
    ];
  }
}
