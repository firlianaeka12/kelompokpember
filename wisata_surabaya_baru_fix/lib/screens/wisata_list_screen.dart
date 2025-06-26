import 'package:flutter/material.dart';
import '../models/wisata_model.dart';
import '../service/wisata_service.dart';
import 'wisata_form_screen.dart';
import 'wisata_detail_screen.dart';

class WisataListScreen extends StatefulWidget {
  final String type; // 'favorit' atau 'riwayat'

  const WisataListScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<WisataListScreen> createState() => _WisataListScreenState();
}

class _WisataListScreenState extends State<WisataListScreen> {
  final WisataService _wisataService = WisataService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == 'favorit' ? 'Wisata Favorit' : 'Riwayat Wisata',
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
        bottom: _isSearching
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari wisata...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              )
            : null,
      ),
      body: StreamBuilder<List<WisataModel>>(
        stream: _getWisataStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {});
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final wisataList = snapshot.data ?? [];

          if (wisataList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.type == 'favorit'
                        ? Icons.favorite_border
                        : Icons.history,
                    color: Colors.grey,
                    size: 80,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.type == 'favorit'
                        ? 'Belum ada wisata favorit'
                        : 'Belum ada riwayat wisata',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: wisataList.length,
            itemBuilder: (context, index) {
              final wisata = wisataList[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      wisata.gambar,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    wisata.namaTempat,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wisata.alamat,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${wisata.hargaTiket.toString()}',
                        style: TextStyle(
                          color: Colors.green[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'detail',
                        child: Row(
                          children: [
                            Icon(Icons.info),
                            SizedBox(width: 8),
                            Text('Detail'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Hapus', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'detail':
                          _navigateToDetail(wisata);
                          break;
                        case 'edit':
                          _navigateToEdit(wisata);
                          break;
                        case 'delete':
                          _showDeleteDialog(wisata);
                          break;
                      }
                    },
                  ),
                  onTap: () => _navigateToDetail(wisata),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        backgroundColor: Colors.blue[600],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Stream<List<WisataModel>> _getWisataStream() {
    if (_searchController.text.isNotEmpty) {
      return widget.type == 'favorit'
          ? _wisataService.searchFavoritWisata(_searchController.text)
          : _wisataService.searchRiwayatWisata(_searchController.text);
    } else {
      return widget.type == 'favorit'
          ? _wisataService.getFavoritWisataStream()
          : _wisataService.getRiwayatWisataStream();
    }
  }

  void _navigateToAdd() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WisataFormScreen(type: widget.type),
      ),
    );
  }

  void _navigateToEdit(WisataModel wisata) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WisataFormScreen(type: widget.type, wisata: wisata),
      ),
    );
  }

  void _navigateToDetail(WisataModel wisata) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WisataDetailScreen(wisata: wisata, type: widget.type),
      ),
    );
  }

  void _showDeleteDialog(WisataModel wisata) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus "${wisata.namaTempat}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteWisata(wisata);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWisata(WisataModel wisata) async {
    try {
      if (widget.type == 'favorit') {
        await _wisataService.deleteFavoritWisata(wisata.id!);
      } else {
        await _wisataService.deleteRiwayatWisata(wisata.id!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${wisata.namaTempat} berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
