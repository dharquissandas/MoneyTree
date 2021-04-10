import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_format/date_format.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/screens/layoutManagers/BudgetLayout.dart';
import 'package:money_tree/screens/forms/TransInputLayout.dart';
import 'package:money_tree/screens/forms/add_bankcard.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';
import 'package:money_tree/utils/Preferences.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String currency = "";

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Main Container
      body: Container(
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            //My Cards Text
            Padding(
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('My Cards',
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
                              child: AddBankCard(
                                bc: null,
                              )));
                    },
                    color: Colors.teal[300],
                    textColor: Colors.white,
                    child: Text("Add card".toUpperCase(),
                        style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            //Cards
            FutureBuilder<List<BankCard>>(
                future: DBProvider.db.getBankCards(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<BankCard>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasData) {
                      return Container(
                        height: 215,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: BouncingScrollPhysics(),
                            padding: EdgeInsets.only(left: 16, right: 10),
                            itemCount: snapshot.data.length,
                            itemBuilder: (context, index) {
                              BankCard bc = snapshot.data[index];
                              return Row(
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: BudgetLayout(
                                            card: snapshot.data[index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Ink(
                                        height: 199,
                                        width: 344,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              blurRadius: 5,
                                              spreadRadius: 1,
                                              offset: Offset(0, 2.0),
                                            )
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(0xFFFF80A4),
                                        ),
                                        child: Stack(
                                          children: <Widget>[
                                            Positioned(
                                              top: -60,
                                              right: 229,
                                              child: Container(
                                                height: 100,
                                                width: 100,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF1B239F)),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: -100,
                                              right: 15,
                                              child: Container(
                                                height: 180,
                                                width: 180,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF1B239F)),
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              top: 78,
                                              child: Text(
                                                "CARD NUMBER",
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              top: 98,
                                              child: Text(
                                                "**** **** **** " +
                                                    bc.cardNumber.toString(),
                                                style: GoogleFonts.inter(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                                right: 10,
                                                top: 15,
                                                child: Image.asset(
                                                  "assets/images/Mastercard.png",
                                                  width: 40,
                                                  height: 40,
                                                )),
                                            Positioned(
                                              left: 20,
                                              bottom: 45,
                                              child: Text(
                                                "CARDHOLDER NAME",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              top: 15,
                                              child: Text(
                                                "CARD BALANCE",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              top: 35,
                                              child: Text(
                                                currency +
                                                    FlutterMoneyFormatter(
                                                            amount: bc.amount)
                                                        .output
                                                        .nonSymbol,
                                                style: GoogleFonts.inter(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 20,
                                              bottom: 21,
                                              child: Text(
                                                bc.cardName,
                                                style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 225,
                                              bottom: 45,
                                              child: Text(
                                                "EXPIRY DATE",
                                                style: GoogleFonts.inter(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Positioned(
                                              left: 225,
                                              bottom: 21,
                                              child: Text(
                                                bc.expiryDate,
                                                style: GoogleFonts.inter(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ],
                                        )),
                                  ),
                                  SizedBox(
                                    height: 215,
                                    width: 10,
                                  )
                                ],
                              );
                            }),
                      );
                    } else {
                      //Show error here
                      return Container();
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }),

            //Overview Text
            Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Overview',
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                  Text(formatDate(DateTime.now(), [M, ' ', yyyy]).toString(),
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                ],
              ),
            ),

            //Overview
            Container(
              height: 100,
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
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text("Total Balance",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3A3A3A))),
                          FutureBuilder<double>(
                            future: DBProvider.db.getTotalAmount(),
                            builder: (BuildContext context,
                                AsyncSnapshot<double> snapshot) {
                              if (snapshot.hasData) {
                                return Text(
                                    currency +
                                        FlutterMoneyFormatter(
                                                amount: snapshot.data)
                                            .output
                                            .nonSymbol,
                                    style: GoogleFonts.inter(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF3A3A3A)));
                              } else {
                                return Container();
                              }
                            },
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Income:",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.green)),
                                FutureBuilder<double>(
                                  future: DBProvider.db.getcurrentMonthIncome(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<double> snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                          currency +
                                              FlutterMoneyFormatter(
                                                      amount: snapshot.data)
                                                  .output
                                                  .nonSymbol,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF3A3A3A)));
                                    } else {
                                      return Container();
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Expense:",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red)),
                                FutureBuilder<double>(
                                  future:
                                      DBProvider.db.getcurrentMonthExpense(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<double> snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                          currency +
                                              FlutterMoneyFormatter(
                                                      amount: snapshot.data)
                                                  .output
                                                  .nonSymbol,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF3A3A3A)));
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Savings:",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.teal[300])),
                                FutureBuilder<double>(
                                  future: DBProvider.db.getcurrentMonthSaving(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<double> snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(
                                          currency +
                                              FlutterMoneyFormatter(
                                                      amount: snapshot.data)
                                                  .output
                                                  .nonSymbol,
                                          style: GoogleFonts.inter(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF3A3A3A)));
                                    } else {
                                      return Container();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Transactions Today Text
            Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Transactions Today',
                      style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                  Text(
                      formatDate(DateTime.now(), [d, "/", m, '/', yyyy])
                          .toString(),
                      style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                ],
              ),
            ),

            //Income Text
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('INCOME:',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.green)),
                ],
              ),
            ),

            //Transactions Today ListView
            FutureBuilder<List<IncomeTransaction>>(
              future: DBProvider.db.getIncomeTransactionbyDate(DateTime.now()),
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
                            borderRadius: BorderRadius.circular(15),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                        int.parse(it.date
                                                            .substring(0, 4)),
                                                        int.parse(it.date
                                                            .substring(5, 7)),
                                                        int.parse(it.date
                                                            .substring(8, 10))),
                                                    [d, ' ', M, ' ', yyyy])
                                                .toString(),
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

            //Expense Text
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8, right: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('EXPENSE:',
                      style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.red)),
                ],
              ),
            ),

            //Transactions Today ListView
            FutureBuilder<List<ExpenseTransaction>>(
              future: DBProvider.db.getExpenseTransactionbyDate(DateTime.now()),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                                        int.parse(et.date
                                                            .substring(0, 4)),
                                                        int.parse(et.date
                                                            .substring(5, 7)),
                                                        int.parse(et.date
                                                            .substring(8, 10))),
                                                    [d, ' ', M, ' ', yyyy])
                                                .toString(),
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
      ),
    );
  }
}
