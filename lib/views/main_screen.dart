import 'package:rice_diseases_classification/views/home_screen.dart';
import 'package:rice_diseases_classification/views/riwayat_screen.dart';
import 'package:rice_diseases_classification/views/list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rice_diseases_classification/views/hasil_scan_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

// Variabel untuk melacak halaman/tab yang sedang aktif
class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  // Untuk akses kamera atau galeri
  final ImagePicker _picker = ImagePicker();
  // Daftar halaman yang akan ditampilkan
  List<Widget> _pages = [];
  // Fungsi untuk mengambil foto dari kamera
  Future<void> _ambilFotoDariKamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final path = pickedFile.path;
      // Setelah foto diambil, halaman hasil scan diganti dan ditampilkan
      setState(() {
        _pages[2] = HasilScanPage(
          key: UniqueKey(), // Tambahkan ini
          imagePath: path,
          imagePath2: pickedFile,
          uploadGambar: "1",
        );
        _selectedIndex = 2;
      });
    }
  }


  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman
    _pages = [
      HomePage(onItemTapped: onItemTapped, onScanResult: (path, file) {
        setState(() {
          _pages[2] = HasilScanPage(imagePath: path, imagePath2: file, uploadGambar: "1",);
          _selectedIndex = 2;
        });
      },),
      RiwayatPage(onBackToHome: () => onItemTapped(0), onItemTapped: onItemTapped, onScanResult: (path, index) {
        setState(() {
          _pages[2] = HasilScanPage(imagePath: path, uploadGambar: "0", indexPenyakit: index,);
          _selectedIndex = 2;
        });
      },),
      Container(), // Akan diganti setelah ambil foto
      ListPage(onBackToHome: () => onItemTapped(0)),
    ];
  }

  // Fungsi untuk berpindah tab
  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // karena tombol tengah tidak dihitung
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tampilkan halaman sesuai tab aktif
      body: _pages[_selectedIndex],
      // Bottom navigation bar dengan 2 tombol + floating button di tengah
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            // HOME ICON
            GestureDetector(
              onTap: () => onItemTapped(0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 1.h), // spacing atas
                  SvgPicture.asset(
                    "assets/icon/icon_home.svg",
                    width: 3.5.h,
                    height: 3.5.h,
                    color: (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
                        ? Color(0xFF0CA356)
                        : Colors.grey,
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    height: 0.3.h,
                    width: 6.h,
                    color: (_selectedIndex == 0 || _selectedIndex == 1 || _selectedIndex == 2)
                        ? Color(0xFF0CA356)
                        : Colors.transparent,
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),

            const SizedBox(width: 48), // Spacer for FAB

            // LIST ICON
            GestureDetector(
              onTap: () => onItemTapped(3),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 1.h), // spacing atas
                  SvgPicture.asset(
                    "assets/icon/icon_list.svg",
                    width: 3.5.h,
                    height: 3.5.h,
                    color: _selectedIndex == 3 ? Color(0xFF0CA356) : Colors.grey,
                  ),
                  SizedBox(height: 0.5.h),
                  Container(
                    height: 0.3.h,
                    width: 6.h,
                    color: _selectedIndex == 3 ? Color(0xFF0CA356) : Colors.transparent,
                  ),
                  SizedBox(height: 1.h),
                ],
              ),
            ),
          ],
        ),
      ),
      // Tombol kamera di tengah bottom bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 7.h,  // lebar custom
        height: 7.h, // tinggi custom
        child: FloatingActionButton(
          backgroundColor: Color(0xFF0CA356),
          onPressed: () => _ambilFotoDariKamera(),
          tooltip: 'Kamera',
          child: SvgPicture.asset(
            "assets/icon/icon_camera.svg",
            width: 3.h,
            height: 3.h,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
