import 'dart:convert';
import 'dart:io';

import 'package:mime/mime.dart';

/// Request model for creating a notification.
class CreateNotificationRequest {
  const CreateNotificationRequest({
    required this.title,
    required this.message,
    required this.notificationType,
    required this.school,
    this.attachment,
    this.dateTime,
    this.classes = const [],
    this.students = const [],
  });

  final String title;
  final String message;
  final String notificationType;
  final String school;
  final File? attachment;
  final DateTime? dateTime;
  final List<String> classes;
  final List<String> students;

  /// Converts the request to JSON format for API submission.
  Future<Map<String, dynamic>> toJson() async {
    final json = <String, dynamic>{
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'school': school,
    };

    if (attachment != null) {
      json['attachment'] = await _fileToBase64DataUri(attachment!);
    }

    if (dateTime != null) {
      json['date_time'] = dateTime!.toUtc().toIso8601String();
    }

    if (classes.isNotEmpty) {
      json['classes'] = classes;
    }

    if (students.isNotEmpty) {
      json['students'] = students;
    }

    return json;
  }

  /// Converts a file to base64 data URI format.
  static Future<String> _fileToBase64DataUri(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
    return 'data:$mimeType;base64,$base64String';
  }
}
