import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:wisata_surabaya_baru_fix/service/auth_service.dart';
import 'package:wisata_surabaya_baru_fix/screens/login_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/wisata_list_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/about_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/notification_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/settings_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/help_screen.dart';

class AkunScreen extends StatefulWidget {
  const AkunScreen({Key? key}) : super(key: key);

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  String _username = 'Pengguna';
  String _email = 'email@contoh.com';
  File? _profileImage;
  String? _location;
  bool _isLoading = true;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _getCurrentLocation();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);
      final userData = await _authService.getCurrentUser();

      if (!mounted) return;

      setState(() {
        _username = userData?['username'] ?? 'Pengguna';
        _email = userData?['email'] ?? 'email@contoh.com';
        if (userData?['profileImage'] != null) {
          _profileImage = File(userData!['profileImage']);
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Gagal memuat data pengguna: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    try {
      setState(() => _isLoading = true);
      await _authService.updateProfileImage(imageFile.path);

      if (!mounted) return;
      setState(() {
        _profileImage = imageFile;
        _isLoading = false;
      });
    } catch (e) {
      print('Gagal mengupdate foto profil: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengupdate foto profil')),
      );
    }
  }

  Future<void> _takeProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) return;

      // Get current location
      await _getCurrentLocation();

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(
        image.path,
      ).copy('${appDir.path}/$fileName');

      // Save to device gallery
      final bytes = await savedImage.readAsBytes();
      final result = await ImageGallerySaverPlus.saveImage(bytes);
      if (result['isSuccess']) {
        print('Foto disimpan di galeri');
      } else {
        print('Gagal menyimpan foto di galeri');
      }

      // Update profile
      await _updateProfileImage(savedImage);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diupdate')),
      );
    } catch (e) {
      print('Error taking photo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _chooseProfilePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) return;

      // Get current location
      await _getCurrentLocation();

      // Save to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(
        image.path,
      ).copy('${appDir.path}/$fileName');

      // Update profile
      await _updateProfileImage(savedImage);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diupdate')),
      );
    } catch (e) {
      print('Error choosing photo: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() => _isGettingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Layanan lokasi tidak aktif')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin lokasi ditolak permanen')),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _location =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isGettingLocation = false);
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _takeProfilePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _chooseProfilePhoto();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      setState(() => _isLoading = true);
      await _authService.logout();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      print('Logout gagal: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal logout')));
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: _showPhotoOptions,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue[100],
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.blue[600])
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              _username,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _email,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 20),
            if (_location != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Lokasi: $_location',
                      style: TextStyle(color: Colors.blue[800], fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            ElevatedButton(
              onPressed: _showPhotoOptions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Ubah Foto Profil'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).cardColor,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: Colors.blue.withOpacity(0.1),
        highlightColor: Colors.blue.withOpacity(0.05),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.blue).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor ?? Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akun Saya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 16),
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Riwayat Kunjungan',
                    subtitle: 'Lihat tempat wisata yang pernah dikunjungi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WisataListScreen(type: 'riwayat'),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.favorite_border,
                    title: 'Wisata Favorit',
                    subtitle: 'Tempat wisata yang ingin dikunjungi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WisataListScreen(type: 'favorit'),
                        ),
                      );
                    },
                    iconColor: Colors.pink,
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    subtitle: 'Pengaturan notifikasi aplikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => NotificationScreen()),
                      );
                    },
                    iconColor: Colors.orange,
                  ),
                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Pengaturan',
                    subtitle: 'Atur preferensi aplikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SettingsScreen()),
                      );
                    },
                    iconColor: Colors.grey,
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    subtitle: 'FAQ dan panduan penggunaan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HelpScreen()),
                      );
                    },
                    iconColor: Colors.green,
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi dan informasi pengembang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                    iconColor: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      subtitle: 'Keluar dari akun Anda',
                      onTap: _showLogoutDialog,
                      iconColor: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
