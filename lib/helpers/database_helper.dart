import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:todo/models/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database _db;

  DatabaseHelper._instance();

  String tasksTable = 'task_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDate = 'date';
  String colPriority = 'priority';
  String colStatus = 'status';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDb();
    }
    return _db;
  }

  Future<Database> _initDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'toDo_app.db';
    final toDoListDb =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return toDoListDb;
  }

  void _createDb(Database db, int version) async {
    await db.execute(
        'CREATE TABLE $tasksTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDate TEXT, $colPriority TEXT, $colStatus INTEGER)');
  }

  Future<List<Map<String, dynamic>>> getTaskMapList() async {
    Database db = await this.db;
    final List<Map<String, dynamic>> result = await db.query(tasksTable);
    return result;
  }

  Future<List<Task>> getTaskList() async {
    final List<Map<String, dynamic>> taskMapList = await getTaskMapList();
    final List<Task> result = [];
    taskMapList.forEach((element) {
      result.add(Task.fromMap(element));
    });
    result.sort((taskA, taskB) => taskA.date.compareTo(taskB.date));
    return result;
  }

  Future<int> addTask(Task task) async {
    Database db = await this.db;
    final result = await db.insert(tasksTable, task.toMap());
    return result;
  }

  Future<int> updateTask(Task task) async {
    Database db = await this.db;
    final result = await db.update(tasksTable, task.toMap(),
        where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }

  Future<int> deleteTask(Task task) async {
    Database db = await this.db;
    final result =
        await db.delete(tasksTable, where: '$colId = ?', whereArgs: [task.id]);
    return result;
  }
}
