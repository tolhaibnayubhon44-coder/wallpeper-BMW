// lib/screens/FullscreenWallpaper.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:walpeper_bmw_4_yangi/wallpaper_service.dart';
import '../WallpaperProvider.dart';

class FullscreenWallpaper extends StatefulWidget {
  final Map<String, dynamic> image;

  const FullscreenWallpaper({super.key, required this.image});

  @override
  State<FullscreenWallpaper> createState() => _FullscreenWallpaperState();
}

class _FullscreenWallpaperState extends State<FullscreenWallpaper> {
  bool _showControls = true;
  bool _isLoading = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  String get _imageUrl =>
      widget.image['full'] ??
      widget.image['original'] ??
      widget.image['portrait'] ??
      widget.image['src']?['original'] ??
      widget.image['src']?['portrait'] ??
      '';

  String get _fileName => 'BMW_Wallpaper_${widget.image['id']}';

  get Share => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fon rasmi
            Hero(
              tag: 'main_${widget.image['id']}',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  _imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.blue[400],
                          value: progress.expectedTotalBytes != null
                              ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.black,
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, color: Colors.red, size: 50),
                            SizedBox(height: 10),
                            Text(
                              'Rasm yuklanmadi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Loading overlay
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            color: Colors.blue[400],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Gradient overlay
            if (_showControls && !_isLoading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                      stops: const [0.0, 0.2, 0.7, 1.0],
                    ),
                  ),
                ),
              ),

            // Top Bar
            if (_showControls && !_isLoading)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCircleButton(
                          icon: Icons.arrow_back,
                          onTap: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.image['description'] ?? 'BMW Wallpaper',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        Consumer<WallpaperProvider>(
                          builder: (context, provider, child) {
                            final isSaved = provider.isSaved(
                              widget.image['id'],
                            );
                            return _buildCircleButton(
                              icon: isSaved
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isSaved ? Colors.red : Colors.white,
                              onTap: () {
                                provider.toggleSave(widget.image);
                                _showSnackBar(
                                  isSaved ? 'O\'chirildi' : 'Saqlandi! ❤️',
                                  icon: isSaved ? Icons.delete : Icons.favorite,
                                  color: isSaved
                                      ? Colors.grey[700]!
                                      : Colors.green,
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Bottom Bar
            if (_showControls && !_isLoading)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Photographer info
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[400],
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Photographer',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      widget.image['photographer'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildActionButton(
                              icon: Icons.info_outline,
                              label: 'Ma\'lumot',
                              onTap: () => _showInfoDialog(),
                            ),
                            _buildActionButton(
                              icon: Icons.download,
                              label: 'Yuklab olish',
                              onTap: () => _downloadWallpaper(),
                            ),
                            _buildActionButton(
                              icon: Icons.wallpaper,
                              label: 'O\'rnatish',
                              onTap: () => _setWallpaper(),
                            ),
                            _buildActionButton(
                              icon: Icons.share,
                              label: 'Ulashish',
                              onTap: () => _shareWallpaper(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[700]!, Colors.blue[500]!],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 11)),
        ],
      ),
    );
  }

  // ✅ YUKLAB OLISH - gallery_saver
  Future<void> _downloadWallpaper() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Yuklab olinmoqda...';
    });

    try {
      final success = await WallpaperService.saveToGallery(
        imageUrl: _imageUrl,
        fileName: _fileName,
        onStatus: (status) {
          if (mounted) {
            setState(() => _statusMessage = status);
          }
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          _showSuccessDialog('Galereyaga saqlandi! 📥');
        } else {
          _showSnackBar(
            'Yuklab olishda xatolik!',
            icon: Icons.error,
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Xatolik: $e', icon: Icons.error, color: Colors.red);
      }
    }
  }

  // ✅ WALLPAPER O'RNATISH - wallx_setter
  Future<void> _setWallpaper() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Wallpaper o\'rnatilmoqda...';
    });

    try {
      final success = await WallpaperService.setWallpaper(
        imageUrl: _imageUrl,
        onStatus: (status) {
          if (mounted) {
            setState(() => _statusMessage = status);
          }
        },
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          _showSuccessDialog('Wallpaper muvaffaqiyatli o\'rnatildi! 🎉');
        } else {
          _showSnackBar(
            'Wallpaper o\'rnatishda xatolik!',
            icon: Icons.error,
            color: Colors.red,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Xatolik: $e', icon: Icons.error, color: Colors.red);
      }
    }
  }

  // ✅ ULASHISH
  Future<void> _shareWallpaper() async {
    try {
      await Share.share(
        'BMW Wallpaper: $_imageUrl\n\nDownload BMW Wallpaper App!',
        subject: 'BMW Wallpaper',
      );
    } catch (e) {
      _showSnackBar(
        'Ulashishda xatolik!',
        icon: Icons.error,
        color: Colors.red,
      );
    }
  }

  // ✅ MA'LUMOT DIALOG
  void _showInfoDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Wallpaper Ma\'lumotlari',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                'Photographer',
                widget.image['photographer'] ?? 'Unknown',
              ),
              _buildInfoRow(
                'Description',
                widget.image['description'] ?? 'No description',
              ),
              _buildInfoRow(
                'Resolution',
                '${widget.image['width'] ?? '?'}x${widget.image['height'] ?? '?'}',
              ),
              _buildInfoRow('ID', '${widget.image['id'] ?? 'Unknown'}'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    String message, {
    required IconData icon,
    required Color color,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ✅ Success dialog - faqat dialogni yopadi
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true, // Dialog tashqarisiga bosib yopish mumkin
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Muvaffaqiyatli!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ],
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                // ✅ Faqat dialogni yopamiz (FullscreenWallpaper sahifasidan chiqmaymiz)
                Navigator.of(dialogContext).pop();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue[600]!, Colors.blue[400]!],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
