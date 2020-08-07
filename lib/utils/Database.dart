import 'dart:io';

import 'package:money_tree/models/IncomeCategorieModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart';
import 'package:money_tree/models/IncomeTransaction_model.dart';

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

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "moneyTree.db");
    return await openDatabase(path, version: 1, onOpen: (db) {},
        onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE intrans (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          date TEXT,
          category INTEGER,
          amount FLOAT,
          reoccur BIT,
          FOREIGN KEY (category) REFERENCES incats (id)
        )
      ''');
      await db.execute('''
        CREATE TABLE incats (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )
      ''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Allowance')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Salary')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Petty Cash')''');
      await db.execute('''INSERT INTO incats (name) VALUES ('Bonus')''');
    });
  }

  newIncomeTransaction(IncomeTransaction incomeTrans) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO intrans (
        name, date, category, amount, reoccur
      ) VALUES (?, ?, ?, ?, ?)
    ''', [
      incomeTrans.name,
      incomeTrans.date,
      incomeTrans.category,
      incomeTrans.amount,
      incomeTrans.reoccur
    ]);

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

  Future<List<IncomeCategory>> getIncomeCategories() async {
    final db = await database;
    var res = await db.query("incats");
    List<IncomeCategory> intranslist = res.isNotEmpty
        ? res.map((e) => IncomeCategory.fromMap(e)).toList()
        : [];
    return intranslist;
  }
}
