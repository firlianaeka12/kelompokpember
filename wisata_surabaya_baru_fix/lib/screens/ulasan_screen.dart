import 'package:flutter/material.dart';
import '../models/ulasan.dart';
import '../service/ulasan_service.dart';
import 'ulasan_form.dart';

class UlasanScreen extends StatefulWidget {
  final int wisataId;
  final String wisataNama;
  final int userId; // Tambahkan parameter userId

  const UlasanScreen({
    Key? key,
    required this.wisataId,
    required this.wisataNama,
    required this.userId, // Tambahkan ini
  }) : super(key: key);

  @override
  _UlasanScreenState createState() => _UlasanScreenState();
}

class _UlasanScreenState extends State<UlasanScreen> {
  List<Ulasan> _ulasanList = [];
  double _averageRating = 0;
  int _totalUlasan = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _muatUlasan();
  }

  Future<void> _muatUlasan() async {
    setState(() => _isLoading = true);
    try {
      final response = await UlasanService.dapatkanUlasanByWisata(
        widget.wisataId,
      );
      setState(() {
        _ulasanList = (response['ulasan'] as List).cast<Ulasan>();
        _averageRating = response['rata_rata_rating'] ?? 0.0;
        _totalUlasan = response['total_ulasan'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat ulasan: ${e.toString()}'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
      debugPrint('Error memuat ulasan: ${e.toString()}');
    }
  }

  Future<void> _hapusUlasan(int id) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menghapus ulasan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      try {
        await UlasanService.hapusUlasan(id);
        _muatUlasan();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ulasan berhasil dihapus')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus ulasan: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ulasan ${widget.wisataNama}')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Ulasan',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UlasanFormScreen(
                wisataId: widget.wisataId,
                wisataNama: widget.wisataNama,
                userId: widget.userId, // Sertakan userId
              ),
            ),
          );
          if (result == true) _muatUlasan();
        },
        child: const Icon(Icons.add_comment),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _muatUlasan,
              child: CustomScrollView(
                slivers: [
                  if (_totalUlasan > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  'Rating Rata-rata',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      Icons.star,
                                      size: 28,
                                      color: index < _averageRating.round()
                                          ? Colors.amber
                                          : Colors.grey,
                                    );
                                  }),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Dari $_totalUlasan ulasan',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  _ulasanList.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.comment,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text('Belum ada ulasan'),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: _muatUlasan,
                                  child: const Text('Muat Ulang'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final ulasan = _ulasanList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: List.generate(5, (i) {
                                            return Icon(
                                              Icons.star,
                                              size: 20,
                                              color: i < ulasan.rating
                                                  ? Colors.amber
                                                  : Colors.grey,
                                            );
                                          }),
                                        ),
                                        if (ulasan.userId == widget.userId)
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _hapusUlasan(ulasan.id),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      ulasan.komentar,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Oleh: User ${ulasan.userId}',
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }, childCount: _ulasanList.length),
                        ),
                ],
              ),
            ),
    );
  }
}
