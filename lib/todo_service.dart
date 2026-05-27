import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Одоогийн нэвтэрсэн хэрэглэгчийн uid
  String get userId => FirebaseAuth.instance.currentUser!.uid;

  // ─────────────────────────────────────────
  // PLAN CRUD
  // ─────────────────────────────────────────

  /// Plan нэмэх
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

  /// Plan stream (realtime)
  Stream<QuerySnapshot> getPlans() {
    return _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  /// Plan засах
  Future<void> updatePlan(String planId, String newTitle) async {
    await _firestore
        .collection("users")
        .doc(userId)
        .collection("plans")
        .doc(planId)
        .update({"title": newTitle});
  }

  /// Plan устгах (доторх task-уудтай хамт)
  Future<void> deletePlan(String planId) async {
    // Эхлээд task-уудыг устгана
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

    // Plan document-г устгана
    batch.delete(
      _firestore
          .collection("users")
          .doc(userId)
          .collection("plans")
          .doc(planId),
    );

    await batch.commit();
  }

  // ─────────────────────────────────────────
  // TASK CRUD
  // ─────────────────────────────────────────

  /// Task нэмэх
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

  /// Task stream (realtime)
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

  /// Task toggle (isDone өөрчлөх)
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

  /// Task засах
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