import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/radialpainter.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:money_tree/utils/Preferences.dart';

class SavingInfo extends StatefulWidget {
  final Saving saving;
  SavingInfo({Key key, @required this.saving}) : super(key: key);
  @override
  _SavingInfoState createState() => _SavingInfoState();
}

class _SavingInfoState extends State<SavingInfo> {
  List<SavingTransaction> tlist = List<SavingTransaction>();
  var largestpaidamount;
  String currency = "";

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    setState(() {});
    var la;

    DBProvider.db.getSavingsTransForSaving(widget.saving.id).then((value) {
      setState(() {
        tlist = value;
      });
    });

    //largest amount
    for (var i = 0; i < tlist.length; i++) {
      if (tlist[i].paymentamount > la) {
        la = tlist[i].paymentaccount;
      }
    }
    setState(() {
      largestpaidamount = la;
    });

    super.initState();
  }

  createBar() {
    var points = <BarChartGroupData>[];
    for (var i = 0; i < tlist.length; i++) {
      points.add(
        BarChartGroupData(x: i, barRods: [
          BarChartRodData(
              y: tlist[i].paymentamount, color: Colors.lightBlueAccent)
        ], showingTooltipIndicators: [
          0
        ]),
      );
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          FutureBuilder<Saving>(
            future: DBProvider.db.getSavingById(widget.saving.id),
            builder: (BuildContext context, AsyncSnapshot<Saving> snapshot) {
              if (snapshot.hasData) {
                Saving s = snapshot.data;
                return Container(
                  margin:
                      EdgeInsets.only(bottom: 16, top: 16, right: 16, left: 16),
                  height: 260,
                  width: double.infinity,
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
                    color: Colors.white,
                  ),
                  child: Stack(
                    children: <Widget>[
                      //Item Name
                      Positioned(
                        left: 20,
                        top: 16,
                        child: Text(
                          s.savingsItem,
                          style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 20,
                        top: 130,
                        child: Text(
                          "AMOUNT SAVED:",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 20,
                        top: 150,
                        child: Text(
                          currency +
                              FlutterMoneyFormatter(amount: s.amountSaved)
                                  .output
                                  .nonSymbol,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 20,
                        top: 70,
                        child: Text(
                          "TOTAL AMOUNT:",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 20,
                        top: 90,
                        child: Text(
                          currency +
                              FlutterMoneyFormatter(amount: s.totalAmount)
                                  .output
                                  .nonSymbol,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 20,
                        top: 190,
                        child: Text(
                          "AMOUNT NEEDED:",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 16,
                        top: 210,
                        child: Text(
                          currency +
                              FlutterMoneyFormatter(
                                      amount: s.totalAmount - s.amountSaved)
                                  .output
                                  .nonSymbol,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      //Tree Circular
                      Positioned(
                        top: 80,
                        left: 16,
                        child: Container(
                          height: 150,
                          width: 160,
                          child: CustomPaint(
                            foregroundPainter: RadialPainter(
                                bgColor: Colors.grey[200],
                                lineColor: Colors.green,
                                percent: s.amountSaved / s.totalAmount,
                                width: 10),
                            child: Center(
                              child: Text(
                                "Tree",
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
          FutureBuilder<List<SavingTransaction>>(
            future: DBProvider.db.getSavingsTransForSaving(widget.saving.id),
            builder: (BuildContext context,
                AsyncSnapshot<List<SavingTransaction>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length <= 1) {
                  return Container();
                } else {
                  var points = <FlSpot>[];
                  var total = 0.0;
                  for (var i = 0; i < snapshot.data.length; i++) {
                    total = total +
                        (snapshot.data[i].paymentamount /
                                widget.saving.totalAmount) *
                            10;
                    points.add(FlSpot(i.toDouble(), (total)));
                  }

                  return Container(
                    margin: EdgeInsets.only(bottom: 16, right: 16, left: 16),
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
                            "Savings Accumulation",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(
                            height: 37,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: LineChart(
                                  mainData(points),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          Container(
            margin: EdgeInsets.only(bottom: 16, right: 16, left: 16),
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
                    "Savings Added",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    height: 37,
                  ),
                  Row(
                    children: [
                      Expanded(child: barMainData()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartData mainData(points) {
    return LineChartData(
        lineTouchData: LineTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFFD2DEE9),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xFFD2DEE9),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: SideTitles(
              showTitles: true,
              reservedSize: 18,
              textStyle: const TextStyle(
                  color: Color(0xff68737d),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              getTitles: (value) {
                for (var i = 0; i < tlist.length; i++) {
                  if (value.toInt() == i) {
                    return formatDate(
                        DateTime(
                            int.parse(tlist[i].paymentdate.substring(0, 4)),
                            int.parse(tlist[i].paymentdate.substring(5, 7)),
                            int.parse(tlist[i].paymentdate.substring(8, 10))),
                        [d, '/', m]).toString();
                  }
                }
              },
              margin: 12),
          leftTitles: SideTitles(
            showTitles: true,
            textStyle: const TextStyle(
              color: Color(0xff67727d),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            getTitles: (value) {
              for (var i = 0; i <= 10; i++) {
                if (value == 0) {
                  return currency +
                      FlutterMoneyFormatter(amount: 0.00).output.nonSymbol;
                }
                if (value > 0 && value == i) {
                  return " £" +
                      FlutterMoneyFormatter(
                              amount: (widget.saving.totalAmount * i * 0.1))
                          .output
                          .nonSymbol;
                }
              }
            },
            reservedSize: 50,
            margin: 16,
          ),
        ),
        axisTitleData: FlAxisTitleData(
          leftTitle: AxisTitle(showTitle: true, titleText: ""),
          bottomTitle: AxisTitle(showTitle: true, titleText: "Date"),
        ),
        borderData: FlBorderData(
            show: false,
            border: Border.all(color: const Color(0xff37434d), width: 1)),
        minX: 0,
        minY: 0,
        maxX: tlist.length.toDouble() - 1,
        maxY: 10,
        lineBarsData: [
          LineChartBarData(
            spots: points,
            isCurved: true,
            colors: gradientColors,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ]);
  }

  BarChart barMainData() {
    return BarChart(
      BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: largestpaidamount,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              tooltipPadding: EdgeInsets.all(0),
              tooltipBottomMargin: 8,
              getTooltipItem: (
                BarChartGroupData group,
                int groupIndex,
                BarChartRodData rod,
                int rodIndex,
              ) {
                return BarTooltipItem(
                  currency +
                      FlutterMoneyFormatter(amount: rod.y).output.nonSymbol,
                  //rod.y.round().toString(),
                  TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              showTitles: true,
              textStyle: TextStyle(
                  color: const Color(0xff7589a2),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              margin: 20,
              getTitles: (double value) {
                for (var i = 0; i < tlist.length; i++) {
                  if (value.toInt() == i) {
                    return formatDate(
                        DateTime(
                            int.parse(tlist[i].paymentdate.substring(0, 4)),
                            int.parse(tlist[i].paymentdate.substring(5, 7)),
                            int.parse(tlist[i].paymentdate.substring(8, 10))),
                        [d, '/', m]).toString();
                  }
                }
              },
            ),
            leftTitles: SideTitles(showTitles: false),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          barGroups: createBar()),
    );
  }
}
