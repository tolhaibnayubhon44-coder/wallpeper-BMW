// lib/wallpaper_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wallx_setter/wallx_setter.dart';
import 'package:easy_gallery_saver/easy_gallery_saver.dart';

class WallpaperService {
  // WallxSetter instance
  static final WallxSetter _wallxSetter = WallxSetter();

  // ✅ Ruxsatlarni tekshirish
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      // Android 13+ uchun
      final photosStatus = await Permission.photos.request();
      if (photosStatus.isGranted) {
        return true;
      }

      // Eski Android versiyalari uchun
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        return true;
      }

      // Agar rad etilgan bo'lsa
      if (storageStatus.isPermanentlyDenied || photosStatus.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  // ✅ Rasmni URL dan yuklab olish (bytes)
  static Future<Uint8List?> downloadImageBytes(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
    } catch (e) {
      debugPrint('Download error: $e');
    }
    return null;
  }

  // ✅ Rasmni vaqtinchalik faylga saqlash
  static Future<String?> downloadToTempFile(String url, String fileName) async {
    try {
      final bytes = await downloadImageBytes(url);
      if (bytes == null) return null;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${fileName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return filePath;
    } catch (e) {
      debugPrint('Save to temp file error: $e');
      return null;
    }
  }

  // ✅ GALEREYAGA SAQLASH - easy_gallery_saver
  static Future<bool> saveToGallery({
    required String imageUrl,
    required String fileName,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Ruxsat tekshirilmoqda...');
      
      // Ruxsatni tekshirish
      bool hasPermission = await EasyGallerySaver.checkPermission();
      if (!hasPermission) {
        // Ruxsat so'rash
        hasPermission = await requestPermissions();
        if (!hasPermission) {
          onStatus?.call('Ruxsat berilmadi');
          return false;
        }
      }

      onStatus?.call('Galereyaga saqlanmoqda...');

      // ✅ easy_gallery_saver bilan to'g'ridan-to'g'ri URL dan saqlash
      bool result = await EasyGallerySaver.saveImage(
        imageUrl,
        albumName: 'BMW Wallpapers',
      );

      if (result) {
        onStatus?.call('Saqlandi!');
        debugPrint('✅ Rasm galereyaga saqlandi!');
        return true;
      } else {
        onStatus?.call('Saqlashda xatolik');
        debugPrint('❌ Saqlashda xatolik');
        return false;
      }
    } catch (e) {
      debugPrint('Gallery save error: $e');
      onStatus?.call('Xatolik: $e');
      return false;
    }
  }

  // ✅ WALLPAPER O'RNATISH - wallx_setter
  static Future<bool> setWallpaper({
    required String imageUrl,
    Function(String)? onStatus,
  }) async {
    try {
      onStatus?.call('Rasm yuklanmoqda...');

      // Rasmni vaqtinchalik faylga saqlash
      final filePath = await downloadToTempFile(imageUrl, 'wallpaper');
      if (filePath == null) {
        onStatus?.call('Yuklab olishda xatolik');
        return false;
      }

      onStatus?.call('Wallpaper o\'rnatilmoqda...');

      // ✅ wallx_setter bilan wallpaper o'rnatish
      bool? result = await _wallxSetter.setWallpaper(filePath);

      // Vaqtinchalik faylni o'chirish
      try {
        final tempFile = File(filePath);
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}

      if (result == true) {
        onStatus?.call('O\'rnatildi!');
        return true;
      } else {
        onStatus?.call('Xatolik yuz berdi');
        return false;
      }
    } catch (e) {
      debugPrint('Set wallpaper error: $e');
      onStatus?.call('Xatolik: $e');
      return false;
    }
  }
}