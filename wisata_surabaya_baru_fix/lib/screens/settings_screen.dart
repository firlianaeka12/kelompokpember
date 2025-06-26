import 'package:flutter/material.dart';
import 'package:wisata_surabaya_baru_fix/screens/akun_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkModeEnabled = false;
  String _language = 'Indonesia';
  String _mapProvider = 'Google Maps';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Aplikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
              context,
              MaterialPageRoute(builder: (context) => const AkunScreen()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tampilan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode Gelap'),
                    subtitle: const Text('Aktifkan untuk tampilan gelap'),
                    value: _darkModeEnabled,
                    onChanged: (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Bahasa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Bahasa Aplikasi'),
                subtitle: Text(_language),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Peta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Penyedia Peta'),
                subtitle: Text(_mapProvider),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showMapProviderDialog();
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Lainnya',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Bersihkan Cache'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      _clearCache();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Kebijakan Privasi'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to privacy policy
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Ketentuan Layanan'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // Navigate to terms of service
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Bahasa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Indonesia'),
              value: 'Indonesia',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value.toString();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMapProviderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Penyedia Peta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Google Maps'),
              value: 'Google Maps',
              groupValue: _mapProvider,
              onChanged: (value) {
                setState(() {
                  _mapProvider = value.toString();
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile(
              title: const Text('OpenStreetMap'),
              value: 'OpenStreetMap',
              groupValue: _mapProvider,
              onChanged: (value) {
                setState(() {
                  _mapProvider = value.toString();
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bersihkan Cache'),
        content: const Text(
          'Apakah Anda yakin ingin membersihkan cache aplikasi?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache berhasil dibersihkan')),
              );
            },
            child: const Text('Bersihkan'),
          ),
        ],
      ),
    );
  }
}
