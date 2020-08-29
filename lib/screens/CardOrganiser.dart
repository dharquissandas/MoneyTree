import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/utils/Database.dart';

class CardOrganiser extends StatefulWidget {
  @override
  _CardOrganiserState createState() => _CardOrganiserState();
}

class _CardOrganiserState extends State<CardOrganiser> {
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
      body: Container(
        margin: EdgeInsets.only(top: 16),
        child: FutureBuilder<List<BankCard>>(
          future: DBProvider.db.getBankCards(),
          builder:
              (BuildContext context, AsyncSnapshot<List<BankCard>> snapshot) {
            if (snapshot.hasData) {
              return ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    ;
                  });
                },
                children: List.generate(snapshot.data.length, (index) {
                  BankCard bc = snapshot.data[index];
                  return Container(
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
                              "£" + bc.amount.toString(),
                              style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1B239F)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
    ;
  }
}
