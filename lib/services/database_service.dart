import 'package:mongo_dart/mongo_dart.dart';
import '../config/app_config.dart';
import '../data/models/student_model.dart';
import '../data/models/alumni_model.dart';
import '../data/models/admin_model.dart';
import '../data/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Db? _db;

  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;
    try {
      _db = await Db.create(AppConfig.mongoDbUrl);
      await _db!.open();
      print("Connected to MongoDB");
    } catch (e) {
      print("Error connecting to MongoDB: $e");
    }
  }

  DbCollection get _students => _db!.collection('students');
  DbCollection get _alumni => _db!.collection('alumni');
  DbCollection get _admins => _db!.collection('admins');
  DbCollection get _qa => _db!.collection('qa');
  DbCollection get _posts => _db!.collection('posts');
  DbCollection get _events => _db!.collection('events');

  // --- Student Operations ---
  Future<void> saveStudent(StudentModel student) async {
    await _students.insert(student.toMap());
  }

  Future<StudentModel?> getStudent(String id) async {
    final data = await _students.findOne(where.eq('_id', id));
    if (data == null) return null;
    return StudentModel.fromMap(data);
  }

  Future<StudentModel?> getStudentByEmail(String email) async {
    final data = await _students.findOne(where.eq('email', email));
    if (data == null) return null;
    return StudentModel.fromMap(data);
  }

  // --- Alumni Operations ---
  Future<void> saveAlumni(AlumniModel alumni) async {
    await _alumni.insert(alumni.toMap());
  }

  Future<AlumniModel?> getAlumni(String id) async {
    final data = await _alumni.findOne(where.eq('_id', id));
    if (data == null) return null;
    return AlumniModel.fromMap(data);
  }

  Future<AlumniModel?> getAlumniByEmail(String email) async {
    final data = await _alumni.findOne(where.eq('email', email));
    if (data == null) return null;
    return AlumniModel.fromMap(data);
  }

  Future<List<AlumniModel>> getAllAlumni({bool onlyVerified = false}) async {
    final selector = onlyVerified ? where.eq('isVerified', true) : where;
    final list = await _alumni.find(selector).toList();
    return list.map((m) => AlumniModel.fromMap(m)).toList();
  }

  // --- Admin Operations ---
  Future<void> saveAdmin(AdminModel admin) async {
    await _admins.save(admin.toMap());
  }

  Future<AdminModel?> getAdminByEmail(String email) async {
    final data = await _admins.findOne(where.eq('email', email));
    if (data == null) return null;
    return AdminModel.fromMap(data);
  }

  // --- Verification Operations ---
  Future<List<Map<String, dynamic>>> getPendingVerifications() async {
    final students = await _students.find(where.eq('isVerified', false)).toList();
    final alumni = await _alumni.find(where.eq('isVerified', false)).toList();

    List<Map<String, dynamic>> pending = [];
    for (var s in students) {
      pending.add({...s, 'role': 'student'});
    }
    for (var a in alumni) {
      pending.add({...a, 'role': 'alumni'});
    }
    return pending;
  }

  Future<void> verifyUser(String id, String role, bool status) async {
    final collection = role == 'student' ? _students : _alumni;
    if (status) {
      await collection.update(where.eq('_id', id), modify.set('isVerified', true));
    } else {
      // If rejected, maybe delete or mark as rejected
      await collection.remove(where.eq('_id', id));
    }
  }

  // --- Q&A Operations ---
  Future<List<QAModel>> getAllQA() async {
    final list = await _qa.find().toList();
    return list.map((m) => QAModel.fromMap(m)).toList();
  }

  Future<void> saveQA(QAModel qa) async {
    await _qa.insert(qa.toMap());
  }

  Future<void> updateQA(QAModel qa) async {
    await _qa.replaceOne(where.eq('_id', qa.id), qa.toMap());
  }
}
