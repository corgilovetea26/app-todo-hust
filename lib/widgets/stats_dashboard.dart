import 'package:flutter/material.dart';
import '../models/todo_item.dart';

class StatsDashboard extends StatelessWidget {
  final List<TodoItem> allTodos;
  final List<TodoItem> visibleTodos;

  const StatsDashboard({
    super.key,
    required this.allTodos,
    required this.visibleTodos,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate stats
    final totalTasks = visibleTodos.length;
    final completedTasks = visibleTodos.where((t) => t.done).length;
    final activeTasks = totalTasks - completedTasks;
    final completionRate = totalTasks == 0 ? 0 : (completedTasks / totalTasks * 100).toStringAsFixed(1);
    
    final overdueTasks = visibleTodos.where((t) {
      if (t.done || t.dueDate == null) return false;
      final dueDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return dueDate.isBefore(today);
    }).length;

    final todayTasks = visibleTodos.where((t) {
      if (t.dueDate == null) return false;
      final dueDate = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
      return dueDate == today;
    }).length;

    final highPriority = visibleTodos.where((t) => t.priority == Priority.high).length;
    final mediumPriority = visibleTodos.where((t) => t.priority == Priority.medium).length;
    final lowPriority = visibleTodos.where((t) => t.priority == Priority.low).length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _StatCard(
              title: 'Total',
              value: '$totalTasks',
              icon: Icons.list,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            _StatCard(
              title: 'Active',
              value: '$activeTasks',
              icon: Icons.play_arrow,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            _StatCard(
              title: 'Done',
              value: '$completedTasks',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
            const SizedBox(width: 8),
            _StatCard(
              title: 'Completion',
              value: '$completionRate%',
              icon: Icons.percent,
              color: Colors.purple,
            ),
            const SizedBox(width: 8),
            if (overdueTasks > 0)
              _StatCard(
                title: 'Overdue',
                value: '$overdueTasks',
                icon: Icons.warning,
                color: Colors.red,
              ),
            if (overdueTasks > 0) const SizedBox(width: 8),
            _StatCard(
              title: 'Today',
              value: '$todayTasks',
              icon: Icons.today,
              color: const Color(0xFFf57c00),
            ),
            const SizedBox(width: 8),
            _StatCard(
              title: 'Priority',
              value: '$highPriority/$mediumPriority/$lowPriority',
              subtitle: 'H/M/L',
              icon: Icons.flag,
              color: const Color(0xFFd32f2f),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
