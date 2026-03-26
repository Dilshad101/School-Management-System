import 'package:equatable/equatable.dart';

/// Model representing a timetable entry for a period on a specific day.
class TimetableEntryModel extends Equatable {
  const TimetableEntryModel({
    required this.id,
    required this.dayOfWeek,
    this.subjectId,
    this.subjectName,
    this.teacherId,
    this.teacherName,
    this.periodId,
    this.classroomId,
  });

  final String id;
  final int dayOfWeek; // 0 = Monday, 1 = Tuesday, etc.
  final String? subjectId;
  final String? subjectName;
  final String? teacherId;
  final String? teacherName;
  final String? periodId;
  final String? classroomId;

  bool get isAssigned => subjectId != null && teacherId != null;

  factory TimetableEntryModel.fromJson(Map<String, dynamic> json) {
    // Handle subject - can be a string ID or an object with id and name
    String? subjectId;
    String? subjectName;
    final subject = json['subject'];
    if (subject is Map<String, dynamic>) {
      subjectId = subject['id']?.toString();
      subjectName = subject['name']?.toString();
    } else if (subject != null) {
      subjectId = subject.toString();
      subjectName = json['subject_name']?.toString();
    }

    // Handle teacher - can be a string ID or an object with id and name
    String? teacherId;
    String? teacherName;
    final teacher = json['teacher'];
    if (teacher is Map<String, dynamic>) {
      teacherId = teacher['id']?.toString();
      teacherName = teacher['name']?.toString();
    } else if (teacher != null) {
      teacherId = teacher.toString();
      teacherName = json['teacher_name']?.toString();
    }

    return TimetableEntryModel(
      id: json['id']?.toString() ?? '',
      dayOfWeek: _parseDayOfWeek(json['day_of_week']),
      subjectId: subjectId,
      subjectName: subjectName,
      teacherId: teacherId,
      teacherName: teacherName,
      periodId: json['period']?.toString(),
      classroomId: json['classroom']?.toString(),
    );
  }

  static int _parseDayOfWeek(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
    id,
    dayOfWeek,
    subjectId,
    subjectName,
    teacherId,
    teacherName,
    periodId,
    classroomId,
  ];
}

/// Model representing a period with its timetable entries.
class PeriodWithTimetableModel extends Equatable {
  const PeriodWithTimetableModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.order,
    required this.school,
    this.timetable,
  });

  final String id;
  final String startTime;
  final String endTime;
  final int order;
  final String school;
  final List<TimetableEntryModel>? timetable;

  /// Formats time from "HH:mm:ss" to "HH:mm AM/PM"
  String get formattedStartTime => _formatTime(startTime);
  String get formattedEndTime => _formatTime(endTime);

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return time;

      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';

      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '$hour:$minute $period';
    } catch (_) {
      return time;
    }
  }

  /// Gets the timetable entry for a specific day.
  /// [dayIndex] is 0-based (0 = Monday), but API stores 1-based (1 = Monday)
  TimetableEntryModel? getEntryForDay(int dayIndex) {
    final apiDayOfWeek = dayIndex + 1; // Convert to 1-based for API comparison
    return timetable?.firstWhere(
      (entry) => entry.dayOfWeek == apiDayOfWeek,
      orElse: () => TimetableEntryModel(id: '', dayOfWeek: apiDayOfWeek),
    );
  }

  factory PeriodWithTimetableModel.fromJson(Map<String, dynamic> json) {
    final timetableList = (json['timetable'] as List<dynamic>?)
        ?.map((e) => TimetableEntryModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PeriodWithTimetableModel(
      id: json['id']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      order: _parseInt(json['order']),
      school: json['school']?.toString() ?? '',
      timetable: timetableList,
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [id, startTime, endTime, order, school, timetable];
}

/// Response model for timetable (list of periods with timetable entries).
class TimetableResponse extends Equatable {
  const TimetableResponse({required this.periods});

  final List<PeriodWithTimetableModel> periods;

  factory TimetableResponse.fromJson(Map<String, dynamic> json) {
    // API returns: { "data": [ { "day_of_week": 1, "periods": [...] }, ... ] }
    final dataList = json['data'] as List<dynamic>? ?? [];

    // Transform the day-based structure into a period-based structure
    final Map<String, PeriodBuilder> periodMap = {};

    for (final dayData in dataList) {
      final dayOfWeek = dayData['day_of_week'] as int;
      final periods = dayData['periods'] as List<dynamic>? ?? [];

      for (final periodData in periods) {
        final periodId = periodData['period']?.toString() ?? '';
        final timetableData = periodData['timetable'];

        // Initialize period builder if not exists
        periodMap.putIfAbsent(
          periodId,
          () => PeriodBuilder(periodId: periodId),
        );

        // Add timetable entry for this day if exists
        if (timetableData != null && timetableData is Map<String, dynamic>) {
          periodMap[periodId]!.addEntry(
            TimetableEntryModel.fromJson({
              ...timetableData,
              'day_of_week': dayOfWeek,
            }),
          );
        }
      }
    }

    // Convert to list and sort by period order (using periodId for now)
    final periodsList = periodMap.values
        .map((builder) => builder.build())
        .toList();

    return TimetableResponse(periods: periodsList);
  }

  /// Creates a TimetableResponse by merging timetable data with period details.
  factory TimetableResponse.fromJsonWithPeriods({
    required Map<String, dynamic> timetableJson,
    required Map<String, dynamic> periodsJson,
  }) {
    // Parse periods data to get period details
    // Periods API returns: { "data": { "results": [...] } } or { "results": [...] }
    final periodsData =
        periodsJson['data'] as Map<String, dynamic>? ?? periodsJson;
    final periodsList =
        periodsData['results'] as List<dynamic>? ??
        (periodsJson['results'] as List<dynamic>?) ??
        [];

    // Create a map of period details by ID
    final Map<String, Map<String, dynamic>> periodDetailsMap = {};
    for (final period in periodsList) {
      final periodMap = period as Map<String, dynamic>;
      final id = periodMap['id']?.toString() ?? '';
      if (id.isNotEmpty) {
        periodDetailsMap[id] = periodMap;
      }
    }

    // Parse timetable data
    // Timetable API returns: { "data": [ { "day_of_week": 1, "periods": [...] }, ... ] }
    final timetableDataList = timetableJson['data'] as List<dynamic>? ?? [];

    // Build period map with timetable entries
    final Map<String, PeriodBuilder> periodBuilderMap = {};

    for (final dayData in timetableDataList) {
      final dayOfWeek = dayData['day_of_week'] as int;
      final periods = dayData['periods'] as List<dynamic>? ?? [];

      for (final periodData in periods) {
        final periodId = periodData['period']?.toString() ?? '';
        final timetableData = periodData['timetable'];

        // Get period details from the periods map
        final details = periodDetailsMap[periodId];

        // Initialize period builder if not exists
        periodBuilderMap.putIfAbsent(
          periodId,
          () => PeriodBuilder(
            periodId: periodId,
            startTime: details?['start_time']?.toString() ?? '',
            endTime: details?['end_time']?.toString() ?? '',
            order: _parseInt(details?['order']),
            school: details?['school']?.toString() ?? '',
          ),
        );

        // Add timetable entry for this day if exists
        if (timetableData != null && timetableData is Map<String, dynamic>) {
          periodBuilderMap[periodId]!.addEntry(
            TimetableEntryModel.fromJson({
              ...timetableData,
              'day_of_week': dayOfWeek,
            }),
          );
        }
      }
    }

    // Convert to list and sort by period order
    final resultPeriods = periodBuilderMap.values
        .map((builder) => builder.build())
        .toList();
    resultPeriods.sort((a, b) => a.order.compareTo(b.order));

    return TimetableResponse(periods: resultPeriods);
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [periods];
}

/// Helper class to build PeriodWithTimetableModel from day-based API response.
class PeriodBuilder {
  PeriodBuilder({
    required this.periodId,
    this.startTime = '',
    this.endTime = '',
    this.order = 0,
    this.school = '',
  });

  final String periodId;
  final String startTime;
  final String endTime;
  final int order;
  final String school;
  final List<TimetableEntryModel> entries = [];

  void addEntry(TimetableEntryModel entry) {
    entries.add(entry);
  }

  PeriodWithTimetableModel build() {
    return PeriodWithTimetableModel(
      id: periodId,
      startTime: startTime,
      endTime: endTime,
      order: order,
      school: school,
      timetable: entries.isEmpty ? null : entries,
    );
  }
}
