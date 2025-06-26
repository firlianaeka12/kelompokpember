import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ulasan.dart';

class UlasanService {
  static const String _baseUrl = 'http://172.16.27.254/wisata/api/ulasan.php';
  static const Duration _timeout = Duration(seconds: 15);

  static dynamic _handleResponse(http.Response response) {
    final responseBody = response.body.trim();

    print('Response Status: ${response.statusCode}');
    print('Response Body: $responseBody');

    if (responseBody.isEmpty) {
      throw Exception('Respon server kosong');
    }

    if (responseBody.startsWith('<') || responseBody.contains('<html>')) {
      throw Exception(
        'Server mengembalikan HTML error. Periksa URL dan koneksi server.',
      );
    }

    try {
      final responseData = json.decode(responseBody);

      if (responseData['status'] == 'error') {
        throw Exception(responseData['message'] ?? 'Terjadi kesalahan');
      }

      return responseData['data'];
    } catch (e) {
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      print('JSON Parse Error: $e');
      print('Response Body: $responseBody');
      throw Exception('Gagal memparse JSON: $e');
    }
  }

  /// Mengambil semua ulasan
  static Future<List<Ulasan>> dapatkanSemuaUlasan() async {
    try {
      final response = await http
          .get(
            Uri.parse(_baseUrl),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);

      if (responseData is List) {
        return responseData
            .map((json) => Ulasan.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Format data tidak valid dari server');
      }
    } catch (e) {
      print('Error in dapatkanSemuaUlasan: $e');
      throw Exception('Gagal memuat ulasan: ${e.toString()}');
    }
  }

  /// Mengambil ulasan berdasarkan ID wisata dengan statistik
  static Future<Map<String, dynamic>> dapatkanUlasanByWisata(
    int wisataId,
  ) async {
    try {
      if (wisataId <= 0) {
        throw Exception('ID wisata tidak valid');
      }

      final uri = Uri.parse('$_baseUrl?wisata_id=$wisataId');
      print('Request URL: $uri');

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);

      return {
        'ulasan': (responseData['ulasan'] as List? ?? [])
            .map((json) => Ulasan.fromJson(Map<String, dynamic>.from(json)))
            .toList(),
        'rata_rata_rating': (responseData['rata_rata_rating'] ?? 0.0)
            .toDouble(),
        'total_ulasan': responseData['total_ulasan'] ?? 0,
      };
    } catch (e) {
      print('Error in dapatkanUlasanByWisata: $e');
      throw Exception('Gagal memuat ulasan untuk wisata ini: ${e.toString()}');
    }
  }

  /// Membuat ulasan baru
  static Future<Ulasan> buatUlasan({
    required int userId,
    required int wisataId,
    required String wisataNama,
    required int rating,
    required String komentar,
  }) async {
    try {
      // Validasi input
      if (userId <= 0) {
        throw Exception('User ID tidak valid');
      }

      if (wisataId <= 0) {
        throw Exception('ID wisata tidak valid');
      }

      if (rating < 1 || rating > 5) {
        throw Exception('Rating harus antara 1-5');
      }

      if (wisataNama.trim().isEmpty) {
        throw Exception('Nama wisata tidak boleh kosong');
      }

      final requestBody = {
        'userId': userId,
        'wisataId': wisataId,
        'wisataNama': wisataNama.trim(),
        'rating': rating,
        'komentar': komentar.trim(),
      };

      print('Request Body: ${json.encode(requestBody)}');

      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);
      return Ulasan.fromJson(Map<String, dynamic>.from(responseData));
    } catch (e) {
      print('Error in buatUlasan: $e');
      throw Exception('Gagal membuat ulasan: ${e.toString()}');
    }
  }

  /// Mengambil detail ulasan berdasarkan ID
  static Future<Ulasan> dapatkanUlasanById(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID ulasan tidak valid');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl?id=$id'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);

      if (responseData is List && responseData.isNotEmpty) {
        return Ulasan.fromJson(Map<String, dynamic>.from(responseData.first));
      } else if (responseData is Map) {
        return Ulasan.fromJson(Map<String, dynamic>.from(responseData));
      } else {
        throw Exception('Ulasan tidak ditemukan');
      }
    } catch (e) {
      print('Error in dapatkanUlasanById: $e');
      throw Exception('Gagal memuat detail ulasan: ${e.toString()}');
    }
  }

  /// Memperbarui ulasan yang sudah ada
  static Future<void> perbaruiUlasan({
    required int id,
    int? rating,
    String? komentar,
  }) async {
    try {
      if (id <= 0) {
        throw Exception('ID ulasan tidak valid');
      }

      if (rating == null && komentar == null) {
        throw Exception(
          'Minimal satu field (rating atau komentar) harus diupdate',
        );
      }

      if (rating != null && (rating < 1 || rating > 5)) {
        throw Exception('Rating harus antara 1-5');
      }

      final requestBody = <String, dynamic>{'id': id};

      if (rating != null) {
        requestBody['rating'] = rating;
      }

      if (komentar != null) {
        requestBody['komentar'] = komentar.trim();
      }

      print('Update Request: ${json.encode(requestBody)}');

      final response = await http
          .put(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      _handleResponse(response);
    } catch (e) {
      print('Error in perbaruiUlasan: $e');
      throw Exception('Gagal memperbarui ulasan: ${e.toString()}');
    }
  }

  /// Menghapus ulasan
  static Future<void> hapusUlasan(int id) async {
    try {
      if (id <= 0) {
        throw Exception('ID ulasan tidak valid');
      }

      final response = await http
          .delete(
            Uri.parse('$_baseUrl?id=$id'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      _handleResponse(response);
    } catch (e) {
      print('Error in hapusUlasan: $e');
      throw Exception('Gagal menghapus ulasan: ${e.toString()}');
    }
  }

  /// Mendapatkan ulasan berdasarkan user ID
  static Future<List<Ulasan>> dapatkanUlasanByUser(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception('User ID tidak valid');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl?user_id=$userId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);

      if (responseData is List) {
        return responseData
            .map((json) => Ulasan.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      } else {
        throw Exception('Format data tidak valid dari server');
      }
    } catch (e) {
      print('Error in dapatkanUlasanByUser: $e');
      throw Exception('Gagal memuat ulasan user: ${e.toString()}');
    }
  }

  /// Mendapatkan statistik rating untuk wisata tertentu
  static Future<Map<String, dynamic>> dapatkanStatistikRating(
    int wisataId,
  ) async {
    try {
      if (wisataId <= 0) {
        throw Exception('ID wisata tidak valid');
      }

      final response = await http
          .get(
            Uri.parse('$_baseUrl?wisata_id=$wisataId'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
          )
          .timeout(_timeout);

      final responseData = _handleResponse(response);

      return {
        'rata_rata_rating': (responseData['rata_rata_rating'] ?? 0.0)
            .toDouble(),
        'total_ulasan': responseData['total_ulasan'] ?? 0,
      };
    } catch (e) {
      print('Error in dapatkanStatistikRating: $e');
      throw Exception('Gagal memuat statistik rating: ${e.toString()}');
    }
  }

  /// Cek apakah user sudah memberikan ulasan untuk wisata tertentu
  static Future<bool> cekUlasanUser(int userId, int wisataId) async {
    try {
      if (userId <= 0 || wisataId <= 0) {
        return false;
      }

      final ulasanUser = await dapatkanUlasanByUser(userId);
      return ulasanUser.any((ulasan) => ulasan.wisataId == wisataId);
    } catch (e) {
      print('Error in cekUlasanUser: $e');
      return false;
    }
  }

  /// Mendapatkan ulasan user untuk wisata tertentu
  static Future<Ulasan?> dapatkanUlasanUserUntukWisata(
    int userId,
    int wisataId,
  ) async {
    try {
      if (userId <= 0 || wisataId <= 0) {
        return null;
      }

      final ulasanUser = await dapatkanUlasanByUser(userId);
      final ulasanWisata = ulasanUser
          .where((ulasan) => ulasan.wisataId == wisataId)
          .toList();

      return ulasanWisata.isNotEmpty ? ulasanWisata.first : null;
    } catch (e) {
      print('Error in dapatkanUlasanUserUntukWisata: $e');
      return null;
    }
  }
}
