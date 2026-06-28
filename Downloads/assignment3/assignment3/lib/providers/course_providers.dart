import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../services/course_api_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';
import '../repositories/course_repository.dart';

// ── SERVICES ──────────────────────────────────────────────────────────────

final apiServiceProvider = Provider<CourseApiService>((ref) {
  final service = CourseApiService();
  ref.onDispose(service.dispose);
  return service;
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

// ── REPOSITORY ────────────────────────────────────────────────────────────

final courseRepositoryProvider = Provider<CourseRepository>((ref) {
  return CourseRepository(
    apiService: ref.watch(apiServiceProvider),
    localStorage: ref.watch(localStorageProvider),
    connectivity: ref.watch(connectivityServiceProvider),
  );
});

// ── CONNECTIVITY STATE ────────────────────────────────────────────────────

final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  return connectivity.onConnectivityChanged;
});

// ── COURSE STATE ──────────────────────────────────────────────────────────

// Holds filter/search query
final searchQueryProvider = StateProvider<String>((ref) => '');

// Core state: list of courses + metadata
class CoursesState {
  final List<Course> courses;
  final bool isLoading;
  final String? error;
  final bool fromCache;
  final DateTime? lastSync;

  const CoursesState({
    this.courses = const [],
    this.isLoading = false,
    this.error,
    this.fromCache = false,
    this.lastSync,
  });

  CoursesState copyWith({
    List<Course>? courses,
    bool? isLoading,
    String? error,
    bool? fromCache,
    DateTime? lastSync,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      fromCache: fromCache ?? this.fromCache,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  bool get isEmpty => courses.isEmpty && !isLoading;
  bool get hasError => error != null;
}

// Main StateNotifier for courses
class CoursesNotifier extends StateNotifier<CoursesState> {
  final CourseRepository _repository;

  CoursesNotifier(this._repository) : super(const CoursesState()) {
    fetchCourses();
  }

  // ── FETCH ────────────────────────────────────────────────────────────────
  Future<void> fetchCourses() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getCourses();
      final lastSync = await _repository.getLastSyncTime();
      state = CoursesState(
        courses: result.courses,
        fromCache: result.fromCache,
        lastSync: lastSync,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<bool> addCourse({required String title, required String body}) async {
    try {
      final course = await _repository.createCourse(title: title, body: body);
      state = state.copyWith(courses: [course, ...state.courses]);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }

  // ── UPDATE (Optimistic) ───────────────────────────────────────────────────
  Future<bool> updateCourse(Course updated) async {
    final oldList = List<Course>.from(state.courses);

    // Optimistic update
    state = state.copyWith(
      courses: state.courses
          .map((c) => c.id == updated.id ? updated.copyWith(isPendingUpdate: true) : c)
          .toList(),
    );

    try {
      final confirmed = await _repository.updateCourse(updated);
      state = state.copyWith(
        courses: state.courses
            .map((c) => c.id == confirmed.id ? confirmed : c)
            .toList(),
      );
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(courses: oldList, error: 'Update failed. Changes reverted.');
      return false;
    }
  }

  // ── DELETE (Optimistic) ───────────────────────────────────────────────────
  Future<bool> deleteCourse(int id) async {
    final oldList = List<Course>.from(state.courses);

    // Optimistic delete
    state = state.copyWith(
      courses: state.courses.where((c) => c.id != id).toList(),
    );

    try {
      await _repository.deleteCourse(id);
      return true;
    } catch (e) {
      // Rollback
      state = state.copyWith(courses: oldList, error: 'Delete failed. Item restored.');
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final coursesProvider =
    StateNotifierProvider<CoursesNotifier, CoursesState>((ref) {
  return CoursesNotifier(ref.watch(courseRepositoryProvider));
});

// ── FILTERED COURSES ──────────────────────────────────────────────────────
final filteredCoursesProvider = Provider<List<Course>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final courses = ref.watch(coursesProvider).courses;
  if (query.isEmpty) return courses;
  return courses
      .where((c) =>
          c.title.toLowerCase().contains(query) ||
          c.body.toLowerCase().contains(query))
      .toList();
});
