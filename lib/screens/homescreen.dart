import 'package:flutter/material.dart';
import 'package:money_tree/models/IncomeTransaction_model.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/screens/add_income.dart';
import 'package:money_tree/utils/Database.dart';
import '../models/card_model.dart';
import '../models/operations_model.dart';
import '../models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //current operation selected
  int current = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 8),
        child: ListView(
          physics: BouncingScrollPhysics(),
          children: <Widget>[
            // Appbar
            Container(
              margin: EdgeInsets.only(left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {},
                    child: Icon(Icons.menu, size: 30, color: Color(0xFF3A3A3A)),
                  ),
                  Container(
                    height: 59,
                    width: 59,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage("assets/images/Logo.png"),
                      ),
                    ),
                  )
                ],
              ),
            ),

            // Padding
            SizedBox(
              height: 25,
            ),

            // Welcome Message
            Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Good Morning',
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF3A3A3A))),
                  Text('Deep Harquissandas',
                      style: GoogleFonts.inter(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3A3A3A))),
                ],
              ),
            ),

            //Registered Cards
            Container(
              height: 215,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  padding: EdgeInsets.only(left: 16, right: 6),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return Container(
                        margin: EdgeInsets.only(right: 10, bottom: 8, top: 8),
                        height: 199,
                        width: 344,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 5,
                              spreadRadius: 1,
                              offset: Offset(0, 2.0),
                            )
                          ],
                          borderRadius: BorderRadius.circular(20),
                          color: Color(cards[index].cardBackground),
                        ),
                        child: Stack(
                          children: <Widget>[
                            Positioned(
                              top: -60,
                              right: 229,
                              child: Container(
                                height: 100,
                                width: 100,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(cards[index].cardForeground)),
                              ),
                            ),
                            Positioned(
                              bottom: -100,
                              right: 15,
                              child: Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(cards[index].cardForeground)),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              top: 48,
                              child: Text(
                                "CARD NUMBER",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              top: 65,
                              child: Text(
                                cards[index].cardNumber,
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Positioned(
                                right: 30,
                                top: 50,
                                child: Image.asset(
                                  cards[index].cardType,
                                  width: 40,
                                  height: 40,
                                )),
                            Positioned(
                              left: 20,
                              bottom: 45,
                              child: Text(
                                "CARDHOLDER NAME",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ),
                            Positioned(
                              left: 20,
                              bottom: 21,
                              child: Text(
                                cards[index].user,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                            Positioned(
                              left: 225,
                              bottom: 45,
                              child: Text(
                                "EXPIRY DATE",
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ),
                            Positioned(
                              left: 225,
                              bottom: 21,
                              child: Text(
                                cards[index].cardExpired,
                                style: GoogleFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ));
                  }),
            ),

            //Operations Text
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Text("Operations",
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ],
              ),
            ),

            //Operation Cards
            Container(
              height: 143,
              child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: datas.length,
                  padding: EdgeInsets.only(left: 16),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          current = index;
                        });

                        if (current.toString() == "0") {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: Duration(microseconds: 4),
                                  child: AddIncome()));
                        }
                      },
                      child: OperationCard(
                          operation: datas[index].operation,
                          selectedIcon: datas[index].selectedIcon,
                          unselectedIcon: datas[index].unselectedIcon,
                          isSelected: current == index,
                          context: this),
                    );
                  }),
            ),

            //Transaction Text
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
              child: Row(
                children: <Widget>[
                  Text("Transaction History",
                      style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black)),
                ],
              ),
            ),

            FutureBuilder<List<IncomeTransaction>>(
              future: DBProvider.db.getIncomeTransaction(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<IncomeTransaction>> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    padding: EdgeInsets.only(left: 16, right: 16),
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      IncomeTransaction it = snapshot.data[index];
                      return Container(
                        height: 91,
                        margin: EdgeInsets.only(bottom: 13),
                        padding: EdgeInsets.only(
                            left: 24, top: 12, bottom: 12, right: 22),
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
                                      it.name,
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black),
                                    ),
                                    Text(
                                      it.date,
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      it.category.toString(),
                                      style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      it.reoccur.toString(),
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
                                  it.amount.toString(),
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1B239F)),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OperationCard extends StatefulWidget {
  final String operation;
  final String selectedIcon;
  final String unselectedIcon;
  final bool isSelected;
  final _HomeScreenState context;

  OperationCard(
      {this.operation,
      this.selectedIcon,
      this.unselectedIcon,
      this.isSelected,
      this.context});

  @override
  _OperationCardState createState() => _OperationCardState();
}

class _OperationCardState extends State<OperationCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 16, top: 10, bottom: 10),
      width: 123,
      height: 123,
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 2.0),
            )
          ],
          borderRadius: BorderRadius.circular(15),
          color: widget.isSelected ? Color(0xFF1B239F) : Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
              widget.isSelected ? widget.selectedIcon : widget.unselectedIcon),
          SizedBox(
            height: 9,
          ),
          Text(
            widget.operation,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: widget.isSelected ? Colors.white : Color(0xFF1B239F),
            ),
          )
        ],
      ),
    );
  }
}
