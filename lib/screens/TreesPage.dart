import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/radialpainter.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/SavingsLayout.dart';
import 'package:money_tree/screens/add_saving_goal.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';

class TreePage extends StatefulWidget {
  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            // Saving Tree Text
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('My Saving Goals',
                      style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(color: Colors.teal[300])),
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: AddSavingGoal(s: null)));
                    },
                    color: Colors.teal[300],
                    textColor: Colors.white,
                    child: Text("Add Saving Goal".toUpperCase(),
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            FutureBuilder<List<Saving>>(
                future: DBProvider.db.getSavings(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Saving>> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: 16, right: 6),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Saving s = snapshot.data[index];
                          print(s.id);
                          print(s.amountSaved);
                          return Container(
                            margin:
                                EdgeInsets.only(right: 10, bottom: 8, top: 8),
                            child: InkWell(
                              onTap: () {
                                DBProvider.db
                                    .getSavingsTransForSaving(s.id)
                                    .then((value) {
                                  if (value.length > 0) {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: SavingsLayout(
                                              saving: snapshot.data[index],
                                            )));
                                  } else {
                                    final snackbar = SnackBar(
                                        duration: Duration(seconds: 1),
                                        content: Text("No Savings Made"));
                                    Scaffold.of(context).showSnackBar(snackbar);
                                  }
                                });
                              },
                              child: Ink(
                                height: 260,
                                width: 360,
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
                                        "£" +
                                            FlutterMoneyFormatter(
                                                    amount: s.amountSaved)
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
                                        "£" +
                                            FlutterMoneyFormatter(
                                                    amount: s.totalAmount)
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
                                        "£" +
                                            FlutterMoneyFormatter(
                                                    amount: s.totalAmount -
                                                        s.amountSaved)
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
                                              percent:
                                                  s.amountSaved / s.totalAmount,
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
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return Container();
                  }
                })
          ],
        ),
      ),
    );
  }
}
