import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

class ListPage extends StatefulWidget {
  final VoidCallback onBackToHome;

  const ListPage({super.key, required this.onBackToHome});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final List<Map<String, String>> faqList = [
    {
      'judul': 'bacterial leaf blight',
      'deskripsi': '''
Bahasa Indonesia: Hawar Daun Bakteri
Gejala: Bercak basah warna hijau keabu-abuan memanjang di pinggir atau ujung daun, daun menguning lalu mengering
Penanganan: Gunakan varietas toleran, microbe hayati (Pseudomonas, Trichoderma), sanitasi tanaman, serta varietas sesuai patotipe
Rekomendasi Pupuk: Batasi pupuk N agar tidak berlebih, bisa gunakan biofertilizer/PGPR untuk menyeimbangkan'''
    },
    {
      'judul': 'bacterial leaf streak',
      'deskripsi': '''
Bahasa Indonesia: Hawar Pelepah Daun Bakteri
Gejala: Garis-garis cokelat belang lurus memanjang di daun, menyerupai streak
Penanganan: Serupa HDB — varietas tahan, sanitasi, dan pupuk N seimbang
Rekomendasi Pupuk: N dikontrol, pupuk organik untuk memperkuat jaringan'''
    },
    {
      'judul': 'bacterial panicle blight',
      'deskripsi': '''
Bahasa Indonesia: Hawar Bunga/Sungaian Bakteri
Gejala: Pangkal malai busuk, mengering dan berkerut
Penanganan: Sanitasi lapisan malai terinfeksi, varietas toleran, fungisida bila diperlukan
Rekomendasi Pupuk: Seimbang N-K, pastikan K cukup untuk memperkuat batang dan malai'''
    },
    {
      'judul': 'blast',
      'deskripsi': '''
Bahasa Indonesia: Blas
Gejala: Bercak belah ketupat berwarna abu-cokelat pada daun, terkadang bulu abu pada permukaan
Penanganan: Varietas tahan, aplikasi fungisida sistemik (blasticidin‑S, triazol), sanitasi
Rekomendasi Pupuk: Hindari N berlebih; seimbangkan dengan K dan mikro seperti Zn'''
    },
    {
      'judul': 'brown spot',
      'deskripsi': '''
Bahasa Indonesia: Bercak Cokelat
Gejala: Bercak bulat/oval cokelat dengan lingkaran kuning, dapat menyatu besar
Penanganan: Sanitasi jerami, rotasi tanaman, fungisida (salisilat/benzoat)
Rekomendasi Pupuk: Tambah K dan Ca; batasi N; tambahkan pupuk mikto (Mg, Zn)'''
    },
    {
      'judul': 'dead heart',
      'deskripsi': '''
Bahasa Indonesia: Dead Heart
Gejala: Bagian tengah batang mengering dan mati menjulang, memperlihatkan tongkol hijau kering
Penanganan: Atasi hama penggerek/pengisap; drainase baik; varietas toleran
Rekomendasi Pupuk: Tambah unsur mikro (Zn, Si) untuk ketahanan batang'''
    },
    {
      'judul': 'downy mildew',
      'deskripsi': '''
Bahasa Indonesia: Lembap Bawah Daun
Gejala: Permukaan bawah daun muncul jamur putih seperti embun, daun menguning
Penanganan: Fungisida sistemik, pengendalian kelembapan, rotasi
Rekomendasi Pupuk: Pupuk mikro (Mn, Zn); hindari N berlebih'''
    },
    {
      'judul': 'hispa',
      'deskripsi': '''
Bahasa Indonesia: Hama Hispa (serangga)
Gejala: Daun berparasit ulat dewasa berwarna gelap; daun berlubang/berbintik
Penanganan: Insektisida, predator alami, varietas toleran
Rekomendasi Pupuk: Pupuk seimbang, hindari N tinggi agar daun tidak lembek'''
    },
    {
      'judul': 'normal',
      'deskripsi': '''
Bahasa Indonesia: Tanaman Normal/Tidak Terinfeksi
Gejala: Hijau sehat, tidak ada bercak/pengeringan
Penanganan: Pemupukan seimbang, sanitasi, rotasi tanaman
Rekomendasi Pupuk: NPK seimbang sesuai kebutuhan varietas; tambah mikro bila defisiensi'''
    },
    {
      'judul': 'tungro',
      'deskripsi': '''
Bahasa Indonesia: Penyakit Tungro
Gejala: Daun kuning, melipat, pertumbuhan terhambat; pertumbuhan kerdil
Penanganan: Varietas tahan, kontrol wereng (vektor), sanitasi, benih bersih
Rekomendasi Pupuk: Seimbangkan N-K; pastikan P dan mikro; hindari N berlebih'''
    },
  ];

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    return WillPopScope(
      onWillPop: () async {
        widget.onBackToHome();
        return false; // Jangan pop halaman, cukup ubah tab
      },
      child: Column(
        children: [
          SizedBox(height: 10.h,),
          Center(
            child: Text(
              'Panduan Penyakit Padi',
              style: GoogleFonts.poppins(
                fontSize: 2.5.h,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 2.h,),
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: faqList.length,
                itemBuilder: (context, index) {
                  final item = faqList[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      left: 3.h,
                      right: 3.h,
                      top: index == 0 ? 2.h : 0,
                      bottom: index == faqList.length - 1 ? 6.h : 2.h,
                    ),
                    child: CustomExpansionTile(item: item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomExpansionTile extends StatefulWidget {
  final Map<String, String> item;

  const CustomExpansionTile({super.key, required this.item});

  @override
  State<CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<CustomExpansionTile>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _iconRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _iconRotation = Tween<double>(begin: 0, end: 0.5)
        .animate(_controller); // 0.5 turns = 180 degrees
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildStyledDescription(String deskripsi) {
    final lines = deskripsi.trim().split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final parts = line.split(':');
        if (parts.length > 1) {
          final title = parts[0].trim();
          final content = parts.sublist(1).join(':').trim();
          return RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(
                fontSize: 1.75.h,
                color: Colors.black,
                height: 1.5
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: GoogleFonts.poppins(
                    fontSize: 1.75.h,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                TextSpan(text: content),
              ],
            ),
          );
        } else {
          return Text(
            line,
            style: const TextStyle(color: Colors.black87),
          );
        }
      }).toList(),
    );
  }
  String capitalizeEachWord(String text) {
    return text
        .split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : '')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return Column(
      children: [
        GestureDetector(
          onTap: _handleTap,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF0CA356),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(_isExpanded ? 0 : 10),
                bottomRight: Radius.circular(_isExpanded ? 0 : 10),
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.75.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 2.h,),
                Expanded(
                  child: Text(
                    capitalizeEachWord(item['judul']!),
                    style: GoogleFonts.poppins(
                      fontSize: 2.h,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 2.h,),
                AnimatedBuilder(
                  animation: _iconRotation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _iconRotation.value * 3.1416 * 2,
                      child: child,
                    );
                  },
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 4.h,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded
              ? Container(
            width: 100.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              border: Border.all(
                color: Colors.grey,
                width: 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
            child: _buildStyledDescription(item['deskripsi']!),
          )
              : const SizedBox(),
        ),
      ],
    );
  }
}
