import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Dog 클래스에 `toMap` 메서드를 추가하세요
class User {
  final int? id;
  final String fid;
  final String nickname;
  final String? created_at;

  User(
      {this.id,
      this.fid = '',
      this.nickname = 'nickname', // randomnickname
      this.created_at}); // timestamp

  // dog를 Map으로 변환합니다. key는 데이터베이스 컬럼 명과 동일해야 합니다.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fid': fid,
      'nickname': nickname,
      'created_at': created_at
    };
  }
}

class UserHelper {
  // 데이터베이스를 시작한다.
  static Future _openDb() async {
    final databasePath = await getDatabasesPath();
    String path = join(databasePath, 'my_database.db');

    final db = await openDatabase(
      path,
      version: 1,
      onConfigure: (Database db) => {},
      onCreate: _onCreate,
      onUpgrade: (Database db, int oldVersion, int newVersion) => {},
    );

    return db;
  }

  // 데이터베이스 테이블을 생성한다.
  static Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users ( 
        id INTEGER PRIMARY KEY,
        fid TEXT NOT NULL,
        nickname TEXT NOT NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // 데이터 불러오기
  static Future get_by_fid(String fid) async {
    final db = await _openDb();
    var list = await db.query(
      'users',
      where: 'fid = ?',
      whereArgs: [fid],
    );
    return list;
  }

  static Future get_all() async {
    final db = await _openDb();
    var list = await db.query('users');
    return list;
  }

  // 새로운 데이터를 추가한다.
  static Future<int> add(User user) async {
    final db = await _openDb();
    int Id = await db.insert(
      'users', // table name
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Id;
  }

  // 변경된 데이터를 업데이트한다.
  static Future update(User user) async {
    final db = await _openDb();
    await db.update(
      'users', // table name
      user.toMap(), // update user row data
      where: 'id = ?',
      whereArgs: [user.id],
    );
    return user;
  }

  // 데이터를 삭제한다.
  static Future<int> remove(int id) async {
    final db = await _openDb();
    await db.delete(
      'users', // table name
      where: 'id = ?',
      whereArgs: [id],
    );
    return id;
  }
}
