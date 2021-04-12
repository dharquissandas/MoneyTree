import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';

class OverviewCard extends StatelessWidget {
  final String currency;
  final double total;
  final double income;
  final double expense;
  final double saving;

  const OverviewCard(
      {Key key,
      this.currency,
      this.total,
      this.income,
      this.expense,
      this.saving})
      : super(key: key);

  //Build Overview Card
  @override
  Widget build(BuildContext context) {
    return BackgroundCard(
      height: 100,
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Row(
          children: <Widget>[
            // Total Overview
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Total Balance",
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A3A3A))),
                  Text(
                      currency +
                          FlutterMoneyFormatter(amount: this.total)
                              .output
                              .nonSymbol,
                      style: GoogleFonts.inter(
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                ],
              ),
            ),
            // Income/Expense/Savings Overview
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
                        Text(
                            currency +
                                FlutterMoneyFormatter(amount: this.income)
                                    .output
                                    .nonSymbol,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A3A3A)))
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
                        Text(
                            currency +
                                FlutterMoneyFormatter(amount: this.expense)
                                    .output
                                    .nonSymbol,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A3A3A))),
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
                        Text(
                            currency +
                                FlutterMoneyFormatter(amount: this.saving)
                                    .output
                                    .nonSymbol,
                            style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A3A3A)))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
