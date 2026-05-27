import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> addPlan(String title) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .add({
      "title": title,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getPlans() {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> updatePlan(String planId, String newTitle) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .update({"title": newTitle});
  }

  Future<void> deletePlan(String planId) async {
    final tasks = await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .get();

    final batch = _firestore.batch();
    for (final doc in tasks.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(
      _firestore
          .collection("users")
          .doc(userId)
          .collection("plans")
          .doc(planId),
    );

    await batch.commit();
  }

  Future<void> addTask(String planId, String title) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .add({
      "title": title,
      "isDone": false,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getTasks(String planId) {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  Future<void> toggleTask(String planId, String taskId, bool currentValue) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .doc(taskId)
        .update({"isDone": !currentValue});
  }

  Future<void> updateTask(String planId, String taskId, String newTitle) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .doc(taskId)
        .update({"title": newTitle});
  }

  /// Task устгах
  Future<void> deleteTask(String planId, String taskId) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .collection("tasks")
        .doc(taskId)
        .delete();
  }
}