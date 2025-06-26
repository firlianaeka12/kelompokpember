import 'package:flutter/material.dart';
import 'package:wisata_surabaya_baru_fix/models/tempat_wisata.dart';
import 'package:wisata_surabaya_baru_fix/models/ulasan.dart';
import 'package:wisata_surabaya_baru_fix/service/auth_service.dart';
import 'package:wisata_surabaya_baru_fix/service/ulasan_service.dart';
import 'package:wisata_surabaya_baru_fix/screens/login_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/ulasan_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/detail_wisata.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  late TabController _akunTabController;

  String _username = 'Pengguna';
  bool _isLoading = true;
  int _selectedIndex = 0;
  String _searchQuery = '';

  // Data dummy untuk contoh dengan lebih banyak variasi
  final List<TempatWisata> _wisataList = [
    TempatWisata(
      id: 1,
      namaTempat: 'Monumen Kapal Selam',
      alamat: 'Jl. Pemuda No.39, Embong Kaliasin, Genteng, Surabaya',
      deskripsiSingkat:
          'Monumen Kapal Selam adalah museum berupa kapal selam KRI Pasopati 410 yang pernah digunakan TNI AL. Kapal ini merupakan buatan Uni Soviet tahun 1952 dan aktif hingga 1990. Pengunjung dapat masuk ke dalam kapal selam untuk melihat berbagai ruangan seperti torpedo, ruang kendali, dan tempat tidur awak kapal.',
      hargaTiket: 15000,
      gambarUtama: 'assets/kapal_selam1.jpg',
      fasilitas: [
        'Toilet',
        'Parkir',
        'Restoran',
        'Akses Difable',
        'Wifi',
        'Mushola',
      ],
    ),
    TempatWisata(
      id: 2,
      namaTempat: 'House of Sampoerna',
      alamat: 'Jl. Taman Sampoerna No.6, Krembangan Utara, Surabaya',
      deskripsiSingkat:
          'Museum yang menceritakan sejarah industri rokok di Indonesia, khususnya Sampoerna. Bangunan bergaya kolonial ini menampilkan proses pembuatan rokok tradisional, koleksi benda bersejarah, dan galeri seni. Terdapat juga kafe dan toko suvenir.',
      hargaTiket: 25000,
      gambarUtama: 'assets/sampoerna.jpg',
      fasilitas: [
        'Toilet',
        'Parkir',
        'Restoran',
        'Akses Difable',
        'Wifi',
        'Mushola',
      ],
    ),
    TempatWisata(
      id: 3,
      namaTempat: 'Kebun Binatang Surabaya',
      alamat: 'Jl. Setail No.1, Darmo, Wonokromo, Surabaya',
      deskripsiSingkat:
          'Kebun binatang tertua di Asia Tenggara (didirikan 1916) dengan luas 15 hektar. Memiliki koleksi lebih dari 2.000 hewan dari 200 spesies, termasuk komodo, orangutan, dan harimau Sumatera. Terdapat juga taman bermain anak dan wahana air.',
      hargaTiket: 30000,
      gambarUtama: 'assets/kebunbinatang.jpg',
      fasilitas: [
        'Toilet',
        'Parkir',
        'Restoran',
        'Akses Difable',
        'Wifi',
        'Mushola',
      ],
    ),
    TempatWisata(
      id: 4,
      namaTempat: 'Tugu Pahlawan',
      alamat: 'Jl. Pahlawan, Alun-alun Contong, Bubutan, Surabaya',
      deskripsiSingkat:
          'Monumen setinggi 41,15 meter ini dibangun untuk memperingati Pertempuran 10 November 1945. Terdapat museum di bawah monumen yang menyimpan berbagai benda bersejarah dari masa perjuangan. Area sekitar monumen sering digunakan untuk acara kenegaraan dan upacara.',
      hargaTiket: 10000,
      gambarUtama: 'assets/tugu.jpg',
      fasilitas: [
        'Toilet',
        'Parkir',
        'Restoran',
        'Akses Difable',
        'Wifi',
        'Mushola',
      ],
    ),
  ];

  List<Ulasan> _ulasanSaya = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _akunTabController = TabController(length: 2, vsync: this);
    _checkLoginAndLoadData();
    _muatUlasanSaya();
  }

  // Method untuk memuat ulasan yang dibuat oleh user
  Future<void> _muatUlasanSaya() async {
    try {
      final semuaUlasan = await UlasanService.dapatkanSemuaUlasan();
      // Asumsikan userId = 1 untuk contoh (harus diganti dengan userId asli)
      setState(() {
        _ulasanSaya = semuaUlasan
            .where((ulasan) => ulasan.userId == 1)
            .toList();
      });
    } catch (e) {
      debugPrint('Gagal memuat ulasan: $e');
    }
  }

  // Method untuk validasi session
  Future<bool> _validateSession() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        return false;
      }

      final userData = await _authService.getCurrentUser();
      return userData != null;
    } catch (e) {
      debugPrint('Error validating session: $e');
      return false;
    }
  }

  // Method untuk cek login dan load data
  Future<void> _checkLoginAndLoadData() async {
    await _loadUserData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _akunTabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      // Validasi session terlebih dahulu
      final isSessionValid = await _validateSession();

      if (!isSessionValid) {
        // Jika session tidak valid, redirect ke login
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
        return;
      }

      // Ambil data user dari AuthService
      final userData = await _authService.getCurrentUser();

      if (mounted) {
        setState(() {
          _username = userData?['username'] ?? 'Pengguna';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Gagal memuat data pengguna: $e');
      if (mounted) {
        setState(() {
          _username = 'Pengguna';
          _isLoading = false;
        });

        // Jika error karena network atau server, tampilkan pesan
        _showSnackBar('Gagal memuat data pengguna');
      }
    }
  }

  Future<void> _logout() async {
    // Tampilkan dialog konfirmasi
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    setState(() => _isLoading = true);

    try {
      // Panggil method logout dari AuthService
      await _authService.logout();

      if (!mounted) return;

      // Redirect ke login screen dan hapus semua route sebelumnya
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      debugPrint('Error logout: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Gagal melakukan logout: ${e.toString()}');
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  List<TempatWisata> get _filteredWisataList {
    if (_searchQuery.isEmpty) {
      return _wisataList;
    }
    return _wisataList.where((wisata) {
      final namaTempat = wisata.namaTempat.toLowerCase();
      final alamat = wisata.alamat.toLowerCase();
      final query = _searchQuery.toLowerCase();

      return namaTempat.contains(query) || alamat.contains(query);
    }).toList();
  }

  // Method untuk format currency
  String _formatCurrency(int amount) {
    return 'Rp ${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // Method untuk tab Beranda
  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserData();
        _showSnackBar('Data berhasil diperbarui');
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang,',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  Text(
                    _username,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Jelajahi keindahan Surabaya!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari tempat wisata...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
              ),
            ),
            const SizedBox(height: 24),

            // Header Daftar Wisata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tempat Wisata Surabaya',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_filteredWisataList.length} tempat',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List Wisata
            _filteredWisataList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filteredWisataList.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final wisata = _filteredWisataList[index];
                      return _buildWisataCard(wisata);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada tempat wisata ditemukan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba gunakan kata kunci yang berbeda',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildWisataCard(TempatWisata wisata) {
    return Card(
      elevation: 4,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToDetailScreen(wisata),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    wisata.gambarUtama,
                    fit: BoxFit.cover, // Sesuaikan dengan kebutuhan
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wisata.namaTempat,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      wisata.deskripsiSingkat,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _formatCurrency(wisata.hargaTiket),
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetailScreen(TempatWisata wisata) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailWisataScreen(wisata: wisata),
      ),
    );
  }

  // Method untuk tab Akun
  Widget _buildAkunTab() {
    return Column(
      children: [
        // Tab Bar untuk Akun
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _akunTabController,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade700,
            onTap: (index) {},
            tabs: const [
              Tab(text: 'Profil'),
              Tab(text: 'Ulasan Saya'),
            ],
          ),
        ),

        // Tab View untuk Akun
        Expanded(
          child: TabBarView(
            controller: _akunTabController,
            children: [
              // Tab Profil
              _buildProfilTab(),

              // Tab Ulasan Saya
              _buildUlasanTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade50, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pengguna Wisata Surabaya',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Menu Section
          const Text(
            'Menu Utama',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Menu Items
          _buildMenuTile(
            icon: Icons.favorite,
            title: 'Wisata Favorit',
            subtitle: 'Lihat tempat wisata yang disimpan',
            onTap: () => _showSnackBar('Fitur Wisata Favorit'),
          ),
          _buildMenuTile(
            icon: Icons.history,
            title: 'Riwayat Kunjungan',
            subtitle: 'Tempat yang pernah dikunjungi',
            onTap: () => _showSnackBar('Fitur Riwayat Kunjungan'),
          ),

          const SizedBox(height: 24),

          const Text(
            'Pengaturan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          _buildMenuTile(
            icon: Icons.settings,
            title: 'Pengaturan',
            subtitle: 'Atur preferensi aplikasi',
            onTap: () => _showSnackBar('Fitur Pengaturan'),
          ),
          _buildMenuTile(
            icon: Icons.help,
            title: 'Bantuan',
            subtitle: 'FAQ dan panduan penggunaan',
            onTap: () => _showSnackBar('Fitur Bantuan'),
          ),
          _buildMenuTile(
            icon: Icons.info,
            title: 'Tentang Aplikasi',
            subtitle: 'Informasi versi dan developer',
            onTap: () => _showSnackBar('Fitur Tentang Aplikasi'),
          ),

          const SizedBox(height: 32),

          // Logout Button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildUlasanTab() {
    return _ulasanSaya.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.reviews, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'Belum ada ulasan',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    // Navigasi ke daftar wisata untuk membuat ulasan baru
                    setState(() => _selectedIndex = 0);
                  },
                  child: const Text('Buat Ulasan Pertama'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _muatUlasanSaya,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ulasanSaya.length,
              itemBuilder: (context, index) {
                final ulasan = _ulasanSaya[index];
                final wisata = _wisataList.firstWhere(
                  (w) => w.id == ulasan.wisataId,
                  orElse: () => TempatWisata(
                    id: 0,
                    namaTempat: 'Tempat tidak ditemukan',
                    alamat: '',
                    deskripsiSingkat: '',
                    hargaTiket: 0,
                    gambarUtama: '',
                    fasilitas: [],
                  ),
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              wisata.namaTempat,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Row(
                              children: List.generate(
                                5,
                                (i) => Icon(
                                  Icons.star,
                                  size: 16,
                                  color: i < ulasan.rating
                                      ? Colors.amber
                                      : Colors.grey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ulasan.komentar,
                          style: TextStyle(color: Colors.grey.shade800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ditulis pada: ${ulasan.tanggal}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                // Navigasi ke detail ulasan
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UlasanScreen(
                                      wisataId: wisata.id,
                                      wisataNama: wisata.namaTempat,
                                      userId: wisata.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Lihat Detail'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue.shade600),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wisata Surabaya'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data...'),
                ],
              ),
            )
          : IndexedStack(
              index: _selectedIndex,
              children: [_buildHomeTab(), _buildAkunTab()],
            ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        elevation: 8,
      ),
    );
  }
}
