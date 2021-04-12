import 'package:date_format/date_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/models/SavingsModel.dart';

class SavingsTransactionsGraph extends StatelessWidget {
  final String currency;
  final Saving saving;
  final dynamic tlist;

  const SavingsTransactionsGraph(
      {Key key, this.currency, this.saving, this.tlist})
      : super(key: key);

// Display Savings Transaction Graph
  @override
  Widget build(BuildContext context) {
    return BackgroundCard(
      child: Padding(
        padding:
            const EdgeInsets.only(right: 30, left: 16, top: 16, bottom: 12),
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
    );
  }

  createLargestPaidAmount() {
    double la = 0;
    for (var i = 0; i < tlist.length; i++) {
      if (tlist[i].paymentamount > la) {
        la = tlist[i].paymentamount;
      }
    }
    return la;
  }

  BarChart barMainData() {
    return BarChart(
      BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: createLargestPaidAmount(),
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
}
