import 'package:floor/floor.dart';
import 'package:todo_list/database/typeConverters/DateTimeConverter.dart';

/// Classes/data for relational representation of a task, accessing tasks in database
@Entity(tableName: User.tableName)
class User {
  User(
      this.id, this.userId, this.userName);

  @ignore
  static const tableName = "user";

  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String userId;
  final String userName;

  User.create(this.userId, this.userName)
      : id = null;
}

@dao
abstract class UserDao {

  @Query("SELECT * FROM ${User.tableName} WHERE userId = :userId")
  Future<User?> getByUserId(String userId);

  @Query("DELETE FROM ${User.tableName} WHERE id = :id")
  Future<void> delete(int id);

  @insert
  Future<void> insertUser(User user);

}
