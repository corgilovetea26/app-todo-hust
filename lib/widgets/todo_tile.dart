import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class TodoTile extends StatelessWidget {
  final TodoItem todo;
  final void Function() onToggle;
  final void Function() onDelete;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            // Colored stripe
            Container(width: 4, height: 84, color: _getDueDateColor()),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: todo.done,
                          onChanged: (_) => onToggle(),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        Expanded(
                          child: Text(
                            todo.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: todo.done ? TextDecoration.lineThrough : null,
                              color: todo.done ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                        PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          onSelected: (v) {
                            if (v == 'delete') onDelete();
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildPriorityBadge(),
                        const SizedBox(width: 8),
                        if (todo.tags.isNotEmpty) ...[
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: todo.tags.map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: Colors.blue[50],
                              )).toList(),
                            ),
                          ),
                        ],
                        if (todo.dueDate != null) ...[
                          const SizedBox(width: 8),
                          Chip(
                            avatar: Icon(Icons.calendar_today, size: 14, color: _getDueDateColor()),
                            label: Text(_formatDate(todo.dueDate!), style: TextStyle(fontSize: 11, color: _getDueDateColor())),
                            visualDensity: VisualDensity.compact,
                            backgroundColor: Colors.transparent,
                            side: BorderSide(color: _getDueDateColor()),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge() {
    final colors = {
      Priority.high: const Color(0xFFd32f2f),
      Priority.medium: const Color(0xFFf57c00),
      Priority.low: const Color(0xFF2e7d32),
    };
    final labels = {
      Priority.high: 'High',
      Priority.medium: 'Medium',
      Priority.low: 'Low',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colors[todo.priority]!.withValues(alpha: 0.2),
        border: Border.all(color: colors[todo.priority]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        labels[todo.priority]!,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colors[todo.priority],
        ),
      ),
    );
  }

  Color _getDueDateColor() {
    if (todo.dueDate == null) return Colors.orange;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      todo.dueDate!.year,
      todo.dueDate!.month,
      todo.dueDate!.day,
    );
    
    if (dueDate.isBefore(today)) {
      return const Color(0xFFd32f2f); // Red - Overdue
    } else if (dueDate == today) {
      return const Color(0xFFf57c00); // Orange - Today
    } else if (dueDate == today.add(const Duration(days: 1))) {
      return const Color(0xFF0277bd); // Blue - Tomorrow
    }
    return Colors.grey[400]!; // Gray - Future
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    }
    
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}

