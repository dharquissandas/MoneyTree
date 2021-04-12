import 'package:flutter/material.dart';
import 'package:money_tree/components/graphs/savingsAccumulationGraph.dart';
import 'package:money_tree/components/graphs/savingsTransactionsGraph.dart';
import 'package:money_tree/components/heading.dart';
import 'package:money_tree/components/savingsTreeCard.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';
import 'package:money_tree/utils/Database/Database.dart';
import 'package:money_tree/utils/Preferences.dart';

class SavingInfo extends StatefulWidget {
  final Saving saving;
  SavingInfo({Key key, @required this.saving}) : super(key: key);
  @override
  _SavingInfoState createState() => _SavingInfoState();
}

class _SavingInfoState extends State<SavingInfo> {
  String currency = "";

  @override
  void initState() {
    getCurrency().then((value) => currency = value);
    setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: <Widget>[
          // Savings Card
          FutureBuilder<Saving>(
            future: DBProvider.db.getSavingById(widget.saving.id),
            builder: (BuildContext context, AsyncSnapshot<Saving> snapshot) {
              if (snapshot.hasData) {
                Saving s = snapshot.data;
                return Container(
                    margin: EdgeInsets.all(16.0),
                    height: 260,
                    child: SavingsTreeCard(
                      currency: currency,
                      s: s,
                    ));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),

          // Savings Title
          Heading(
            title: "Saving Transaction Breakdown",
            fontSize: 20,
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 16),
          ),

          // Savings Accumulation Graph
          FutureBuilder<List<SavingTransaction>>(
            future: DBProvider.db.getSavingsTransForSaving(widget.saving.id),
            builder: (BuildContext context,
                AsyncSnapshot<List<SavingTransaction>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.length > 1) {
                  return savingsAccumulationGraph(
                      currency: currency,
                      saving: widget.saving,
                      tlist: snapshot.data);
                } else {
                  return Container();
                }
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),

          // Savings Transactions Graph
          FutureBuilder<List<SavingTransaction>>(
            future: DBProvider.db.getSavingsTransForSaving(widget.saving.id),
            builder: (BuildContext context,
                AsyncSnapshot<List<SavingTransaction>> snapshot) {
              if (snapshot.hasData) {
                return SavingsTransactionsGraph(
                    currency: currency,
                    saving: widget.saving,
                    tlist: snapshot.data);
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
