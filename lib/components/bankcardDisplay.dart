import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/BankCardModel.dart';

class BankCardDisplay extends StatelessWidget {
  final double height;
  final double width;
  final bool clickable;
  final BankCard bc;
  final String currency;

  const BankCardDisplay(
      {Key key,
      this.height,
      this.width,
      this.bc,
      this.clickable,
      this.currency})
      : super(key: key);

  // Display Bank Card
  @override
  Widget build(BuildContext context) {
    if (this.clickable) {
      return Ink(
          height: this.height,
          width: this.width,
          decoration: buildBoxDecoration(),
          child: buildInternalCard(this.bc, this.currency));
    } else {
      return Container(
          height: this.height,
          width: this.width,
          decoration: buildBoxDecoration(),
          child: buildInternalCard(this.bc, this.currency));
    }
  }
}

// Build Box Decoration
BoxDecoration buildBoxDecoration() {
  return BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 5,
        spreadRadius: 1,
        offset: Offset(0, 2.0),
      )
    ],
    borderRadius: BorderRadius.circular(20),
    color: Color(0xFFFF80A4),
  );
}

Image getCardNetworkImage(BankCard bc) {
  if (bc.cardType == "Mastercard") {
    return Image.asset(
      "assets/images/Mastercard.png",
      width: 40,
      height: 40,
    );
  } else if (bc.cardType == "Visa") {
    return Image.asset(
      "assets/images/Visa.png",
      width: 40,
      height: 40,
    );
  } else if (bc.cardType == "American Express") {
    return Image.asset(
      "assets/images/Amex.png",
      width: 40,
      height: 40,
    );
  } else {
    return Image.asset(
      "assets/images/Discover.png",
      width: 40,
      height: 40,
    );
  }
}

// Build Card Layout Stack
Stack buildInternalCard(bc, currency) {
  return Stack(
    children: <Widget>[
      Positioned(
        top: -60,
        right: 229,
        child: Container(
          height: 100,
          width: 100,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1B239F)),
        ),
      ),
      Positioned(
        bottom: -100,
        right: 15,
        child: Container(
          height: 180,
          width: 180,
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1B239F)),
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
          "**** **** **** " + bc.cardNumber.toString(),
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      Positioned(right: 10, top: 15, child: getCardNetworkImage(bc)),
      Positioned(
        left: 20,
        bottom: 45,
        child: Text(
          "CARDHOLDER NAME",
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      Positioned(
        left: 20,
        top: 15,
        child: Text(
          "CARD BALANCE",
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      Positioned(
        left: 20,
        top: 35,
        child: Text(
          currency + FlutterMoneyFormatter(amount: bc.amount).output.nonSymbol,
          style: GoogleFonts.inter(
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      Positioned(
        left: 20,
        bottom: 21,
        child: Text(
          bc.cardName,
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      Positioned(
        left: 225,
        bottom: 45,
        child: Text(
          "EXPIRY DATE",
          style: GoogleFonts.inter(
              fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white),
        ),
      ),
      Positioned(
        left: 225,
        bottom: 21,
        child: Text(
          bc.expiryDate,
          style: GoogleFonts.inter(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    ],
  );
}
