import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/budgetPages/BudgetInfo.dart';
import 'package:money_tree/screens/budgetPages/BudgetPlanner.dart';
import 'package:money_tree/screens/budgetPages/BudgetSavings.dart';
import 'package:money_tree/screens/budgetPages/BudgetTransactions.dart';
import 'package:money_tree/screens/forms/add_budget.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:page_transition/page_transition.dart';

class BudgetLayout extends StatefulWidget {
  final BankCard card;
  BudgetLayout({Key key, @required this.card}) : super(key: key);
  @override
  _BudgetLayoutState createState() => _BudgetLayoutState();
}

class _BudgetLayoutState extends State<BudgetLayout> {
  int pageIndex;
  dynamic currMonthBudget = Null;

  //Set Page Index and get Month Budget
  @override
  void initState() {
    pageIndex = 0;

    DBProvider.db.getBudget(widget.card.id).then((value) {
      setState(() {
        currMonthBudget = value;
      });
    });
    super.initState();
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
      return BudgetInfo(bankCard: widget.card);
    } else if (pageIndex == 1) {
      return BudgetPlanner(bankCard: widget.card, monthBudget: currMonthBudget);
    } else if (pageIndex == 2) {
      return BudgetTransactions(bankCard: widget.card);
    } else if (pageIndex == 3) {
      return BudgetSavings(
        bankCard: widget.card,
      );
    }
  }

  //Define Navigation Options
  List<BubbleBottomBarItem> getNavigation() {
    return <BubbleBottomBarItem>[
      BubbleBottomBarItem(
        backgroundColor: Colors.teal[300],
        icon: Icon(
          Icons.dashboard,
          color: Colors.black,
        ),
        activeIcon: Icon(
          Icons.dashboard,
          color: Colors.teal[300],
        ),
        title: Text("Dashboard"),
      ),
      BubbleBottomBarItem(
        backgroundColor: Colors.teal[300],
        icon: Icon(
          Icons.assessment,
          color: Colors.black,
        ),
        activeIcon: Icon(
          Icons.assessment,
          color: Colors.teal[300],
        ),
        title: Text("Budget"),
      ),
      BubbleBottomBarItem(
        backgroundColor: Colors.red,
        icon: Icon(
          Icons.trending_down,
          color: Colors.black,
        ),
        activeIcon: Icon(
          Icons.trending_down,
          color: Colors.red,
        ),
        title: Text("Transactions"),
      ),
      BubbleBottomBarItem(
        backgroundColor: Colors.teal[300],
        icon: Icon(
          Icons.account_balance_wallet,
          color: Colors.black,
        ),
        activeIcon: Icon(
          Icons.account_balance_wallet,
          color: Colors.teal[300],
        ),
        title: Text("Savings"),
      )
    ];
  }

  //Build Bottom Bar
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Budget Analysis",
            style: TextStyle(color: Colors.black),
          )),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.downToUp,
              child: AddBudget(
                bankCard: widget.card,
                budget: currMonthBudget,
              ),
            ),
          );
        },
        child: currMonthBudget == Null ? Icon(Icons.add) : Icon(Icons.create),
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
        items: getNavigation(),
      ),
      body: pageSetter(),
    );
  }
}
