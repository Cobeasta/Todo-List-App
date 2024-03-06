// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppDatabase.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  TaskDao? _taskDaoInstance;

  UserDao? _userDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `task` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `description` TEXT NOT NULL, `deadline` INTEGER NOT NULL, `completedDate` INTEGER, `userId` INTEGER NOT NULL, FOREIGN KEY (`userId`) REFERENCES `user` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `user` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `userId` TEXT NOT NULL, `userName` TEXT NOT NULL)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  TaskDao get taskDao {
    return _taskDaoInstance ??= _$TaskDao(database, changeListener);
  }

  @override
  UserDao get userDao {
    return _userDaoInstance ??= _$UserDao(database, changeListener);
  }
}

class _$TaskDao extends TaskDao {
  _$TaskDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _taskInsertionAdapter = InsertionAdapter(
            database,
            'task',
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'deadline': _dateTimeConverter.encode(item.deadline),
                  'completedDate':
                      _optionalDateTimeConverter.encode(item.completedDate),
                  'userId': item.userId
                }),
        _taskUpdateAdapter = UpdateAdapter(
            database,
            'task',
            ['id'],
            (Task item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'deadline': _dateTimeConverter.encode(item.deadline),
                  'completedDate':
                      _optionalDateTimeConverter.encode(item.completedDate),
                  'userId': item.userId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Task> _taskInsertionAdapter;

  final UpdateAdapter<Task> _taskUpdateAdapter;

  @override
  Future<List<Task>> list(int uid) async {
    return _queryAdapter.queryList('SELECT * FROM task WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['title'] as String,
            row['description'] as String,
            _dateTimeConverter.decode(row['deadline'] as int),
            _optionalDateTimeConverter.decode(row['completedDate'] as int?),
            row['userId'] as int),
        arguments: [uid]);
  }

  @override
  Future<Task?> getByTitle(
    String title,
    int uid,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM task WHERE title = ?1 AND userId = ?2',
        mapper: (Map<String, Object?> row) => Task(
            row['id'] as int?,
            row['title'] as String,
            row['description'] as String,
            _dateTimeConverter.decode(row['deadline'] as int),
            _optionalDateTimeConverter.decode(row['completedDate'] as int?),
            row['userId'] as int),
        arguments: [title, uid]);
  }

  @override
  Future<void> delete(
    int id,
    int uid,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM task WHERE id = ?1 AND userId = ?2',
        arguments: [id, uid]);
  }

  @override
  Future<List<Task>> getIncomplete(int uid) async {
    return _queryAdapter.queryList(
        'SELECT FROM task WHERE isComplete IS NOT NULL AND userId = ?1 ORDER BY isComplete DESC',
        mapper: (Map<String, Object?> row) => Task(row['id'] as int?, row['title'] as String, row['description'] as String, _dateTimeConverter.decode(row['deadline'] as int), _optionalDateTimeConverter.decode(row['completedDate'] as int?), row['userId'] as int),
        arguments: [uid]);
  }

  @override
  Future<List<Task>> getComplete(int uid) async {
    return _queryAdapter.queryList(
        'SELECT FROM task WHERE isComplete IS NULL AND userId = ?1 ORDER BY isComplete DESC',
        mapper: (Map<String, Object?> row) => Task(row['id'] as int?, row['title'] as String, row['description'] as String, _dateTimeConverter.decode(row['deadline'] as int), _optionalDateTimeConverter.decode(row['completedDate'] as int?), row['userId'] as int),
        arguments: [uid]);
  }

  @override
  Future<void> insertOne(Task task) async {
    await _taskInsertionAdapter.insert(task, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertAll(List<Task> tasks) {
    return _taskInsertionAdapter.insertListAndReturnIds(
        tasks, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOne(Task task) async {
    await _taskUpdateAdapter.update(task, OnConflictStrategy.abort);
  }
}

class _$UserDao extends UserDao {
  _$UserDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _userInsertionAdapter = InsertionAdapter(
            database,
            'user',
            (User item) => <String, Object?>{
                  'id': item.id,
                  'userId': item.userId,
                  'userName': item.userName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<User> _userInsertionAdapter;

  @override
  Future<User?> getByUserId(String userId) async {
    return _queryAdapter.query('SELECT * FROM user WHERE userId = ?1',
        mapper: (Map<String, Object?> row) => User(row['id'] as int?,
            row['userId'] as String, row['userName'] as String),
        arguments: [userId]);
  }

  @override
  Future<void> delete(int id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM user WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> insertUser(User user) async {
    await _userInsertionAdapter.insert(user, OnConflictStrategy.abort);
  }
}

// ignore_for_file: unused_element
final _dateTimeConverter = DateTimeConverter();
final _optionalDateTimeConverter = OptionalDateTimeConverter();
