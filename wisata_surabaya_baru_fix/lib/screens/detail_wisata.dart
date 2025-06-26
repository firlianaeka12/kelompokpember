import 'package:flutter/material.dart';
import 'package:wisata_surabaya_baru_fix/models/tempat_wisata.dart';
import 'package:wisata_surabaya_baru_fix/screens/ulasan_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/tambah_foto_screen.dart'; // Import the new screen

class DetailWisataScreen extends StatelessWidget {
  final TempatWisata wisata;

  const DetailWisataScreen({Key? key, required this.wisata}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      wisata.gambarUtama,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      alignment: Alignment.center,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50),
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            wisata.namaTempat,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lokasi
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          wisata.alamat,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Deskripsi
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wisata.deskripsiSingkat,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                    textAlign: TextAlign.justify,
                    textHeightBehavior: const TextHeightBehavior(
                      applyHeightToFirstAscent: true,
                      applyHeightToLastDescent: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Harga Tiket dan Tombol Ulasan
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Harga Tiket',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Rp ${wisata.hargaTiket.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UlasanScreen(
                                wisataId: wisata.id,
                                wisataNama: wisata.namaTempat,
                                userId: 1, // Ganti dengan userId yang sesuai
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.reviews, size: 18),
                        label: const Text('Lihat Ulasan'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 20),

                  // Fasilitas
                  const Text(
                    'Fasilitas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: wisata.fasilitas.map((fasilitas) {
                      return InkWell(
                        onTap: () => _showFacilityDetails(context, fasilitas),
                        child: _buildFacilityChip(
                          _getIconForFacility(fasilitas),
                          fasilitas,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 20),

                  // Jam Operasional
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildScheduleRow('Senin - Jumat', '08:00 - 17:00'),
                  _buildScheduleRow('Sabtu - Minggu', '07:00 - 18:00'),
                  _buildScheduleRow('Hari Libur', '07:00 - 20:00'),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      // Modified floating action button section
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Aksi untuk menampilkan peta
            },
            backgroundColor: Colors.blue[600],
            child: const Icon(Icons.directions, color: Colors.white),
            heroTag: 'directions',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TambahFotoScreen(wisata: wisata),
                ),
              );
            },
            backgroundColor: Colors.green[600],
            child: const Icon(Icons.camera_alt, color: Colors.white),
            heroTag: 'camera',
          ),
        ],
      ),
    );
  }

  // Function to show facility details when clicked
  void _showFacilityDetails(BuildContext context, String facility) {
    String description = '';
    IconData icon = _getIconForFacility(facility);

    // Customize descriptions for each facility
    switch (facility.toLowerCase()) {
      case 'toilet':
        description =
            'Tersedia toilet umum yang bersih dan terawat di area wisata ini.';
        break;
      case 'parkir':
        description =
            'Area parkir yang luas dan aman tersedia untuk pengunjung.';
        break;
      case 'restoran':
        description =
            'Terdapat restoran/kafe dengan berbagai menu makanan dan minuman.';
        break;
      case 'akses difabel':
        description =
            'Fasilitas ramah difabel dengan akses kursi roda dan toilet khusus.';
        break;
      case 'wifi':
        description =
            'WiFi gratis tersedia di area tertentu dengan kecepatan memadai.';
        break;
      case 'mushola':
        description =
            'Tempat shalat yang nyaman dan bersih untuk pengunjung muslim.';
        break;
      default:
        description =
            'Fasilitas $facility tersedia untuk kenyamanan pengunjung.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Text(facility),
          ],
        ),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // Helper function untuk membuat chip fasilitas
  Widget _buildFacilityChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      backgroundColor: Colors.blue[50],
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  // Helper function untuk membuat baris jam operasional
  Widget _buildScheduleRow(String day, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontSize: 16)),
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function untuk mendapatkan icon berdasarkan fasilitas
  IconData _getIconForFacility(String facility) {
    switch (facility.toLowerCase()) {
      case 'toilet':
        return Icons.wc;
      case 'parkir':
        return Icons.local_parking;
      case 'restoran':
        return Icons.restaurant;
      case 'akses difabel':
        return Icons.accessible;
      case 'wifi':
        return Icons.wifi;
      case 'mushola':
        return Icons.mosque;
      default:
        return Icons.check_circle;
    }
  }
}