// data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'domain.dart';

class FavoriteRepository implements IFavoriteRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoriteRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : firestore = firestore ?? FirebaseFirestore.instance,
      auth = auth ?? FirebaseAuth.instance;

  // Stream de favoritos en tiempo real
  Stream<List<String>> favoritesStream() {
    final uid = auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);
    return firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => d.id).toList());
  }

  @override
  Future<void> addFavorite(String stationId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(stationId)
        .set({
          'stationId': stationId,
          'createdAt': FieldValue.serverTimestamp(),
        });
  }

  @override
  Future<void> removeFavorite(String stationId) async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;
    await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .doc(stationId)
        .delete();
  }

  @override
  Future<List<String>> getFavorites() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return [];
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('favorites')
        .get();
    return snapshot.docs.map((d) => d.id).toList();
  }
}
