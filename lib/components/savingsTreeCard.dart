import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/radialpainter.dart';
import 'package:money_tree/models/SavingsModel.dart';

class SavingsTreeCard extends StatelessWidget {
  final String currency;
  final Saving s;

  const SavingsTreeCard({Key key, this.currency, this.s}) : super(key: key);

// Display Generic White Card
  @override
  Widget build(BuildContext context) {
    return Ink(
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
                  FlutterMoneyFormatter(amount: s.amountSaved).output.nonSymbol,
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
                  FlutterMoneyFormatter(amount: s.totalAmount).output.nonSymbol,
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
                  FlutterMoneyFormatter(amount: s.totalAmount - s.amountSaved)
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
                    percent: s.amountSaved / s.totalAmount,
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
    );
  }
}
