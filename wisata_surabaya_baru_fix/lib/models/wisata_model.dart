// lib/models/wisata_model.dart
class WisataModel {
  final String? id;
  final String alamat;
  final String deskripsi;
  final String gambar;
  final int hargaTiket;
  final String namaTempat;

  WisataModel({
    this.id,
    required this.alamat,
    required this.deskripsi,
    required this.gambar,
    required this.hargaTiket,
    required this.namaTempat,
  });

  // Convert from Firestore document
  factory WisataModel.fromFirestore(Map<String, dynamic> data, String id) {
    return WisataModel(
      id: id,
      alamat: data['alamat'] ?? '',
      deskripsi: data['deskripsi'] ?? '',
      gambar: data['gambar'] ?? '',
      hargaTiket: data['harga_tiket'] ?? 0,
      namaTempat: data['nama_tempat'] ?? '',
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'alamat': alamat,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'harga_tiket': hargaTiket,
      'nama_tempat': namaTempat,
    };
  }

  // Copy with method for updates
  WisataModel copyWith({
    String? id,
    String? alamat,
    String? deskripsi,
    String? gambar,
    int? hargaTiket,
    String? namaTempat,
  }) {
    return WisataModel(
      id: id ?? this.id,
      alamat: alamat ?? this.alamat,
      deskripsi: deskripsi ?? this.deskripsi,
      gambar: gambar ?? this.gambar,
      hargaTiket: hargaTiket ?? this.hargaTiket,
      namaTempat: namaTempat ?? this.namaTempat,
    );
  }

  @override
  String toString() {
    return 'WisataModel(id: $id, alamat: $alamat, deskripsi: $deskripsi, gambar: $gambar, hargaTiket: $hargaTiket, namaTempat: $namaTempat)';
  }
}
