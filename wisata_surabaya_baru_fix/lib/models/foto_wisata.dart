class FotoWisata {
  final int id;
  final int wisataId;
  final String namaTempat;
  final String alamat;
  final String namaPengguna;
  final String pathFoto;
  final DateTime tanggalDiambil;

  FotoWisata({
    required this.id,
    required this.wisataId,
    required this.namaTempat,
    required this.alamat,
    required this.namaPengguna,
    required this.pathFoto,
    required this.tanggalDiambil,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'wisataId': wisataId,
      'namaTempat': namaTempat,
      'alamat': alamat,
      'namaPengguna': namaPengguna,
      'pathFoto': pathFoto,
      'tanggalDiambil': tanggalDiambil.toIso8601String(),
    };
  }

  factory FotoWisata.fromMap(Map<String, dynamic> map) {
    return FotoWisata(
      id: map['id'],
      wisataId: map['wisataId'],
      namaTempat: map['namaTempat'],
      alamat: map['alamat'],
      namaPengguna: map['namaPengguna'],
      pathFoto: map['pathFoto'],
      tanggalDiambil: DateTime.parse(map['tanggalDiambil']),
    );
  }
}
