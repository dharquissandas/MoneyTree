import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/screens/add_expense.dart';
import 'package:money_tree/screens/add_income.dart';
import 'package:money_tree/screens/add_saving.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';

import 'HomeLayout.dart';

class TransInput extends StatefulWidget {
  final int page;
  final dynamic transaction;
  final Saving saving;
  TransInput(
      {Key key,
      @required this.page,
      @required this.transaction,
      @required this.saving})
      : super(key: key);
  @override
  _TransInputState createState() => _TransInputState();
}

class _TransInputState extends State<TransInput> {
  int pageIndex;

  @override
  void initState() {
    super.initState();
    pageIndex = widget.page;
  }

  changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  int boolcheck(bool reoccur) {
    if (reoccur) {
      return 1;
    }
    return 0;
  }

  pageSetter() {
    if (pageIndex == 0) {
      return AddIncome(
        transaction: widget.transaction,
      );
    } else if (pageIndex == 1) {
      return AddExpense(transaction: widget.transaction);
    } else {
      if (widget.saving != null) {
        return AddSaving(
            transaction: widget.transaction, saving: widget.saving);
      } else {
        return AddSaving(transaction: widget.transaction, saving: null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (pageIndex == 0) {
            if (!incomeformkey.currentState.validate()) {
              return;
            }
            incomeformkey.currentState.save();

            if (incomeid == -1) {
              var newIncomeTransaction = IncomeTransaction(
                  name: incomename,
                  category: incomecategory,
                  date: incomedate,
                  amount: incomeamount,
                  bankCard: incomebankcard,
                  reoccur: boolcheck(incomereoccur));

              DBProvider.db.newIncomeTransaction(newIncomeTransaction);
            } else {
              var updatedIncomeTransaction = IncomeTransaction(
                  id: incomeid,
                  name: incomename,
                  category: incomecategory,
                  date: incomedate,
                  amount: incomeamount,
                  bankCard: incomebankcard,
                  reoccur: boolcheck(incomereoccur));

              DBProvider.db
                  .updateIncomeTransaction(incomeid, updatedIncomeTransaction);
            }
            incomeformkey.currentState.reset();
            incomebankcard = null;
            incomecategory = null;
          } else if (pageIndex == 1) {
            if (!expenseformkey.currentState.validate()) {
              return;
            }
            expenseformkey.currentState.save();
            if (expenseid == -1) {
              var newExpenseTransaction = ExpenseTransaction(
                  name: expensename,
                  category: expensecategory,
                  date: expensedate,
                  amount: expenseamount,
                  bankCard: expensebankcard,
                  reoccur: boolcheck(expensereoccur));

              DBProvider.db.newExpenseTransaction(newExpenseTransaction);
            } else {
              var updatedExpenseTransaction = ExpenseTransaction(
                  id: expenseid,
                  name: expensename,
                  category: expensecategory,
                  date: expensedate,
                  amount: expenseamount,
                  bankCard: expensebankcard,
                  reoccur: boolcheck(expensereoccur));

              DBProvider.db.updateExpenseTransaction(
                  expenseid, updatedExpenseTransaction);
            }
            expenseformkey.currentState.reset();
            expensebankcard = null;
            expensecategory = null;
          } else if (pageIndex == 2) {
            if (!savingpaymentkey.currentState.validate()) {
              return;
            }
            savingpaymentkey.currentState.save();

            if (savingid == -1) {
              print("here");
              var newSavingTransaction = SavingTransaction(
                  paymentaccount: paymentaccount,
                  paymentamount: paymentamount,
                  saving: saving,
                  paymentdate: paymentdate,
                  savingreoccur: boolcheck(savingreoccur));

              DBProvider.db.newSavingTransaction(newSavingTransaction);
            } else {
              print("There");
              var updatedSavingTransaction = SavingTransaction(
                  id: savingid,
                  paymentaccount: paymentaccount,
                  paymentamount: paymentamount,
                  saving: saving,
                  paymentdate: paymentdate,
                  savingreoccur: boolcheck(savingreoccur));

              DBProvider.db
                  .updateSavingTransaction(savingid, updatedSavingTransaction);
            }

            savingpaymentkey.currentState.reset();
            saving = null;
            paymentaccount = null;
            savingid = -1;
          }
          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(type: PageTransitionType.upToDown, child: Home()),
              (r) => false);
        },
        child: Icon(Icons.check),
        backgroundColor: Colors.teal[300],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: BubbleBottomBar(
        opacity: 0.2,
        backgroundColor: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        currentIndex: pageIndex,
        hasInk: true,
        inkColor: Colors.black12,
        hasNotch: true,
        fabLocation: BubbleBottomBarFabLocation.end,
        onTap: changePage,
        items: <BubbleBottomBarItem>[
          BubbleBottomBarItem(
            backgroundColor: Colors.green,
            icon: Icon(
              Icons.add,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.add,
              color: Colors.green,
            ),
            title: Text("Add Income"),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.red,
            icon: Icon(
              Icons.remove,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.remove,
              color: Colors.red,
            ),
            title: Text("Add Expense"),
          ),
          BubbleBottomBarItem(
            backgroundColor: Colors.teal,
            icon: Icon(
              Icons.account_balance_wallet,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.account_balance_wallet,
              color: Colors.teal,
            ),
            title: Text("Pay Saving"),
          ),
        ],
      ),
      body: pageSetter(),
    ));
  }
}
