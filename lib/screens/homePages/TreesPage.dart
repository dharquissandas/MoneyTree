import 'package:flutter/material.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/components/savingsTreeCard.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/screens/forms/add_saving_goal.dart';
import 'package:money_tree/screens/layoutManagers/SavingsLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Messages.dart';
import 'package:money_tree/utils/Preferences.dart';
import 'package:page_transition/page_transition.dart';

class TreePage extends StatefulWidget {
  @override
  _TreePageState createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  String currency = "";

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    super.initState();
  }

  // onClick redirect to Savings Analysis
  savingsRedirect(Saving s) {
    DBProvider.db.getSavingsTransForSaving(s.id).then((value) {
      if (value.length > 0) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: SavingsLayout(
                  saving: s,
                )));
      } else {
        final snackbar = SnackBar(
            duration: Duration(seconds: 1), content: Text("No Savings Made"));
        Scaffold.of(context).showSnackBar(snackbar);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScrollConfiguration(
        behavior: ScrollBehavior(),
        child: ListView(
          children: <Widget>[
            // Saving Tree Heading
            Heading(
              title: "My Saving Goals",
              fontSize: 22,
              padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 4),
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: Colors.teal[300])),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: AddSavingGoal()));
                },
                color: Colors.teal[300],
                textColor: Colors.white,
                child: Text("Add Saving Goal".toUpperCase(),
                    style: TextStyle(fontSize: 12)),
              ),
            ),

            // Listview of Savings
            FutureBuilder<List<Saving>>(
                future: DBProvider.db.getSavings(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Saving>> snapshot) {
                  if (snapshot.hasData && snapshot.data.isNotEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(left: 16, right: 6),
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          Saving s = snapshot.data[index];
                          return Container(
                            margin:
                                EdgeInsets.only(right: 10, bottom: 8, top: 8),
                            child: InkWell(
                              onTap: () {
                                savingsRedirect(s);
                              },
                              child: SavingsTreeCard(
                                currency: currency,
                                s: s,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  } else {
                    return buildSavingsChecker();
                  }
                })
          ],
        ),
      ),
    );
  }
}
