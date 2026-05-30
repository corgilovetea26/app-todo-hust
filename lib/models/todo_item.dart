import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { low, medium, high }

class TodoItem {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String ownerId;
  final Priority priority;
  final List<String> tags;

  const TodoItem({
    required this.id,
    required this.title,
    this.done = false,
    this.dueDate,
    required this.createdAt,
    required this.ownerId,
    this.priority = Priority.medium,
    this.tags = const [],
  });

  TodoItem copyWith({
    String? title,
    bool? done,
    DateTime? dueDate,
    DateTime? createdAt,
    String? ownerId,
    Priority? priority,
    List<String>? tags,
  }) {
    return TodoItem(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
      'priority': priority.toString().split('.').last,
      'tags': tags,
    };
  }

  static TodoItem? fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = data['title'] as String?;
    final done = data['done'] as bool?;
    final createdAt = data['createdAt'] as Timestamp?;
    final dueDate = data['dueDate'] as Timestamp?;
    final ownerId = data['ownerId'] as String?;
    final priorityStr = data['priority'] as String?;
    final tagsList = data['tags'] as List?;

    if (title == null || done == null || createdAt == null || ownerId == null) {
      return null;
    }

    Priority priority = Priority.medium;
    if (priorityStr != null) {
      priority = Priority.values.firstWhere(
        (p) => p.toString().split('.').last == priorityStr,
        orElse: () => Priority.medium,
      );
    }

    final tags = (tagsList ?? []).cast<String>().toList();

    return TodoItem(
      id: doc.id,
      title: title,
      done: done,
      dueDate: dueDate?.toDate(),
      createdAt: createdAt.toDate(),
      ownerId: ownerId,
      priority: priority,
      tags: tags,
    );
  }
}
