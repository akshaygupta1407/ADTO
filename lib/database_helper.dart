import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper{

  static final _dbName = 'ADTODatabase.db';
      //'test1.db';
      //'myDatabase.db';
  static final _dbVersion =1;
  static final _tableName = 'myTable1';
  static final columnId = '_id';
  static final columnName= 'name';
  static final columnLatitude= 'Latitude';
  static final columnLongitude= 'Longitude';
  static final columnDistance = 'Distance';
  static final columnStartTime = 'StartTime';
  static final columnEndTime = 'EndTime';
  static final columnImageUrl = 'ImageUrl';

  //making it a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database?> get database async{
    if(_database!=null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path,_dbName);
    return await openDatabase(path,version: _dbVersion,onCreate: _onCreate);
  }
  // $columnName TEXT NOT NULL,
  Future _onCreate(Database db,int version) async{
        await db.execute(
          ''' 
          CREATE TABLE $_tableName 
          ( 
          $columnId INTEGER PRIMARY KEY,
          $columnLatitude TEXT NOT NULL,
          $columnLongitude TEXT NOT NULL,
          $columnDistance TEXT NOT NULL,
          $columnStartTime TEXT NOT NULL,
          $columnEndTime TEXT NOT NULL,
          $columnImageUrl TEXT NOT NULL
           )  
          '''
        );
        print("created");
  }
/*
$columnLatitude TEXT NOT NULL,
          $columnLongitude TEXT NOT NULL,
          $columnDistance TEXT NOT NULL,
          $columnStartTime TEXT NOT NULL,
          $columnEndTime TEXT NOT NULL,
          $columnImageUrl TEXT NOT NULL,
   */
  Future<int> insert(Map<String,dynamic> row) async{
      Database? db = await instance.database;
      return await db!.insert(_tableName, row);
  }

  Future<List<Map<String,dynamic>>> queryAll() async{
        Database? db = await instance.database;
        return await db!.query(_tableName);
  }

  Future<int> update(Map<String,dynamic> row)async{
    Database? db = await instance.database;
    int id = row[columnId];
    return await db!.update(_tableName, row,where: '$columnId = ?',whereArgs: [id]);
  }

  Future<int> delete() async{
    Database? db = await instance.database;
    return await db!.delete(_tableName);
  }
}
/*
int id
,where: '$columnId = ?',whereArgs: [id]
    */