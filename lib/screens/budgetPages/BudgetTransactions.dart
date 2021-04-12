import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/screens/layoutManagers/TransInputLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:month_picker_strip/month_picker_strip.dart';
import 'package:page_transition/page_transition.dart';

class BudgetTransactions extends StatefulWidget {
  final BankCard bankCard;
  BudgetTransactions({Key key, @required this.bankCard}) : super(key: key);
  @override
  _BudgetTransactionsState createState() => _BudgetTransactionsState();
}

class _BudgetTransactionsState extends State<BudgetTransactions> {
  DateTime selectedMonth;
  DateTime currMonth;
  DateTime fromMonth;

  bool need = true;
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
          //Month Selector Strip
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

          //Seperator
          Divider(
            height: 1.0,
          ),

          //Expense Transaction Heading
          Heading(
            title: need ? "Need Transactions" : "Want Transactions",
            fontSize: 22,
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.0),
                  side: BorderSide(color: Colors.teal[300])),
              onPressed: () {
                setState(() {
                  if (need) {
                    need = false;
                  } else {
                    need = true;
                  }
                });
              },
              color: Colors.teal[300],
              textColor: Colors.white,
              child:
                  Text(need ? "WANT" : "NEED", style: TextStyle(fontSize: 12)),
            ),
          ),

          //Seperator
          SizedBox(
            height: 10,
            width: double.infinity,
          ),

          //Dynamic List Of Expense Transactions
          FutureBuilder<List<ExpenseTransaction>>(
            future: need
                ? DBProvider.db.getMonthNeedExpenseTransactions(
                    widget.bankCard.id, selectedMonth)
                : DBProvider.db.getMonthWantExpenseTransactions(
                    widget.bankCard.id, selectedMonth),
            builder: (BuildContext context,
                AsyncSnapshot<List<ExpenseTransaction>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length == 0) {
                  return Center(child: Text("No Expense Transactions"));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      ExpenseTransaction et = snapshot.data[index];
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
                                      page: 1,
                                      transaction: et,
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
                                          et.name,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.black),
                                        ),
                                        Text(
                                          formatDate(
                                              DateTime(
                                                  int.parse(
                                                      et.date.substring(0, 4)),
                                                  int.parse(
                                                      et.date.substring(5, 7)),
                                                  int.parse(et.date
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
                                                  amount: et.amount)
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
                                            .deleteExpenseTransaction(et);
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
