import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'WallpaperPage.dart';  // ✅ To'g'ri import

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Status bar va navigation bar ranglarini o'rnatish
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMW Wallpapers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: WallpaperPage(),  // ✅ To'g'ri chaqiruv
    );
  }
}