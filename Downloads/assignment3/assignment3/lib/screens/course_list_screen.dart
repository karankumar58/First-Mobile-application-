import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/course_providers.dart';
import '../models/course_model.dart';
import '../widgets/common_widgets.dart';
import 'course_form_screen.dart';
import 'course_detail_screen.dart';

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await ref.read(coursesProvider.notifier).fetchCourses();
  }

  Future<void> _confirmDelete(BuildContext context, Course course) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Delete "${course.title}"?\nThis cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success =
          await ref.read(coursesProvider.notifier).deleteCourse(course.id);
      if (context.mounted) {
        success
            ? showSuccessSnackbar(context, 'Course deleted')
            : showErrorSnackbar(context, 'Delete failed. Item restored.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(coursesProvider);
    final filteredCourses = ref.watch(filteredCoursesProvider);

    // Show errors via snackbar
    ref.listen<CoursesState>(coursesProvider, (_, next) {
      if (next.error != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            showErrorSnackbar(context, next.error!);
            ref.read(coursesProvider.notifier).clearError();
          }
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        centerTitle: false,
        actions: [
          if (state.fromCache)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: const Text('Cached', style: TextStyle(fontSize: 11)),
                avatar: const Icon(Icons.storage, size: 14),
                visualDensity: VisualDensity.compact,
                backgroundColor: Colors.amber.shade100,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _onRefresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses…',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(searchQueryProvider.notifier)
                              .state = '';
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
              onChanged: (val) =>
                  ref.read(searchQueryProvider.notifier).state = val,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const ConnectivityBanner(),
          // Last sync info
          if (state.lastSync != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Last synced: ${_formatTime(state.lastSync!)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            ),
          Expanded(
            child: _buildBody(state, filteredCourses),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const CourseFormScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  Widget _buildBody(CoursesState state, List<Course> courses) {
    if (state.isLoading) {
      return const LoadingWidget(message: 'Fetching courses…');
    }

    if (state.hasError && courses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.cloud_off,
        title: 'Could not load courses',
        subtitle: state.error ?? 'An error occurred',
        onAction: _onRefresh,
        actionLabel: 'Try Again',
      );
    }

    if (courses.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.school_outlined,
        title: 'No courses found',
        subtitle: _searchController.text.isNotEmpty
            ? 'Try a different search term'
            : 'Add a course to get started',
        onAction: _searchController.text.isNotEmpty ? null : () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const CourseFormScreen()));
        },
        actionLabel: 'Add Course',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: courses.length,
        itemBuilder: (ctx, i) {
          final course = courses[i];
          return CourseTile(
            course: course,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CourseDetailScreen(course: course)),
            ),
            onEdit: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CourseFormScreen(course: course)),
            ),
            onDelete: () => _confirmDelete(context, course),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
