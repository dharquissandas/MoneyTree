import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/radialpainter.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/forms/add_saving_goal.dart';
import 'package:money_tree/screens/layoutManagers/SavingsLayout.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:page_transition/page_transition.dart';

class TreePage extends StatefulWidget {
  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  String currency = "";
  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    super.initState();
  }

  buildSavingsChecker() {
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
                "Please Add A Saving",
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
                  "Press the button on the top right of the page to create a Money Tree and display it here.",
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
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.only(left: 16, right: 6),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Saving s = snapshot.data[index];
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
                                        currency +
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
                                        currency +
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
                                        currency +
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
                    return buildSavingsChecker();
                  }
                })
          ],
        ),
      ),
    );
  }
}
