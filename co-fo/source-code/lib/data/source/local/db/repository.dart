import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uniapp/data/source/local/db/database.dart';
import 'package:uniapp/data/source/local/models/current_user.dart';

@lazySingleton
class UserProfileRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Future<void> save(CurrentUser currentUser) async {
    final db = await _dbHelper.database;
    await db.insert(
      'CurrentUser',
      currentUser.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CurrentUser?> getUserProfile() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'CurrentUser',
      limit: 1,
    );
    return result.isNotEmpty ? CurrentUser.fromJson(result.first) : null;
  }

  Future<void> updateUserAvatar({
    required String userId,
    required String avatar,
  }) async {
    final db = await _dbHelper.database;
    final updateFields = <String, dynamic>{};
    updateFields['avatar'] = avatar;
    await db.update(
      'CurrentUser',
      updateFields,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> deleteUserProfile() async {
    final db = await _dbHelper.database;
    await db.delete('CurrentUser');
  }
}
