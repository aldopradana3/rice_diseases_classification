import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  final void Function(int index) onItemTapped;
  final void Function(String path, XFile pickedFile) onScanResult;

  const HomePage({super.key, required this.onItemTapped, required this.onScanResult});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
  }

  Future<void> _ambilFotoDariGaleri() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final path = pickedFile.path;
      widget.onScanResult(path, pickedFile); // kirim ke parent
      widget.onItemTapped(2); // navigasi ke tab hasil scan
    }
  }



  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            'assets/images/rerumputan.png',
            width: 100.w,
            fit: BoxFit.fitWidth, // Tambahkan ini
          ),
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.h),
          child: Column(
            children: [
              SizedBox(height: 15.h,),
              Center(
                child: Text(
                  'Selamat Datang di Aplikasi Deteksi Penyakit Padi',
                  style: GoogleFonts.poppins(
                      fontSize: 2.5.h,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 5.h,),
              Center(
                child: Text(
                  capitalizeEachWord(
                    'Aplikasi ini membantu petani dan pengguna lainnya untuk mengenali jenis penyakit pada tanaman padi hanya dengan foto. Dapatkan juga rekomendasi pupuk untuk penanganan yang tepat.',
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 1.5.h,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 6.h,),
              Center(
                child: Text(
                  capitalizeEachWord(
                    'Arahkan kamera ke daun padi atau unggah gambar',
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 1.5.h,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 1.h,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _ambilFotoDariGaleri();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(85.w, 6.h), // ✅ Ukuran fix
                    // Atur tinggi dan lebar sesuai kebutuhan
                    backgroundColor: Color(0xFF0CA356),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border
                    ),
                  ),
                  child: Text(
                    'Mulai Deteksi',
                    style: GoogleFonts.poppins(
                      fontSize: 2.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 1.5.h,),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    widget.onItemTapped(1);
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(85.w, 6.h), // ✅ Ukuran fix
                    // Atur tinggi dan lebar sesuai kebutuhan
                    backgroundColor: Color(0xFFEB5757),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Sudut border
                    ),
                  ),
                  child: Text(
                    'Riwayat Deteksi',
                    style: GoogleFonts.poppins(
                      fontSize: 2.h,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
