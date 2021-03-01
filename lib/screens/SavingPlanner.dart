import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/CalculatedSavingsModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/screens/add_saving.dart';
import 'package:money_tree/utils/Database.dart';

class SavingsPlanner extends StatefulWidget {
  final Saving saving;
  SavingsPlanner({key, @required this.saving}) : super(key: key);
  @override
  _SavingsPlannerState createState() => _SavingsPlannerState();
}

class _SavingsPlannerState extends State<SavingsPlanner> {
  Saving s;
  List<SavingTransaction> transList = List<SavingTransaction>();

  @override
  void initState() {
    DBProvider.db.getSavingById(widget.saving.id).then((saving) {
      setState(() {
        s = saving;
      });
    });

    DBProvider.db
        .getSavingsTransForSaving(widget.saving.id)
        .then((savingstransactions) {
      setState(() {
        transList = savingstransactions;
      });
    });

    super.initState();
  }

  buildDateFromString(String stringDate) {
    return DateTime(
        int.parse(stringDate.substring(0, 4)),
        int.parse(stringDate.substring(5, 7)),
        int.parse(stringDate.substring(8, 10)));
  }

  DateTime getDateFromDateTime(DateTime dt) {
    String date = dt.toIso8601String().substring(0, 10);
    return DateTime.parse(date);
  }

  getTransTotalForPeriod(
      DateTime startDate, DateTime endDate, List<SavingTransaction> tList) {
    double total = 0.0;
    for (var i = 0; i < tList.length; i++) {
      if (DateTime.parse(tList[i].paymentdate)
                  .isAfter(startDate.subtract(Duration(days: 1))) &&
              DateTime.parse(tList[i].paymentdate)
                  .isBefore(endDate.add(Duration(days: 1))) ||
          DateTime.parse(tList[i].paymentdate).compareTo(startDate) == 0 ||
          DateTime.parse(tList[i].paymentdate).compareTo(endDate) == 0) {
        total = total + tList[i].paymentamount;
      }
    }
    return total;
  }

  getPaymentTotal(List<Cpayment> paymentList) {
    double total = 0;
    for (var i = 0; i < paymentList.length; i++) {
      total = total + paymentList[i].amount;
    }
    return total;
  }

  buildPaymentArray(CalculatedSaving cs) {
    List<Cpayment> paymentList = List<Cpayment>();
    double feasiblePayment = cs.feasiblePayment;
    DateTime startDate = buildDateFromString(s.startDate);
    DateTime goalDate = buildDateFromString(cs.goalDate);
    Duration duration = goalDate.difference(startDate);

    //First Payment Period
    int numberOfPayments = duration.inDays ~/ cs.paymentFrequency;

    DateTime endDate;
    if (cs.paymentFrequency > 1) {
      endDate = startDate.add(Duration(days: cs.paymentFrequency - 1));
    } else {
      endDate = startDate;
    }

    double periodTotal = getTransTotalForPeriod(startDate, endDate, transList);
    double extra = cs.feasiblePayment - periodTotal;
    paymentList.add(Cpayment(startDate, endDate, cs.feasiblePayment,
        periodTotal, extra, s.amountSaved, s.totalAmount - s.amountSaved));

    //Middle Payment Periods
    for (var i = 1; i < numberOfPayments; i++) {
      if (s.totalAmount == getPaymentTotal(paymentList)) {
        break;
      }
      startDate = paymentList[i - 1].endDate.add(Duration(days: 1));

      if (cs.paymentFrequency > 1) {
        endDate = startDate.add(Duration(days: cs.paymentFrequency - 1));
      } else {
        endDate = startDate;
      }

      //before payment period
      if (getDateFromDateTime(DateTime.now()).isBefore(startDate)) {
        if (paymentList[i - 1].missed != 0) {
          feasiblePayment = cs.feasiblePayment + extra;
        } else {
          feasiblePayment = cs.feasiblePayment;
        }
        periodTotal = feasiblePayment;
        extra = 0;
      }
      //during payment period and after
      else if ((getDateFromDateTime(DateTime.now())
                  .isAfter(startDate.subtract(Duration(days: 1))) &&
              getDateFromDateTime(DateTime.now())
                  .isBefore(endDate.add(Duration(days: 1))) ||
          getDateFromDateTime(DateTime.now()).isAfter(endDate))) {
        if (paymentList[i - 1].missed != 0) {
          feasiblePayment = cs.feasiblePayment + extra;
        } else {
          feasiblePayment = cs.feasiblePayment;
        }
        periodTotal = getTransTotalForPeriod(startDate, endDate, transList);
        extra = feasiblePayment - periodTotal;
      }

      paymentList.add(Cpayment(
          getDateFromDateTime(startDate),
          getDateFromDateTime(endDate),
          feasiblePayment,
          periodTotal,
          extra,
          s.amountSaved,
          s.totalAmount - s.amountSaved));
    }

    //Last Payment Period
    if (s.totalAmount > getPaymentTotal(paymentList)) {
      startDate = paymentList.last.endDate.add(Duration(days: 1));
      endDate = goalDate;

      //before payment period
      if (getDateFromDateTime(DateTime.now()).isBefore(startDate)) {
        feasiblePayment = s.totalAmount - getPaymentTotal(paymentList);
        periodTotal = feasiblePayment;
        extra = 0;
      }
      //during payment period and after
      else if ((getDateFromDateTime(DateTime.now())
                  .isAfter(startDate.subtract(Duration(days: 1))) &&
              getDateFromDateTime(DateTime.now())
                  .isBefore(endDate.add(Duration(days: 1))) ||
          getDateFromDateTime(DateTime.now()).isAfter(endDate))) {
        feasiblePayment = s.totalAmount - getPaymentTotal(paymentList);
        periodTotal = getTransTotalForPeriod(startDate, endDate, transList);
        extra = feasiblePayment - periodTotal;
      }

      paymentList.add(Cpayment(
          getDateFromDateTime(startDate),
          getDateFromDateTime(goalDate),
          feasiblePayment,
          periodTotal,
          extra,
          s.amountSaved,
          s.totalAmount - s.amountSaved));
    }

    return paymentList;
  }

  getPeriodColor(startDate, endDate) {
    //before payment period
    if (getDateFromDateTime(DateTime.now()).isBefore(startDate)) {
      return Colors.redAccent[100];
    }
    //during payment period
    else if ((getDateFromDateTime(DateTime.now())
            .isAfter(startDate.subtract(Duration(days: 1))) &&
        getDateFromDateTime(DateTime.now())
            .isBefore(endDate.add(Duration(days: 1))))) {
      return Colors.amberAccent[100];
      //after payment period
    } else if (getDateFromDateTime(DateTime.now()).isAfter(endDate)) {
      return Colors.greenAccent[100];
    }
  }

  List<DataRow> buildRows(List<Cpayment> list) {
    var a = <DataRow>[];
    for (var i = 0; i < list.length; i++) {
      String startDate = list[i].startDate.toIso8601String().substring(0, 10);
      String endDate = list[i].endDate.toIso8601String().substring(0, 10);

      a.add(
        DataRow(
            color: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              return getPeriodColor(list[i].startDate, list[i].endDate);
            }),
            cells: <DataCell>[
              DataCell(Text(formatDate(
                      DateTime(
                          int.parse(startDate.substring(0, 4)),
                          int.parse(startDate.substring(5, 7)),
                          int.parse(startDate.substring(8, 10))),
                      [d, '/', m]) +
                  " - " +
                  formatDate(
                      DateTime(
                          int.parse(endDate.substring(0, 4)),
                          int.parse(endDate.substring(5, 7)),
                          int.parse(endDate.substring(8, 10))),
                      [d, '/', m]))),
              DataCell(Text("£" +
                  FlutterMoneyFormatter(amount: list[i].calculatedamount)
                      .output
                      .nonSymbol)),
              DataCell(Text("£" +
                  FlutterMoneyFormatter(amount: list[i].amount)
                      .output
                      .nonSymbol)),
              DataCell(Text("£" +
                  FlutterMoneyFormatter(amount: list[i].missed)
                      .output
                      .nonSymbol)),
            ]),
      );
    }
    return a;
  }

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
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            child: Text("Payment Plan Overview",
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
          ),

          FutureBuilder<CalculatedSaving>(
            future:
                DBProvider.db.getCalculateSavingByParentId(widget.saving.id),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                CalculatedSaving cs = snapshot.data;
                return Container(
                  margin:
                      EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                  height: 100,
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
                          "£" +
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
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

          //Payment Breakdown
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
            child: Text("Payment Plan Breakdown",
                style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3A3A3A))),
          ),

          //Card
          FutureBuilder<CalculatedSaving>(
            future:
                DBProvider.db.getCalculateSavingByParentId(widget.saving.id),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                CalculatedSaving cs = snapshot.data;
                List<Cpayment> paymentList = buildPaymentArray(cs);
                return Container(
                  margin:
                      EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
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
                  child: DataTable(
                    columnSpacing: 1,
                    columns: <DataColumn>[
                      DataColumn(
                        label: Text("Period",
                            style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3A3A3A))),
                      ),
                      DataColumn(
                          label: Text("Needed",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3A3A3A)))),
                      DataColumn(
                          label: Text("Paid",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3A3A3A)))),
                      DataColumn(
                          label: Text("Extra",
                              style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF3A3A3A)))),
                    ],
                    rows: buildRows(paymentList),
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
    );
  }
}

class Cpayment {
  DateTime startDate;
  DateTime endDate;
  double calculatedamount;
  double amount;
  double missed;
  double totalPaid;
  double totalRemaining;

  Cpayment(this.startDate, this.endDate, this.calculatedamount, this.amount,
      this.missed, this.totalPaid, this.totalRemaining);
}
