import 'package:hive/hive.dart';

part 'course_model.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final int userId;

  // Optimistic update: track if pending remote sync
  @HiveField(4)
  final bool isPendingDelete;

  @HiveField(5)
  final bool isPendingUpdate;

  const Course({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    this.isPendingDelete = false,
    this.isPendingUpdate = false,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      userId: json['userId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
    };
  }

  Course copyWith({
    int? id,
    String? title,
    String? body,
    int? userId,
    bool? isPendingDelete,
    bool? isPendingUpdate,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      userId: userId ?? this.userId,
      isPendingDelete: isPendingDelete ?? this.isPendingDelete,
      isPendingUpdate: isPendingUpdate ?? this.isPendingUpdate,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Course(id: $id, title: $title)';
}
