import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fucking_do_it/models/comment.dart';
import 'package:fucking_do_it/models/person.dart';
import 'package:fucking_do_it/models/task.dart';
import 'package:fucking_do_it/types/status.dart';

class Repository {
  static StreamSubscription listen(
    String taskId,
    Function(Task? task) callback,
  ) {
    final Stream<DocumentSnapshot<Map<String, dynamic>>> stream =
        Repository._doc(taskId).snapshots();

    return stream.listen((snapshot) {
      if (snapshot.exists) {
        callback(Task.fromDocument(snapshot));
      } else {
        callback(null);
      }
    });
  }

  static StreamSubscription listenAssignedToMe(
      Function(List<Task> tasks) callback) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        Repository._collection()
            .where(
              Task.FIELD_ASSIGNED_TO,
              arrayContains: FirebaseAuth.instance.currentUser?.uid,
            )
            .where(Task.FIELD_STATUS, isEqualTo: Status.accepted.name)
            .snapshots();

    return processStream(stream, callback);
  }

  static StreamSubscription listenCreated(Function(List<Task> tasks) callback) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        Repository._collection()
            .where(
              Task.FIELD_CREATED_BY,
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .where(Task.FIELD_STATUS, isEqualTo: Status.created.name)
            .snapshots();

    return processStream(stream, callback);
  }

  static StreamSubscription listenAccepted(
      Function(List<Task> tasks) callback) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        Repository._collection()
            .where(
              Task.FIELD_CREATED_BY,
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .where(Task.FIELD_STATUS, isEqualTo: Status.accepted.name)
            .snapshots();

    return processStream(stream, callback);
  }

  static StreamSubscription listenInReview(
      Function(List<Task> tasks) callback) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        Repository._collection()
            .where(
              Task.FIELD_CREATED_BY,
              isEqualTo: FirebaseAuth.instance.currentUser?.uid,
            )
            .where(Task.FIELD_STATUS, isEqualTo: Status.done.name)
            .snapshots();

    return processStream(stream, callback);
  }

  static StreamSubscription processStream(
      Stream<QuerySnapshot<Map<String, dynamic>>> stream,
      Function(List<Task> tasks) callback) {
    return stream.listen((event) async {
      final List<Task> tasks = [];

      for (final document in event.docs) {
        tasks.add(Task.fromDocument(document));
      }

      tasks.sort((a, b) => a.compareTo(b));

      callback(tasks);
    });
  }

  static Future get(String taskId) async {
    final DocumentSnapshot<Map<String, dynamic>> document =
        await _doc(taskId).get();

    return Task.fromDocument(document);
  }

  static Future<DocumentReference> create(Task task) =>
      _collection().add(task.document);

  static Future update(Task task) => _doc(task.id).set(task.document);

  static Future addComment({
    required Task task,
    required Comment comment,
  }) {
    task.comments.add(comment.document);

    return _doc(task.id).update({
      Task.FIELD_COMMENTS: task.comments,
    });
  }

  static Future complete(Task task) => _doc(task.id).update({
        Task.FIELD_STATUS: Status.done.name,
      });

  static Future reopen(Task task) => _doc(task.id).update({
        Task.FIELD_STATUS: Status.accepted.name,
      });

  static Future accept(Task task) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final List<String> assignedTo = task.assignedTo;

    if (!assignedTo.contains(userId)) {
      assignedTo.add(userId);

      final Map<String, dynamic> assignedInfo = task.assignedInfo;
      assignedInfo[userId] = {
        Person.FIELD_AVATAR: FirebaseAuth.instance.currentUser?.photoURL,
        Person.FIELD_NAME: FirebaseAuth.instance.currentUser?.displayName,
        Person.FIELD_EMAIL: FirebaseAuth.instance.currentUser?.email,
      };

      return _doc(task.id).update({
        Task.FIELD_ASSIGNED_TO: assignedTo,
        Task.FIELD_ASSIGNED_INFO: assignedInfo,
        Task.FIELD_STATUS: Status.accepted.name,
      });
    }
  }

  static Future delete(Task task) => _doc(task.id).delete();

  static Future leave(Task task) async {
    final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    task.assignedTo.remove(userId);
    task.assignedInfo.remove(userId);

    return _doc(task.id).update({
      Task.FIELD_ASSIGNED_TO: task.assignedTo,
      Task.FIELD_ASSIGNED_INFO: task.assignedInfo,
      Task.FIELD_STATUS:
          task.assignedTo.isEmpty ? Status.created.name : Status.accepted.name,
    });
  }

  static CollectionReference<Map<String, dynamic>> _collection() =>
      FirebaseFirestore.instance.collection('tasks');

  static DocumentReference<Map<String, dynamic>> _doc(String id) =>
      FirebaseFirestore.instance.collection('tasks').doc(id);
}
