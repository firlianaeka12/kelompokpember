import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String appName = '';
  String version = '';
  String buildNumber = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getPackageInfo();
  }

  Future<void> _getPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appName = packageInfo.appName;
      version = packageInfo.version;
      buildNumber = packageInfo.buildNumber;
      isLoading = false;
    });
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: Image.asset(
                      'assets/logo.png', // Replace with your app logo
                      height: 120,
                      width: 120,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      appName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Versi $version (Build $buildNumber)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Deskripsi Aplikasi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Aplikasi Wisata Surabaya adalah platform untuk menemukan dan menjelajahi berbagai tempat wisata menarik di Surabaya. Dengan fitur favorit dan riwayat kunjungan, pengguna dapat dengan mudah mengelola daftar tempat yang ingin dikunjungi.',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Fitur Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(Icons.favorite, 'Wisata Favorit'),
                  _buildFeatureItem(Icons.history, 'Riwayat Kunjungan'),
                  _buildFeatureItem(Icons.map, 'Peta Lokasi Wisata'),
                  _buildFeatureItem(Icons.star, 'Rating dan Ulasan'),
                  const SizedBox(height: 20),
                  const Text(
                    'Hubungi Kami',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildContactItem(
                    Icons.email,
                    'Email',
                    'support@wisatasurabaya.com',
                    'mailto:support@wisatasurabaya.com',
                  ),
                  _buildContactItem(
                    Icons.web,
                    'Website',
                    'www.wisatasurabaya.com',
                    'https://www.wisatasurabaya.com',
                  ),
                  _buildContactItem(
                    Icons.phone,
                    'Telepon',
                    '+62 123 4567 890',
                    'tel:+621234567890',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Hak Cipta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2023 Wisata Surabaya. All rights reserved.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      IconData icon, String label, String value, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: () => _launchURL(url),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}