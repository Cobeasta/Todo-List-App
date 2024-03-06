

import 'package:floor/floor.dart';

import 'user.dart';


abstract class UserProtectedTableBase {
  UserProtectedTableBase(this.userId);


 static const userForeignKey = ForeignKey(childColumns: ["id"], parentColumns: ["id"], entity: User);

final int userId;
  static const userTableFilter = "userId = :uid";
}