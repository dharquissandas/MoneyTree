import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/screens/forms/add_expense.dart';
import 'package:money_tree/screens/forms/add_income.dart';
import 'package:money_tree/screens/forms/add_saving.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:page_transition/page_transition.dart';

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

  //Page Changer
  changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  //Page Setter
  pageSetter() {
    if (pageIndex == 0) {
      if (widget.transaction is IncomeTransaction) {
        return AddIncome(transaction: widget.transaction);
      } else {
        return AddIncome(transaction: null);
      }
    } else if (pageIndex == 1) {
      if (widget.transaction is ExpenseTransaction) {
        return AddExpense(transaction: widget.transaction);
      } else {
        return AddExpense(transaction: null);
      }
    } else {
      if (widget.transaction is SavingTransaction) {
        if (widget.saving != null) {
          return AddSaving(
              transaction: widget.transaction, saving: widget.saving);
        } else {
          return AddSaving(transaction: widget.transaction, saving: null);
        }
      } else {
        return AddSaving(transaction: null, saving: null);
      }
    }
  }

  //Convert Boolean to Int for Database Storage
  int boolcheck(bool reoccur) {
    if (reoccur) {
      return 1;
    }
    return 0;
  }

  //Add / Update Income Transaction
  addorUpdateIncomeTransaction() {
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

      DBProvider.db.updateIncomeTransaction(incomeid, updatedIncomeTransaction);
    }
    incomeformkey.currentState.reset();
    incomebankcard = null;
    incomecategory = null;
  }

  //Add / Update Expense Transaction
  addorUpdateExpenseTransaction() {
    if (expenseid == -1) {
      var newExpenseTransaction = ExpenseTransaction(
          name: expensename,
          category: expensecategory,
          date: expensedate,
          amount: expenseamount,
          need: boolcheck(need),
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
          need: boolcheck(need),
          bankCard: expensebankcard,
          reoccur: boolcheck(expensereoccur));

      DBProvider.db
          .updateExpenseTransaction(expenseid, updatedExpenseTransaction);
    }
    expenseformkey.currentState.reset();
    expensebankcard = null;
    expensecategory = null;
  }

  //Add / Update Saving Transaction
  addorUpdateSavingTransaction() {
    if (savingid == -1) {
      var newSavingTransaction = SavingTransaction(
          paymentaccount: paymentaccount,
          paymentamount: paymentamount,
          saving: saving,
          paymentdate: paymentdate,
          savingreoccur: boolcheck(savingreoccur));

      DBProvider.db.newSavingTransaction(newSavingTransaction);
    } else {
      var updatedSavingTransaction = SavingTransaction(
          id: savingid,
          paymentaccount: paymentaccount,
          paymentamount: paymentamount,
          saving: saving,
          paymentdate: paymentdate,
          savingreoccur: boolcheck(savingreoccur));

      DBProvider.db.updateSavingTransaction(savingid, updatedSavingTransaction);
    }

    savingpaymentkey.currentState.reset();
    savingid = -1;
    saving = null;
    paymentaccount = null;
  }

  //Build Navigation Bar
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
            addorUpdateIncomeTransaction();
          } else if (pageIndex == 1) {
            if (!expenseformkey.currentState.validate()) {
              return;
            }
            expenseformkey.currentState.save();
            addorUpdateExpenseTransaction();
          } else if (pageIndex == 2) {
            if (!savingpaymentkey.currentState.validate()) {
              return;
            }
            savingpaymentkey.currentState.save();
            addorUpdateSavingTransaction();
          }

          Navigator.pushAndRemoveUntil(
              context,
              PageTransition(
                  type: PageTransitionType.leftToRight, child: Home()),
              (route) => false);
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
          items: buildNavigation()),
      body: pageSetter(),
    ));
  }

  //Build Navigation Options
  buildNavigation() {
    return <BubbleBottomBarItem>[
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
    ];
  }
}
