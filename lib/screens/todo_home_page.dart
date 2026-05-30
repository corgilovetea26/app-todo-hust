import 'package:flutter/material.dart';

import '../models/todo_item.dart';
import '../services/auth_service.dart';
import '../services/todo_service.dart';
import '../utils/constants.dart';
import '../widgets/todo_tile.dart';
import '../widgets/stats_dashboard.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  DateTime? _filterDate;
  _FilterType _filterType = _FilterType.all;
  Priority? _priorityFilter;
  _StatusFilter _statusFilter = _StatusFilter.all;
  int _pageSize = AppSizes.pageStep;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  DateTime _startOfWeek(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  Future<void> _addTodo({
    required String title,
    DateTime? dueDate,
    required Priority priority,
    required List<String> tags,
  }) async {
    final uid = AuthService.currentUser?.uid;
    if (uid == null) {
      _showSnack('Please sign in to add todos.');
      return;
    }

    final todo = TodoItem(
      id: TodoService.generateTodoId(uid),
      title: title,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      ownerId: uid,
      priority: priority,
      tags: tags,
    );

    try {
      await TodoService.addTodo(todo);
    } catch (_) {
      _showSnack('Failed to save todo.');
    }
  }

  Future<DateTime?> _pickDate({DateTime? initialDate}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return null;
    return _dateOnly(picked);
  }

  Future<void> _showAddTodoSheet() async {
    final titleController = TextEditingController();
    final tagsController = TextEditingController();
    DateTime? dueDate;
    Priority selectedPriority = Priority.medium;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'New task',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      hintText: 'Task name...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await _pickDate(initialDate: dueDate);
                            if (picked != null) {
                              setState(() {
                                dueDate = picked;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today, size: 18),
                          label: Text(
                            dueDate == null ? 'Set due date' : 'Due: ${_formatDate(dueDate!)}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          selectedPriority.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: Priority.values.map((option) {
                      return ChoiceChip(
                        label: Text(option.name),
                        selected: selectedPriority == option,
                        selectedColor: AppColors.primary.withValues(alpha: 0.18),
                        onSelected: (_) => setState(() => selectedPriority = option),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: tagsController,
                    decoration: InputDecoration(
                      hintText: 'Tags, e.g. work, urgent',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.label_outline),
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) {
                          _showSnack('Please enter a task name.');
                          return;
                        }
                        final tags = tagsController.text
                            .split(',')
                            .map((value) => value.trim())
                            .where((value) => value.isNotEmpty)
                            .toList();
                        _addTodo(
                          title: title,
                          dueDate: dueDate,
                          priority: selectedPriority,
                          tags: tags,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Text('Add task'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showFilterSheet() async {
    var tempFilterType = _filterType;
    DateTime? tempFilterDate = _filterDate;
    var tempPriority = _priorityFilter;
    var tempStatus = _statusFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 16,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  const Text('Date', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChoice('All', tempFilterType == _FilterType.all, () {
                        setState(() {
                          tempFilterType = _FilterType.all;
                          tempFilterDate = null;
                        });
                      }),
                      _buildFilterChoice('Today', tempFilterType == _FilterType.today, () {
                        setState(() {
                          tempFilterType = _FilterType.today;
                          tempFilterDate = null;
                        });
                      }),
                      _buildFilterChoice('This Week', tempFilterType == _FilterType.thisWeek, () {
                        setState(() {
                          tempFilterType = _FilterType.thisWeek;
                          tempFilterDate = null;
                        });
                      }),
                      _buildFilterChoice('No Date', tempFilterType == _FilterType.noDate, () {
                        setState(() {
                          tempFilterType = _FilterType.noDate;
                          tempFilterDate = null;
                        });
                      }),
                      _buildFilterChoice('Pick Date', tempFilterType == _FilterType.specificDate, () async {
                        final picked = await _pickDate(initialDate: tempFilterDate);
                        if (picked != null) {
                          setState(() {
                            tempFilterType = _FilterType.specificDate;
                            tempFilterDate = picked;
                          });
                        }
                      }),
                    ],
                  ),
                    if (tempFilterType == _FilterType.specificDate && tempFilterDate != null) ...[
                      const SizedBox(height: 12),
                      Text('Date: ${_formatDate(tempFilterDate!)}', style: const TextStyle(color: Colors.grey)),
                  ],
                  const SizedBox(height: 16),
                  const Text('Status', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChoice('All', tempStatus == _StatusFilter.all, () => setState(() => tempStatus = _StatusFilter.all)),
                      _buildFilterChoice('Active', tempStatus == _StatusFilter.active, () => setState(() => tempStatus = _StatusFilter.active)),
                      _buildFilterChoice('Done', tempStatus == _StatusFilter.completed, () => setState(() => tempStatus = _StatusFilter.completed)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChoice('All', tempPriority == null, () => setState(() => tempPriority = null)),
                      _buildFilterChoice('High', tempPriority == Priority.high, () => setState(() => tempPriority = Priority.high)),
                      _buildFilterChoice('Medium', tempPriority == Priority.medium, () => setState(() => tempPriority = Priority.medium)),
                      _buildFilterChoice('Low', tempPriority == Priority.low, () => setState(() => tempPriority = Priority.low)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            tempFilterType = _FilterType.all;
                            tempFilterDate = null;
                            tempPriority = null;
                            tempStatus = _StatusFilter.all;
                          });
                        },
                        child: const Text('Clear all'),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _filterType = tempFilterType;
                            _filterDate = tempFilterDate;
                            _priorityFilter = tempPriority;
                            _statusFilter = tempStatus;
                          });
                          Navigator.of(context).pop();
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _toggleTodo(TodoItem todo) async {
    try {
      await TodoService.updateTodo(todo.copyWith(done: !todo.done));
    } catch (_) {
      _showSnack('Failed to update todo.');
    }
  }

  Future<void> _removeTodo(TodoItem todo) async {
    try {
      await TodoService.deleteTodo(todo.ownerId, todo.id);
    } catch (_) {
      _showSnack('Failed to delete todo.');
    }
  }

  Future<void> _signOut() async {
    try {
      await AuthService.signOut();
    } catch (_) {
      _showSnack('Unable to sign out. Please try again.');
    }
  }

  List<TodoItem> _applyFilters(List<TodoItem> todos) {
    final now = DateTime.now();
    final today = _dateOnly(now);
    final thisWeekStart = _startOfWeek(now);

    final dateFiltered = todos.where((todo) {
      switch (_filterType) {
        case _FilterType.all:
          return true;
        case _FilterType.today:
          return todo.dueDate != null && _dateOnly(todo.dueDate!) == today;
        case _FilterType.thisWeek:
          return todo.dueDate != null && _startOfWeek(todo.dueDate!) == thisWeekStart;
        case _FilterType.noDate:
          return todo.dueDate == null;
          case _FilterType.specificDate:
            return _filterDate != null && todo.dueDate != null && _dateOnly(todo.dueDate!) == _filterDate;
      }
    }).toList();

    final priorityFiltered = _priorityFilter != null
        ? dateFiltered.where((todo) => todo.priority == _priorityFilter).toList()
        : dateFiltered;

    final visibleTodos = priorityFiltered.where((todo) {
      if (_statusFilter == _StatusFilter.active && todo.done) {
        return false;
      }
      if (_statusFilter == _StatusFilter.completed && !todo.done) {
        return false;
      }
      return true;
    }).toList();

    visibleTodos.sort((a, b) {
      // Sort by priority first (high > medium > low)
      final priorityOrder = {Priority.high: 0, Priority.medium: 1, Priority.low: 2};
      final priorityCompare = priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      if (priorityCompare != 0) return priorityCompare;

      // Then by due date
      final ad = a.dueDate;
      final bd = b.dueDate;
      if (ad == null && bd == null) {
        return a.createdAt.compareTo(b.createdAt);
      }
      if (ad == null) return 1;
      if (bd == null) return -1;
      final dateCompare = _dateOnly(ad).compareTo(_dateOnly(bd));
      return dateCompare != 0 ? dateCompare : a.createdAt.compareTo(b.createdAt);
    });

    return visibleTodos;
  }

  void _loadMore() {
    setState(() {
      _pageSize += AppSizes.pageStep;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in again.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _showFilterSheet,
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filters',
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: AppColors.primary,
              child: Text(
                (user.displayName ?? user.email ?? 'U').substring(0, 1).toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            onSelected: (v) {
              if (v == 'signout') _signOut();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'signout', child: Text('Sign out')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<List<TodoItem>>(
          stream: TodoService.todoStream(user.uid, _pageSize),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Unable to load todos. Please check your connection.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final todos = snapshot.data ?? const [];
            final visibleTodos = _applyFilters(todos);
            final totalCount = visibleTodos.length;
            final completedCount = visibleTodos.where((t) => t.done).length;
            final activeCount = totalCount - completedCount;
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasMore = todos.length >= _pageSize;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user.displayName ?? user.email ?? 'there'}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$activeCount active • $completedCount done',
                              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Text(
                          '$completedCount',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                StatsDashboard(allTodos: todos, visibleTodos: visibleTodos),
                if (_filterType != _FilterType.all || _priorityFilter != null || _statusFilter != _StatusFilter.all) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (_filterType != _FilterType.all) Chip(label: Text(_describeDateFilter())),
                        if (_priorityFilter != null) Chip(label: Text('Priority: ${_priorityFilter!.name}')),
                        if (_statusFilter != _StatusFilter.all) Chip(label: Text(_statusFilter == _StatusFilter.active ? 'Active' : 'Done')),
                        ActionChip(
                          label: const Text('Clear filters'),
                          onPressed: () => setState(() {
                            _filterType = _FilterType.all;
                            _filterDate = null;
                            _priorityFilter = null;
                            _statusFilter = _StatusFilter.all;
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
                const Divider(height: 1),
                Expanded(
                  child: isLoading && visibleTodos.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : visibleTodos.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 64,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No tasks yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap + to add your first task.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: visibleTodos.length + (hasMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == visibleTodos.length) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: OutlinedButton(
                                        onPressed: _loadMore,
                                        child: const Text('Load more'),
                                      ),
                                    ),
                                  );
                                }
                                final todo = visibleTodos[index];
                                return Dismissible(
                                  key: ValueKey(todo.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    color: Colors.red,
                                    child: const Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (_) => _removeTodo(todo),
                                  child: TodoTile(
                                    todo: todo,
                                    onToggle: () => _toggleTodo(todo),
                                    onDelete: () => _removeTodo(todo),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTodoSheet,
        tooltip: 'Add task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChoice(String label, bool selected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withValues(alpha: 0.18),
      backgroundColor: Colors.grey[100],
    );
  }

  String _describeDateFilter() {
    switch (_filterType) {
      case _FilterType.all:
        return 'All dates';
      case _FilterType.today:
        return 'Today';
      case _FilterType.thisWeek:
        return 'This week';
      case _FilterType.noDate:
        return 'No date';
      case _FilterType.specificDate:
        return _filterDate == null ? 'Selected date' : 'Date: ${_formatDate(_filterDate!)}';
    }
  }
}

enum _FilterType {
  all,
  today,
  thisWeek,
  noDate,
  specificDate,
}

enum _StatusFilter {
  all,
  active,
  completed,
}
