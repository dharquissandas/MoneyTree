import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/screens/forms/TransInputLayout.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:page_transition/page_transition.dart';

class BudgetSavings extends StatefulWidget {
  final BankCard bankCard;
  BudgetSavings({Key key, @required this.bankCard}) : super(key: key);
  @override
  _BudgetSavingsState createState() => _BudgetSavingsState();
}

class _BudgetSavingsState extends State<BudgetSavings> {
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
          FutureBuilder<dynamic>(
              future:
                  DBProvider.db.getFirstTransactionforCard(widget.bankCard.id),
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
          Divider(
            height: 1.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text("Savings",
                    style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3A3A3A))),
              ],
            ),
          ),
          SizedBox(
            height: 10,
            width: double.infinity,
          ),
          FutureBuilder<List<SavingTransaction>>(
            future: DBProvider.db
                .getMonthSavingTransList(widget.bankCard.id, selectedMonth),
            builder: (BuildContext context,
                AsyncSnapshot<List<SavingTransaction>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Center(child: Text("No Saving Transactions"));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      SavingTransaction st = snapshot.data[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: TransInput(
                                      page: 2,
                                      transaction: st,
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
                                          formatDate(
                                                  DateTime(
                                                      int.parse(st.paymentdate
                                                          .substring(0, 4)),
                                                      int.parse(st.paymentdate
                                                          .substring(5, 7)),
                                                      int.parse(st.paymentdate
                                                          .substring(8, 10))),
                                                  [d, ' ', M, ' ', yyyy])
                                              .toString(),
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "Saving",
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
                                                  amount: st.paymentamount)
                                              .output
                                              .nonSymbol,
                                      style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.teal[300]),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        DBProvider.db.deleteSavingTrans(st);
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
                                    ),
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
