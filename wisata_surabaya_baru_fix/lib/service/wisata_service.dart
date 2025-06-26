// lib/services/wisata_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wisata_model.dart';

class WisataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionFavorit = 'favorit_wisata';
  final String _collectionRiwayat = 'riwayat_wisata';

  // CRUD untuk Favorit Wisata

  // Create - Tambah wisata favorit
  Future<String> addFavoritWisata(WisataModel wisata) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionFavorit)
          .add(wisata.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah wisata favorit: $e');
    }
  }

  // Read - Get semua wisata favorit
  Stream<List<WisataModel>> getFavoritWisataStream() {
    return _firestore
        .collection(_collectionFavorit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WisataModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Read - Get wisata favorit berdasarkan ID
  Future<WisataModel?> getFavoritWisataById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionFavorit)
          .doc(id)
          .get();

      if (doc.exists) {
        return WisataModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data wisata favorit: $e');
    }
  }

  // Update - Update wisata favorit
  Future<void> updateFavoritWisata(String id, WisataModel wisata) async {
    try {
      await _firestore
          .collection(_collectionFavorit)
          .doc(id)
          .update(wisata.toFirestore());
    } catch (e) {
      throw Exception('Gagal mengupdate wisata favorit: $e');
    }
  }

  // Delete - Hapus wisata favorit
  Future<void> deleteFavoritWisata(String id) async {
    try {
      await _firestore.collection(_collectionFavorit).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus wisata favorit: $e');
    }
  }

  // CRUD untuk Riwayat Wisata

  // Create - Tambah riwayat wisata
  Future<String> addRiwayatWisata(WisataModel wisata) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collectionRiwayat)
          .add(wisata.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menambah riwayat wisata: $e');
    }
  }

  // Read - Get semua riwayat wisata
  Stream<List<WisataModel>> getRiwayatWisataStream() {
    return _firestore
        .collection(_collectionRiwayat)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WisataModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Read - Get riwayat wisata berdasarkan ID
  Future<WisataModel?> getRiwayatWisataById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collectionRiwayat)
          .doc(id)
          .get();

      if (doc.exists) {
        return WisataModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data riwayat wisata: $e');
    }
  }

  // Update - Update riwayat wisata
  Future<void> updateRiwayatWisata(String id, WisataModel wisata) async {
    try {
      await _firestore
          .collection(_collectionRiwayat)
          .doc(id)
          .update(wisata.toFirestore());
    } catch (e) {
      throw Exception('Gagal mengupdate riwayat wisata: $e');
    }
  }

  // Delete - Hapus riwayat wisata
  Future<void> deleteRiwayatWisata(String id) async {
    try {
      await _firestore.collection(_collectionRiwayat).doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus riwayat wisata: $e');
    }
  }

  // Utility methods

  // Search wisata favorit berdasarkan nama
  Stream<List<WisataModel>> searchFavoritWisata(String query) {
    return _firestore
        .collection(_collectionFavorit)
        .where('nama_tempat', isGreaterThanOrEqualTo: query)
        .where('nama_tempat', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WisataModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Search riwayat wisata berdasarkan nama
  Stream<List<WisataModel>> searchRiwayatWisata(String query) {
    return _firestore
        .collection(_collectionRiwayat)
        .where('nama_tempat', isGreaterThanOrEqualTo: query)
        .where('nama_tempat', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WisataModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // Check apakah wisata sudah ada di favorit
  Future<bool> isWisataInFavorit(String namaTempat) async {
    try {
      QuerySnapshot query = await _firestore
          .collection(_collectionFavorit)
          .where('nama_tempat', isEqualTo: namaTempat)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
