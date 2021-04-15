import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/screens/forms/add_bankcard.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:page_transition/page_transition.dart';

class CardOrganiser extends StatefulWidget {
  @override
  _CardOrganiserState createState() => _CardOrganiserState();
}

class _CardOrganiserState extends State<CardOrganiser> {
  List<BankCard> bclist = List<BankCard>();
  String currency = "";

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    DBProvider.db.getBankCards().then((value) {
      setState(() {
        bclist = value;
      });
    });
    super.initState();
  }

  updateBankCardOrder() {
    for (var i = 0; i < bclist.length; i++) {
      DBProvider.db.updateBankCardOrder(i, bclist[i].id);
    }

    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: PageTransitionType.leftToRight, child: Home()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "Organise Bank Cards",
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
              updateBankCardOrder();
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
                final BankCard item = bclist.removeAt(oldIndex);
                item.cardOrder = newIndex;
                bclist.insert(newIndex, item);
              },
            );
          },
          children: List.generate(
            bclist.length,
            (index) {
              BankCard bc = bclist[index];
              return GestureDetector(
                key: Key(bc.id.toString()),
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: AddBankCard(
                          bc: bc,
                        )),
                  );
                },
                child: Dismissible(
                  key: Key(bc.id.toString()),
                  confirmDismiss: (DismissDirection direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          key: Key(bc.id.toString()),
                          title: const Text("Delete Card"),
                          content: const Text(
                              "Deleting this card will also delete all transactions associated with this card. Do you wish to delete this card?"),
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
                    DBProvider.db.deleteBankCardById(bc.id);
                  },
                  child: Container(
                    key: Key(bc.id.toString()),
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
                                  bc.cardName,
                                  style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black),
                                ),
                                Text(
                                  formatDate(
                                      DateTime(
                                          int.parse(
                                              bc.expiryDate.substring(0, 4)),
                                          int.parse(
                                              bc.expiryDate.substring(5, 7)),
                                          int.parse(
                                              bc.expiryDate.substring(8, 10))),
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
                                currency +
                                    FlutterMoneyFormatter(amount: bc.amount)
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
