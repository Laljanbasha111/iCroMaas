import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Enum representing the type of reminder.
enum ReminderType {
  irrigation,
  fertilizer,
  pesticide,
  harvest,
  general,
  weatherAlert,
  diseaseCheck,
}

/// Enum representing the priority level of a reminder.
enum ReminderPriority { low, medium, high, urgent }

/// Enum representing the current status of a reminder.
enum ReminderStatus { pending, completed, cancelled, overdue }

/// Enum representing the frequency of a reminder.
enum ReminderFrequency { once, daily, weekly, monthly, custom }

/// ReminderModel represents a scheduled task or alert in the Crop Analyzer app.
class ReminderModel {
  final String id;
  final String title;
  final String description;
  final ReminderType type;
  final ReminderPriority priority;
  ReminderStatus status;
  final ReminderFrequency frequency;
  DateTime scheduledDateTime;
  DateTime? completedDateTime;
  final String? cropId;
  final String? fieldId;
  final String userId;
  final bool isRecurring;
  final bool notificationEnabled;
  final DateTime createdAt;
  DateTime updatedAt;
  final Map<String, dynamic>? metadata;

  ReminderModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.status,
    required this.frequency,
    required this.scheduledDateTime,
    this.completedDateTime,
    this.cropId,
    this.fieldId,
    required this.userId,
    this.isRecurring = false,
    this.notificationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
  });

  /// Factory constructor to create a ReminderModel from a Map.
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? UniqueKey().toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: ReminderType.values.firstWhere(
            (e) => describeEnum(e) == map['type'],
        orElse: () => ReminderType.general,
      ),
      priority: ReminderPriority.values.firstWhere(
            (e) => describeEnum(e) == map['priority'],
        orElse: () => ReminderPriority.medium,
      ),
      status: ReminderStatus.values.firstWhere(
            (e) => describeEnum(e) == map['status'],
        orElse: () => ReminderStatus.pending,
      ),
      frequency: ReminderFrequency.values.firstWhere(
            (e) => describeEnum(e) == map['frequency'],
        orElse: () => ReminderFrequency.once,
      ),
      scheduledDateTime: DateTime.tryParse(map['scheduledDateTime'] ?? '') ?? DateTime.now(),
      completedDateTime: map['completedDateTime'] != null
          ? DateTime.tryParse(map['completedDateTime'])
          : null,
      cropId: map['cropId'],
      fieldId: map['fieldId'],
      userId: map['userId'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      notificationEnabled: map['notificationEnabled'] ?? true,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : {},
    );
  }

  /// Converts ReminderModel to a Map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': describeEnum(type),
      'priority': describeEnum(priority),
      'status': describeEnum(status),
      'frequency': describeEnum(frequency),
      'scheduledDateTime': scheduledDateTime.toIso8601String(),
      'completedDateTime': completedDateTime?.toIso8601String(),
      'cropId': cropId,
      'fieldId': fieldId,
      'userId': userId,
      'isRecurring': isRecurring,
      'notificationEnabled': notificationEnabled,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Factory constructor to create a ReminderModel from a JSON string.
  factory ReminderModel.fromJson(String jsonStr) {
    final Map<String, dynamic> map = jsonDecode(jsonStr);
    return ReminderModel.fromMap(map);
  }

  /// Converts ReminderModel to a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Creates a copy of the ReminderModel with optional modifications.
  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    ReminderPriority? priority,
    ReminderStatus? status,
    ReminderFrequency? frequency,
    DateTime? scheduledDateTime,
    DateTime? completedDateTime,
    String? cropId,
    String? fieldId,
    String? userId,
    bool? isRecurring,
    bool? notificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      completedDateTime: completedDateTime ?? this.completedDateTime,
      cropId: cropId ?? this.cropId,
      fieldId: fieldId ?? this.fieldId,
      userId: userId ?? this.userId,
      isRecurring: isRecurring ?? this.isRecurring,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Factory constructor for an empty reminder.
  factory ReminderModel.empty() {
    return ReminderModel(
      id: UniqueKey().toString(),
      title: '',
      description: '',
      type: ReminderType.general,
      priority: ReminderPriority.medium,
      status: ReminderStatus.pending,
      frequency: ReminderFrequency.once,
      scheduledDateTime: DateTime.now(),
      userId: '',
      isRecurring: false,
      notificationEnabled: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metadata: const {},
    );
  }

  /// Marks the reminder as completed.
  void markAsCompleted() {
    status = ReminderStatus.completed;
    completedDateTime = DateTime.now();
    updatedAt = DateTime.now();
  }

  /// Marks the reminder as cancelled.
  void markAsCancelled() {
    status = ReminderStatus.cancelled;
    updatedAt = DateTime.now();
  }

  /// Reschedules the reminder to a new date and time.
  void reschedule(DateTime newDateTime) {
    scheduledDateTime = newDateTime;
    status = ReminderStatus.pending;
    updatedAt = DateTime.now();
  }

  /// Returns true if the reminder is completed.
  bool get isCompleted => status == ReminderStatus.completed;

  /// Returns true if the reminder is pending.
  bool get isPending => status == ReminderStatus.pending;

  /// Returns true if the reminder is overdue.
  bool get isOverdue =>
      status == ReminderStatus.pending && DateTime.now().isAfter(scheduledDateTime);

  /// Returns true if the reminder is cancelled.
  bool get isCancelled => status == ReminderStatus.cancelled;

  /// Returns the number of days until the reminder is due.
  int get daysUntilDue {
    final diff = scheduledDateTime.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  /// Returns a formatted date string (e.g., "12 Mar 2026").
  String get formattedDate {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${scheduledDateTime.day} ${months[scheduledDateTime.month - 1]} ${scheduledDateTime.year}';
  }

  /// Returns a formatted time string (e.g., "10:45 AM").
  String get formattedTime {
    final hour = scheduledDateTime.hour > 12
        ? scheduledDateTime.hour - 12
        : scheduledDateTime.hour;
    final minute = scheduledDateTime.minute.toString().padLeft(2, '0');
    final period = scheduledDateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  /// Returns a color based on the reminder priority.
  Color get priorityColor {
    switch (priority) {
      case ReminderPriority.low:
        return Colors.green;
      case ReminderPriority.medium:
        return Colors.blue;
      case ReminderPriority.high:
        return Colors.orange;
      case ReminderPriority.urgent:
        return Colors.red;
    }
  }

  /// Returns an icon based on the reminder type.
  IconData get typeIcon {
    switch (type) {
      case ReminderType.irrigation:
        return Icons.water_drop;
      case ReminderType.fertilizer:
        return Icons.grass;
      case ReminderType.pesticide:
        return Icons.bug_report;
      case ReminderType.harvest:
        return Icons.agriculture;
      case ReminderType.general:
        return Icons.notifications;
      case ReminderType.weatherAlert:
        return Icons.cloud;
      case ReminderType.diseaseCheck:
        return Icons.local_hospital;
    }
  }

  @override
  String toString() {
    return 'ReminderModel(id: $id, title: $title, type: $type, priority: $priority, '
        'status: $status, scheduledDateTime: $scheduledDateTime, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}