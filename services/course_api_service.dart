import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course_model.dart';

class CourseApiService {
  CourseApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  Future<List<Course>> fetchCourses() async {
    final response = await _client.get(Uri.parse('$_baseUrl/posts'));

    if (response.statusCode != 200) {
      throw Exception('Unable to fetch courses. Status: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .take(20)
        .toList();
  }

  Future<Course> addCourse(Course course) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/posts'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode != 201) {
      throw Exception('Unable to add course. Status: ${response.statusCode}');
    }

    return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Course> updateCourse(Course course) async {
    final id = course.id;
    if (id == null) {
      throw Exception('Course id is required for update.');
    }

    final response = await _client.put(
      Uri.parse('$_baseUrl/posts/$id'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(course.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to update course. Status: ${response.statusCode}');
    }

    return Course.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteCourse(int id) async {
    final response = await _client.delete(Uri.parse('$_baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Unable to delete course. Status: ${response.statusCode}');
    }
  }
}
