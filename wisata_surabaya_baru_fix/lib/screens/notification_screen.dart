import 'package:flutter/material.dart';
import 'package:wisata_surabaya_baru_fix/screens/akun_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _pushNotificationEnabled = true;
  bool _emailNotificationEnabled = false;
  bool _promoNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Notifikasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
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
              'Jenis Notifikasi',
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
                    title: const Text('Notifikasi Push'),
                    subtitle: const Text(
                      'Aktifkan untuk menerima notifikasi langsung',
                    ),
                    value: _pushNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _pushNotificationEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Notifikasi Email'),
                    subtitle: const Text(
                      'Aktifkan untuk menerima notifikasi via email',
                    ),
                    value: _emailNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _emailNotificationEnabled = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Promo dan Penawaran'),
                    subtitle: const Text(
                      'Aktifkan untuk menerima promo menarik',
                    ),
                    value: _promoNotificationEnabled,
                    onChanged: (value) {
                      setState(() {
                        _promoNotificationEnabled = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Notifikasi Terkini',
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
                    leading: const Icon(Icons.event, color: Colors.blue),
                    title: const Text('Event Wisata Surabaya'),
                    subtitle: const Text(
                      'Ada event baru di Taman Bungkul minggu depan',
                    ),
                    trailing: Text(
                      'Baru',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.discount, color: Colors.green),
                    title: const Text('Diskon Tiket Masuk'),
                    subtitle: const Text(
                      'Diskon 20% untuk wisata pilihan bulan ini',
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info, color: Colors.orange),
                    title: const Text('Pembaruan Aplikasi'),
                    subtitle: const Text(
                      'Versi terbaru aplikasi sudah tersedia',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
