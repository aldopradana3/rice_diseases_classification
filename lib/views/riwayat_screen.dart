import 'dart:convert';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:rice_diseases_classification/main.dart';

class RiwayatPage extends StatefulWidget {
  final VoidCallback onBackToHome;
  final void Function(int index) onItemTapped;
  final void Function(String path, int index) onScanResult;

  const RiwayatPage({Key? key, required this.onBackToHome, required this.onItemTapped, required this.onScanResult}) : super(key: key);

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Map<String, dynamic>> dataList = [];

  final List<String> judulPenyakit = [
    'Bacterial Leaf Streak (Hawar Pelepah Daun Bakteri)',
    'Bacterial Panicle Blight (Hawar Bunga/Sungaian Bakteri)',
    'Blast (Blas)',
    'Brown Spot (Bercak Cokelat)',
    'Dead Heart (Dead Heart)',
    'Downy Mildew (Lembap Bawah Daun)',
    'Hispa (Hama Hispa)',
    'Normal (Tanaman Normal/Tidak Terinfeksi)',
    'Tungro (Penyakit Tungro)',
  ];

  @override
  void initState() {
    super.initState();
    ambilDataScan();
  }

  Future<void> ambilDataScan() async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList('scan_data') ?? [];
    final List<Map<String, dynamic>> loadedData =
        existingJson.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    setState(() {
      dataList = loadedData;
    });
  }

  Future<void> hapusSemuaDataScan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_data');
    await prefs.clear();

    setState(() {
      dataList.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.onBackToHome();
        return false;
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 3.h),
          child: Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Center(
                child: Text(
                  'Riwayat Deteksi',
                  style: GoogleFonts.poppins(
                      fontSize: 2.5.h,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 2.h,
              ),
              if (dataList.isNotEmpty)
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(
                                horizontal: 1.5.h, vertical: 1.h),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            hapusSemuaDataScan();
                          },
                          icon: Icon(
                            Icons.delete_outline_outlined,
                            color: Colors.white,
                            size: 3.h,
                          ),
                          label: Text(
                            "Hapus Riwayat",
                            style: GoogleFonts.poppins(
                                fontSize: 1.65.h,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                                height: 1.4),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 2.h,
                    ),
                  ],
                ),
              dataList.isEmpty
                  ? Container(
                      height: 70.h,
                      child: Center(
                        child: Text('Belum ada data',
                            style: GoogleFonts.poppins(
                                fontSize: 1.75.h,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                                height: 1.4)),
                      ))
                  : Expanded(
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context)
                            .copyWith(overscroll: false),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: dataList.length,
                          itemBuilder: (context, index) {
                            final data = dataList[index];
                            final imagePath = data['path'];
                            final penyakitIndex = data['index'] ?? 0;

                            return GestureDetector(
                              onTap: () async {
                                widget.onScanResult(imagePath, penyakitIndex);
                                mainPageKey.currentState?.onItemTapped(2);
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 1.h),
                                padding: EdgeInsets.all(1.5.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(imagePath),
                                        width: 10.h,
                                        height: 10.h,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            width: 10.h,
                                            height: 10.h,
                                            color: Colors.grey,
                                            child:
                                                const Icon(Icons.broken_image),
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 1.5.h),
                                    Expanded(
                                      child: Text(
                                        judulPenyakit
                                                .asMap()
                                                .containsKey(penyakitIndex)
                                            ? "Hasil Deteksi : ${judulPenyakit[penyakitIndex]}"
                                            : 'Index tidak dikenal',
                                        style: GoogleFonts.poppins(
                                            fontSize: 1.75.h,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                            height: 1.4),
                                      ),
                                    ),
                                    SizedBox(width: 1.5.h),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.grey.shade400,
                                      size: 2.5.h,
                                    ),
                                    SizedBox(width: 1.h),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
              SizedBox(
                height: 5.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
