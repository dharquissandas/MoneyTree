import 'dart:io';
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
      await db.execute('''
        CREATE TABLE intrans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date DATE,
          category INTEGER,
          amount FLOAT,
          reoccur BIT,
          bankcard Integer,
          FOREIGN KEY (bankcard) REFERENCES bankcards (id),
          FOREIGN KEY (category) REFERENCES incats (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE bankcards (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          cardnumber INTEGER,
          cardname TEXT,
          expirydate TEXT,
          amount FLOAT,
          cardtype TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE extrans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date DATE,
          category INTEGER,
          amount FLOAT,
          reoccur BIT,
          bankcard INTEGER,
          FOREIGN KEY (bankcard) REFERENCES bankcards (id),
          FOREIGN KEY (category) REFERENCES excats (id)
        )
      ''');
      await db.execute('''
        CREATE TABLE savings (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          savingsitem TEXT,
          amountsaved FLOAT,
          totalamount FLOAT,
          goaldate DATE
        )
      ''');
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
      await db.execute('''
        CREATE TABLE incats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
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
      await db.execute('''INSERT INTO excats (name) VALUES ('Savings')''');
    });
  }

  //Cards
  newCard(BankCard bankCard) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO bankcards (
        cardnumber, cardname, expirydate, amount, cardtype
      ) VALUES (?, ?, ?, ?, ?)
    ''', [
      bankCard.cardNumber,
      bankCard.cardName,
      bankCard.expiryDate,
      bankCard.amount,
      bankCard.cardType
    ]);

    return res;
  }

  Future<List<BankCard>> getBankCards() async {
    final db = await database;
    var res = await db.query("bankcards");
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

  getIncomeTransById(id) async {
    final db = await database;
    var res = await db.query("intrans", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? IncomeTransaction.fromMap(res.first) : Null;
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
        name, date, category, amount, bankcard, reoccur
      ) VALUES (?, ?, ?, ?, ?, ?)
    ''', [
      expenseTrans.name,
      expenseTrans.date,
      expenseTrans.category,
      expenseTrans.amount,
      expenseTrans.bankCard,
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

  getExpenseTransById(id) async {
    final db = await database;
    var res = await db.query("extrans", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? ExpenseTransaction.fromMap(res.first) : Null;
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
        savingsitem, amountsaved, totalamount, goaldate
      ) VALUES (?, ?, ?, ?)
    ''', [
      saving.savingsItem,
      saving.amountSaved,
      saving.totalAmount,
      saving.goalDate
    ]);

    return res;
  }

  Future<List<Saving>> getSavings() async {
    final db = await database;
    var res = await db.query("savings");
    List<Saving> savingslist =
        res.isNotEmpty ? res.map((e) => Saving.fromMap(e)).toList() : [];
    return savingslist;
  }

  Future<Saving> getSavingById(id) async {
    final db = await database;
    var res = await db.rawQuery('''
    SELECT * FROM savings WHERE id = ?
    ''', [id]);
    return res.isNotEmpty ? Saving.fromMap(res.first) : Null;
  }

  deleteSavingGoal(int id) async {
    final db = await database;
    getSavingsTransForSaving(id).then((savingtrans) async {
      for (var i = 0; i < savingtrans.length; i++) {
        deleteSavingTrans(savingtrans[i]);
      }
    });
    db.delete("savings", where: "id = ?", whereArgs: [id]);
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
      savingsItem: savingfirst.savingsItem,
      amountSaved: savingfirst.amountSaved + savingtrans.paymentamount,
      totalAmount: savingfirst.totalAmount,
      goalDate: savingfirst.goalDate,
    );

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
    print(id);
    var res = await db.rawQuery('''
    SELECT * FROM savingstransactions WHERE id = ?
    ''', [id]);
    print(res.first);
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
    });

    db.delete("savingstransactions", where: "id = ?", whereArgs: [st.id]);
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
      } else {
        endday = 28;
      }
    }

    return endday;
  }
}
