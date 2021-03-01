import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/SavingInfo.dart';
import 'package:money_tree/screens/SavingPlanner.dart';
import 'package:money_tree/screens/SavingsPage.dart';
import 'package:money_tree/screens/TransInputLayout.dart';
import 'package:page_transition/page_transition.dart';

class SavingsLayout extends StatefulWidget {
  final Saving saving;
  SavingsLayout({Key key, @required this.saving}) : super(key: key);
  @override
  _SavingsLayoutState createState() => _SavingsLayoutState();
}

class _SavingsLayoutState extends State<SavingsLayout> {
  int pageIndex;
  @override
  void initState() {
    pageIndex = 0;

    super.initState();
  }

  changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  pageSetter() {
    if (widget.saving.calculated == 1) {
      if (pageIndex == 0) {
        return SavingInfo(saving: widget.saving);
      } else if (pageIndex == 1) {
        return SavingsPlanner(saving: widget.saving);
      } else if (pageIndex == 2) {
        return SavingsPage(saving: widget.saving.id);
      }
    } else {
      if (pageIndex == 0) {
        return SavingInfo(saving: widget.saving);
      } else if (pageIndex == 1) {
        return SavingsPage(saving: widget.saving.id);
      }
    }
  }

  List<BubbleBottomBarItem> getNavigation() {
    if (widget.saving.calculated == 1) {
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
          title: Text("Planner"),
        ),
        BubbleBottomBarItem(
          backgroundColor: Colors.green,
          icon: Icon(
            Icons.trending_up,
            color: Colors.black,
          ),
          activeIcon: Icon(
            Icons.trending_up,
            color: Colors.green,
          ),
          title: Text("Transactions"),
        )
      ];
    } else {
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
          backgroundColor: Colors.green,
          icon: Icon(
            Icons.trending_up,
            color: Colors.black,
          ),
          activeIcon: Icon(
            Icons.trending_up,
            color: Colors.green,
          ),
          title: Text("Transactions"),
        )
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Savings Analysis",
            style: TextStyle(color: Colors.black),
          )),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.downToUp,
                  child: TransInput(
                    page: 2,
                    transaction: null,
                    saving: widget.saving,
                  )));
        },
        child: Icon(Icons.add),
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
