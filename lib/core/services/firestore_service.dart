import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class QueryFilter {
  final String field;
  final dynamic value;
  final String operator;

  QueryFilter({
    required this.field,
    required this.value,
    this.operator = '==',
  });
}

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() => _instance;

  FirestoreService._internal();

  late FirebaseFirestore _firestore;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
    _firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
    _initialized = true;
  }

  FirebaseFirestore get firestore => _firestore;

// -------------------- Generic CRUD Operations --------------------

  Future<String?> addDocument(String collection,
      Map<String, dynamic> data) async {
    try {
      final docRef = await _firestore.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Error adding document: $e');
      return null;
    }
  }

  Future<DocumentSnapshot?> getDocument(String collection, String docId) async {
    try {
      return await _firestore.collection(collection).doc(docId).get();
    } catch (e) {
      debugPrint('Error getting document: $e');
      return null;
    }
  }

  Future<bool> updateDocument(String collection, String docId,
      Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Error updating document: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getAllDocuments(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error getting all documents: $e');
      return [];
    }
  }

  Stream<DocumentSnapshot> getDocumentStream(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  Stream<QuerySnapshot> getCollectionStream(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<List<Map<String, dynamic>>> queryDocuments(String collection,
      Map<String, dynamic> filters) async {
    try {
      Query query = _firestore.collection(collection);
      filters.forEach((key, value) {
        query = query.where(key, isEqualTo: value);
      });
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error querying documents: $e');
      return [];
    }
  }

  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    final batch = _firestore.batch();
    try {
      for (var op in operations) {
        final docRef = _firestore.collection(op['collection']).doc(op['docId']);
        final data = op['data'] ?? {};
        final type = op['type'];
        if (type == 'set') {
          batch.set(docRef, data);
        } else if (type == 'update') {
          batch.update(docRef, data);
        } else if (type == 'delete') {
          batch.delete(docRef);
        }
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error in batch write: $e');
    }
  }

  Future<void> runTransaction(
      Future<void> Function(Transaction) transactionHandler) async {
    try {
      await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      debugPrint('Error running transaction: $e');
    }
  }

// -------------------- User Operations --------------------

  Future<void> createUser(String userId, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(userId).set({
      ...userData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentSnapshot?> getUser(String userId) async {
    return await getDocument('users', userId);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    await updateDocument('users', userId, userData);
  }

  Future<void> deleteUser(String userId) async {
    await deleteDocument('users', userId);
  }

// -------------------- Crop Operations --------------------

  Future<String?> addCrop(Map<String, dynamic> cropData) async {
    return await addDocument('crops', cropData);
  }

  Future<DocumentSnapshot?> getCrop(String cropId) async {
    return await getDocument('crops', cropId);
  }

  Future<void> updateCrop(String cropId, Map<String, dynamic> cropData) async {
    await updateDocument('crops', cropId, cropData);
  }

  Future<void> deleteCrop(String cropId) async {
    await deleteDocument('crops', cropId);
  }

  Future<List<Map<String, dynamic>>> getUserCrops(String userId) async {
    return await queryDocuments('crops', {'userId': userId});
  }

  Future<List<Map<String, dynamic>>> getCropsByField(String fieldId) async {
    return await queryDocuments('crops', {'fieldId': fieldId});
  }

// -------------------- Disease Operations --------------------

  Future<String?> addDiseaseRecord(Map<String, dynamic> diseaseData) async {
    return await addDocument('diseases', diseaseData);
  }

  Future<DocumentSnapshot?> getDiseaseRecord(String diseaseId) async {
    return await getDocument('diseases', diseaseId);
  }

  Future<void> updateDiseaseRecord(String diseaseId,
      Map<String, dynamic> data) async {
    await updateDocument('diseases', diseaseId, data);
  }

  Future<void> deleteDiseaseRecord(String diseaseId) async {
    await deleteDocument('diseases', diseaseId);
  }

  Future<List<Map<String, dynamic>>> getUserDiseases(String userId) async {
    return await queryDocuments('diseases', {'userId': userId});
  }

// -------------------- Field Operations --------------------

  Future<String?> addField(Map<String, dynamic> fieldData) async {
    return await addDocument('fields', fieldData);
  }

  Future<DocumentSnapshot?> getField(String fieldId) async {
    return await getDocument('fields', fieldId);
  }

  Future<void> updateField(String fieldId,
      Map<String, dynamic> fieldData) async {
    await updateDocument('fields', fieldId, fieldData);
  }

  Future<void> deleteField(String fieldId) async {
    await deleteDocument('fields', fieldId);
  }

  Future<List<Map<String, dynamic>>> getUserFields(String userId) async {
    return await queryDocuments('fields', {'userId': userId});
  }

// -------------------- Analysis Operations --------------------

  Future<String?> addAnalysis(Map<String, dynamic> analysisData) async {
    return await addDocument('analyses', analysisData);
  }

  Future<DocumentSnapshot?> getAnalysis(String analysisId) async {
    return await getDocument('analyses', analysisId);
  }

  Future<List<Map<String, dynamic>>> getUserAnalyses(String userId) async {
    return await queryDocuments('analyses', {'userId': userId});
  }

  Future<void> deleteAnalysis(String analysisId) async {
    await deleteDocument('analyses', analysisId);
  }

// -------------------- Query Operations --------------------

  Future<List<Map<String, dynamic>>> queryByField(String collection,
      String field, dynamic value) async {
    try {
      final snapshot =
      await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error querying by field: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> queryWithMultipleFilters(String collection,
      List<QueryFilter> filters) async {
    try {
      Query query = _firestore.collection(collection);
      for (var filter in filters) {
        switch (filter.operator) {
          case '>':
            query = query.where(filter.field, isGreaterThan: filter.value);
            break;
          case '<':
            query = query.where(filter.field, isLessThan: filter.value);
            break;
          case '>=':
            query =
                query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
            break;
          case '<=':
            query =
                query.where(filter.field, isLessThanOrEqualTo: filter.value);
            break;
          case '!=':
            query = query.where(filter.field, isNotEqualTo: filter.value);
            break;
          default:
            query = query.where(filter.field, isEqualTo: filter.value);
        }
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error querying with multiple filters: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> orderByField(String collection,
      String field, bool descending) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy(field, descending: descending)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error ordering by field: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> limitResults(String collection,
      int limit) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error limiting results: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> paginateResults(String collection,
      DocumentSnapshot? lastDoc, int limit) async {
    try {
      Query query = _firestore.collection(collection).limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('Error paginating results: $e');
      return [];
    }
  }

// -------------------- Real-time Streaming --------------------

  Stream<QuerySnapshot> streamUserCrops(String userId) {
    return _firestore
        .collection('crops')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> streamUserFields(String userId) {
    return _firestore
        .collection('fields')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> streamDiseaseRecords(String userId) {
    return _firestore
        .collection('diseases')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  Stream<QuerySnapshot> streamAnalyses(String userId) {
    return _firestore
        .collection('analyses')
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

// -------------------- Batch Operations --------------------

  Future<void> batchAddCrops(List<Map<String, dynamic>> crops) async {
    final batch = _firestore.batch();
    try {
      for (var crop in crops) {
        final docRef = _firestore.collection('crops').doc();
        batch.set(docRef, crop);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error batch adding crops: $e');
    }
  }

  Future<void> batchUpdateCrops(List<Map<String, dynamic>> updates) async {
    final batch = _firestore.batch();
    try {
      for (var update in updates) {
        final docRef = _firestore.collection('crops').doc(update['id']);
        batch.update(docRef, update);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error batch updating crops: $e');
    }
  }

  Future<void> batchDeleteCrops(List<String> cropIds) async {
    final batch = _firestore.batch();
    try {
      for (var id in cropIds) {
        final docRef = _firestore.collection('crops').doc(id);
        batch.delete(docRef);
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error batch deleting crops: $e');
    }
  }

// -------------------- Helper Methods --------------------

  Future<bool> documentExists(String collection, String docId) async {
    try {
      final doc = await _firestore.collection(collection).doc(docId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking document existence: $e');
      return false;
    }
  }

  Future<int> getDocumentCount(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting document count: $e');
      return 0;
    }
  }

  FieldValue getTimestamp() {
    return FieldValue.serverTimestamp();
  }

  String generateDocumentId(String collection) {
    return _firestore
        .collection(collection)
        .doc()
        .id;
  }
}