import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WallpaperProvider with ChangeNotifier {
  List<Map<String, dynamic>> _savedWallpapers = [];
  
  List<Map<String, dynamic>> get savedWallpapers => _savedWallpapers;

  WallpaperProvider() {
    loadSavedWallpapers();
  }

  // Saqlangan wallpaperlarni yuklash
  Future<void> loadSavedWallpapers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('saved_wallpapers');
    
    if (savedData != null) {
      final List<dynamic> decoded = json.decode(savedData);
      _savedWallpapers = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      notifyListeners();
    }
  }

  // Wallpaperlarni saqlash
  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_wallpapers', json.encode(_savedWallpapers));
  }

  // Saqlangan yoki yo'qligini tekshirish
  bool isSaved(String id) {
    return _savedWallpapers.any((w) => w['id'] == id);
  }

  // Saqlash
  Future<void> saveWallpaper(Map<String, dynamic> wallpaper) async {
    if (!isSaved(wallpaper['id'])) {
      _savedWallpapers.add(wallpaper);
      await _saveToStorage();
      notifyListeners();
    }
  }

  // O'chirish
  Future<void> removeWallpaper(String id) async {
    _savedWallpapers.removeWhere((w) => w['id'] == id);
    await _saveToStorage();
    notifyListeners();
  }

  // Toggle
  Future<void> toggleSave(Map<String, dynamic> wallpaper) async {
    if (isSaved(wallpaper['id'])) {
      await removeWallpaper(wallpaper['id']);
    } else {
      await saveWallpaper(wallpaper);
    }
  }

  // Hammasini o'chirish
  Future<void> clearAll() async {
    _savedWallpapers.clear();
    await _saveToStorage();
    notifyListeners();
  }
}