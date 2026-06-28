import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../providers/course_providers.dart';
import '../widgets/common_widgets.dart';
import 'course_form_screen.dart';

class CourseDetailScreen extends ConsumerWidget {
  final Course course;

  const CourseDetailScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Watch live state so optimistic updates reflect here too
    final liveState = ref.watch(coursesProvider);
    final liveCourse = liveState.courses.firstWhere(
      (c) => c.id == course.id,
      orElse: () => course,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CourseFormScreen(course: liveCourse)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Course'),
                  content: Text('Delete "${liveCourse.title}"?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel')),
                    FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await ref
                    .read(coursesProvider.notifier)
                    .deleteCourse(liveCourse.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              width: double.infinity,
              height: 180,
              color: theme.colorScheme.primaryContainer,
              child: Center(
                child: Icon(
                  Icons.school,
                  size: 72,
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.6),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge (pending sync)
                  if (liveCourse.isPendingUpdate)
                    Chip(
                      label: const Text('Pending sync',
                          style: TextStyle(fontSize: 11)),
                      avatar: const Icon(Icons.sync, size: 14),
                      backgroundColor: Colors.amber.shade100,
                      visualDensity: VisualDensity.compact,
                    ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    liveCourse.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Meta row
                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.tag,
                          label: 'ID: ${liveCourse.id}'),
                      const SizedBox(width: 8),
                      _InfoChip(
                          icon: Icons.person_outline,
                          label: 'User: ${liveCourse.userId}'),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  Text('Description',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    liveCourse.body,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(height: 1.6),
                  ),
                  const Divider(height: 32),

                  // Schedule placeholder
                  Text('Schedule',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _ScheduleRow(
                      icon: Icons.access_time, label: 'Class Timing', value: 'Mon / Wed  9:00 AM – 10:30 AM'),
                  const SizedBox(height: 8),
                  _ScheduleRow(
                      icon: Icons.room_outlined, label: 'Room', value: 'Room 204, Block B'),
                  const SizedBox(height: 8),
                  _ScheduleRow(
                      icon: Icons.person, label: 'Instructor', value: 'TBD'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 14),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ScheduleRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
