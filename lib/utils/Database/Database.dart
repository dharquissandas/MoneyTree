import 'dart:io';
import 'package:money_tree/models/BudgetModel.dart';
import 'package:money_tree/models/CalculatedSavingsModel.dart';
import 'package:money_tree/models/CategoryModel.dart';
import 'package:money_tree/models/ExpenseTransactionModel.dart';
import 'package:money_tree/models/IncomeTransactionModel.dart';
import 'package:money_tree/models/BankCardModel.dart';
import 'package:money_tree/models/SavingsModel.dart';
import 'package:money_tree/models/SavingsTransactionModel.dart';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();
  static Database _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDB();
    return _database;
  }

  //Init
  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "moneyTree.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      //intrans
      await db.execute('''
        CREATE TABLE intrans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date DATE,
          category INTEGER,
          amount FLOAT,
          reoccur BIT,
          bankcard INTEGER,
          FOREIGN KEY (bankcard) REFERENCES bankcards (id),
          FOREIGN KEY (category) REFERENCES incats (id)
        )
      ''');
      //bankcards
      await db.execute('''
        CREATE TABLE bankcards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cardorder INTEGER,
          cardnumber INTEGER,
          cardname TEXT,
          expirydate TEXT,
          amount FLOAT,
          cardtype TEXT
        )
      ''');
      //extrans
      await db.execute('''
        CREATE TABLE extrans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date DATE, 
          category INTEGER,
          amount FLOAT,
          reoccur BIT,
          need BIT,
          bankcard INTEGER,
          FOREIGN KEY (bankcard) REFERENCES bankcards (id),
          FOREIGN KEY (category) REFERENCES excats (id)
        )
      ''');
      //savings
      await db.execute('''
        CREATE TABLE savings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          savingorder INTEGER,
          savingsitem TEXT,
          amountsaved FLOAT,
          totalamount FLOAT,
          startdate DATE,
          description TEXT,
          calculated INTEGER
        )
      ''');
      //calculatedsavings
      await db.execute('''
        CREATE TABLE calculatedsavings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          parentid INTEGER,
          goaldate DATE,
          feasiblepayment FLOAT,
          paymentfrequency INTEGER,
          savingtype INTEGER
        )
      ''');
      //savingstransactions
      await db.execute('''
        CREATE TABLE savingstransactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          paymentaccount INTEGER,
          paymentamount FLOAT,
          saving INTEGER,
          paymentdate DATE,
          savingreoccur BIT,
          FOREIGN KEY (paymentaccount) REFERENCES bankcards (id),
          FOREIGN KEY (saving) REFERENCES savings (id)
        )
      ''');
      //incats
      await db.execute('''
        CREATE TABLE incats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
      //cardbudgets
      await db.execute('''
        CREATE TABLE cardbudgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          bankcard INTEGER,
          month DATE,
          need INTEGER,
          want INTEGER,
          save INTEGER,
          foodamount FLOAT,
          sociallifeamount FLOAT,
          selfdevamount FLOAT,
          cultureamount FLOAT,
          householdamount FLOAT,
          apperalamount FLOAT,
          beautyamount FLOAT,
          healthamount FLOAT,
          educationamount FLOAT,
          giftamount FLOAT,
          techamount FLOAT,
          FOREIGN KEY (bankcard) REFERENCES bankcards (id)
        )
      ''');
      //exacts
      await db.execute('''
        CREATE TABLE excats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Allowance')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Salary')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Petty Cash')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Bonus')''');

      await db.execute('''INSERT INTO excats (name) VALUES ('Food')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Social Life')''');
      await db
          .execute('''INSERT INTO excats (name) VALUES ('Self-Development')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Culture')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Household')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Apparel')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Beauty')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Health')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Education')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Gift')''');
      await db.execute('''INSERT INTO excats (name) VALUES ('Technology')''');
    });
  }

  //Cards
  newCard(BankCard bankCard) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO bankcards (
        cardnumber, cardorder, cardname, expirydate, amount, cardtype
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      bankCard.cardNumber,
      bankCard.cardOrder,
      bankCard.cardName,
      bankCard.expiryDate,
      bankCard.amount,
      bankCard.cardType
    ]);

    return res;
  }

  Future<List<BankCard>> getBankCards() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM bankcards ORDER BY cardorder
    ''');
    List<BankCard> bankcardslist =
        res.isNotEmpty ? res.map((e) => BankCard.fromMap(e)).toList() : [];
    return bankcardslist;
  }

  Future<BankCard> getBankCardById(int id) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM bankcards WHERE id = ?
    ''', [id]);
    return res.isNotEmpty ? BankCard.fromMap(res.first) : Null;
  }

  updateBankCard(id, bankCard) async {
    final db = await database;
    var res = await db.update("bankcards", bankCard.toMap(),
        where: "id = ?", whereArgs: [id]);
    return res;
  }

  updateBankCardOrder(cardorder, id) async {
    final db = await database;
    var res = await db.rawUpdate('''
      UPDATE bankcards SET cardorder = ? WHERE id = ?
    ''', [cardorder, id]);
    return res;
  }

  deleteBankCardById(id) async {
    final db = await database;
    db.delete("intrans", where: "bankcard = ?", whereArgs: [id]);
    db.delete("extrans", where: "bankcard = ?", whereArgs: [id]);
    db.delete("savingstransactions",
        where: "paymentaccount = ?", whereArgs: [id]);

    db.delete("bankcards", where: "id = ?", whereArgs: [id]);
  }

  //Income
  newIncomeTransaction(IncomeTransaction incomeTrans) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO intrans (
        name, date, category, amount, bankcard, reoccur
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      incomeTrans.name,
      incomeTrans.date,
      incomeTrans.category,
      incomeTrans.amount,
      incomeTrans.bankCard,
      incomeTrans.reoccur
    ]);

    var card = await db
        .query("bankcards", where: "id = ?", whereArgs: [incomeTrans.bankCard]);
    BankCard cardfirst = card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

    BankCard updatedcard = BankCard(
      id: incomeTrans.bankCard,
      cardNumber: cardfirst.cardNumber,
      cardName: cardfirst.cardName,
      expiryDate: cardfirst.expiryDate,
      amount: cardfirst.amount + incomeTrans.amount,
      cardType: cardfirst.cardType,
    );

    res = await db.update("bankcards", updatedcard.toMap(),
        where: "id = ?", whereArgs: [incomeTrans.bankCard]);

    return res;
  }

  Future<List<IncomeTransaction>> getIncomeTransaction() async {
    final db = await database;
    var res = await db.query("intrans");
    List<IncomeTransaction> intranslist = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];
    return intranslist;
  }

  Future<List<IncomeTransaction>> getIncomeTransactionbyCardandMonth(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<IncomeTransaction> intranslist = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];
    return intranslist;
  }

  Future<List<IncomeTransaction>> getIncomeTransactionListbyMonth(
      DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE date >= ? AND date <= ? ORDER BY date DESC
    ''', [startDate, endDate]);
    List<IncomeTransaction> intranslist = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];
    return intranslist;
  }

  Future<List<IncomeTransaction>> getIncomeTransactionbyDate(date) async {
    String curdate = date.toString().substring(0, 10);
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE date = ?
    ''', [curdate]);
    List<IncomeTransaction> intranslist = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];
    return intranslist;
  }

  Future<double> getcurrentMonthIncome() async {
    int month = DateTime.now().month;
    int year = DateTime.now().year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE `date` >= ? and `date` <= ?
    ''', [startDate, endDate]);
    List<IncomeTransaction> amounts = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  Future<double> getMonthIncome(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<IncomeTransaction> amounts = res.isNotEmpty
        ? res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  getIncomeTransById(id) async {
    final db = await database;
    var res = await db.query("intrans", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? IncomeTransaction.fromMap(res.first) : Null;
  }

  getFirstIncomeTransaction() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans ORDER BY date ASC Limit 1
    ''');

    dynamic firstres = res.isNotEmpty
        ? DateTime.parse(IncomeTransaction.fromMap(res.first).date)
        : Null;

    return firstres;
  }

  updateIncomeTransaction(int id, IncomeTransaction it) async {
    final db = await database;
    var res;

    getIncomeTransById(id).then((oldit) async {
      res = await db
          .update("intrans", it.toMap(), where: "id = ?", whereArgs: [id]);

      var card = await db
          .query("bankcards", where: "id = ?", whereArgs: [it.bankCard]);

      BankCard cardfirst =
          card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

      if (oldit.bankCard == it.bankCard) {
        BankCard updatedcard = BankCard(
          id: it.bankCard,
          cardNumber: cardfirst.cardNumber,
          cardName: cardfirst.cardName,
          expiryDate: cardfirst.expiryDate,
          amount: (cardfirst.amount - oldit.amount) + it.amount,
          cardType: cardfirst.cardType,
        );
        res = await db.update("bankcards", updatedcard.toMap(),
            where: "id = ?", whereArgs: [it.bankCard]);
      } else {
        deleteIncomeTransaction(oldit);
        newIncomeTransaction(it);
      }
    });

    return res;
  }

  deleteIncomeTransaction(IncomeTransaction t) async {
    final db = await database;
    getBankCardById(t.bankCard).then((bc) {
      BankCard updatedcard = BankCard(
        id: bc.id,
        cardNumber: bc.cardNumber,
        cardName: bc.cardName,
        expiryDate: bc.expiryDate,
        amount: bc.amount - t.amount,
        cardType: bc.cardType,
      );
      updateBankCard(bc.id, updatedcard);
    });
    db.delete("intrans", where: "id = ?", whereArgs: [t.id]);
  }

  //Expenses
  newExpenseTransaction(ExpenseTransaction expenseTrans) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO extrans (
        name, date, category, amount, bankcard, need, reoccur
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      expenseTrans.name,
      expenseTrans.date,
      expenseTrans.category,
      expenseTrans.amount,
      expenseTrans.bankCard,
      expenseTrans.need,
      expenseTrans.reoccur
    ]);

    var card = await db.query("bankcards",
        where: "id = ?", whereArgs: [expenseTrans.bankCard]);
    BankCard cardfirst = card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

    BankCard updatedcard = BankCard(
      id: expenseTrans.bankCard,
      cardNumber: cardfirst.cardNumber,
      cardName: cardfirst.cardName,
      expiryDate: cardfirst.expiryDate,
      amount: cardfirst.amount - expenseTrans.amount,
      cardType: cardfirst.cardType,
    );

    res = await db.update("bankcards", updatedcard.toMap(),
        where: "id = ?", whereArgs: [expenseTrans.bankCard]);

    return res;
  }

  Future<List<ExpenseTransaction>> getExpenseTransaction() async {
    final db = await database;
    var res = await db.query("extrans");
    List<ExpenseTransaction> extranslist = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return extranslist;
  }

  Future<List<ExpenseTransaction>> getExpenseTransactionbyCardandMonth(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> extranslist = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return extranslist;
  }

  Future<List<ExpenseTransaction>> getExpenseTransactionbyDate(date) async {
    String curdate = date.toString().substring(0, 10);
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE date = ?
    ''', [curdate]);
    List<ExpenseTransaction> extranslist = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return extranslist;
  }

  Future<List<ExpenseTransaction>> getExpenseTransactionListbyMonth(
      DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE date >= ? AND date <= ? ORDER BY date DESC
    ''', [startDate, endDate]);
    List<ExpenseTransaction> extranslist = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return extranslist;
  }

  Future<double> getcurrentMonthExpense() async {
    int month = DateTime.now().month;
    int year = DateTime.now().year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE `date` >= ? and `date` <= ?
    ''', [startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  Future<double> getMonthExpense(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  Future<Map<String, double>> getMonthExpenseCategoryList(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double food = 0;
    double sociallife = 0;
    double selfdev = 0;
    double culture = 0;
    double household = 0;
    double apperal = 0;
    double beauty = 0;
    double health = 0;
    double education = 0;
    double gift = 0;
    double tech = 0;
    double total = 0;
    for (var i = 0; i < amounts.length; i++) {
      if (amounts[i].category == 1) {
        food = food + amounts[i].amount;
      } else if (amounts[i].category == 2) {
        sociallife = sociallife + amounts[i].amount;
      } else if (amounts[i].category == 3) {
        selfdev = selfdev + amounts[i].amount;
      } else if (amounts[i].category == 4) {
        culture = culture + amounts[i].amount;
      } else if (amounts[i].category == 5) {
        household = household + amounts[i].amount;
      } else if (amounts[i].category == 6) {
        apperal = apperal + amounts[i].amount;
      } else if (amounts[i].category == 7) {
        beauty = beauty + amounts[i].amount;
      } else if (amounts[i].category == 8) {
        health = health + amounts[i].amount;
      } else if (amounts[i].category == 9) {
        education = education + amounts[i].amount;
      } else if (amounts[i].category == 10) {
        gift = gift + amounts[i].amount;
      } else {
        tech = tech + amounts[i].amount;
      }
      total = total + amounts[i].amount;
    }

    Map<String, double> finalmap = {
      'Food': food,
      'Social Life': sociallife,
      'Self-Development': selfdev,
      'Culture': culture,
      'Household': household,
      'Apperal': apperal,
      'Beauty': beauty,
      'Health': health,
      'Education': education,
      'Gift': gift,
      'Technology': tech,
      'Total': total
    };
    return finalmap;
  }

  Future<double> getMonthNeedExpense(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND need == 1 AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  Future<List<ExpenseTransaction>> getMonthNeedExpenseTransactions(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND need == 1 AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return amounts;
  }

  Future<double> getMonthWantExpense(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND need == 0 AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].amount;
    }
    return amount;
  }

  Future<List<ExpenseTransaction>> getMonthWantExpenseTransactions(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND need == 0 AND date >= ? AND date <= ?
    ''', [card, startDate, endDate]);
    List<ExpenseTransaction> amounts = res.isNotEmpty
        ? res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];
    return amounts;
  }

  getExpenseTransById(id) async {
    final db = await database;
    var res = await db.query("extrans", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? ExpenseTransaction.fromMap(res.first) : Null;
  }

  getFirstExpenseTransaction() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans ORDER BY date ASC Limit 1
    ''');

    dynamic firstres = res.isNotEmpty
        ? DateTime.parse(ExpenseTransaction.fromMap(res.first).date)
        : Null;

    return firstres;
  }

  updateExpenseTransaction(int id, ExpenseTransaction et) async {
    final db = await database;
    var res;

    getExpenseTransById(id).then((oldet) async {
      res = await db
          .update("extrans", et.toMap(), where: "id = ?", whereArgs: [id]);

      var card = await db
          .query("bankcards", where: "id = ?", whereArgs: [et.bankCard]);
      BankCard cardfirst =
          card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

      if (oldet.bankCard == et.bankCard) {
        BankCard updatedcard = BankCard(
          id: et.bankCard,
          cardNumber: cardfirst.cardNumber,
          cardName: cardfirst.cardName,
          expiryDate: cardfirst.expiryDate,
          amount: (cardfirst.amount + oldet.amount) - et.amount,
          cardType: cardfirst.cardType,
        );

        res = await db.update("bankcards", updatedcard.toMap(),
            where: "id = ?", whereArgs: [et.bankCard]);
      } else {
        deleteExpenseTransaction(oldet);
        newExpenseTransaction(et);
      }
    });

    return res;
  }

  deleteExpenseTransaction(ExpenseTransaction t) async {
    final db = await database;
    getBankCardById(t.bankCard).then((bc) {
      BankCard updatedcard = BankCard(
        id: bc.id,
        cardNumber: bc.cardNumber,
        cardName: bc.cardName,
        expiryDate: bc.expiryDate,
        amount: bc.amount + t.amount,
        cardType: bc.cardType,
      );
      updateBankCard(bc.id, updatedcard);
    });
    db.delete("extrans", where: "id = ?", whereArgs: [t.id]);
  }

  //Savings
  newSaving(Saving saving) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO savings (
        savingorder, savingsitem, amountsaved, totalamount, startdate, description, calculated
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      saving.savingOrder,
      saving.savingsItem,
      saving.amountSaved,
      saving.totalAmount,
      saving.startDate,
      saving.description,
      saving.calculated
    ]);
    return res;
  }

  Future<List<Saving>> getSavings() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savings ORDER BY savingorder DESC
    ''');
    List<Saving> savingslist =
        res.isNotEmpty ? res.map((e) => Saving.fromMap(e)).toList() : [];
    return savingslist;
  }

  Future<List<Saving>> getCompleteSavings() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savings WHERE totalamount == amountsaved ORDER BY savingorder DESC
    ''');
    List<Saving> savingslist =
        res.isNotEmpty ? res.map((e) => Saving.fromMap(e)).toList() : [];
    return savingslist;
  }

  Future<List<Saving>> getOngoingSavings() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savings WHERE totalamount != amountsaved ORDER BY savingorder
    ''');
    List<Saving> savingslist =
        res.isNotEmpty ? res.map((e) => Saving.fromMap(e)).toList() : [];
    return savingslist;
  }

  dynamic getSavingById(id) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM savings WHERE id = ?
    ''', [id]);
    return res.isNotEmpty ? Saving.fromMap(res.first) : Null;
  }

  updateSavingOrder(savingorder, id) async {
    final db = await database;
    var res = await db.rawUpdate('''
      UPDATE savings SET savingorder = ? WHERE id = ?
    ''', [savingorder, id]);
    return res;
  }

  updateSaving(id, saving) async {
    final db = await database;
    var res = await db
        .update("savings", saving.toMap(), where: "id = ?", whereArgs: [id]);
    return res;
  }

  deleteSavingGoal(int id) async {
    final db = await database;
    getSavingsTransForSaving(id).then((savingtrans) async {
      for (var i = 0; i < savingtrans.length; i++) {
        deleteSavingTrans(savingtrans[i]);
      }
    }).then((value) {
      db.delete("savings", where: "id = ?", whereArgs: [id]);
    });
  }

  //Calculated Savings
  newCalculatedSaving(CalculatedSaving cs) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO calculatedsavings (
          goalDate,
          parentid,
          feasiblepayment,
          paymentfrequency,
          savingtype
      ) VALUES (?, ?, ?, ?, ?)
    ''', [
      cs.goalDate,
      cs.parentId,
      cs.feasiblePayment,
      cs.paymentFrequency,
      cs.savingType
    ]);

    return res;
  }

  Future<CalculatedSaving> getCalculateSavingByParentId(int pid) async {
    final db = await database;
    var res = await db
        .query("calculatedsavings", where: "parentid = ?", whereArgs: [pid]);
    return res.isNotEmpty ? CalculatedSaving.fromMap(res.first) : Null;
  }

  //Savings Transactions
  newSavingTransaction(SavingTransaction savingtrans) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO savingstransactions (
        paymentaccount, paymentamount, saving, paymentdate, savingreoccur
      ) VALUES (?, ?, ?, ?, ?)
    ''', [
      savingtrans.paymentaccount,
      savingtrans.paymentamount,
      savingtrans.saving,
      savingtrans.paymentdate,
      savingtrans.savingreoccur
    ]);

    var saving = await db
        .query("savings", where: "id = ?", whereArgs: [savingtrans.saving]);
    Saving savingfirst =
        saving.isNotEmpty ? Saving.fromMap(saving.first) : Null;

    Saving updatedsaving = Saving(
        id: savingtrans.saving,
        savingOrder: savingfirst.savingOrder,
        savingsItem: savingfirst.savingsItem,
        amountSaved: savingfirst.amountSaved + savingtrans.paymentamount,
        totalAmount: savingfirst.totalAmount,
        startDate: savingfirst.startDate,
        description: savingfirst.description,
        calculated: savingfirst.calculated);

    res = await db.update("savings", updatedsaving.toMap(),
        where: "id = ?", whereArgs: [savingtrans.saving]);

    var card = await db.query("bankcards",
        where: "id = ?", whereArgs: [savingtrans.paymentaccount]);
    BankCard cardfirst = card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

    BankCard updatedcard = BankCard(
      id: savingtrans.paymentaccount,
      cardNumber: cardfirst.cardNumber,
      cardName: cardfirst.cardName,
      expiryDate: cardfirst.expiryDate,
      amount: cardfirst.amount - savingtrans.paymentamount,
      cardType: cardfirst.cardType,
    );

    res = await db.update("bankcards", updatedcard.toMap(),
        where: "id = ?", whereArgs: [savingtrans.paymentaccount]);

    return res;
  }

  Future<SavingTransaction> getSavingTransById(id) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM savingstransactions WHERE id = ?
    ''', [id]);
    return res.isNotEmpty ? SavingTransaction.fromMap(res.first) : Null;
  }

  Future<List<SavingTransaction>> getSavingsTransForSaving(saving) async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE saving = ?
    ''', [saving]);
    List<SavingTransaction> savingslist = res.isNotEmpty
        ? res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];
    return savingslist;
  }

  Future<double> getcurrentMonthSaving() async {
    int month = DateTime.now().month;
    int year = DateTime.now().year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE `paymentdate` >= ? and `paymentdate` <= ?
    ''', [startDate, endDate]);
    List<SavingTransaction> amounts = res.isNotEmpty
        ? res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].paymentamount;
    }
    return amount;
  }

  getFirstSavingsTransaction() async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM extrans ORDER BY date ASC Limit 1
    ''');

    dynamic firstres = res.isNotEmpty
        ? DateTime.parse(ExpenseTransaction.fromMap(res.first).date)
        : Null;

    return firstres;
  }

  updateSavingTransaction(int id, SavingTransaction st) async {
    final db = await database;
    var res;

    getSavingTransById(id).then((oldst) async {
      res = await db.update("savingstransactions", st.toMap(),
          where: "id = ?", whereArgs: [id]);

      var card = await db
          .query("bankcards", where: "id = ?", whereArgs: [st.paymentaccount]);
      BankCard cardfirst =
          card.isNotEmpty ? BankCard.fromMap(card.first) : Null;

      if (oldst.paymentaccount == st.paymentaccount) {
        BankCard updatedcard = BankCard(
          id: st.paymentaccount,
          cardNumber: cardfirst.cardNumber,
          cardName: cardfirst.cardName,
          expiryDate: cardfirst.expiryDate,
          amount: (cardfirst.amount - oldst.paymentamount) + st.paymentamount,
          cardType: cardfirst.cardType,
        );
        res = await db.update("bankcards", updatedcard.toMap(),
            where: "id = ?", whereArgs: [st.paymentaccount]);
      } else {
        deleteSavingTrans(oldst);
        newSavingTransaction(st);
      }

      getSavingById(st.saving).then((value) {
        Saving updatedSaving = Saving(
            id: st.saving,
            savingOrder: value.savingOrder,
            savingsItem: value.savingsItem,
            amountSaved:
                (value.amountSaved - oldst.paymentamount) + st.paymentamount,
            totalAmount: value.totalAmount,
            startDate: value.startDate,
            description: value.description,
            calculated: value.calculated);

        updateSaving(id, updatedSaving);
      });
    });

    return res;
  }

  deleteSavingTrans(SavingTransaction st) async {
    final db = await database;

    getBankCardById(st.paymentaccount).then((bc) async {
      BankCard updatedcard = BankCard(
        id: st.paymentaccount,
        cardNumber: bc.cardNumber,
        cardName: bc.cardName,
        expiryDate: bc.expiryDate,
        amount: bc.amount + st.paymentamount,
        cardType: bc.cardType,
      );

      updateBankCard(bc.id, updatedcard);
    }).then((value) {
      getSavingById(st.saving).then((s) async {
        if (s != Null) {
          Saving updatedSaving = Saving(
              id: s.id,
              savingOrder: s.savingOrder,
              savingsItem: s.savingsItem,
              amountSaved: s.amountSaved - st.paymentamount,
              totalAmount: s.totalAmount,
              startDate: s.startDate,
              description: s.description,
              calculated: s.calculated);

          updateSaving(s.id, updatedSaving);
        }
      }).then((value) {
        db.delete("savingstransactions", where: "id = ?", whereArgs: [st.id]);
      });
    });
  }

  Future<double> getSavingTotalForTimeFrame(
      savingsid, startDate, endDate) async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE `paymentdate` >= ? and `paymentdate` <= ?
    and `saving` = ?''', [startDate, endDate, savingsid]);
    List<SavingTransaction> amounts = res.isNotEmpty
        ? res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].paymentamount;
    }
    return amount;
  }

  Future<double> getMonthSavingTrans(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
    ''', [card, startDate, endDate]);
    List<SavingTransaction> amounts = res.isNotEmpty
        ? res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    double amount = 0;
    for (var i = 0; i < amounts.length; i++) {
      amount = amount + amounts[i].paymentamount;
    }
    return amount;
  }

  Future<List<SavingTransaction>> getMonthSavingTransList(
      int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
    ''', [card, startDate, endDate]);
    List<SavingTransaction> amounts = res.isNotEmpty
        ? res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];
    return amounts;
  }

  //Bankcard Budgets
  newBudget(Budget budget) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO cardbudgets (
        bankcard, month, need, want, save, foodamount, sociallifeamount, selfdevamount, cultureamount, householdamount, apperalamount, beautyamount, healthamount, educationamount, giftamount, techamount
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''', [
      budget.bankcard,
      budget.month,
      budget.need,
      budget.want,
      budget.save,
      budget.foodamount,
      budget.sociallifeamount,
      budget.selfdevamount,
      budget.cultureamount,
      budget.householdamount,
      budget.apperalamount,
      budget.beautyamount,
      budget.healthamount,
      budget.educationamount,
      budget.giftamount,
      budget.techamount
    ]);

    return res;
  }

  getBudget(int card) async {
    String currMonth =
        DateTime(DateTime.now().year, DateTime.now().month).toIso8601String();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM cardbudgets WHERE `bankcard` >= ? and `month` == ?
    ''', [card, currMonth]);
    return res.isNotEmpty ? Budget.fromMap(res.first) : Null;
  }

  getMonthBudget(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String startDate = strYear + "-" + strMonth + "-01";
    String endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM cardbudgets WHERE bankcard = ? AND month >= ? AND month <= ?
    ''', [card, startDate, endDate]);
    return res.isNotEmpty ? Budget.fromMap(res.first) : Null;
  }

  updateBudget(Budget budget, int oldBudgetId) async {
    final db = await database;
    var res = await db.update("cardbudgets", budget.toMap(),
        where: "id = ?", whereArgs: [oldBudgetId]);
    return res;
  }

  //Categories
  Future<List<Category>> getIncomeCategories() async {
    final db = await database;
    var res = await db.query("incats");
    List<Category> intranslist =
        res.isNotEmpty ? res.map((e) => Category.fromMap(e)).toList() : [];
    return intranslist;
  }

  Future<List<Category>> getExpenseCategories() async {
    final db = await database;
    var res = await db.query("excats");
    List<Category> extranslist =
        res.isNotEmpty ? res.map((e) => Category.fromMap(e)).toList() : [];
    return extranslist;
  }

  //Extras
  Future<double> getTotalAmount() async {
    final db = await database;
    var res = await db.query("bankcards");
    List<BankCard> bankcardslist =
        res.isNotEmpty ? res.map((e) => BankCard.fromMap(e)).toList() : [];

    double totalAmount = 0;
    for (var i = 0; i < bankcardslist.length; i++) {
      totalAmount = totalAmount + bankcardslist[i].amount;
    }
    return totalAmount;
  }

  getFirstTransactionforCard(int card) async {
    final db = await database;
    var res = await db.rawQuery('''
      SELECT * FROM intrans WHERE bankcard = ? ORDER BY date ASC Limit 1
    ''', [card]);

    var res2 = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? ORDER BY date ASC Limit 1
    ''', [card]);

    dynamic firstres = res.isNotEmpty
        ? DateTime.parse(IncomeTransaction.fromMap(res.first).date)
        : Null;

    dynamic secondres = res2.isNotEmpty
        ? DateTime.parse(ExpenseTransaction.fromMap(res2.first).date)
        : Null;

    if (firstres == Null && secondres != Null) return secondres;
    if (firstres != Null && secondres == Null) return firstres;

    if (firstres != Null && secondres != Null) {
      DateTime a = firstres as DateTime;
      DateTime b = secondres as DateTime;
      if (a.isBefore(b)) {
        return a;
      } else {
        return b;
      }
    } else {
      return DateTime(DateTime.now().year, DateTime.now().month);
    }
  }

  getCardPieData(int card, DateTime givenmonth) async {
    double income;
    double expense;
    double saving;
    getMonthIncome(card, givenmonth).then((value) => income = value);
    getMonthExpense(card, givenmonth).then((value) => expense = value);
    getMonthSavingTrans(card, givenmonth).then((value) => saving = value);
    return [income, expense, saving, income + expense + saving];
  }

  getLineGraphIncomeData(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String w1startDate = strYear + "-" + strMonth + "-01";
    String w1endDate = strYear + "-" + strMonth + "-07";

    String w2startDate = strYear + "-" + strMonth + "-08";
    String w2endDate = strYear + "-" + strMonth + "-14";

    String w3startDate = strYear + "-" + strMonth + "-15";
    String w3endDate = strYear + "-" + strMonth + "-21";

    String w4startDate = strYear + "-" + strMonth + "-22";
    String w4endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var w1res = await db.rawQuery('''
      SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, w1startDate, w1endDate]);

    var w2res = await db.rawQuery('''
    SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w2startDate, w2endDate]);

    var w3res = await db.rawQuery('''
    SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w3startDate, w3endDate]);

    var w4res = await db.rawQuery('''
    SELECT * FROM intrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w4startDate, w4endDate]);

    List<IncomeTransaction> w1 = w1res.isNotEmpty
        ? w1res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    List<IncomeTransaction> w2 = w2res.isNotEmpty
        ? w2res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    List<IncomeTransaction> w3 = w3res.isNotEmpty
        ? w3res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    List<IncomeTransaction> w4 = w4res.isNotEmpty
        ? w4res.map((e) => IncomeTransaction.fromMap(e)).toList()
        : [];

    double w1avg = 0;
    double w2avg = 0;
    double w3avg = 0;
    double w4avg = 0;

    if (w1.length != 0) {
      w1avg = avg(w1);
    }
    if (w2.length != 0) {
      w2avg = avg(w2);
    }
    if (w3.length != 0) {
      w3avg = avg(w3);
    }
    if (w4.length != 0) {
      w4avg = avg(w4);
    }

    return [w1avg, w2avg, w3avg, w4avg];
  }

  getLineGraphExpenseData(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String w1startDate = strYear + "-" + strMonth + "-01";
    String w1endDate = strYear + "-" + strMonth + "-07";

    String w2startDate = strYear + "-" + strMonth + "-08";
    String w2endDate = strYear + "-" + strMonth + "-14";

    String w3startDate = strYear + "-" + strMonth + "-15";
    String w3endDate = strYear + "-" + strMonth + "-21";

    String w4startDate = strYear + "-" + strMonth + "-22";
    String w4endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var w1res = await db.rawQuery('''
      SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
    ''', [card, w1startDate, w1endDate]);

    var w2res = await db.rawQuery('''
    SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w2startDate, w2endDate]);

    var w3res = await db.rawQuery('''
    SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w3startDate, w3endDate]);

    var w4res = await db.rawQuery('''
    SELECT * FROM extrans WHERE bankcard = ? AND date >= ? AND date <= ?
  ''', [card, w4startDate, w4endDate]);

    List<ExpenseTransaction> w1 = w1res.isNotEmpty
        ? w1res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    List<ExpenseTransaction> w2 = w2res.isNotEmpty
        ? w2res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    List<ExpenseTransaction> w3 = w3res.isNotEmpty
        ? w3res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    List<ExpenseTransaction> w4 = w4res.isNotEmpty
        ? w4res.map((e) => ExpenseTransaction.fromMap(e)).toList()
        : [];

    double w1avg = 0;
    double w2avg = 0;
    double w3avg = 0;
    double w4avg = 0;

    if (w1.length != 0) {
      w1avg = avg(w1);
    }
    if (w2.length != 0) {
      w2avg = avg(w2);
    }
    if (w3.length != 0) {
      w3avg = avg(w3);
    }
    if (w4.length != 0) {
      w4avg = avg(w4);
    }

    return [w1avg, w2avg, w3avg, w4avg];
  }

  getLineGraphSavingsData(int card, DateTime givenmonth) async {
    int month = givenmonth.month;
    int year = givenmonth.year;

    bool leap = leapYear(year);
    String strMonth;
    int endday = endDayCalc(leap);

    String strYear = DateTime.now().year.toString();

    if (month < 10) {
      strMonth = '0' + month.toString();
    } else {
      strMonth = month.toString();
    }

    String w1startDate = strYear + "-" + strMonth + "-01";
    String w1endDate = strYear + "-" + strMonth + "-07";

    String w2startDate = strYear + "-" + strMonth + "-08";
    String w2endDate = strYear + "-" + strMonth + "-14";

    String w3startDate = strYear + "-" + strMonth + "-15";
    String w3endDate = strYear + "-" + strMonth + "-21";

    String w4startDate = strYear + "-" + strMonth + "-22";
    String w4endDate = strYear + "-" + strMonth + "-" + endday.toString();

    final db = await database;
    var w1res = await db.rawQuery('''
      SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
    ''', [card, w1startDate, w1endDate]);

    var w2res = await db.rawQuery('''
    SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
  ''', [card, w2startDate, w2endDate]);

    var w3res = await db.rawQuery('''
    SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
  ''', [card, w3startDate, w3endDate]);

    var w4res = await db.rawQuery('''
    SELECT * FROM savingstransactions WHERE paymentaccount = ? AND paymentdate >= ? AND paymentdate <= ?
  ''', [card, w4startDate, w4endDate]);

    List<SavingTransaction> w1 = w1res.isNotEmpty
        ? w1res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    List<SavingTransaction> w2 = w2res.isNotEmpty
        ? w2res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    List<SavingTransaction> w3 = w3res.isNotEmpty
        ? w3res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    List<SavingTransaction> w4 = w4res.isNotEmpty
        ? w4res.map((e) => SavingTransaction.fromMap(e)).toList()
        : [];

    double w1avg = 0;
    double w2avg = 0;
    double w3avg = 0;
    double w4avg = 0;

    if (w1.length != 0) {
      w1avg = savingAvg(w1);
    }
    if (w2.length != 0) {
      w2avg = savingAvg(w2);
    }
    if (w3.length != 0) {
      w3avg = savingAvg(w3);
    }
    if (w4.length != 0) {
      w4avg = savingAvg(w4);
    }

    return [w1avg, w2avg, w3avg, w4avg];
  }

  //Utils
  bool leapYear(year) {
    bool leap = false;

    if (year % 4 == 0) {
      if (year % 100 == 0) {
        if (year % 400 == 0) {
          leap = true;
        } else {
          leap = false;
        }
      } else {
        leap = true;
      }
    } else {
      leap = false;
    }

    return leap;
  }

  int endDayCalc(leap) {
    int month = DateTime.now().month;
    int endday = 30;

    if (month == 1 ||
        month == 3 ||
        month == 5 ||
        month == 7 ||
        month == 8 ||
        month == 10 ||
        month == 12) {
      endday = 31;
    } else {
      if (month == 2 && leap) {
        endday = 29;
      }
      if (month == 2 && !leap) {
        endday = 28;
      }
    }

    return endday;
  }

  double avg(list) {
    double avg = 0;
    for (int i = 0; i < list.length; i++) {
      avg = avg + list[i].amount;
    }
    avg = avg / list.length;
    return avg;
  }

  double savingAvg(list) {
    double avg = 0;
    for (int i = 0; i < list.length; i++) {
      avg = avg + list[i].paymentamount;
    }
    avg = avg / list.length;
    return avg;
  }
}
