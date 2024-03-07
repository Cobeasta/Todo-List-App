


import 'package:injectable/injectable.dart';
import 'package:todo_list/database/tables/user.dart';
import 'package:todo_list/main.dart';

@singleton
class UserRepository {
  final UserDao _userDao;

  UserRepository(this._userDao);

  Future<User?> getUserByUserId(String userId) async {
    return await _userDao.getByUserId(userId);
  }
  Future<void> adduser(String userId, String username) async{
    return _userDao.insertUser(User(null, userId, username));
  }
}