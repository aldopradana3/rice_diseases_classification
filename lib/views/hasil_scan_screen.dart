import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'package:image/image.dart' as img;
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:rice_diseases_classification/main.dart';

class HasilScanPage extends StatefulWidget {
  final String? imagePath;
  final int? indexPenyakit;
  final XFile? imagePath2;
  final String uploadGambar;

  const HasilScanPage(
      {super.key,
      this.imagePath,
      this.imagePath2,
      this.indexPenyakit,
      required this.uploadGambar});

  @override
  State<HasilScanPage> createState() => _HasilScanPageState();
}

class _HasilScanPageState extends State<HasilScanPage> {
  late int indexPenyakit;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();
  late String _currentImagePath;
  late XFile _currentXFile;
  double? _confidence; // confidence dari model

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.imagePath!;
    if (widget.uploadGambar == "1") {
      _loadAndRunModel(widget.imagePath!, widget.imagePath2!);
      _currentXFile = widget.imagePath2!;
    } else if (widget.uploadGambar == "0") {
      _isLoading = false;
      indexPenyakit = widget.indexPenyakit!;
      _loadConfidenceFromLocal(widget.imagePath!);
    }
  }

  Future<void> _loadConfidenceFromLocal(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList('scan_data') ?? [];

    for (final entry in existingJson) {
      final data = jsonDecode(entry);
      if (data['path'] == imagePath && data.containsKey('confidence')) {
        setState(() {
          _confidence = (data['confidence'] as num).toDouble();
        });
        break;
      }
    }
  }


  Future<void> _ambilFotoDariGaleri() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      _currentImagePath = pickedFile.path;
      _currentXFile = pickedFile;
      await _loadAndRunModel(_currentImagePath, _currentXFile);
    }
  }

  Future<void> _simpanKeLokal(XFile? pickedFile, int detectedIndex, double confidence) async {
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
    final savedImage = await File(pickedFile.path).copy('${appDir.path}/$fileName');

    final prefs = await SharedPreferences.getInstance();
    final existingJson = prefs.getStringList('scan_data') ?? [];

    final newEntry = {
      'path': savedImage.path,
      'index': detectedIndex,
      'confidence': confidence, // simpan confidence di sini
    };

    existingJson.add(jsonEncode(newEntry));
    await prefs.setStringList('scan_data', existingJson);
  }


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

  final List<String> rekomendasiPupuk = [
    'N dikontrol, pupuk organik untuk memperkuat jaringan',
    'Seimbang N-K, pastikan K cukup untuk memperkuat batang dan malai',
    'Hindari N berlebih; seimbangkan dengan K dan mikro seperti Zn',
    'Tambah K dan Ca; batasi N; tambahkan pupuk mikto (Mg, Zn)',
    'Tambah unsur mikro (Zn, Si) untuk ketahanan batang',
    'Pupuk mikro (Mn, Zn); hindari N berlebih',
    'Pupuk seimbang, hindari N tinggi agar daun tidak lembek',
    'NPK seimbang sesuai kebutuhan varietas; tambah mikro bila defisiensi',
    'Seimbangkan N-K; pastikan P dan mikro; hindari N berlebih',
  ];

  Future<void> _loadAndRunModel(String imagePath, XFile imageXFile) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final interpreter =
          await Interpreter.fromAsset('model/model_vgg19.tflite');
      final labels = await FileUtil.loadLabels('assets/model/labels.txt');

      final inputType = interpreter.getInputTensor(0).type;
      final outputShape = interpreter.getOutputTensor(0).shape;
      final outputType = interpreter.getOutputTensor(0).type;

      final imageProcessor = ImageProcessorBuilder()
          .add(ResizeOp(224, 224, ResizeMethod.BILINEAR))
          .add(NormalizeOp(0, 255))
          .build();

      final imageBytes = await File(imagePath).readAsBytes();
      final image = img.decodeImage(imageBytes)!;

      img.Image rotatedImage = image;
      if (image.width > image.height) {
        rotatedImage = img.copyRotate(image, 90);
      }

      final tensorImage = TensorImage(inputType);
      tensorImage.loadImage(rotatedImage);
      final processedImage = imageProcessor.process(tensorImage);


      final outputTensorBuffer =
          TensorBuffer.createFixedSize(outputShape, outputType);
      interpreter.run(processedImage.buffer, outputTensorBuffer.buffer);

      final rawProb =
          TensorProcessorBuilder().build().process(outputTensorBuffer);
      final probs = rawProb.getDoubleList();

      final Map<String, double> labeledProb = {};
      for (int i = 0; i < labels.length; i++) {
        labeledProb[labels[i]] = probs[i];
      }

      final sorted = labeledProb.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topResult = sorted.first;
      final confidence = topResult.value * 100;

      if (confidence >= 65.0) {
        final detectedIndex = judulPenyakit.indexWhere(
          (judul) => judul.toLowerCase().contains(topResult.key.toLowerCase()),
        );
        if (detectedIndex != -1) {
          setState(() {
            indexPenyakit = detectedIndex;
            _confidence = confidence;
            _isLoading = false;
          });
          await _simpanKeLokal(imageXFile, detectedIndex, confidence);
        }
      } else {
        setState(() {
          indexPenyakit = -1;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        indexPenyakit = -1;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        mainPageKey.currentState?.onItemTapped(0);
        return false; // Jangan pop halaman, cukup ubah tab
      },
      child: Scaffold(
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : indexPenyakit != -1
                  ? Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.h),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            Center(
                              child: Text(
                                widget.uploadGambar == "1"
                                    ? 'Hasil Deteksi'
                                    : 'Riwayat Hasil Deteksi',
                                style: GoogleFonts.poppins(
                                  fontSize: 2.5.h,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            Image.file(
                              File(_currentImagePath),
                              fit: BoxFit.cover,
                              width: 50.w,
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            MyExpandableItem(
                              deskripsi:
                              "${judulPenyakit[indexPenyakit]}\n\nNilai: ${_confidence?.toStringAsFixed(2) ?? '--'}%",
                              judul: "Hasil Deteksi",
                            ),
                            SizedBox(
                              height: 3.h,
                            ),
                            MyExpandableItem(
                              deskripsi: rekomendasiPupuk[indexPenyakit],
                              judul: "Rekomendasi Pupuk",
                            ),
                            SizedBox(
                              height: 8.h,
                            ),
                            if (widget.uploadGambar == "1")
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
                                      borderRadius: BorderRadius.circular(
                                          10), // Sudut border
                                    ),
                                  ),
                                  child: Text(
                                    'Ulangi Deteksi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 2.h,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 5.h,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Text(
                      "Scan gagal dilakukan",
                      style: GoogleFonts.poppins(
                        fontSize: 2.h,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
        ),
      ),
    );
  }
}

class MyExpandableItem extends StatefulWidget {
  final String judul;
  final String deskripsi;

  const MyExpandableItem({
    super.key,
    required this.judul,
    required this.deskripsi,
  });

  @override
  State<MyExpandableItem> createState() => _MyExpandableItemState();
}

class _MyExpandableItemState extends State<MyExpandableItem>
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
        return Text(
          line,
          style: GoogleFonts.poppins(
            fontSize: 1.75.h,
            color: Colors.black,
            height: 1.5,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                SizedBox(width: 2.h),
                Expanded(
                  child: Text(
                    widget.judul,
                    style: GoogleFonts.poppins(
                      fontSize: 2.h,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 2.h),
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
                  padding:
                      EdgeInsets.symmetric(horizontal: 2.h, vertical: 1.5.h),
                  child: _buildStyledDescription(widget.deskripsi),
                )
              : const SizedBox(),
        ),
      ],
    );
  }
}
