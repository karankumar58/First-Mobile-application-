import 'package:hive_flutter/hive_flutter.dart';
import '../models/course_model.dart';

class LocalStorageService {
  static const String _coursesBoxName = 'courses_box';
  static const String _lastSyncKey = 'last_sync_timestamp';

  Box<Course>? _coursesBox;

  // ── INIT ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CourseAdapter());
    }
    _coursesBox = await Hive.openBox<Course>(_coursesBoxName);
  }

  Box<Course> get _box {
    if (_coursesBox == null || !_coursesBox!.isOpen) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _coursesBox!;
  }

  // ── READ ──────────────────────────────────────────────────────────────────
  List<Course> getAllCourses() {
    return _box.values.toList();
  }

  Course? getCourse(int id) {
    return _box.get(id);
  }

  bool get isEmpty => _box.isEmpty;

  // ── WRITE ─────────────────────────────────────────────────────────────────
  Future<void> saveCourses(List<Course> courses) async {
    await _box.clear();
    final map = {for (final c in courses) c.id: c};
    await _box.putAll(map);
    await _saveLastSync();
  }

  Future<void> saveCourse(Course course) async {
    await _box.put(course.id, course);
  }

  Future<void> deleteCourse(int id) async {
    await _box.delete(id);
  }

  Future<void> updateCourse(Course course) async {
    await _box.put(course.id, course);
  }

  // ── SYNC METADATA ─────────────────────────────────────────────────────────
  Future<void> _saveLastSync() async {
    final metaBox = await Hive.openBox('meta');
    await metaBox.put(_lastSyncKey, DateTime.now().toIso8601String());
  }

  Future<DateTime?> getLastSyncTime() async {
    final metaBox = await Hive.openBox('meta');
    final raw = metaBox.get(_lastSyncKey) as String?;
    return raw != null ? DateTime.tryParse(raw) : null;
  }

  bool get hasData => !_box.isEmpty;

  Future<void> close() async {
    await _coursesBox?.close();
  }
}
