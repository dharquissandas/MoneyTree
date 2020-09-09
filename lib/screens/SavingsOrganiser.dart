import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/add_saving_goal.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';

import 'HomeLayout.dart';

class SavingsOrganiser extends StatefulWidget {
  @override
  _SavingsOrganiserState createState() => _SavingsOrganiserState();
}

class _SavingsOrganiserState extends State<SavingsOrganiser> {
  List<Saving> slist = List<Saving>();

  @override
  void initState() {
    DBProvider.db.getSavings().then((value) {
      setState(() {
        slist = value;
      });
    });
    super.initState();
  }

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
              for (var i = 0; i < slist.length; i++) {
                DBProvider.db.updateSavingOrder(i, slist[i].id);
              }
              Navigator.pushAndRemoveUntil(
                  context,
                  PageTransition(
                      type: PageTransitionType.leftToRight, child: Home()),
                  (route) => false);
            }),
      ),
      body: Container(
        margin: EdgeInsets.only(top: 16, left: 8, right: 8),
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
              return GestureDetector(
                key: Key(s.id.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: AddSavingGoal(
                        s: s,
                      ),
                    ),
                  );
                },
                child: Dismissible(
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
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
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
                  child: Container(
                    key: Key(s.id.toString()),
                    height: 70,
                    margin: EdgeInsets.only(bottom: 13),
                    padding: EdgeInsets.only(
                        left: 24, top: 12, bottom: 12, right: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 5,
                          spreadRadius: 1,
                          offset: Offset(0, 2.0),
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
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
                                Text(
                                  formatDate(
                                      DateTime(
                                          int.parse(s.goalDate.substring(0, 4)),
                                          int.parse(s.goalDate.substring(5, 7)),
                                          int.parse(
                                              s.goalDate.substring(8, 10))),
                                      [d, ' ', M, ' ', yyyy]).toString(),
                                  style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                                "£" +
                                    FlutterMoneyFormatter(amount: s.totalAmount)
                                        .output
                                        .nonSymbol,
                                style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1B239F))),
                          ],
                        ),
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
