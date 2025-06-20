import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Halaman KameraPage
class KameraPage extends StatefulWidget {
  @override
  _KameraPageState createState() => _KameraPageState();
}

class _KameraPageState extends State<KameraPage> {
  // List untuk menyimpan path foto
  List<String> _fotoPaths = [];
  // ImagePicker
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadFotoPaths();
  }
  // Fungsi: Ambil foto dari kamera
  Future<void> _ambilFotoDariKamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    await _simpanFoto(pickedFile);
  }
  // Fungsi: Ambil foto dari galeri
  Future<void> _ambilFotoDariGaleri() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    await _simpanFoto(pickedFile);
  }
  // Fungsi: Simpan path foto ke list & SharedPreferences
  Future<void> _simpanFoto(XFile? pickedFile) async {
    if (pickedFile != null) {
      final path = pickedFile.path;
      // Update state list foto
      setState(() {
        _fotoPaths.add(path);
      });
      // Simpan ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('foto_paths', _fotoPaths);
    }
  }
  // Fungsi: Load foto paths dari SharedPreferences
  Future<void> _loadFotoPaths() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPaths = prefs.getStringList('foto_paths') ?? [];
    // Cek apakah file masih ada
    _fotoPaths = savedPaths.where((path) => File(path).existsSync()).toList();

    setState(() {});
  }
  // Fungsi: Hapus semua foto (file & SharedPreferences)
  Future<void> _hapusSemuaFoto() async {
    // Hapus file foto dari storage (jika masih ada)
    for (var path in _fotoPaths) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }

    // Kosongkan list dan SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('foto_paths');

    setState(() {
      _fotoPaths.clear();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galeri Kamera'),
        actions: [
          // Tombol "Hapus Semua"
          IconButton(
            icon: Icon(Icons.delete_forever),
            tooltip: 'Hapus Semua Foto',
            onPressed: () {
              if (_fotoPaths.isNotEmpty) {
                // Tampilkan dialog konfirmasi hapus
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Konfirmasi'),
                    content: Text('Yakin ingin menghapus semua foto?'),
                    actions: [
                      TextButton(
                        child: Text('Batal'),
                        onPressed: () => Navigator.pop(context),
                      ),
                      ElevatedButton(
                        child: Text('Hapus'),
                        onPressed: () {
                          Navigator.pop(context);
                          _hapusSemuaFoto();
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      // Body: Tampilkan galeri foto atau pesan kosong
      body: _fotoPaths.isEmpty
          ? Center(child: Text('Belum ada foto'))
          : GridView.builder(
        padding: EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: _fotoPaths.length,
        itemBuilder: (context, index) {
          return Image.file(File(_fotoPaths[index]), fit: BoxFit.cover);
        },
      ),
       // BottomNavigationBar: Tombol ambil foto / ambil galeri
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: _ambilFotoDariKamera,
              icon: Icon(Icons.camera_alt),
              label: Text('Kamera'),
            ),
            ElevatedButton.icon(
              onPressed: _ambilFotoDariGaleri,
              icon: Icon(Icons.photo),
              label: Text('Galeri'),
            ),
          ],
        ),
      ),
    );
  }
}
