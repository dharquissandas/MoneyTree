import 'package:currency_textfield/currency_textfield.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_tree/models/IncomeTransaction_model.dart';
import 'package:money_tree/utils/Database.dart';

class AddIncome extends StatefulWidget {
  @override
  _AddIncomeState createState() => _AddIncomeState();
}

class _AddIncomeState extends State<AddIncome> {
  List<DropdownMenuItem<int>> categoryList = [];

  void loadCategoryList() {
    categoryList = [];
    categoryList.add(new DropdownMenuItem(
      child: new Text("Allowance"),
      value: 0,
    ));
    categoryList.add(new DropdownMenuItem(
      child: new Text("Salary"),
      value: 1,
    ));
    categoryList.add(new DropdownMenuItem(
      child: new Text("Petty Cash"),
      value: 2,
    ));
    categoryList.add(new DropdownMenuItem(
      child: new Text("Bonus"),
      value: 3,
    ));
    categoryList.add(new DropdownMenuItem(
      child: new Text("Other"),
      value: 4,
    ));
  }

  String name;
  String date = DateTime.now().toIso8601String();
  int category = 0;
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
        date = picked.toIso8601String();
        _date.value = TextEditingValue(text: picked.toString());
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
    loadCategoryList();
    return DropdownButton(
      hint: new Text("Select Category"),
      items: categoryList,
      value: category,
      onChanged: (value) {
        setState(() {
          category = value;
        });
      },
      isExpanded: true,
    );
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
                              category: "account",
                              date: date,
                              amount: amount.toString(),
                              reoccur: "false");

                          DBProvider.db
                              .newIncomeTransaction(newIncomeTransaction);
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
