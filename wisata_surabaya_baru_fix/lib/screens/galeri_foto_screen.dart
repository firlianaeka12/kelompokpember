import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wisata_surabaya_baru_fix/screens/lihat_foto_screen.dart';

class GaleriFotoScreen extends StatefulWidget {
  final List<File> photos;
  final String namaTempat;

  const GaleriFotoScreen({
    Key? key,
    required this.photos,
    required this.namaTempat,
  }) : super(key: key);

  @override
  _GaleriFotoScreenState createState() => _GaleriFotoScreenState();
}

class _GaleriFotoScreenState extends State<GaleriFotoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Galeri Foto ${widget.namaTempat}')),
      body: widget.photos.isEmpty
          ? const Center(child: Text('Tidak ada foto tersimpan'))
          : GridView.builder(
              padding: const EdgeInsets.all(4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Lebih banyak kolom untuk tampilan padat
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: widget.photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LihatFotoScreen(
                          imagePath: widget.photos[index].path,
                          namaTempat: widget.namaTempat,
                          alamat: '',
                          namaPengguna: '',
                          onDelete: (path) {
                            // Implementasi hapus foto
                            setState(() {
                              widget.photos.removeWhere(
                                  (file) => file.path == path);
                            });
                          },
                          onEdit: (newTempat, newAlamat, path) {
                            // Tidak perlu implementasi edit di galeri
                          },
                        ),
                      ),
                    );
                  },
                  child: Image.file(
                    widget.photos[index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
    );
  }
}