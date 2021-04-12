import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/Indicator.dart';
import 'package:money_tree/components/backgroundCard.dart';

class BudgetOverviewGraph extends StatelessWidget {
  final String currency;
  final double income;
  final double expense;
  final double saving;

  const BudgetOverviewGraph(
      {Key key, this.currency, this.income, this.expense, this.saving})
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
                  child: drawPieChart(),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Row drawPieChart() {
    return Row(
      children: <Widget>[
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.2,
            child: PieChart(
              PieChartData(
                  borderData: FlBorderData(
                    show: false,
                  ),
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: showingSections()),
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

  List<PieChartSectionData> showingSections() {
    double total = income + expense + saving;
    return List.generate(3, (i) {
      final double fontSize = 12;
      final double radius = 50;
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
}
