class TempatWisata {
  final int id;
  final String namaTempat;
  final String alamat;
  final String deskripsiSingkat;
  final int hargaTiket;
  final String gambarUtama;
  final List<String> fasilitas;

  TempatWisata({
    required this.id,
    required this.namaTempat,
    required this.alamat,
    required this.deskripsiSingkat,
    required this.hargaTiket,
    required this.gambarUtama,
    required this.fasilitas,
  });
}