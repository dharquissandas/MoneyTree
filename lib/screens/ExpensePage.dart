import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/utils/Database.dart';

class ExpensePage extends StatefulWidget {
  @override
  _ExpensePageState createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   title: Text(
      //     "Expense Transactions",
      //     style: TextStyle(color: Colors.black),
      //   ),
      //   centerTitle: true,
      // ),
      body: Container(
        margin: EdgeInsets.only(top: 16),
        child: FutureBuilder<List<ExpenseTransaction>>(
          future: DBProvider.db.getExpenseTransaction(),
          builder: (BuildContext context,
              AsyncSnapshot<List<ExpenseTransaction>> snapshot) {
            if (snapshot.hasData) {
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
                      onTap: () {},
                      borderRadius: BorderRadius.circular(15),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                              int.parse(
                                                  et.date.substring(8, 10))),
                                          [d, ' ', M, ' ', yyyy]).toString(),
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
                                  "£" + et.amount.toString(),
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B239F)),
                                ),
                                InkWell(
                                  onTap: () {
                                    DBProvider.db.deleteExpenseTransaction(et);
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
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }
}
