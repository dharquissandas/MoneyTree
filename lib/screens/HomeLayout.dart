import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:money_tree/screens/CardOrganiser.dart';
import 'package:money_tree/screens/Dashboard.dart';
import 'package:money_tree/screens/TransInputLayout.dart';
import 'package:money_tree/screens/TreesPage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:money_tree/screens/ExpensePage.dart';
import 'package:money_tree/screens/IncomePage.dart';
import 'SavingsOrganiser.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex;

  @override
  void initState() {
    super.initState();
    pageIndex = 0;
  }

  changePage(int index) {
    setState(() {
      pageIndex = index;
    });
  }

  pageSetter() {
    if (pageIndex == 0) {
      return Dashboard();
    } else if (pageIndex == 1) {
      return TreePage();
    } else if (pageIndex == 2) {
      return IncomePage();
    } else {
      return ExpensePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Deep Harquissandas'),
              decoration: BoxDecoration(
                color: Colors.teal[300],
              ),
            ),
            ListTile(
                title: Text('Cards Organiser'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: CardOrganiser()));
                }),
            ListTile(
              title: Text('Saving Tree Organiser'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: SavingsOrganiser()));
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Money Tree",
            style: TextStyle(color: Colors.black),
          )),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.downToUp,
                  child: TransInput(page: 0, transaction: null)));
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
        items: <BubbleBottomBarItem>[
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
              Icons.filter_vintage,
              color: Colors.black,
            ),
            activeIcon: Icon(
              Icons.filter_vintage,
              color: Colors.teal[300],
            ),
            title: Text("Tree"),
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
            title: Text("Income"),
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
            title: Text("Expense"),
          ),
        ],
      ),
      body: pageSetter(),
    );
  }
}
