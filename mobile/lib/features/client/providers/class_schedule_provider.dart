import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/dio_provider.dart';
import '../services/class_schedule_service.dart';

part 'class_schedule_provider.g.dart';

@Riverpod(keepAlive: true)
ClassScheduleService classScheduleService(Ref ref) {
  final client = ref.watch(dioClientProvider);
  return ClassScheduleService(client: client);
}

/// Fetches the weekly class schedule for a student.
@riverpod
Future<WeeklyScheduleData> weeklySchedule(
    Ref ref, String studentId) async {
  final service = ref.watch(classScheduleServiceProvider);
  final data = await service.getWeeklySchedule(studentId);
  final days = (data['days'] as List?) ?? [];

  return WeeklyScheduleData(
    days: days.map((d) => ScheduleDay.fromJson(d as Map<String, dynamic>)).toList(),
  );
}

class WeeklyScheduleData {
  final List<ScheduleDay> days;
  WeeklyScheduleData({required this.days});
}

class ScheduleDay {
  final int dayOfWeek;
  final String dayName;
  final List<ScheduleSlot> slots;

  ScheduleDay({
    required this.dayOfWeek,
    required this.dayName,
    required this.slots,
  });

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final slotsList = (json['slots'] as List?) ?? [];
    return ScheduleDay(
      dayOfWeek: json['day_of_week'] as int,
      dayName: json['day_name'] as String,
      slots: slotsList
          .map((s) => ScheduleSlot.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ScheduleSlot {
  final String id;
  final String courseId;
  final String courseCode;
  final String courseName;
  final String? professor;
  final String? description;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String? room;

  ScheduleSlot({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.courseName,
    this.professor,
    this.description,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.room,
  });

  factory ScheduleSlot.fromJson(Map<String, dynamic> json) {
    return ScheduleSlot(
      id: json['id'] as String,
      courseId: json['course_id'] as String,
      courseCode: json['course_code'] as String,
      courseName: json['course_name'] as String,
      professor: json['professor'] as String?,
      description: json['description'] as String?,
      dayOfWeek: json['day_of_week'] as int,
      startTime: _formatTime(json['start_time']),
      endTime: _formatTime(json['end_time']),
      room: json['room'] as String?,
    );
  }

  /// Format time string from "HH:MM:SS" to "HH:MM"
  static String _formatTime(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    // Handle "HH:MM:SS" -> "HH:MM"
    if (str.length >= 5) return str.substring(0, 5);
    return str;
  }
}
