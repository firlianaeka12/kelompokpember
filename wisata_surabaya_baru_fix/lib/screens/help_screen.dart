import 'package:flutter/material.dart';
import 'package:wisata_surabaya_baru_fix/screens/akun_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'Bagaimana cara menambahkan wisata favorit?',
      answer:
          'Anda bisa menekan tombol hati di detail wisata untuk menambahkannya ke favorit.',
    ),
    FAQItem(
      question: 'Apakah aplikasi ini membutuhkan internet?',
      answer:
          'Ya, aplikasi membutuhkan koneksi internet untuk menampilkan data wisata dan peta.',
    ),
    FAQItem(
      question: 'Bagaimana cara melaporkan masalah?',
      answer:
          'Anda bisa mengirim email ke support@wisatasurabaya.com atau melalui menu feedback di aplikasi.',
    ),
    FAQItem(
      question: 'Apakah ada fitur offline?',
      answer:
          'Saat ini fitur offline hanya tersedia untuk daftar wisata yang sudah pernah dibuka sebelumnya.',
    ),
  ];

  int _expandedIndex = -1; // Diubah dari bool ke int

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan & Dukungan'),
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
              'FAQ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionPanelList(
                expansionCallback: (int index, bool isExpanded) {
                  setState(() {
                    _expandedIndex = isExpanded ? -1 : index;
                  });
                },
                children: _faqs.map<ExpansionPanel>((FAQItem item) {
                  int index = _faqs.indexOf(item);
                  return ExpansionPanel(
                    headerBuilder: (BuildContext context, bool isExpanded) {
                      return ListTile(title: Text(item.question));
                    },
                    body: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Text(item.answer),
                    ),
                    isExpanded: _expandedIndex == index,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Hubungi Kami',
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
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text('Email Support'),
                    subtitle: const Text('support@wisatasurabaya.com'),
                    onTap: () {
                      _launchEmail();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.phone, color: Colors.green),
                    title: const Text('Telepon'),
                    subtitle: const Text('+62 31 1234567'),
                    onTap: () {
                      _launchPhone();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Colors.orange),
                    title: const Text('Live Chat'),
                    subtitle: const Text('Buka jam 08.00 - 16.00 WIB'),
                    onTap: () {
                      // Launch live chat
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Panduan Penggunaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.book, color: Colors.purple),
                title: const Text('Buku Panduan Aplikasi'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Open user guide
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@wisatasurabaya.com',
      queryParameters: {'subject': 'Bantuan Aplikasi Wisata Surabaya'},
    );

    if (await canLaunch(emailLaunchUri.toString())) {
      await launch(emailLaunchUri.toString());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi email')),
      );
    }
  }

  Future<void> _launchPhone() async {
    const phoneNumber = 'tel:+62311234567';
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka aplikasi telepon')),
      );
    }
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
