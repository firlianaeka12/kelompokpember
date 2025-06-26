import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:wisata_surabaya_baru_fix/models/tempat_wisata.dart';
import 'package:wisata_surabaya_baru_fix/screens/lihat_foto_screen.dart';
import 'package:wisata_surabaya_baru_fix/screens/galeri_foto_screen.dart';

class TambahFotoScreen extends StatefulWidget {
  final TempatWisata wisata;

  const TambahFotoScreen({Key? key, required this.wisata}) : super(key: key);

  @override
  _TambahFotoScreenState createState() => _TambahFotoScreenState();
}

class _TambahFotoScreenState extends State<TambahFotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  List<File> _savedPhotos = [];
  String _currentLocation = 'Mendapatkan lokasi...';
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPhotos();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _namaController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Layanan lokasi tidak aktif';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Izin lokasi ditolak';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Izin lokasi ditolak permanen';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      Placemark place = placemarks.first;

      setState(() {
        _currentLocation =
            '${place.street}, ${place.subLocality}, ${place.locality}';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Gagal mendapatkan lokasi: ${e.toString()}';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadSavedPhotos() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(appDir.path);

    try {
      final files = await dir.list().toList();
      setState(() {
        _savedPhotos = files
            .where((file) => file is File && file.path.endsWith('.jpg'))
            .map((file) => File(file.path))
            .toList();
      });
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  Future<void> _getImageFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        // Update lokasi saat mengambil foto baru
        await _getCurrentLocation();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: ${e.toString()}')),
      );
    }
  }

  Future<void> _getImageFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih gambar: ${e.toString()}')),
      );
    }
  }

  Future<void> _simpanFoto() async {
    if (_formKey.currentState!.validate() && _imageFile != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await _imageFile!.copy('${appDir.path}/$fileName');

      setState(() {
        _savedPhotos.add(savedImage);
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LihatFotoScreen(
            imagePath: savedImage.path,
            namaTempat: widget.wisata.namaTempat,
            alamat: _currentLocation, // Gunakan lokasi yang didapat
            namaPengguna: _namaController.text,
            onDelete: (path) {
              setState(() {
                _savedPhotos.removeWhere((file) => file.path == path);
                File(path).delete();
              });
            },
            onEdit: (newTempat, newAlamat, path) {},
          ),
        ),
      );
    } else if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan ambil foto terlebih dahulu')),
      );
    }
  }

  void _lihatFotoTersimpan() {
    if (_savedPhotos.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GaleriFotoScreen(
            photos: _savedPhotos,
            namaTempat: widget.wisata.namaTempat,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Belum ada foto tersimpan')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Foto Wisata'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _lihatFotoTersimpan,
            tooltip: 'Lihat Foto Tersimpan',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.wisata.namaTempat,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.wisata.alamat,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              // Menampilkan lokasi saat ini
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi Saat Ini:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isLoadingLocation
                          ? const LinearProgressIndicator()
                          : Text(_currentLocation),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _getCurrentLocation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Perbarui Lokasi'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Anda',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan masukkan nama Anda';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Ambil Foto:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getImageFromCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _getImageFromGallery,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_imageFile != null)
                Column(
                  children: [
                    const Text(
                      'Pratinjau Foto:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _simpanFoto,
                child: const Text('Simpan Foto'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 20),
              if (_savedPhotos.isNotEmpty)
                ElevatedButton(
                  onPressed: _lihatFotoTersimpan,
                  child: const Text('Lihat Foto Tersimpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
