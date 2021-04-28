import 'package:bubble_bottom_bar/bubble_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/organisers/CardOrganiser.dart';
import 'package:money_tree/screens/homePages/Dashboard.dart';
import 'package:money_tree/screens/layoutManagers/TransInputLayout.dart';
import 'package:money_tree/screens/homePages/TreesPage.dart';
import 'package:money_tree/screens/organisers/SavingsOrganiser.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Dialogues.dart';
import 'package:page_transition/page_transition.dart';
import 'package:money_tree/screens/homePages/ExpensePage.dart';
import 'package:money_tree/screens/homePages/IncomePage.dart';

class Home extends StatefulWidget {
  final String prevPage;
  Home({Key key, this.prevPage}) : super(key: key);
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  dynamic totalAmount;
  TabController _tabController;
  int pageIndex;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    pageIndex = 0;
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
      if (widget.prevPage == "transInputLayout") {
        DBProvider.db.getIncomeCategories().then((value) {
          setState(() {
            totalAmount = value;
          });
        });
      }
      return Dashboard();
    } else if (pageIndex == 1) {
      return TreePage(
        tabController: _tabController,
      );
    } else if (pageIndex == 2) {
      return IncomePage();
    } else {
      return ExpensePage();
    }
  }

  //Redirect to Card Organiser
  openCardOrganiser() {
    Navigator.pop(context);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: CardOrganiser()));
  }

  //Redirec to Savings Organiser
  openSavingsOrganiser() {
    Navigator.pop(context);
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: SavingsOrganiser()));
  }

  buildSavingsTreeNavBar() {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Money Tree'),
              decoration: BoxDecoration(
                color: Colors.teal[300],
              ),
            ),
            ListTile(
                title: Text('Cards Organiser'),
                onTap: () {
                  openCardOrganiser();
                }),
            ListTile(
              title: Text('Saving Tree Organiser'),
              onTap: () {
                openSavingsOrganiser();
              },
            ),
            ListTile(
              title: Text('Currency Selector'),
              onTap: () {
                openCurrencySelector(context);
              },
            ),
            ListTile(
              title: Text('Notifications'),
              onTap: () {
                openNotificationSelection(
                    context, flutterLocalNotificationsPlugin);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  "Ongoing",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              ),
              Tab(
                child: Text(
                  "Complete",
                  style: TextStyle(color: Colors.black, fontSize: 16),
                ),
              )
            ],
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Money Tree",
            style: TextStyle(color: Colors.black),
          )),
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        key: Key("addTransButton"),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.downToUp,
                  child: TransInput(
                    page: 0,
                    transaction: null,
                    saving: null,
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
        items: buildPages(),
      ),
      body: pageSetter(),
    );
  }

  buildnormalNavBar() {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Money Tree'),
              decoration: BoxDecoration(
                color: Colors.teal[300],
              ),
            ),
            ListTile(
                title: Text('Cards Organiser'),
                onTap: () {
                  openCardOrganiser();
                }),
            ListTile(
              title: Text('Saving Tree Organiser'),
              onTap: () {
                openSavingsOrganiser();
              },
            ),
            ListTile(
              title: Text('Currency Selector'),
              onTap: () {
                openCurrencySelector(context);
              },
            ),
            ListTile(
              title: Text('Notifications'),
              onTap: () {
                openNotificationSelection(
                    context, flutterLocalNotificationsPlugin);
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
        key: Key("addTransButton"),
        onPressed: () {
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.downToUp,
                  child: TransInput(
                    page: 0,
                    transaction: null,
                    saving: null,
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
        items: buildPages(),
      ),
      body: pageSetter(),
    );
  }

  //Build Layout
  @override
  Widget build(BuildContext context) {
    return pageIndex == 1 ? buildSavingsTreeNavBar() : buildnormalNavBar();
  }

  //Buld Buttom Tabs
  buildPages() {
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
    ];
  }
}
