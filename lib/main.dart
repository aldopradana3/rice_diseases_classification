import 'package:sizer/sizer.dart';
import 'package:rice_diseases_classification/views/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // wajib sebelum SystemChrome

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // hanya potret tegak
  ]);

  runApp(
    Sizer(
      builder: (context, orientation, deviceType) {
        return const MyApp();
      },
    ),
  );
}
// Di luar class mana pun
final GlobalKey<MainPageState> mainPageKey = GlobalKey<MainPageState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          scaffoldBackgroundColor: Color(0xFFFAFAFA),
          primarySwatch: Colors.green),
      title: 'Bottom Bar Demo',
      home: MainPage(key: mainPageKey),
    );
  }
}
