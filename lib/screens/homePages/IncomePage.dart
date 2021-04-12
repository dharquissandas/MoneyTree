import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/screens/layoutManagers/TransInputLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:page_transition/page_transition.dart';

class IncomePage extends StatefulWidget {
  @override
  _IncomePageState createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  DateTime selectedMonth;
  DateTime currMonth;
  DateTime fromMonth;

  String currency = "";

  @override
  void initState() {
    super.initState();
    getCurrency().then((value) => currency = value);
    selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    currMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          //Get Month Strip
          FutureBuilder<dynamic>(
              future: DBProvider.db.getFirstIncomeTransaction(),
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

          //Seperator
          Divider(
            height: 1.0,
          ),

          //Spacing
          SizedBox(
            height: 10,
            width: double.infinity,
          ),

          //List of Income Transactions
          FutureBuilder<List<IncomeTransaction>>(
            future:
                DBProvider.db.getIncomeTransactionListbyMonth(selectedMonth),
            builder: (BuildContext context,
                AsyncSnapshot<List<IncomeTransaction>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Center(child: Text("No Income Transactions"));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      IncomeTransaction it = snapshot.data[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: TransInput(
                                      page: 0,
                                      transaction: it,
                                      saving: null,
                                    )));
                          },
                          child: Ink(
                            height: 70,
                            padding: EdgeInsets.only(
                                left: 24, top: 12, bottom: 12, right: 22),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 5,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2.0),
                                )
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          it.name,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          formatDate(
                                              DateTime(
                                                  int.parse(
                                                      it.date.substring(0, 4)),
                                                  int.parse(
                                                      it.date.substring(5, 7)),
                                                  int.parse(it.date
                                                      .substring(8, 10))),
                                              [
                                                d,
                                                ' ',
                                                M,
                                                ' ',
                                                yyyy
                                              ]).toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      currency +
                                          FlutterMoneyFormatter(
                                                  amount: it.amount)
                                              .output
                                              .nonSymbol,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.teal[300]),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        DBProvider.db
                                            .deleteIncomeTransaction(it);
                                        setState(() {});
                                      },
                                      child: Container(
                                        padding: EdgeInsets.only(left: 12.0),
                                        child: Text(
                                          'x',
                                          style: GoogleFonts.inter(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.red),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}
