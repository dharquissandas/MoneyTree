import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/Indicator.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/models/BudgetModel.dart';

class BudgetComparisonGraph extends StatelessWidget {
  final double need;
  final double want;
  final double save;
  final dynamic budgeted;

  const BudgetComparisonGraph(
      {Key key, this.need, this.want, this.save, this.budgeted})
      : super(key: key);

// Display Comparison Bar Graph
  @override
  Widget build(BuildContext context) {
    final Color leftBarColor = const Color(0xff53fdd7);
    final Color rightBarColor = const Color(0xffff5182);
    final double width = 15;

    return BackgroundCard(
      child: Padding(
        padding:
            const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 12),
        child: Column(
          children: [
            Text(
              "Budgeted vs Actual Budgeting Ratios",
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                    child: drawBarGraph(leftBarColor, rightBarColor, width)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //Draw Comparison Bae Graph
  Widget drawBarGraph(Color leftBarColor, Color rightBarColor, double width) {
    return Column(
      children: [
        BarChart(
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
            barGroups: makeBarData(leftBarColor, rightBarColor, width),
          ),
        ),
        SizedBox(
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
    );
  }

  //Create Bar Graph Data
  makeBarData(Color leftBarColor, Color rightBarColor, double width) {
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

    final barGroup1 = makeGroupData(0, budgetneed, double.parse(needdata),
        leftBarColor, rightBarColor, width);
    final barGroup2 = makeGroupData(1, budgetwant, double.parse(wantdata),
        leftBarColor, rightBarColor, width);
    final barGroup3 = makeGroupData(2, budgetsave, double.parse(savedata),
        leftBarColor, rightBarColor, width);

    final items = [
      barGroup1,
      barGroup2,
      barGroup3,
    ];

    List<BarChartGroupData> rawBarGroups = items;
    List<BarChartGroupData> showingBarGroups = rawBarGroups;
    return showingBarGroups;
  }

  //Group Bar Graph Data
  BarChartGroupData makeGroupData(int x, double y1, double y2,
      Color leftBarColor, Color rightBarColor, double width) {
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
