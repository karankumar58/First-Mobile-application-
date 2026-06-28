import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/course_model.dart';
import '../providers/course_providers.dart';
import '../widgets/common_widgets.dart';

class CourseFormScreen extends ConsumerStatefulWidget {
  final Course? course; // null = create, non-null = edit

  const CourseFormScreen({super.key, this.course});

  @override
  ConsumerState<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends ConsumerState<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  bool _isSubmitting = false;

  bool get isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.course?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.course?.body ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    bool success;
    if (isEditing) {
      final updated = widget.course!.copyWith(
        title: _titleCtrl.text.trim(),
        body: _bodyCtrl.text.trim(),
      );
      success = await ref.read(coursesProvider.notifier).updateCourse(updated);
    } else {
      success = await ref.read(coursesProvider.notifier).addCourse(
            title: _titleCtrl.text.trim(),
            body: _bodyCtrl.text.trim(),
          );
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        showSuccessSnackbar(
          context,
          isEditing ? 'Course updated!' : 'Course added!',
        );
        Navigator.pop(context);
      } else {
        showErrorSnackbar(context, isEditing ? 'Update failed' : 'Failed to add course');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add Course'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              TextFormField(
                controller: _titleCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Course Title *',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Title is required';
                  }
                  if (val.trim().length < 5) {
                    return 'Title must be at least 5 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Body / Description
              TextFormField(
                controller: _bodyCtrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Course Description *',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 60),
                    child: Icon(Icons.description),
                  ),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (val.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),

              // Submit
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(isEditing ? Icons.save : Icons.add),
                label: Text(
                  _isSubmitting
                      ? 'Saving…'
                      : isEditing
                          ? 'Save Changes'
                          : 'Add Course',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              if (isEditing) ...[
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
