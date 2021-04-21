import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/paymentTable.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/models/CalculatedSavingsModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';

class SavingsPlanner extends StatefulWidget {
  final Saving saving;
  SavingsPlanner({key, @required this.saving}) : super(key: key);
  @override
  _SavingsPlannerState createState() => _SavingsPlannerState();
}

class _SavingsPlannerState extends State<SavingsPlanner> {
  String currency = "";

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    super.initState();
  }

  //Info Card For Calculated Saving
  Stack buildCalculatedSavingsInfo(cs) {
    return Stack(
      children: <Widget>[
        Positioned(
          left: 20,
          top: 16,
          child: Text(
            "Initial Feasible Amount:",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 210,
          top: 18,
          child: Text(
            currency +
                FlutterMoneyFormatter(amount: cs.feasiblePayment)
                    .output
                    .nonSymbol,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 40,
          child: Text(
            "Set Goal Date:",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 140,
          top: 42,
          child: Text(
            cs.goalDate,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 20,
          top: 64,
          child: Text(
            "Payment Frequency:",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        Positioned(
          left: 190,
          top: 66,
          child: Text(
            getTextualFrequency(cs.paymentFrequency),
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // Convert frequancy to String
  String getTextualFrequency(int pf) {
    if (pf == 1) {
      return "Daily ~ Every 1 Day";
    } else if (pf == 7) {
      return "Weekly ~ Every 7 Days";
    } else if (pf == 30) {
      return "Monthly ~ Every 30 Days";
    } else {
      return "Yearly ~ Every 365 Days";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView(
          children: <Widget>[
            // Payment Plan Overview
            Heading(
              title: "Payment Plan Overview",
              fontSize: 20,
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            ),

            //Calculated Saving Info
            FutureBuilder<CalculatedSaving>(
              future:
                  DBProvider.db.getCalculateSavingByParentId(widget.saving.id),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  CalculatedSaving cs = snapshot.data;
                  return BackgroundCard(
                      height: 100, child: buildCalculatedSavingsInfo(cs));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),

            //Payment Breakdown
            Heading(
              title: "Payment Plan Breakdown",
              fontSize: 20,
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            ),

            //Payment Plan Table
            FutureBuilder<dynamic>(
              future: Future.wait([
                DBProvider.db.getCalculateSavingByParentId(widget.saving.id),
                DBProvider.db.getSavingsTransForSaving(widget.saving.id)
              ]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return BackgroundCard(
                    child: PaymentTable(
                      transList: snapshot.data[1],
                      saving: widget.saving,
                      calculatedSaving: snapshot.data[0],
                      currency: currency,
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
