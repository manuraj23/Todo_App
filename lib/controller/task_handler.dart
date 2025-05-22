import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class TaskHandler {
  final String userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Function to delete a task from the 'tasks' array field of a user document
  Future<bool> deleteTask(String? taskName) async {
    try {
      DocumentReference userDoc = _firestore.collection('users').doc(userEmail);
      await userDoc.update({
        'tasks': FieldValue.arrayRemove([taskName]),
      });
      if (taskName != null) {
        CollectionReference taskSubcollection = userDoc.collection(taskName);
        await deleteCollectionInBatch(taskSubcollection);
      }

      print('Task and associated subcollections deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

// Helper function to delete a collection in batches
  Future<void> deleteCollectionInBatch(CollectionReference collectionRef) async {
    const int batchSize = 100; // Firestore batch limit
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Retrieve all documents in the collection in one go (up to batchSize limit)
    QuerySnapshot snapshots = await collectionRef.limit(batchSize).get();
    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }

    // Commit batch if there are documents to delete
    if (snapshots.docs.isNotEmpty) {
      await batch.commit();
      // Recursively delete the next batch
      await deleteCollectionInBatch(collectionRef);
    }
  }


  void getTasks() async{
    // Get the user document reference
    final userDoc = await _firestore.collection('users').doc(userEmail).collection("My Tasks");
    userDoc.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc["title"]);
        print(doc['description']);
      });
    });
  }

  Future<bool> add_task(String selected_task, String title, String description, bool favoriate, String task_date_string) async {
    final userDoc = _firestore.collection('users').doc(userEmail).collection(selected_task);

    if (title.isNotEmpty) {
      try {
        DateTime taskDate = DateFormat('yyyy-MM-dd HH:mm').parse(task_date_string);
        DocumentReference docRef = userDoc.doc();
        String taskId = docRef.id;
        print('Generated Task ID: $taskId');
        await docRef.set({
          'createdAt': FieldValue.serverTimestamp(),
          'description': description,
          'favoriate': favoriate,
          'priority': 1,    // 0: Low, 1: Medium, 2: High
          'status': 0,      // 0: In Progress, 1: Completed
          'task_id': taskId,
          'task_date': taskDate,  // Storing as DateTime, Firestore will store it as a Timestamp
          'title': title,
          'updated_at': FieldValue.serverTimestamp(),
        });

        print("Task added successfully");
        return true;
      } catch (e) {
        print("Error adding task: $e");
        return false;
      }
    }
    else return false;
  }

  Future<bool> delete_completed_task(String taskName) async {
    try {
      CollectionReference userDoc = _firestore.collection('users').doc(userEmail).collection(taskName);
      QuerySnapshot querySnapshot = await userDoc.where('status', isEqualTo: 1).get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
      print('deleted all completed tasks');
      return true;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  Future<bool> renameCollection({
    required String oldCollectionName,
    required String newCollectionName,
  }) async {
    final userDoc = _firestore.collection('users').doc(userEmail);
    final userSnapshot = await userDoc.get();

    // Check if the 'tasks' field already contains the new collection name
    final List<dynamic> existingTasks = userSnapshot.data()?['tasks'] ?? [];
    if (existingTasks.contains(newCollectionName)) {
      print("The task list name '$newCollectionName' already exists.");
      return false;
    }


    try {
      // Reference to the old and new collections
      final oldCollectionRef = userDoc.collection(oldCollectionName);
      final newCollectionRef = userDoc.collection(newCollectionName);
      await userDoc.update({
        'tasks': FieldValue.arrayRemove([oldCollectionName]),
      });
      await userDoc.update({
        'tasks': FieldValue.arrayUnion([newCollectionName]),
      });

      // Fetch all documents from the old collection
      final QuerySnapshot querySnapshot = await oldCollectionRef.get();

      // Copy each document to the new collection
      for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
        final newDocRef = newCollectionRef.doc(doc.id);
        // Cast doc.data() to Map<String, dynamic>
        await newDocRef.set(doc.data() as Map<String, dynamic>);
      }

      // After copying, delete documents from the old collection
      for (final QueryDocumentSnapshot doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print("Collection renamed from '$oldCollectionName' to '$newCollectionName'");
      return true;
    } catch (e) {
      print("Error renaming collection: $e");
      return false;
      rethrow; // Optional: rethrow the error to handle it higher up
    }
  }

  Future<bool> saveTask({
    required String titleText,
  }) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userEmail);
    if (titleText.isNotEmpty) {
      try {
        // Check if the document exists
        DocumentSnapshot docSnapshot = await userDoc.get();
        if (docSnapshot.exists) {
          // Update the tasks array by adding the new task
          await userDoc.update({
            'tasks': FieldValue.arrayUnion([titleText])
          });
          print("Task added successfully");
        } else {
          // If the document does not exist, you might want to create it and add the task
          await userDoc.set({
            'tasks': [titleText]
          });
          print("User document created and task added");
        }
        return true;
      } catch (e) {
        print("Error adding task: $e");
        return false;
      }
    } else {
      return false;
    }
  }

}
