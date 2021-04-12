import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/CalculatedSavingsModel.dart';
import 'package:money_tree/models/CpaymentModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';

class PaymentTable extends StatelessWidget {
  final dynamic transList;
  final String currency;
  final Saving saving;
  final CalculatedSaving calculatedSaving;

  const PaymentTable(
      {Key key,
      this.transList,
      this.currency,
      this.saving,
      this.calculatedSaving})
      : super(key: key);

  // Display Table
  @override
  Widget build(BuildContext context) {
    return DataTable(
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
      rows: buildRows(buildPaymentArray()),
    );
  }

  //TABLE DISPLAY CODE

  //build display rows
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
              DataCell(Text(currency +
                  FlutterMoneyFormatter(amount: list[i].calculatedamount)
                      .output
                      .nonSymbol)),
              DataCell(Text(currency +
                  FlutterMoneyFormatter(amount: list[i].amount)
                      .output
                      .nonSymbol)),
              DataCell(Text(currency +
                  FlutterMoneyFormatter(amount: list[i].missed)
                      .output
                      .nonSymbol)),
            ]),
      );
    }
    return a;
  }

  //display appropriate colours for rows
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

  //TABLE DATA BUILD CODE

  //calculate payment data
  buildPaymentArray() {
    List<Cpayment> paymentList = List<Cpayment>();
    double feasiblePayment = calculatedSaving.feasiblePayment;
    DateTime startDate = buildDateFromString(saving.startDate);
    DateTime goalDate = buildDateFromString(calculatedSaving.goalDate);
    Duration duration = goalDate.difference(startDate);

    //First Payment Period
    int numberOfPayments = duration.inDays ~/ calculatedSaving.paymentFrequency;

    DateTime endDate;
    if (calculatedSaving.paymentFrequency > 1) {
      endDate =
          startDate.add(Duration(days: calculatedSaving.paymentFrequency - 1));
    } else {
      endDate = startDate;
    }

    double periodTotal = getTransTotalForPeriod(startDate, endDate, transList);
    double extra = calculatedSaving.feasiblePayment - periodTotal;
    paymentList.add(Cpayment(
        startDate,
        endDate,
        calculatedSaving.feasiblePayment,
        periodTotal,
        extra,
        saving.amountSaved,
        saving.totalAmount - saving.amountSaved));

    //Middle Payment Periods
    for (var i = 1; i < numberOfPayments; i++) {
      if (saving.totalAmount == getPaymentTotal(paymentList)) {
        break;
      }
      startDate = paymentList[i - 1].endDate.add(Duration(days: 1));

      if (calculatedSaving.paymentFrequency > 1) {
        endDate = startDate
            .add(Duration(days: calculatedSaving.paymentFrequency - 1));
      } else {
        endDate = startDate;
      }

      //before payment period
      if (getDateFromDateTime(DateTime.now()).isBefore(startDate)) {
        if (paymentList[i - 1].missed != 0) {
          feasiblePayment = calculatedSaving.feasiblePayment + extra;
        } else {
          feasiblePayment = calculatedSaving.feasiblePayment;
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
          feasiblePayment = calculatedSaving.feasiblePayment + extra;
        } else {
          feasiblePayment = calculatedSaving.feasiblePayment;
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
          saving.amountSaved,
          saving.totalAmount - saving.amountSaved));
    }

    //Last Payment Period
    if (saving.totalAmount > getPaymentTotal(paymentList)) {
      startDate = paymentList.last.endDate.add(Duration(days: 1));
      endDate = goalDate;

      //before payment period
      if (getDateFromDateTime(DateTime.now()).isBefore(startDate)) {
        feasiblePayment = saving.totalAmount - getPaymentTotal(paymentList);
        periodTotal = feasiblePayment;
        extra = 0;
      }
      //during payment period and after
      else if ((getDateFromDateTime(DateTime.now())
                  .isAfter(startDate.subtract(Duration(days: 1))) &&
              getDateFromDateTime(DateTime.now())
                  .isBefore(endDate.add(Duration(days: 1))) ||
          getDateFromDateTime(DateTime.now()).isAfter(endDate))) {
        feasiblePayment = saving.totalAmount - getPaymentTotal(paymentList);
        periodTotal = getTransTotalForPeriod(startDate, endDate, transList);
        extra = feasiblePayment - periodTotal;
      }

      paymentList.add(Cpayment(
          getDateFromDateTime(startDate),
          getDateFromDateTime(goalDate),
          feasiblePayment,
          periodTotal,
          extra,
          saving.amountSaved,
          saving.totalAmount - saving.amountSaved));
    }

    return paymentList;
  }

  //HELPER METHODS

  DateTime buildDateFromString(String stringDate) {
    return DateTime(
        int.parse(stringDate.substring(0, 4)),
        int.parse(stringDate.substring(5, 7)),
        int.parse(stringDate.substring(8, 10)));
  }

  DateTime getDateFromDateTime(DateTime dt) {
    String date = dt.toIso8601String().substring(0, 10);
    return DateTime.parse(date);
  }

  double getTransTotalForPeriod(
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

  double getPaymentTotal(List<Cpayment> paymentList) {
    double total = 0;
    for (var i = 0; i < paymentList.length; i++) {
      total = total + paymentList[i].amount;
    }
    return total;
  }
}
