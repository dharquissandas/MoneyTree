import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/components/backgroundCard.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:page_transition/page_transition.dart';

class SavingsOrganiser extends StatefulWidget {
  @override
  _SavingsOrganiserState createState() => _SavingsOrganiserState();
}

class _SavingsOrganiserState extends State<SavingsOrganiser> {
  List<Saving> slist = List<Saving>();
  String currency = "";

  //Create Savings List
  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    DBProvider.db.getSavings().then((value) {
      setState(() {
        slist = value;
      });
    });
    super.initState();
  }

  //Update Savings List
  updateSavingsOrder() {
    for (var i = 0; i < slist.length; i++) {
      DBProvider.db.updateSavingOrder(i, slist[i].id);
    }
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.leftToRight, child: Home()),
        (route) => false);
  }

  //Build Dismissable List To Reorder & Dismiss Savings.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Organise Saving Trees",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: FloatingActionButton.extended(
            icon: Icon(Icons.check),
            backgroundColor: Colors.teal[300],
            elevation: 20,
            label: Text("Confirm"),
            onPressed: () {
              updateSavingsOrder();
            }),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16),
        child: ReorderableListView(
          onReorder: (oldIndex, newIndex) {
            setState(
              () {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final Saving item = slist.removeAt(oldIndex);
                item.savingOrder = newIndex;
                slist.insert(newIndex, item);
              },
            );
          },
          children: List.generate(
            slist.length,
            (index) {
              Saving s = slist[index];
              return Dismissible(
                key: Key(s.id.toString()),
                confirmDismiss: (DismissDirection direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        key: Key(s.id.toString()),
                        title: const Text("Delete Saving Tree"),
                        content: const Text(
                            "Deleting this saving will also delete all transactions associated with this saving. Do you wish to delete this saving?"),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("DELETE")),
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text("CANCEL"),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  DBProvider.db.deleteSavingGoal(s.id);
                },
                child: BackgroundCard(
                  key: Key(s.id.toString()),
                  height: 70,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.menu,
                                color: Colors.grey,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  s.savingsItem,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                                currency +
                                    FlutterMoneyFormatter(amount: s.totalAmount)
                                        .output
                                        .nonSymbol,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B239F))),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
