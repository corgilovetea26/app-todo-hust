import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo_item.dart';

class TodoService {
  static CollectionReference<Map<String, dynamic>> collectionForUser(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('todos');
  }

  static String generateTodoId(String uid) {
    return collectionForUser(uid).doc().id;
  }

  static Stream<List<TodoItem>> todoStream(String uid, int limit) {
    return collectionForUser(uid)
        .where('ownerId', isEqualTo: uid)
        .orderBy('createdAt', descending: false)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map(TodoItem.fromDoc)
          .whereType<TodoItem>()
          .toList();
    });
  }

  static Future<void> addTodo(TodoItem todo) async {
    await collectionForUser(todo.ownerId).doc(todo.id).set(todo.toFirestore());
  }

  static Future<void> updateTodo(TodoItem todo) async {
    await collectionForUser(todo.ownerId).doc(todo.id).update(todo.toFirestore());
  }

  static Future<void> deleteTodo(String ownerId, String id) async {
    await collectionForUser(ownerId).doc(id).delete();
  }
}
