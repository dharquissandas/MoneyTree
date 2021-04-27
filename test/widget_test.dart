import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_tree/main.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/screens/forms/add_bankcard.dart';
import 'package:money_tree/screens/forms/add_income.dart';
import 'package:money_tree/screens/layoutManagers/HomeLayout.dart';
import 'package:money_tree/utils/Database/Database.dart';

void main() {
  testWidgets('Add Bank Card', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String cardName = "Deep Harquissandas";
    String cardNumber = "1234";
    String cardDate = DateTime.now().toString();
    String cardType = "Visa";
    String cardAmount = "15000.00";

    await tester.pumpWidget(MaterialApp(
      home: AddBankCard(
        bc: null,
      ),
    ));
    await tester.pump();

    await tester.enterText(find.byKey(Key("cardName")), cardName);
    await tester.enterText(find.byKey(Key("cardNumber")), cardNumber);
    await tester.enterText(find.byKey(Key("cardDate")), cardDate);
    await tester.tap(find.byKey(Key("cardType")));
    await tester.tap(find.byKey(Key(cardType)));
    await tester.showKeyboard(find.byKey(Key("cardAmount")));
    await tester.enterText(find.byKey(Key("cardAmount")), cardAmount);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text(cardName), findsOneWidget);
  });

  // testWidgets('Add Income Transaction', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   String cardName = "Deep Harquissandas";
  //   String cardNumber = "1234";
  //   String cardDate = DateTime.now().toString();
  //   String cardType = "Visa";
  //   String cardAmount = "15000.00";

  //   String incomeName = "Income";
  //   String incomeCard = "0";
  //   String incomeCategory = "0";
  //   String incomeAmount = "1000.00";

  //   //Add Bank Card
  //   await tester.pumpWidget(MaterialApp(
  //     home: Home(),
  //   ));
  //   await tester.pump();

  //   await tester.tap(find.byType(RaisedButton));
  //   await tester.pumpAndSettle();

  //   await tester.enterText(find.byKey(Key("cardName")), cardName);
  //   await tester.enterText(find.byKey(Key("cardNumber")), cardNumber);
  //   await tester.enterText(find.byKey(Key("cardDate")), cardDate);
  //   await tester.tap(find.byKey(Key("cardType")));
  //   await tester.tap(find.byKey(Key(cardType)));
  //   await tester.showKeyboard(find.byKey(Key("cardAmount")));
  //   await tester.enterText(find.byKey(Key("cardAmount")), cardAmount);

  //   await tester.tap(find.byType(FloatingActionButton));
  //   await tester.pump();

  //   await tester.tap(find.byType(FloatingActionButton));
  //   await tester.pumpAndSettle();

  //   await tester.enterText(find.byKey(Key("incomeName")), incomeName);

  //   await tester.tap(find.byKey(Key("incomeCard")));
  //   await tester.pump();
  //   await tester.tap(find.byKey(Key(incomeCard)));

  //   await tester.tap(find.byKey(Key("incomeType")));
  //   await tester.tap(find.byKey(Key(incomeCategory)));

  //   await tester.showKeyboard(find.byKey(Key("cardAmount")));
  //   await tester.enterText(find.byKey(Key("incomeAmount")), incomeAmount);

  //   await tester.tap(find.byType(FloatingActionButton));
  //   await tester.pump();

  //   expect(find.text(incomeName), findsOneWidget);
  // });

  testWidgets('Add Income Transaction', (WidgetTester tester) async {
    await tester.runAsync(() async {
      String cardName = "Deep Harquissandas";
      int cardNumber = 1234;
      String cardDate = DateTime.now().toString();
      String cardType = "Visa";
      double cardAmount = 15000.00;

      String incomeName = "Income";
      String incomeCard = "0";
      String incomeCategory = "0";
      String incomeAmount = "1000.00";

      BankCard test = new BankCard(
          cardName: cardName,
          cardNumber: cardNumber,
          expiryDate: cardDate,
          cardType: cardType,
          amount: cardAmount,
          cardOrder: 0);

      DBProvider.db.newCard(test);

      await tester.pumpWidget(MaterialApp(
        home: AddIncome(
          transaction: null,
        ),
      ));
      await tester.pump();

      await tester.enterText(find.byKey(Key("incomeName")), incomeName);

      await tester.tap(find.byKey(Key("incomeCard")));
      await tester.pump();
      await tester.tap(find.byKey(Key(incomeCard)));

      await tester.tap(find.byKey(Key("incomeType")));
      await tester.tap(find.byKey(Key(incomeCategory)));

      await tester.showKeyboard(find.byKey(Key("cardAmount")));
      await tester.enterText(find.byKey(Key("incomeAmount")), incomeAmount);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      expect(find.text(incomeName), findsOneWidget);
    });
  });

  testWidgets('Add Expense Transaction', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String cardName = "Deep Harquissandas";
    String cardNumber = "1234";
    String cardDate = DateTime.now().toString();
    String cardType = "Visa";
    String cardAmount = "15000.00";

    await tester.pumpWidget(MaterialApp(
      home: AddBankCard(
        bc: null,
      ),
    ));
    await tester.pump();

    await tester.enterText(find.byKey(Key("cardName")), cardName);
    await tester.enterText(find.byKey(Key("cardNumber")), cardNumber);
    await tester.enterText(find.byKey(Key("cardDate")), cardDate);
    await tester.tap(find.byKey(Key("cardType")));
    await tester.tap(find.byKey(Key(cardType)));
    await tester.showKeyboard(find.byKey(Key("cardAmount")));
    await tester.enterText(find.byKey(Key("cardAmount")), cardAmount);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text(cardName), findsOneWidget);
  });

  testWidgets('Add Savings Transaction', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    String cardName = "Deep Harquissandas";
    String cardNumber = "1234";
    String cardDate = DateTime.now().toString();
    String cardType = "Visa";
    String cardAmount = "15000.00";

    await tester.pumpWidget(MaterialApp(
      home: AddBankCard(
        bc: null,
      ),
    ));
    await tester.pump();

    await tester.enterText(find.byKey(Key("cardName")), cardName);
    await tester.enterText(find.byKey(Key("cardNumber")), cardNumber);
    await tester.enterText(find.byKey(Key("cardDate")), cardDate);
    await tester.tap(find.byKey(Key("cardType")));
    await tester.tap(find.byKey(Key(cardType)));
    await tester.showKeyboard(find.byKey(Key("cardAmount")));
    await tester.enterText(find.byKey(Key("cardAmount")), cardAmount);

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pump();

    expect(find.text(cardName), findsOneWidget);
  });
}
