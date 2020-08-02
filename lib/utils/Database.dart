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

  initDB() async {
    return await openDatabase(join(await getDatabasesPath(), 'money_tree.db'),
        onCreate: (db, version) async {
      await db.execute('''
          CREATE TABLE incomeTransactions (
            name PRIMARYKEY TEXT, date TEXT, category TEXT, amount TEXT, reoccur TEXT
            )
        ''');
    }, version: 1);
  }

  newIncomeTransaction(IncomeTransaction incomeTrans) async {
    final db = await database;
    var res = await db.rawInsert('''
      INSERT INTO incomeTransactions (
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

  Future<dynamic> getIncomeTransaction() async {
    final db = await database;
    var res = await db.query("incomeTransactions");
    if (res.length == 0) {
      return null;
    } else {
      var resMap = res[0];
      return resMap.isNotEmpty ? resMap : Null;
    }
  }
}
