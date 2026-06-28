import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/course_model.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class CourseApiService {
  static const String _baseUrl = 'https://jsonplaceholder.typicode.com';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  CourseApiService({http.Client? client}) : _client = client ?? http.Client();

  // ── READ ──────────────────────────────────────────────────────────────────
  Future<List<Course>> fetchCourses() async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/posts'))
          .timeout(_timeout);

      _assertSuccess(response);

      final List<dynamic> json = jsonDecode(response.body);
      // Limit to 20 for UX
      return json.take(20).map((e) => Course.fromJson(e)).toList();
    } on SocketException {
      throw const ApiException('No internet connection');
    } on HttpException {
      throw const ApiException('HTTP error occurred');
    } on FormatException {
      throw const ApiException('Failed to parse response');
    }
  }

  // ── CREATE ────────────────────────────────────────────────────────────────
  Future<Course> createCourse({
    required String title,
    required String body,
    int userId = 1,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/posts'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'title': title, 'body': body, 'userId': userId}),
          )
          .timeout(_timeout);

      _assertSuccess(response);
      return Course.fromJson(jsonDecode(response.body));
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  // ── UPDATE ────────────────────────────────────────────────────────────────
  Future<Course> updateCourse(Course course) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/posts/${course.id}'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(course.toJson()),
          )
          .timeout(_timeout);

      _assertSuccess(response);
      return Course.fromJson(jsonDecode(response.body));
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  // ── DELETE ────────────────────────────────────────────────────────────────
  Future<void> deleteCourse(int id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$_baseUrl/posts/$id'))
          .timeout(_timeout);

      _assertSuccess(response);
    } on SocketException {
      throw const ApiException('No internet connection');
    }
  }

  void _assertSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'Request failed',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
