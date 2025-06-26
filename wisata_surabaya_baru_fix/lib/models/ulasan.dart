class Ulasan {
  final int id;
  final int userId;
  final int wisataId;
  final String wisataNama;
  final double rating;
  final String komentar;
  final String dibuatPada;
  final String diupdatePada;
  final String tanggal;
  final String username;

  Ulasan({
    required this.id,
    required this.userId,
    required this.wisataId,
    required this.wisataNama,
    required this.rating,
    required this.komentar,
    required this.dibuatPada,
    required this.diupdatePada,
    required this.tanggal,
    required this.username,
  });

  factory Ulasan.fromJson(Map<String, dynamic> json) {
    return Ulasan(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      wisataId: json['wisataId'] ?? 0,
      wisataNama: json['wisataNama'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      komentar: json['komentar'] ?? '',
      dibuatPada: json['dibuatPada'] ?? '',
      diupdatePada: json['diupdatePada'] ?? '',
      tanggal: json['tanggal'] ?? '',
      username: json['username'] ?? 'Anonymous',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'wisataId': wisataId,
      'wisataNama': wisataNama,
      'rating': rating,
      'komentar': komentar,
      'dibuatPada': dibuatPada,
      'diupdatePada': diupdatePada,
      'tanggal': tanggal,
      'username': username,
    };
  }
}
