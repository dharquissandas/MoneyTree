import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/IncomeCategorieModel.dart';
import 'package:money_tree/models/IncomeTransaction_model.dart';
import 'package:money_tree/screens/homescreen.dart';
import 'package:money_tree/utils/Database.dart';
import 'package:page_transition/page_transition.dart';

class AddIncome extends StatefulWidget {
  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  int boolcheck(bool reoccur) {
    if (reoccur) {
      return 1;
    }
    return 0;
  }

  String name;
  String date = DateTime.now().toIso8601String();
  int category;
  double amount;
  bool reoccur = false;

  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController _date = new TextEditingController();
  var controller = CurrencyTextFieldController(
      rightSymbol: "£", decimalSymbol: ".", thousandSymbol: ",");

  Future<Null> _buildDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1901, 1),
        lastDate: DateTime.now());

    if (picked != null) {
      setState(() {
        date = picked.toIso8601String().substring(0, 10);
        _date.value =
            TextEditingValue(text: picked.toString().substring(0, 10));
      });
    }
  }

  Widget buildName() {
    return TextFormField(
      autocorrect: true,
      decoration: InputDecoration(labelText: "Income Source"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Source is Required';
        }
      },
      onSaved: (String value) {
        name = value;
      },
    );
  }

  Widget buildDate() {
    return GestureDetector(
      onTap: () => _buildDate(context),
      child: AbsorbPointer(
        child: TextFormField(
          controller: _date,
          keyboardType: TextInputType.datetime,
          decoration: InputDecoration(
            labelText: 'Date of Income',
          ),
        ),
      ),
    );
  }

  Widget buildCategory() {
    return FutureBuilder<List<IncomeCategory>>(
        future: DBProvider.db.getIncomeCategories(),
        builder: (BuildContext context,
            AsyncSnapshot<List<IncomeCategory>> snapshot) {
          if (snapshot.hasData) {
            return DropdownButton<int>(
              hint: new Text("Select Category"),
              value: category,
              items: snapshot.data
                  .map((cat) => DropdownMenuItem<int>(
                      child: Text(cat.name), value: cat.id))
                  .toList(),
              onChanged: (int value) {
                setState(() {
                  category = value;
                });
              },
              isExpanded: true,
            );
          } else {
            return Container();
          }
        });
  }

  Widget buildAmount() {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: "Income Amount"),
      validator: (value) {
        if (value.isEmpty) {
          return 'Amount is Required';
        }
      },
      onSaved: (value) {
        amount = controller.doubleValue;
      },
    );
  }

  Widget buildReoccur() {
    return CheckboxListTile(
      value: reoccur,
      onChanged: (value) {
        setState(() {
          reoccur = value;
        });
      },
      title: new Text("Recurring Income"),
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: EdgeInsets.only(top: 8),
          child: ListView(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 16, right: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(Icons.arrow_back_ios,
                          size: 30, color: Color(0xFF3A3A3A)),
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
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Add Income',
                        style: GoogleFonts.inter(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A3A3A))),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 16, right: 16),
                child: Form(
                  key: formkey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      buildName(),
                      buildCategory(),
                      buildDate(),
                      buildAmount(),
                      buildReoccur(),
                      SizedBox(
                        height: 100,
                      ),
                      RaisedButton(
                        onPressed: () {
                          if (!formkey.currentState.validate()) {
                            return;
                          }
                          formkey.currentState.save();
                          var newIncomeTransaction = IncomeTransaction(
                              name: name,
                              category: category,
                              date: date.substring(
                                0,
                              ),
                              amount: amount,
                              reoccur: boolcheck(reoccur));

                          DBProvider.db
                              .newIncomeTransaction(newIncomeTransaction);

                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.fade,
                                  duration: Duration(microseconds: 4),
                                  child: HomeScreen()));
                        },
                        child: Text(
                          'Add Income',
                          style: TextStyle(color: Colors.blue, fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
