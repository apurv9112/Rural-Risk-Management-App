import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';

abstract class BaseDao {
  Future<Database> get db async => await AppDatabase.instance.database;
}
