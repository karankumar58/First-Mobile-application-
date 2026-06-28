import '../models/course_model.dart';
import '../services/course_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

/// Repository acts as the single source of truth.
/// UI → StateManagement → Repository → [API Service | Local DB]
class CourseRepository {
  final CourseApiService _apiService;
  final LocalStorageService _localStorage;
  final ConnectivityService _connectivity;

  CourseRepository({
    required CourseApiService apiService,
    required LocalStorageService localStorage,
    required ConnectivityService connectivity,
  })  : _apiService = apiService,
        _localStorage = localStorage,
        _connectivity = connectivity;

  // ── FETCH ─────────────────────────────────────────────────────────────────
  /// Returns courses from API when online; falls back to local cache offline.
  Future<({List<Course> courses, bool fromCache})> getCourses() async {
    final online = await _connectivity.isOnline;

    if (online) {
      try {
        final courses = await _apiService.fetchCourses();
        // Persist fresh data
        await _localStorage.saveCourses(courses);
        return (courses: courses, fromCache: false);
      } catch (_) {
        // API failed → fall back to cache
        final cached = _localStorage.getAllCourses();
        if (cached.isNotEmpty) return (courses: cached, fromCache: true);
        rethrow;
      }
    } else {
      final cached = _localStorage.getAllCourses();
      return (courses: cached, fromCache: true);
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<Course> createCourse({
    required String title,
    required String body,
  }) async {
    final online = await _connectivity.isOnline;
    if (!online) throw const ApiException('Cannot create course while offline');

    final course = await _apiService.createCourse(title: title, body: body);
    // JSONPlaceholder returns id=101 for all POSTs; use timestamp-based local id
    final localId = DateTime.now().millisecondsSinceEpoch % 100000;
    final localCourse = course.copyWith(id: localId);
    await _localStorage.saveCourse(localCourse);
    return localCourse;
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  /// Optimistic: update local immediately, rollback on API failure.
  Future<Course> updateCourse(Course course) async {
    final snapshot = _localStorage.getCourse(course.id);
    // Optimistic local update
    final optimistic = course.copyWith(isPendingUpdate: true);
    await _localStorage.updateCourse(optimistic);

    try {
      final online = await _connectivity.isOnline;
      if (online) {
        final updated = await _apiService.updateCourse(course);
        final confirmed = updated.copyWith(id: course.id, isPendingUpdate: false);
        await _localStorage.updateCourse(confirmed);
        return confirmed;
      }
      // Offline: keep optimistic, will sync later
      return optimistic;
    } catch (e) {
      // Rollback
      if (snapshot != null) await _localStorage.updateCourse(snapshot);
      rethrow;
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  /// Optimistic: mark deleted locally, rollback on API failure.
  Future<void> deleteCourse(int id) async {
    final snapshot = _localStorage.getCourse(id);

    // Optimistic: remove from local immediately
    await _localStorage.deleteCourse(id);

    try {
      final online = await _connectivity.isOnline;
      if (online) {
        await _apiService.deleteCourse(id);
      }
      // If offline, item is removed locally (sync on reconnect is a bonus feature)
    } catch (e) {
      // Rollback
      if (snapshot != null) await _localStorage.saveCourse(snapshot);
      rethrow;
    }
  }

  Future<DateTime?> getLastSyncTime() => _localStorage.getLastSyncTime();
  bool get hasLocalData => _localStorage.hasData;
}
