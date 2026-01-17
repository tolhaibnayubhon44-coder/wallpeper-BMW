import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:walpeper_bmw_4_yangi/SplashScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status bar ni shaffof qilish
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMW Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(), // ✅ SplashScreen birinchi ochiladi
    );
  }
}