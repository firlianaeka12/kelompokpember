import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://172.16.27.254/wisata/api/api.php';

  SharedPreferences? _prefs;

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      await _initPrefs();

      // 1. Dapatkan data user yang sedang login
      final userJson = _prefs!.getString('current_user');
      if (userJson == null) throw Exception('User not logged in');

      final user = json.decode(userJson);
      final username = user['username'];

      // 2. Kirim ke API untuk update profile image
      final response = await http.post(
        Uri.parse('$_baseUrl?action=update_profile_image'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'profile_image': imagePath}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // 3. Update data di SharedPreferences
        final updatedUser = {...user, 'profile_image': imagePath};
        await _prefs!.setString('current_user', json.encode(updatedUser));
      } else {
        throw Exception(
          responseData['message'] ?? 'Failed to update profile image',
        );
      }
    } catch (e) {
      print('Error updating profile image: $e');
      throw Exception('Failed to update profile image');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          // Pastikan SharedPreferences sudah diinisialisasi
          await _initPrefs();

          // Simpan data user ke SharedPreferences
          await _prefs!.setString(
            'current_user',
            json.encode(responseData['data']['user']),
          );
          return {
            'success': true,
            'message': 'Login berhasil',
            'user': responseData['data']['user'],
          };
        }
        return {
          'success': false,
          'message': responseData['message'] ?? 'Login gagal',
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return {
            'success': true,
            'message': 'Registrasi berhasil',
            'user': responseData['data']['user'],
          };
        }
        return {
          'success': false,
          'message': responseData['message'] ?? 'Registrasi gagal',
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${response.statusCode}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    await _initPrefs();

    final userJson = _prefs!.getString('current_user');
    if (userJson == null) return null;

    try {
      final user = json.decode(userJson);
      final response = await http.get(
        Uri.parse('$_baseUrl?action=get_user&username=${user['username']}'),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return responseData['data']['user'];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async {
    await _initPrefs();
    await _prefs!.remove('current_user');
  }

  Future<bool> isLoggedIn() async {
    await _initPrefs();
    return _prefs!.getString('current_user') != null;
  }
}
