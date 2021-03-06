import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:money_tree/components/backgroundCard.dart';

class WeeklyBudgetGraph extends StatelessWidget {
  final String currency;
  final dynamic incomedata;
  final dynamic expensedata;
  final dynamic savingdata;

  const WeeklyBudgetGraph(
      {Key key,
      this.currency,
      this.incomedata,
      this.expensedata,
      this.savingdata})
      : super(key: key);

// Display Weekly Savings Graph
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: BackgroundCard(
        child: Padding(
          padding:
              const EdgeInsets.only(right: 16, left: 16, top: 16, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "Weekly Budget Average",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: LineChart(getData()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Rounding Method
  double roundDouble(double value, int places) {
    double mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }

  // Initialise Data
  LineChartData getData() {
    List<double> totaldata = [];
    totaldata.addAll(incomedata);
    totaldata.addAll(expensedata);
    totaldata.addAll(savingdata);
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
      lineBarsData: linesBarData1(),
    );
  }

  // Render Data
  List<LineChartBarData> linesBarData1() {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        FlSpot(1, roundDouble(incomedata[0], 2)),
        FlSpot(5, roundDouble(incomedata[1], 2)),
        FlSpot(9, roundDouble(incomedata[2], 2)),
        FlSpot(13, roundDouble(incomedata[3], 2)),
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
        FlSpot(1, roundDouble(expensedata[0], 2)),
        FlSpot(5, roundDouble(expensedata[1], 2)),
        FlSpot(9, roundDouble(expensedata[2], 2)),
        FlSpot(13, roundDouble(expensedata[3], 2)),
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
        FlSpot(1, roundDouble(savingdata[0], 2)),
        FlSpot(5, roundDouble(savingdata[1], 2)),
        FlSpot(9, roundDouble(savingdata[2], 2)),
        FlSpot(13, roundDouble(savingdata[3], 2)),
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
