class Course {
  final int? id;
  final int userId;
  final String title;
  final String description;

  const Course({
    this.id,
    this.userId = 1,
    required this.title,
    required this.description,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as int?,
      userId: json['userId'] as int? ?? 1,
      title: json['title'] as String? ?? 'Untitled course',
      description: json['body'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'body': description,
    };
  }

  Course copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
  }) {
    return Course(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
    );
  }
}
