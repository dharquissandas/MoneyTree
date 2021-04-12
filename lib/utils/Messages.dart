import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';

// build No-Budget Card
buildBudgetChecker(
    dynamic currMonthBudget, DateTime selectedMonth, DateTime currMonth) {
  if (currMonthBudget == Null && selectedMonth == currMonth) {
    return BackgroundCard(
      height: 100,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Please Create A Budget",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                  "Press the + on the bottom right of the screen to create a budget for this bankcard for a full budget analysis",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  )),
            ),
          ],
        ),
      ),
    );
  }
  return Container();
}

//build No-Savings Card
buildSavingsChecker() {
  return BackgroundCard(
    height: 90,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Please Add A Saving",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
                "Press the button on the top right of the page to create a Money Tree and display it here.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    ),
  );
}

// build No-Transaction Card
buildTransactionChecker() {
  return BackgroundCard(
    height: 90,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Please Add Transactions",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
                "Go back to the main dashboard and add some transactions to see your budget populate.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                )),
          ),
        ],
      ),
    ),
  );
}
