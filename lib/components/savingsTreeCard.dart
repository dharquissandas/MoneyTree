import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/radialpainter.dart';
import 'package:money_tree/models/SavingsModel.dart';

class SavingsTreeCard extends StatelessWidget {
  final String currency;
  final Saving s;

  const SavingsTreeCard({Key key, this.currency, this.s}) : super(key: key);

  getMoneyTree(Saving s) {
    if (s.amountSaved == s.totalAmount) {
      return Image.asset(
        "assets/images/4.png",
        height: 120,
        width: 120,
      );
    } else if (s.amountSaved == 0) {
      return Image.asset(
        "assets/images/0.png",
        height: 80,
        width: 80,
      );
    }

    double percent = (s.amountSaved / s.totalAmount) * 100;
    if (percent > 0 && percent < 25) {
      return Image.asset(
        "assets/images/1.png",
        height: 120,
        width: 120,
      );
    } else if (percent >= 25 && percent < 75) {
      return Image.asset(
        "assets/images/2.png",
        height: 120,
        width: 120,
      );
    } else if (percent >= 75 && percent < 100) {
      return Image.asset(
        "assets/images/3.png",
        height: 120,
        width: 120,
      );
    }
  }

// Display Generic White Card
  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
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
                    FlutterMoneyFormatter(amount: s.amountSaved)
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
                    FlutterMoneyFormatter(amount: s.totalAmount)
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
                  child: Center(child: getMoneyTree(s)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
