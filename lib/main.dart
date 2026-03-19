import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:table_calendar/table_calendar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          surface: const Color(0xFFF6F5F2),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F5F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F5F2),
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        chipTheme: ChipThemeData(
          side: const BorderSide(color: Color(0xFFCBD5E1)),
          selectedColor: const Color(0xFF0F766E),
          labelStyle: const TextStyle(color: Color(0xFF0F172A)),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const TodoHomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Sign in failed.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _registerWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please enter email and password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Register failed.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return;
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? 'Google sign-in failed.');
    } catch (_) {
      _showMessage('Google sign-in failed.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Welcome back',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Sign in to continue.'),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _signInWithEmail,
              child: const Text('Sign in'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: _isLoading ? null : _registerWithEmail,
              child: const Text('Create account'),
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Divider()),
                SizedBox(width: 8),
                Text('OR'),
                SizedBox(width: 8),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.login),
              label: const Text('Continue with Google'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({Key? key}) : super(key: key);

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  final List<_TodoItem> _todos = [];
  final TextEditingController _controller = TextEditingController();
  DateTime? _selectedDate;
  DateTime? _filterDate;
  DateTime _calendarFocusedDay = DateTime.now();
  DateTime? _calendarSelectedDay;
  _FilterType _filterType = _FilterType.all;
  _StatusFilter _statusFilter = _StatusFilter.all;
  bool _isCalendarExpanded = false;
  bool _isLoadingTodos = true;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _todoSub;
  StreamSubscription<User?>? _authSub;
  static const int _pageStep = 20;
  int _pageSize = _pageStep;
  bool _hasMore = true;

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  DateTime _startOfWeek(DateTime date) {
    final day = _dateOnly(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  void _addTodo() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        _showSnack('Please sign in to add todos.');
        return;
      }
      final now = DateTime.now();
      final id = now.microsecondsSinceEpoch.toString();
      final dueDate = _selectedDate;
      final todo = _TodoItem(
        id: id,
        title: text,
        createdAt: now,
        dueDate: dueDate,
        ownerId: uid,
      );
      setState(() {
        _todos.add(todo);
        _controller.clear();
        _selectedDate = null;
      });
      _saveTodoToCloud(todo);
    }
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = DateTime(picked.year, picked.month, picked.day);
    });
  }

  Future<void> _pickFilterDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _filterDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked == null) return;
    setState(() {
      _filterDate = _dateOnly(picked);
      _filterType = _FilterType.specificDate;
      _calendarSelectedDay = _filterDate;
      _calendarFocusedDay = picked;
    });
  }

  void _clearFilter() {
    setState(() {
      _filterDate = null;
      _filterType = _FilterType.all;
      _calendarSelectedDay = null;
    });
  }

  void _toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    setState(() {
      _todos[index] = _todos[index].copyWith(done: !_todos[index].done);
    });
    _updateTodoInCloud(_todos[index]);
  }

  void _removeTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final todo = _todos[index];
    setState(() {
      _todos.removeAt(index);
    });
    _deleteTodoFromCloud(todo.id);
  }

  Future<void> _signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  CollectionReference<Map<String, dynamic>> _todoCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('User not signed in');
    }
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos');
  }

  void _startTodoListener() {
    _todoSub?.cancel();
    _isLoadingTodos = true;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _isLoadingTodos = false;
          _todos.clear();
        });
      }
      return;
    }
    _todoSub = _todoCollection()
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: false)
        .limit(_pageSize)
        .snapshots()
        .listen(
      (snapshot) {
        final items = snapshot.docs
            .map((doc) => _TodoItem.fromDoc(doc))
            .whereType<_TodoItem>()
            .toList();
        if (!mounted) return;
        setState(() {
          _todos
            ..clear()
            ..addAll(items);
          _isLoadingTodos = false;
          _hasMore = snapshot.docs.length >= _pageSize;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _isLoadingTodos = false;
        });
        debugPrint('Firestore listener error: $error');
        _showSnack('Failed to load todos: $error');
      },
    );
  }

  Future<void> _saveTodoToCloud(_TodoItem todo) async {
    try {
      await _todoCollection().doc(todo.id).set(todo.toFirestore());
    } catch (_) {
      _showSnack('Failed to save todo.');
    }
  }

  Future<void> _updateTodoInCloud(_TodoItem todo) async {
    try {
      await _todoCollection().doc(todo.id).update(todo.toFirestore());
    } catch (_) {
      _showSnack('Failed to update todo.');
    }
  }

  Future<void> _deleteTodoFromCloud(String id) async {
    try {
      await _todoCollection().doc(id).delete();
    } catch (_) {
      _showSnack('Failed to delete todo.');
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void initState() {
    super.initState();
    _authSub = FirebaseAuth.instance.authStateChanges().listen((_) {
      _pageSize = _pageStep;
      _startTodoListener();
    });
  }

  void _loadMore() {
    setState(() {
      _pageSize += _pageStep;
    });
    _startTodoListener();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final now = DateTime.now();
    final today = _dateOnly(now);
    final thisWeekStart = _startOfWeek(now);
    final List<_TodoItem> dateFilteredTodos = _todos.where((t) {
      switch (_filterType) {
        case _FilterType.all:
          return true;
        case _FilterType.today:
          return t.dueDate != null && _dateOnly(t.dueDate!) == today;
        case _FilterType.thisWeek:
          return t.dueDate != null &&
              _startOfWeek(t.dueDate!) == thisWeekStart;
        case _FilterType.noDate:
          return t.dueDate == null;
        case _FilterType.specificDate:
          return _filterDate != null &&
              t.dueDate != null &&
              _dateOnly(t.dueDate!) == _filterDate;
      }
    }).toList();

    final totalCount = dateFilteredTodos.length;
    final completedCount = dateFilteredTodos.where((t) => t.done).length;
    final activeCount = totalCount - completedCount;

    final List<_TodoItem> visibleTodos = dateFilteredTodos.where((t) {
      if (_statusFilter == _StatusFilter.active && t.done) return false;
      if (_statusFilter == _StatusFilter.completed && !t.done) return false;
      return true;
    }).toList();

    visibleTodos.sort((a, b) {
      final ad = a.dueDate;
      final bd = b.dueDate;
      if (ad == null && bd == null) {
        return a.createdAt.compareTo(b.createdAt);
      }
      if (ad == null) return 1;
      if (bd == null) return -1;
      final dateCompare = _dateOnly(ad).compareTo(_dateOnly(bd));
      if (dateCompare != 0) return dateCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            if (user != null)
              Text(
                'Signed in as: ${user.email ?? user.displayName ?? 'User'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              color: const Color(0xFFF4F7F4),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quick Add',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: 'Add a new task',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onSubmitted: (_) => _addTodo(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          onPressed: _addTodo,
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickDueDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _selectedDate == null
                                  ? 'No due date'
                                  : 'Due: ${_formatDate(_selectedDate!)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_selectedDate != null)
                          OutlinedButton(
                            onPressed: () =>
                                setState(() => _selectedDate = null),
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: const Color(0xFFF9F9FB),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filters',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text('All Dates'),
                          selected: _filterType == _FilterType.all,
                          onSelected: (_) => setState(() {
                            _filterType = _FilterType.all;
                            _filterDate = null;
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('Today'),
                          selected: _filterType == _FilterType.today,
                          onSelected: (_) => setState(() {
                            _filterType = _FilterType.today;
                            _filterDate = today;
                            _calendarSelectedDay = today;
                            _calendarFocusedDay = today;
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('This Week'),
                          selected: _filterType == _FilterType.thisWeek,
                          onSelected: (_) => setState(() {
                            _filterType = _FilterType.thisWeek;
                            _filterDate = null;
                          }),
                        ),
                        ChoiceChip(
                          label: const Text('No Date'),
                          selected: _filterType == _FilterType.noDate,
                          onSelected: (_) => setState(() {
                            _filterType = _FilterType.noDate;
                            _filterDate = null;
                            _calendarSelectedDay = null;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text('All ($totalCount)'),
                          selected: _statusFilter == _StatusFilter.all,
                          onSelected: (_) => setState(() {
                            _statusFilter = _StatusFilter.all;
                          }),
                        ),
                        ChoiceChip(
                          label: Text('Active ($activeCount)'),
                          selected: _statusFilter == _StatusFilter.active,
                          onSelected: (_) => setState(() {
                            _statusFilter = _StatusFilter.active;
                          }),
                        ),
                        ChoiceChip(
                          label: Text('Completed ($completedCount)'),
                          selected: _statusFilter == _StatusFilter.completed,
                          onSelected: (_) => setState(() {
                            _statusFilter = _StatusFilter.completed;
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _pickFilterDate,
                            icon: const Icon(Icons.filter_alt),
                            label: Text(
                              _filterDate == null
                                  ? 'Pick a date'
                                  : 'Date: ${_formatDate(_filterDate!)}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_filterDate != null)
                          OutlinedButton(
                            onPressed: _clearFilter,
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => setState(
                        () => _isCalendarExpanded = !_isCalendarExpanded,
                      ),
                      icon: Icon(
                        _isCalendarExpanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                      ),
                      label: Text(
                        _isCalendarExpanded
                            ? 'Hide calendar'
                            : 'Show calendar',
                      ),
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: TableCalendar(
                        firstDay: DateTime(now.year - 1),
                        lastDay: DateTime(now.year + 5),
                        focusedDay: _calendarFocusedDay,
                        selectedDayPredicate: (day) {
                          return _calendarSelectedDay != null &&
                              isSameDay(day, _calendarSelectedDay);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _calendarSelectedDay = _dateOnly(selectedDay);
                            _calendarFocusedDay = focusedDay;
                            _filterType = _FilterType.specificDate;
                            _filterDate = _calendarSelectedDay;
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                      crossFadeState: _isCalendarExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoadingTodos)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(),
              ),
            const Text(
              'Tasks',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (visibleTodos.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'No tasks yet. Add one to get started!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...visibleTodos.map((todo) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Checkbox(
                      value: todo.done,
                      onChanged: (_) => _toggleTodo(todo.id),
                    ),
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration:
                            todo.done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: todo.dueDate == null
                        ? const Text('No due date')
                        : Text('Due: ${_formatDate(todo.dueDate!)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeTodo(todo.id),
                    ),
                  ),
                );
              }),
            if (_hasMore && !_isLoadingTodos) ...[
              const SizedBox(height: 12),
              Center(
                child: OutlinedButton(
                  onPressed: _loadMore,
                  child: const Text('Load more'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _todoSub?.cancel();
    _authSub?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

class _TodoItem {
  final String id;
  final String title;
  final bool done;
  final DateTime? dueDate;
  final DateTime createdAt;
  final String ownerId;

  const _TodoItem({
    required this.id,
    required this.title,
    this.done = false,
    this.dueDate,
    required this.createdAt,
    required this.ownerId,
  });

  _TodoItem copyWith({
    String? title,
    bool? done,
    DateTime? dueDate,
    DateTime? createdAt,
    String? ownerId,
  }) {
    return _TodoItem(
      id: id,
      title: title ?? this.title,
      done: done ?? this.done,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'done': done,
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'createdAt': Timestamp.fromDate(createdAt),
      'ownerId': ownerId,
    };
  }

  static _TodoItem? fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = data['title'] as String?;
    final done = data['done'] as bool?;
    final createdAt = data['createdAt'] as Timestamp?;
    final dueDate = data['dueDate'] as Timestamp?;
    final ownerId = data['ownerId'] as String?;
    if (title == null || done == null || createdAt == null || ownerId == null) {
      return null;
    }
    return _TodoItem(
      id: doc.id,
      title: title,
      done: done,
      dueDate: dueDate?.toDate(),
      createdAt: createdAt.toDate(),
      ownerId: ownerId,
    );
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
