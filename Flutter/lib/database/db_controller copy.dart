import 'package:flutter_app/controllers/login_controller.dart';
import 'package:flutter_app/models/hour_slot.dart';
import 'package:flutter_app/models/prenotation.dart';
import 'package:flutter_app/models/registration_user.dart';
import 'package:flutter_app/models/user.dart';
import 'package:sqflite/sqflite.dart';
import '../models/slot.dart';
import '../models/subject.dart';
import '../models/teacher.dart';

class DbController {
  static Database? _database;
  static DbController? _dbController;
  DbController._createInstance();
  static final DbController db = DbController._createInstance();

  factory DbController() {
    _dbController ??= DbController._createInstance();
    return _dbController!;
  }

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  static Future<Database> initDB() async {
    final dbPath = await getDatabasesPath();
    return await openDatabase(
      '$dbPath/main.db',
      onCreate: (db, version) {
        createTables(db);
        insertData(db);
      },
      version: 1,
    );
  }

  /// Returns the list of [Subject] in alphabetical order
  Future<List<Subject>> getSubjects() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM course order by name asc');
    return List.generate(maps.length, (i) {
      return Subject(
        name: maps[i]['name'],
        description: maps[i]['descrizione'],
      );
    });
  }

  /// Returns the list of [Teacher] in alphabetical order
  Future<List<Teacher>> getTeachers() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.rawQuery('SELECT * FROM teacher order by name asc');
    return List.generate(maps.length, (i) {
      return Teacher(
        email: maps[i]['email'],
        name: maps[i]['name'],
        phone: maps[i]['phone'],
        description: maps[i]['description'],
        imagePath: maps[i]['imagepath'],
      );
    });
  }

  /// Get all the subjects taught by a teacher and their descriptions
  Future<List<Subject>> getTeacherSubjects(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT course.name, course.description 
        FROM teacher_course JOIN course on teacher_course.course = course.name
        WHERE teacher_course.teacher = ?''', [email]);
    return List.generate(maps.length, (i) {
      return Subject(
        name: maps[i]['name'],
        description: maps[i]['description'],
      );
    });
  }

  /// Return the [Teacher] with the given email
  Future<Teacher> getTeacher(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('teacher', where: 'email = ?', whereArgs: [email]);
    return Teacher(
      email: maps[0]['email'],
      name: maps[0]['name'],
      phone: maps[0]['phone'],
      description: maps[0]['description'],
      imagePath: maps[0]['imagepath'],
    );
  }

  /// Return the list of [Prenotation] of a given user
  ///
  /// If the user's email is empty, return an empty list
  Future<List<Prenotation>> getUserPrenotations(User user) async {
    final Database db = await database;
    if (user.email == '') return [];
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ?
        ORDER By prenotation.date DESC, prenotation.begin DESC,
        prenotation.end DESC''', [user.email]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  /// Returns the list of [Prenotation] of an user
  ///
  /// The user's email is retreived from the [LoginController]
  Future<List<Prenotation>> getFilteredUserPrenotations(
      List<String> subjects,
      List<String> teachers,
      String startDate,
      String endDate,
      bool booked,
      bool compleated,
      bool cancelled) async {
    String mail = LoginController.user.email;
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ?
        ${subjects.isNotEmpty ? 'AND subject.name IN (${subjects.map((e) => "'$e'").join(',')}) ' : ''}
        ${teachers.isNotEmpty ? 'AND teacher.name IN (${teachers.map((e) => "'$e'").join(',')}) ' : ''}
        ${startDate.isNotEmpty ? 'AND prenotation.date >= $startDate ' : ''}
        ${endDate.isNotEmpty ? 'AND prenotation.date <= $endDate ' : ''} 
        ${booked || compleated || cancelled ? 'AND(' : ''}
        ${booked ? 'prenotation.state = 0 ' : ''}
        ${compleated ? '${booked ? 'OR' : ''} prenotation.state = 2 ' : ''}
        ${cancelled ? '${booked || compleated ? 'OR' : ''} prenotation.state = 1 ' : ''}
        ${booked || compleated || cancelled ? ')' : ''}
        ORDER By id DESC''', [mail]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  /// Return a list of [Subject]
  ///
  ///
  Future<List<Subject>> getAvailableSubjectsByDate(DateTime date) async {
    String mail = LoginController.user.email;
    final Database db = await database;
    int formattedDate = int.parse(
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
    final List<Map<String, dynamic>> maps = await db.rawQuery(''' 
          WITH nb_slots as (
          SELECT *
          FROM slot
          WHERE NOT EXISTS(
                          SELECT * 
                          FROM prenotation 
                          WHERE prenotation.state != 1 
                          AND prenotation.date = slot.date 
                          AND prenotation.begin = slot.begin_hour 
                          AND prenotation.end = slot.end_hour 
                          AND prenotation.teacher = slot.teacher
                        )
          )
      SELECT DISTINCT subject.name as subject_name, 
            subject.description as subject_description
        from ( 
              SELECT * 
              FROM nb_slots 
              WHERE NOT EXISTS (
                select * 
                from cart 
                where cart.date = nb_slots.date 
                  AND cart.begin_hour = nb_slots.begin_hour 
                  AND cart.end_hour = nb_slots.end_hour 
                  AND cart.teacher = nb_slots.teacher 
                  AND cart.student = ?
                ) 
              ) as slot
        JOIN course as subject ON slot.course = subject.name
        WHERE slot.date = ?
        order by subject.name asc
        ''', [mail, formattedDate]);
    return List.generate(maps.length, (i) {
      return Subject(
        name: maps[i]['subject_name'],
        description: maps[i]['description'],
      );
    });
  }

  /// Return a list of [AvailabeSlot]
  ///
  ///
  Future<List<AvailableSlot>> getAvailableSlots(
      Subject subject, DateTime date, Teacher? teacher) async {
    final Database db = await database;
    int formattedDate = int.parse(
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
    final List<Map<String, dynamic>> maps = teacher == null
        ? await db.rawQuery('''
        SELECT slot.date, slot.begin_hour, slot.end_hour, teacher.name as teacher_name, teacher.email, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM (
          SELECT *
          FROM slot
          WHERE NOT EXISTS(SELECT * FROM prenotation WHERE prenotation.state != 1 AND prenotation.date = slot.date AND prenotation.begin = slot.begin_hour AND prenotation.end = slot.end_hour AND prenotation.teacher = slot.teacher)
          ) as slot join course as subject on slot.course = subject.name join teacher on slot.teacher = teacher.email
        WHERE slot.date = ? AND subject.name = ?
        order by slot.begin_hour asc
        ''', [formattedDate, subject.name])
        : await db.rawQuery('''
        SELECT slot.date, slot.begin_hour, slot.end_hour, teacher.name as teacher_name, teacher.email, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM (
          SELECT *
          FROM slot
          WHERE NOT EXISTS(SELECT * FROM prenotation WHERE prenotation.state != 1 AND prenotation.date = slot.date AND prenotation.begin = slot.begin_hour AND prenotation.end = slot.end_hour AND prenotation.teacher = slot.teacher)
          ) as slot join course as subject on slot.course = subject.name join teacher on slot.teacher = teacher.email
        WHERE slot.date = ? AND subject.name = ? AND slot.teacher = ?
        order by slot.begin_hour asc
        ''', [formattedDate, subject.name, teacher.email]);
    return List.generate(maps.length, (i) {
      return AvailableSlot(
        date: maps[i]['date'],
        beginHour: maps[i]['begin_hour'],
        endHour: maps[i]['end_hour'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  Future<List<AvailableSlot>> getAvailableTeachersSlot(Subject subject,
      DateTime date, AvailableHourSlot? availableHourSlot) async {
    final Database db = await database;
    int formattedDate = int.parse(
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}');
    final List<Map<String, dynamic>> maps = (availableHourSlot == null)
        ? await db.rawQuery(
            '''SELECT slot.date, slot.begin_hour, slot.end_hour, teacher.name as teacher_name, teacher.email, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM slot join course as subject on slot.course = subject.name
        JOIN teacher ON slot.teacher = teacher.email
        WHERE slot.date = ? AND subject.name = ? AND NOT EXISTS(SELECT * FROM prenotation WHERE prenotation.state != 1 AND prenotation.date = slot.date AND prenotation.begin = slot.begin_hour AND prenotation.end = slot.end_hour AND prenotation.teacher = slot.teacher)
        order by teacher.name asc
        ''', [formattedDate, subject.name])
        : await db.rawQuery(
            '''SELECT slot.date, slot.begin_hour, slot.end_hour, teacher.name as teacher_name, teacher.email, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM slot join course as subject on slot.course = subject.name
        JOIN teacher ON slot.teacher = teacher.email
        WHERE slot.date = ? AND subject.name = ? AND slot.begin_hour = ? AND slot.end_hour = ? AND NOT EXISTS(SELECT * FROM prenotation WHERE prenotation.state != 1 AND prenotation.date = slot.date AND prenotation.begin = slot.begin_hour AND prenotation.end = slot.end_hour AND prenotation.teacher = slot.teacher)
        order by teacher.name asc
        ''',
            [
                formattedDate,
                subject.name,
                availableHourSlot.beginHour,
                availableHourSlot.endHour
              ]);
    return List.generate(maps.length, (i) {
      return AvailableSlot(
        date: maps[i]['date'],
        beginHour: maps[i]['begin_hour'],
        endHour: maps[i]['end_hour'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: subject.name,
          description: subject.description,
        ),
      );
    });
  }

  Future<List<AvailableSlot>> getSlotsbyTeacher(Teacher teacher) async {
    final Database db = await database;
    final String mail = LoginController.user.email;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
        WITH nb_slots as (
          SELECT *
          FROM slot
          WHERE NOT EXISTS(
                          SELECT * 
                          FROM prenotation 
                          WHERE prenotation.date = slot.date
                          AND prenotation.state != 1  
                          AND prenotation.begin = slot.begin_hour 
                          AND prenotation.end = slot.end_hour 
                          AND prenotation.teacher = slot.teacher
                        )
          )
        SELECT slot.*, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM ( 
              SELECT * 
              FROM nb_slots 
              WHERE NOT EXISTS (
                select * 
                from cart 
                where cart.date = nb_slots.date 
                  AND cart.begin_hour = nb_slots.begin_hour 
                  AND cart.end_hour = nb_slots.end_hour 
                  AND cart.teacher = nb_slots.teacher 
                  AND cart.student = ?
                ) 
              ) as slot
        JOIN teacher ON slot.teacher = teacher.email
        JOIN course as subject ON slot.course = subject.name
        WHERE slot.teacher = ?
        ORDER BY slot.date''', [mail, teacher.email]);
    return List.generate(maps.length, (i) {
      return AvailableSlot(
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
        date: maps[i]['date'],
        beginHour: maps[i]['begin_hour'],
        endHour: maps[i]['end_hour'],
      );
    });
  }

  Future<User> getUser(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('user', where: 'email = ?', whereArgs: [
      email
    ], columns: [
      'email',
      'fullname',
      'nickname',
      'phone',
      'address',
      'imagepath',
    ]);
    return User(
      email: maps[0]['email'],
      fullName: maps[0]['fullname'],
      phone: maps[0]['phone'],
      nickName: maps[0]['nickname'],
      address: maps[0]['address'],
      imagePath: maps[0]['imagepath'],
    );
  }

  int getCurrDate() {
    return int.parse(
        "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}");
  }

  Future<List<Prenotation>> getBookedPrenotations(String email) async {
    final Database db = await database;
    // date >= ${getCurrDate()}
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
      FROM prenotation
      JOIN teacher ON prenotation.teacher = teacher.email
      JOIN course as subject ON prenotation.course = subject.name
      WHERE prenotation.student = ? AND prenotation.state = 0 AND prenotation.date >= ?

''', [
      email,
      "${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, "0")}${DateTime.now().day.toString().padLeft(2, "0")}"
    ]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['subject_description'],
        ),
      );
    });
  }

  Future<List<Prenotation>> getUserPrenotationsThisWeek(String user) async {
    final Database db = await database;
    var now = DateTime.now();
    var monday = now.subtract(Duration(days: now.weekday - 1));
    var sunday = now.add(Duration(days: 7 - now.weekday));
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ? AND prenotation.date >= ? AND prenotation.date <= ? AND prenotation.state != 1''',
        [
          user,
          "${monday.year}${monday.month.toString().padLeft(2, "0")}${monday.day.toString().padLeft(2, "0")}",
          "${sunday.year}${sunday.month.toString().padLeft(2, "0")}${sunday.day.toString().padLeft(2, "0")}"
        ]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  Future<List<Prenotation>> getUserPrenotationsCompletedThisWeek(
      String user) async {
    final Database db = await database;
    var now = DateTime.now();
    var monday = now.subtract(Duration(days: now.weekday - 1));
    var sunday = now.add(Duration(days: 7 - now.weekday));

    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ? AND prenotation.date >= ? AND prenotation.date <= ? AND prenotation.state = 2''',
        [
          user,
          "${monday.year}${monday.month.toString().padLeft(2, "0")}${monday.day.toString().padLeft(2, "0")}",
          "${sunday.year}${sunday.month.toString().padLeft(2, "0")}${sunday.day.toString().padLeft(2, "0")}"
        ]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  Future<List<Prenotation>> getUserPrenotationsThisMonth(String user) async {
    final Database db = await database;
    var now = DateTime.now();
    var firstDay = DateTime(now.year, now.month, 1);
    var lastDay = DateTime(now.year, now.month + 1, 0);
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ? AND prenotation.date >= ? AND prenotation.date <= ? AND prenotation.state != 1''',
        [
          user,
          "${firstDay.year}${firstDay.month.toString().padLeft(2, "0")}${firstDay.day.toString().padLeft(2, "0")}",
          "${lastDay.year}${lastDay.month.toString().padLeft(2, "0")}${lastDay.day.toString().padLeft(2, "0")}"
        ]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  Future<List<Prenotation>> getUserPrenotationsCompletedThisMonth(
      String user) async {
    final Database db = await database;
    var now = DateTime.now();
    var firstDay = DateTime(now.year, now.month, 1);
    var lastDay = DateTime(now.year, now.month + 1, 0);
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date, prenotation.begin, prenotation.end, prenotation.state, teacher.email, teacher.name as teacher_name, teacher.phone, teacher.imagepath, teacher.description, subject.name as subject_name, subject.description as subject_description
        FROM prenotation
        JOIN teacher ON prenotation.teacher = teacher.email
        JOIN course as subject ON prenotation.course = subject.name
        WHERE prenotation.student = ? AND prenotation.date >= ? AND prenotation.date <= ? AND prenotation.state = 2''',
        [
          user,
          "${firstDay.year}${firstDay.month.toString().padLeft(2, "0")}${firstDay.day.toString().padLeft(2, "0")}",
          "${lastDay.year}${lastDay.month.toString().padLeft(2, "0")}${lastDay.day.toString().padLeft(2, "0")}"
        ]);
    return List.generate(maps.length, (i) {
      return Prenotation(
        date: maps[i]['date'],
        begin: maps[i]['begin'],
        end: maps[i]['end'],
        status: maps[i]['state'],
        teacher: Teacher(
          email: maps[i]['email'],
          name: maps[i]['teacher_name'],
          phone: maps[i]['phone'],
          description: maps[i]['description'],
          imagePath: maps[i]['imagepath'],
        ),
        subject: Subject(
          name: maps[i]['subject_name'],
          description: maps[i]['description'],
        ),
      );
    });
  }

  Future<User> login(String email, String password) async {
    final Database db = await database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('user',
          where: 'email = ? AND password = ?',
          whereArgs: [
            email,
            password
          ],
          columns: [
            'email',
            'fullname',
            'nickname',
            'phone',
            'address',
            'imagepath'
          ]);
      return User(
        email: maps[0]['email'],
        fullName: maps[0]['fullname'],
        phone: maps[0]['phone'],
        nickName: maps[0]['nickname'],
        address: maps[0]['address'],
        imagePath: maps[0]['imagepath'],
      );
    } catch (e) {
      return EmptyUser();
    }
  }

  Future<bool> register(RegistrationUser user) async {
    final Database db = await database;
    try {
      await db.insert('user', toMap(user));
      return true;
    } catch (e) {
      return false;
    }
  }

  void updateUser(Map<String, dynamic> user) async {
    final Database db = await database;
    db.update('user', user, where: 'email = ?', whereArgs: [user['email']]);
  }

  Future<bool> changePassword(String email, String newPass) async {
    final Database db = await database;
    try {
      await db.update('user', {'password': newPass},
          where: 'email = ?', whereArgs: [email]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkPassword(String email, String pass) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user',
        where: 'email = ? AND password = ?', whereArgs: [email, pass]);
    return maps.isNotEmpty;
  }

  /// Find all complete prenotation of a user and return total number of hours
  Future<String> getTotalHours(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date
        FROM prenotation
        WHERE prenotation.student = ? AND prenotation.state = '2'  ''',
        [email]);
    return maps.length.toString();
  }

  /// Find all complete prenotation in the last month of a user and return total number of hours
  Future<String> getTotalHoursLastMonth(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date
        FROM prenotation
        WHERE prenotation.student = ? AND  strftime('%Y%m%d') - prenotation.date < 31 AND prenotation.state = '2' ''',
        [email]);
    return maps.length.toString();
  }

  /// Find all complete prenotation in the last week of a user and return total number of hours
  Future<String> getTotalHoursLastWeek(String email) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT prenotation.date
        FROM prenotation
        WHERE prenotation.student = ? AND strftime('%Y%m%d') - prenotation.date < 7 AND prenotation.state = '2' ''',
        [email]);
    return maps.length.toString();
  }

  /// Get all 3 total hours and return a list
  Future<List<String>> getTotalHoursAll(String email) async {
    List<String> totalHours = [];
    totalHours.add(await getTotalHours(email));
    totalHours.add(await getTotalHoursLastMonth(email));
    totalHours.add(await getTotalHoursLastWeek(email));
    return totalHours;
  }

  /// Add the selected slot to cart
  void addToCart(String mail, String date, String subject, String teacher,
      String begin, String end) async {
    final Database db = await database;
    db.rawQuery('''
        INSERT INTO cart (student, date, begin_hour, end_hour, teacher, course)
        VALUES (?, ?, ?, ?, ?, ?)
        ''', [mail, date, begin, end, teacher, subject]);
  }

  /// Remove the slot from the cart
  void removeFromCart(String mail, String date, String subject, String teacher,
      String begin, String end) async {
    final Database db = await database;
    db.delete('cart',
        where:
            ' date = ? AND begin_hour = ? AND end_hour = ? AND teacher = ? AND course = ?',
        whereArgs: [
          date,
          begin,
          end,
          teacher,
          subject,
        ]);
  }

  /// Get all slots in the cart to show them
  Future<List<AvailableSlot>> getCart(String mail) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''SELECT cart.date, cart.begin_hour, cart.end_hour, cart.course, teacher.email, teacher.name, teacher.phone, teacher.imagepath, teacher.description as tDesc, course.name as subject, course.description 
        FROM cart join teacher on cart.teacher = teacher.email join course on cart.course = course.name
        WHERE cart.student = ?''', [mail]);
    return maps.isNotEmpty
        ? List.generate(maps.length, (i) {
            return AvailableSlot(
              date: maps[i]['date'],
              beginHour: maps[i]['begin_hour'],
              endHour: maps[i]['end_hour'],
              teacher: Teacher(
                  email: maps[i]['email'],
                  name: maps[i]['name'],
                  phone: maps[i]['phone'],
                  imagePath: maps[i]['imagepath'],
                  description: maps[i]['tDesc']),
              subject: Subject(
                name: maps[i]['subject'],
                description: maps[i]['description'],
              ),
            );
          })
        : [];
  }

  Future<bool> deletePrenotation(Prenotation prenotation) async {
    final Database db = await database;
    try {
      await db.update('prenotation', {'state': 1},
          where:
              'student = ? AND date = ? AND begin = ? AND end = ? AND teacher = ? AND state = 0 AND course = ?',
          whereArgs: [
            LoginController.user.email,
            '${prenotation.date.year}${prenotation.date.month.toString().padLeft(2, "0")}${prenotation.date.day.toString().padLeft(2, "0")}',
            '${prenotation.begin.hour.toString().padLeft(2, "0")}:00',
            '${prenotation.end.hour.toString().padLeft(2, "0")}:00',
            prenotation.teacher.email,
            prenotation.subject.name
          ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> confirmPrenotation(Prenotation prenotation) async {
    final Database db = await database;
    try {
      await db.update('prenotation', {'state': 2},
          where:
              'student = ? AND date = ? AND begin = ? AND end = ? AND teacher = ? AND state = 0 AND course = ?',
          whereArgs: [
            LoginController.user.email,
            '${prenotation.date.year}${prenotation.date.month.toString().padLeft(2, "0")}${prenotation.date.day.toString().padLeft(2, "0")}',
            '${prenotation.begin.hour.toString().padLeft(2, "0")}:00',
            '${prenotation.end.hour.toString().padLeft(2, "0")}:00',
            prenotation.teacher.email,
            prenotation.subject.name
          ]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addPrenotations(List<AvailableSlot> slots) async {
    final Database db = await database;
    try {
      Batch batch = db.batch();
      for (AvailableSlot slot in slots) {
        batch.insert('prenotation', {
          'student': LoginController.user.email,
          'date':
              '${slot.date.year}${slot.date.month.toString().padLeft(2, "0")}${slot.date.day.toString().padLeft(2, "0")}',
          'begin': '${slot.beginHour.hour.toString().padLeft(2, '0')}:00',
          'end': '${slot.endHour.hour.toString().padLeft(2, '0')}:00',
          'teacher': slot.teacher.email,
          'state': 0,
          'course': slot.subject.name,
        });
      }
      await batch.commit();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// --- Creation Stuff ---
  static createTables(Database database) {
    Batch batch = database.batch();
    batch.execute('''
      CREATE TABLE IF NOT EXISTS user (
        email TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        fullname TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        imagepath TEXT NOT NULL,
        nickname TEXT
      )
      ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS teacher (
        email TEXT PRIMARY KEY,
        password TEXT NOT NULL,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL,
        imagepath TEXT,
        description TEXT NOT NULL
      )
      ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS slot (
        date INTEGER NOT NULL,
        begin_hour TEXT NOT NULL,
        end_hour TEXT NOT NULL,
        teacher TEXT NOT NULL,
        course TEXT NOT NULL,
        PRIMARY KEY (date, begin_hour, end_hour, teacher, course),
        FOREIGN KEY (teacher) REFERENCES teacher(email),
        FOREIGN KEY (course) REFERENCES course(name)
      )
      ''');

    /// Prenonation States:
    /// 0: Attiva
    /// 1: Disdetta
    /// 2: Effettuata
    batch.execute('''
      CREATE TABLE IF NOT EXISTS prenotation (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        state INTEGER CHECK (state >= 0 AND state <= 2) NOT NULL,
        student TEXT NOT NULL,
        begin TEXT NOT NULL,
        date INTEGER NOT NULL,
        end TEXT NOT NULL,
        teacher TEXT NOT NULL,
        course TEXT NOT NULL
      )
      ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS course(
        name TEXT PRIMARY KEY,
        description TEXT
      )
      ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS teacher_course(
        teacher TEXT NOT NULL,
        course TEXT NOT NULL,
        PRIMARY KEY (teacher, course),
        FOREIGN KEY (teacher) REFERENCES teacher(email),
        FOREIGN KEY (course) REFERENCES course(name)
      )
    ''');
    batch.execute('''
      CREATE TABLE IF NOT EXISTS cart(
        student TEXT NOT NULL,
        date INTEGER NOT NULL,
        begin_hour TEXT NOT NULL,
        end_hour TEXT NOT NULL,
        teacher TEXT NOT NULL,
        course TEXT NOT NULL,
        PRIMARY KEY (student, begin_hour, date, end_hour, teacher),
        FOREIGN KEY (student) REFERENCES user(email),
        FOREIGN KEY (date) REFERENCES slot(date),
        FOREIGN KEY (begin_hour) REFERENCES slot(begin_hour),
        FOREIGN KEY (end_hour) REFERENCES slot(end_hour),
        FOREIGN KEY (teacher) REFERENCES slot(teacher),
        FOREIGN KEY (course) REFERENCES course(name)
      )
      ''');

    // commit the batch
    batch.commit();
  }

  /// --- Insertion Stuff ---
  static insertData(Database database) {
    // -- USERS INSERTION --
    database.insert('user', {
      'email': 'test@test.com',
      'password': 'test',
      'fullname': 'Giorno Giovanna',
      'phone': '1234567890',
      'address': 'Via della Libertà, 1, 00100 Roma',
      'nickname': 'JoJo',
      'imagepath': 'https://i.imgur.com/ifk1dWc.jpeg'
    });
    database.insert('user', {
      'email': 'guest@guest.com',
      'password': 'guest',
      'fullname': 'Nome Cognome',
      'phone': 'Num. di telefono',
      'address': 'Indirizzo, 1, 00100 Città',
      'nickname': 'Ospite',
      'imagepath': 'https://i.imgur.com/ifk1dWc.jpeg'
    });

    // -- TEACHERS INSERTION --
    // Thanks to https://this-person-does-not-exist.com/ for the images
    List<Teacher> teachers = [
      Teacher(
          email: 'pietrosmusi@gmail.com',
          name: 'Pietro Smusi',
          phone: '1234567890',
          description:
              'Ciao, sono Pietro Smusi e sono un insegnante di scienze con una grande passione per l\'insegnamento. Ho conseguito la laurea in Scienze Naturali e mi sono specializzato in biologia. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di biologia, chimica e fisica.',
          imagePath: 'https://i.imgur.com/JyKQWzg.jpg'),
      Teacher(
          email: 'francomaniero@gmail.com',
          name: 'Franco Maniero',
          phone: '1234567890',
          description:
              'Ciao, sono Franco Maniero e sono un insegnante di matematica con una grande passione per l\'insegnamento. Ho conseguito la laurea in Matematica e mi sono specializzato in analisi matematica. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di matematica, analisi matematica e geometria.',
          imagePath: 'https://i.imgur.com/8THejyG.png'),
      Teacher(
          email: 'natasharomanoff@gmail.com',
          name: 'Natasha Romanoff',
          phone: '1234567890',
          description:
              'Ciao, sono Natasha Romanoff e sono un insegnante di inglese con una grande passione per l\'insegnamento. Ho conseguito la laurea in Lingue e mi sono specializzata in inglese. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di inglese, francese e tedesco.',
          imagePath: "https://i.imgur.com/mC604vT.png"),
      Teacher(
          email: 'oraziogobbino@gmail.com',
          name: 'Orazio Gobbino',
          phone: '1234567890',
          description:
              'Ciao, sono Orazio Gobbino e sono un insegnante di inglese con una grande passione per l\'insegnamento. Ho conseguito la laurea in Lingue e mi sono specializzata in inglese. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di inglese, francese e tedesco.',
          imagePath: 'https://i.imgur.com/w7CgUml.png'),
      Teacher(
          email: 'mauriziosolari@gmail.com',
          name: 'Marurizio Solari',
          phone: '1234567890',
          description:
              'Ciao, sono Maurizio Solari e sono un insegnante di inglese con una grande passione per l\'insegnamento. Ho conseguito la laurea in Lingue e mi sono specializzata in inglese. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di inglese, francese e tedesco.',
          imagePath: 'https://i.imgur.com/cJkQgnB.png'),
      Teacher(
          email: 'aurelianobuendia@gmail.com',
          name: 'Aureliano Buendiá',
          phone: '1234567890',
          description:
              'Ciao, sono Aureliano Buendiá e sono un insegnante di inglese con una grande passione per l\'insegnamento. Ho conseguito la laurea in Lingue e mi sono specializzata in inglese. Amo trasmettere la mia conoscenza e l\'entusiasmo per la materia ai miei studenti. Sono un insegnante molto dinamico e mi piace coinvolgere i miei studenti in attività pratiche e divertenti. Sono disponibile per lezioni di inglese, francese e tedesco.',
          imagePath: 'https://i.imgur.com/uaLH1yl.png'),
    ];

    for (var teacher in teachers) {
      database.insert('teacher', {
        'email': teacher.email,
        'password': 'password',
        'name': teacher.name,
        'phone': teacher.phone,
        'address': 'Via Roma, 1, 00100 Roma',
        'description': teacher.description,
        'imagePath': teacher.imagePath,
      });
    }

    List<Subject> subjects = [
      Subject(
        name: 'Italiano',
        description: 'Lezione di italiano',
      ),
      Subject(
        name: 'Matematica',
        description: 'Lezione di matematica',
      ),
      Subject(
        name: 'Informatica',
        description: 'Lezione di informatica',
      ),
      Subject(
        name: 'Fisica',
        description: 'Lezione di fisica',
      ),
      Subject(
        name: 'Chimica',
        description: 'Lezione di chimica',
      ),
      Subject(
        name: 'Storia',
        description: 'Lezione di storia',
      ),
      Subject(
        name: 'Geografia',
        description: 'Lezione di geografia',
      ),
      Subject(
        name: 'Inglese',
        description: 'Lezione di inglese',
      ),
      Subject(
        name: 'Francese',
        description: 'Lezione di francese',
      ),
      Subject(
        name: 'Tedesco',
        description: 'Lezione di tedesco',
      ),
      Subject(
        name: 'Spagnolo',
        description: 'Lezione di spagnolo',
      ),
    ];

    for (var subject in subjects) {
      database.insert('course', {
        'name': subject.name,
        'description': subject.description,
      });
    }

    for (var teacher in teachers) {
      for (var subject in subjects) {
        database.insert('teacher_course', {
          'teacher': teacher.email,
          'course': subject.name,
        });
      }
    }
    var todayDate = DateTime.now();
    var monday = todayDate.subtract(Duration(days: todayDate.weekday - 1));

    // add slot from monday to friday, for every teacher and every subject, from 15:00 to 19:00
    // every slot is 1 hour long

    for (var teacher in teachers) {
      for (var subject in subjects) {
        for (var i = 0; i < 5; i++) {
          for (var j = 15; j < 19; j++) {
            database.insert('slot', {
              'date':
                  '${monday.year}${monday.month.toString().padLeft(2, '0')}${(monday.day + i).toString().padLeft(2, '0')}',
              'begin_hour': '$j:00',
              'end_hour': '${j + 1}:00',
              'teacher': teacher.email,
              'course': subject.name,
            });
          }
        }
      }
    }

    // insert a slot for today
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '10:00',
    //   'end_hour': '11:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('slot', {
    //   'date': 20230112,
    //   'begin_hour': '11:00',
    //   'end_hour': '12:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Informatica'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '11:00',
    //   'end_hour': '12:00',
    //   'teacher': 'oraziogrinzosi@gmail.com',
    //   'course': 'Fisica'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '13:00',
    //   'end_hour': '14:00',
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Fisica'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '15:00',
    //   'end_hour': '16:00',
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '14:00',
    //   'end_hour': '15:00',
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Fisica'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '15:00',
    //   'end_hour': '16:00',
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Informatica'
    // });
    // database.insert('slot', {
    //   'date': 20230112,
    //   'begin_hour': '15:00',
    //   'end_hour': '16:00',
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Informatica'
    // });
    // database.insert('slot', {
    //   'date': 20230111,
    //   'begin_hour': '13:00',
    //   'end_hour': '14:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('slot', {
    //   'date': 20230112,
    //   'begin_hour': '13:00',
    //   'end_hour': '14:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('slot', {
    //   'date': 20230112,
    //   'begin_hour': '13:00',
    //   'end_hour': '14:00',
    //   'teacher': 'pietrosmusi@gmail.com',
    //   'course': 'Matematica'
    // });
    // database.insert('slot', {
    //   'date': 20230106,
    //   'begin_hour': '13:00',
    //   'end_hour': '14:00',
    //   'teacher': 'pietrosmusi@gmail.com',
    //   'course': 'Matematica'
    // });
    // database.insert('slot', {
    //   'date': 20230113,
    //   'begin_hour': '00:00',
    //   'end_hour': '01:00',
    //   'teacher': 'pietrosmusi@gmail.com',
    //   'course': 'Matematica'
    // });
    // database.insert('slot', {
    //   'date': 20230113,
    //   'begin_hour': '15:00',
    //   'end_hour': '16:00',
    //   'teacher': 'pietrosmusi@gmail.com',
    //   'course': 'Matematica'
    // });
    // database.insert('slot', {
    //   'date': 20230113,
    //   'begin_hour': '09:00',
    //   'end_hour': '10:00',
    //   'teacher': 'pietrosmusi@gmail.com',
    //   'course': 'Matematica'
    // });

    // // book that slot
    // database.insert('prenotation', {
    //   'state': 2,
    //   'student': 'test@test.com',
    //   'begin': '10:00',
    //   'date': 20230111,
    //   'end': '11:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('prenotation', {
    //   'state': 1,
    //   'student': 'test@test.com',
    //   'begin': '11:00',
    //   'date': 20230112,
    //   'end': '12:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Informatica'
    // });
    // database.insert('prenotation', {
    //   'state': 0,
    //   'student': 'test@test.com',
    //   'date': 20230111,
    //   'begin': '13:00',
    //   'end': '14:00',
    //   'teacher': 'marinosegnan@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('prenotation', {
    //   'state': 1,
    //   'student': 'test2@test.com',
    //   'begin': '10:00',
    //   'date': 20230111,
    //   'end': '11:00',
    //   'teacher': 'oraziogrinzosi@gmail.com',
    //   'course': 'Fisica'
    // });
    // database.insert('teacher_course',
    //     {'teacher': 'marinosegnan@gmail.com', 'course': 'Italiano'});
    // database.insert('teacher_course',
    //     {'teacher': 'marinosegnan@gmail.com', 'course': 'Informatica'});
    // database.insert('teacher_course',
    //     {'teacher': 'oraziogrinzosi@gmail.com', 'course': 'Fisica'});
    // database.insert('teacher_course',
    //     {'teacher': 'francescomazzuccomaniero@gmail.com', 'course': 'Fisica'});
    // database.insert('teacher_course', {
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Italiano'
    // });
    // database.insert('teacher_course', {
    //   'teacher': 'francescomazzuccomaniero@gmail.com',
    //   'course': 'Informatica'
    // });
  }
}
