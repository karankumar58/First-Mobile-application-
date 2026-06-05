import 'package:flutter/material.dart';

import '../controllers/auth_controller.dart';
import '../models/course_model.dart';
import '../services/course_api_service.dart';
import '../utils/app_theme.dart';
import 'course_form_screen.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AuthController authController;

  const DashboardScreen({super.key, required this.authController});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CourseApiService _courseService = CourseApiService();
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _temporaryId = 1000;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final courses = await _courseService.fetchCourses();
      if (!mounted) return;
      setState(() => _courses = courses);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addCourse() async {
    final course = await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (_) => const CourseFormScreen()),
    );

    if (course == null) return;
    await _runCourseAction(
      successMessage: 'Course added successfully',
      action: () async {
        final created = await _courseService.addCourse(course);
        final localCourse = created.copyWith(
          id: created.id ?? ++_temporaryId,
          title: course.title,
          description: course.description,
        );
        setState(() => _courses.insert(0, localCourse));
      },
    );
  }

  Future<void> _editCourse(Course course) async {
    final updatedCourse = await Navigator.of(context).push<Course>(
      MaterialPageRoute(builder: (_) => CourseFormScreen(course: course)),
    );

    if (updatedCourse == null) return;
    await _runCourseAction(
      successMessage: 'Course updated successfully',
      action: () async {
        final updated = await _courseService.updateCourse(updatedCourse);
        final index = _courses.indexWhere((item) => item.id == course.id);
        if (index != -1) {
          setState(() {
            _courses[index] = updated.copyWith(
              id: course.id,
              title: updatedCourse.title,
              description: updatedCourse.description,
            );
          });
        }
      },
    );
  }

  Future<void> _deleteCourse(Course course) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Course',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'Are you sure you want to delete "${course.title}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              minimumSize: const Size(90, 40),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || course.id == null) return;

    await _runCourseAction(
      successMessage: 'Course deleted successfully',
      action: () async {
        await _courseService.deleteCourse(course.id!);
        setState(() => _courses.removeWhere((item) => item.id == course.id));
      },
    );
  }

  Future<void> _runCourseAction({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    widget.authController.logout();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.authController.currentUser;
    final initials = user?.fullName
            .trim()
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
            .take(2)
            .join() ??
        'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh courses',
            onPressed: _isLoading ? null : _fetchCourses,
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _addCourse,
        tooltip: 'Add course',
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchCourses,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _userCard(userName: user?.fullName, email: user?.email, initials: initials),
              const SizedBox(height: 28),
              const Text(
                'Course API Integration',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'JSONPlaceholder CRUD using GET, POST, PUT, and DELETE',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 16),
              if (_isLoading && _courses.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_errorMessage != null && _courses.isEmpty)
                _errorCard()
              else ...[
                if (_isLoading) const LinearProgressIndicator(),
                if (_isLoading) const SizedBox(height: 12),
                ..._courses.map(
                  (course) => _CourseCard(
                    course: course,
                    onView: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(course: course),
                      ),
                    ),
                    onEdit: () => _editCourse(course),
                    onDelete: () => _deleteCourse(course),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _userCard({String? userName, String? email, required String initials}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, Color(0xFF1971C2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${userName ?? 'Student'}!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email ?? '',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 34),
          const SizedBox(height: 12),
          Text(
            _errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _fetchCourses,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(color: AppTheme.textPrimary)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _logout(context);
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.course,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.school_outlined,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${course.id ?? 'New'}',
                      style: const TextStyle(
                        color: AppTheme.accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            course.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: onView,
                tooltip: 'View details',
                icon: const Icon(Icons.visibility_outlined),
              ),
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit course',
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete course',
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
