import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/Indicator.dart';
import 'package:money_tree/components/backgroundCard.dart';

class BudgetExpenseGraph extends StatelessWidget {
  final Map<String, double> data;

  const BudgetExpenseGraph({Key key, this.data}) : super(key: key);

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

  // Build Pie Chart
  Column drawPieChart() {
    return Column(
      children: [
        Row(
          children: <Widget>[
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.6,
                child: PieChart(
                  PieChartData(
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
        buildIndicatorLayout()
      ],
    );
  }

  // Build Pie Chart Legend
  buildIndicatorLayout() {
    return Row(
      children: [
        SizedBox(height: 1, width: 35),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
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
    );
  }

  //Pie Chart Sections
  List<PieChartSectionData> showingSections(Map<String, double> data) {
    data = zeroBudgetRemoval(data);
    return List.generate(data.length - 1, (i) {
      final double fontSize = 12;
      final double radius = 50;
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
        } else {}
      }
    });
  }

  //HELPER METHODS
  //Return colour for Pie Chart Section
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

  //Removal Of Expense Category As No Total Amount
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
}
