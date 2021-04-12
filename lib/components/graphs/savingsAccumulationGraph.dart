import 'package:date_format/date_format.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/models/SavingsModel.dart';

class savingsAccumulationGraph extends StatelessWidget {
  final String currency;
  final Saving saving;
  final dynamic tlist;

  const savingsAccumulationGraph(
      {Key key, this.currency, this.saving, this.tlist})
      : super(key: key);

// Display Savings Accumulation Graph
  @override
  Widget build(BuildContext context) {
    return BackgroundCard(
      child: Padding(
        padding:
            const EdgeInsets.only(right: 30, left: 16, top: 16, bottom: 12),
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
                    mainData(createPoints()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  createPoints() {
    var points = <FlSpot>[];
    var total = 0.0;
    for (var i = 0; i < tlist.length; i++) {
      total = total + (tlist[i].paymentamount / saving.totalAmount) * 10;
      points.add(FlSpot(i.toDouble(), (total)));
    }
    return points;
  }

  LineChartData mainData(points) {
    List<Color> gradientColors = [
      const Color(0xff23b6e6),
      const Color(0xff02d39a),
    ];

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
                  return currency +
                      FlutterMoneyFormatter(
                              amount: (saving.totalAmount * i * 0.1))
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
          bottomTitle: AxisTitle(showTitle: true, titleText: ""),
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
}
