import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_class_app/models/todo_item.dart';

class FakeQueryDocumentSnapshot extends Fake implements QueryDocumentSnapshot<Map<String, dynamic>> {
  final String _id;
  final Map<String, dynamic> _data;

  FakeQueryDocumentSnapshot(this._id, this._data);

  @override
  String get id => _id;

  @override
  Map<String, dynamic> data([GetOptions? options]) => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('TodoItem', () {
    test('toFirestore produces correct map', () {
      final todo = TodoItem(
        id: 'test-id',
        title: 'Test task',
        done: false,
        dueDate: DateTime.utc(2026, 5, 12),
        createdAt: DateTime.utc(2026, 5, 12, 8, 0),
        ownerId: 'user-123',
      );

      final map = todo.toFirestore();

      expect(map['title'], 'Test task');
      expect(map['done'], false);
      expect(map['dueDate'], isA<Timestamp>());
      expect(map['createdAt'], isA<Timestamp>());
      expect(map['ownerId'], 'user-123');
    });

    test('fromDoc returns a valid TodoItem', () {
      final data = {
        'title': 'Loaded task',
        'done': true,
        'dueDate': Timestamp.fromDate(DateTime.utc(2026, 5, 15)),
        'createdAt': Timestamp.fromDate(DateTime.utc(2026, 5, 12, 8, 0)),
        'ownerId': 'user-123',
      };
      final snapshot = FakeQueryDocumentSnapshot('loaded-id', data);

      final todo = TodoItem.fromDoc(snapshot);

      expect(todo, isNotNull);
      expect(todo!.id, 'loaded-id');
      expect(todo.title, 'Loaded task');
      expect(todo.done, true);
      expect(todo.dueDate?.toUtc(), DateTime.utc(2026, 5, 15));
      expect(todo.createdAt.toUtc(), DateTime.utc(2026, 5, 12, 8, 0));
      expect(todo.ownerId, 'user-123');
    });

    test('copyWith updates only provided fields', () {
      final todo = TodoItem(
        id: 'copy-id',
        title: 'Original',
        done: false,
        dueDate: null,
        createdAt: DateTime.utc(2026, 5, 12, 8, 0),
        ownerId: 'user-123',
      );

      final updated = todo.copyWith(title: 'Updated', done: true);

      expect(updated.id, 'copy-id');
      expect(updated.title, 'Updated');
      expect(updated.done, true);
      expect(updated.ownerId, 'user-123');
    });
  });
}
