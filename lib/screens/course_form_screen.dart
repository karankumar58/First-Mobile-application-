import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../utils/app_theme.dart';
import '../validators/app_validator.dart';

class CourseFormScreen extends StatefulWidget {
  final Course? course;

  const CourseFormScreen({super.key, this.course});

  @override
  State<CourseFormScreen> createState() => _CourseFormScreenState();
}

class _CourseFormScreenState extends State<CourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();
    final course = widget.course;
    if (course != null) {
      _titleController.text = course.title;
      _descriptionController.text = course.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final existing = widget.course;
    final course = Course(
      id: existing?.id,
      userId: existing?.userId ?? 1,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(course);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Course' : 'Add Course'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing ? 'Update course details' : 'Create a new course',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Data is sent to JSONPlaceholder posts API.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),
                _label('Course Title'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Enter course title',
                    prefixIcon: Icon(Icons.menu_book_outlined),
                  ),
                  validator: (value) =>
                      AppValidator.validateRequired(value, 'Course title'),
                ),
                const SizedBox(height: 18),
                _label('Description'),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 5,
                  maxLines: 8,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Enter course description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (value) =>
                      AppValidator.validateRequired(value, 'Description'),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(_isEditing ? Icons.save_outlined : Icons.add),
                  label: Text(_isEditing ? 'Update Course' : 'Add Course'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
