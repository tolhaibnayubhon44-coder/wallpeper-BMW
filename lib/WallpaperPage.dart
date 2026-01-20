// lib/screens/WallpaperPage.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:walpeper_bmw_4_yangi/WallpaperProvider.dart';
// import '../providers/wallpaper_provider.dart';
import 'FullscreenWallpaper.dart';

class Rasmlar {
  final String apiKey =
      'DBXMj46y3oqXASOxktUYRgpig2vJK1uzWlyI0ehOtCjDYAbiEUB49PQJ';
  final String apiUrl = 'https://api.pexels.com/v1';

  Future<List<Map<String, dynamic>>> searchBMW(String query, int page) async {
    List<Map<String, dynamic>> images = [];

    try {
      final searchQuery =
          query.toLowerCase().contains('bmw') ? query : 'BMW $query';

      final response = await http.get(
        Uri.parse(
          '$apiUrl/search?query=${Uri.encodeComponent(searchQuery)}&per_page=30&page=$page&orientation=portrait',
        ),
        headers: {'Authorization': apiKey},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['photos'] != null) {
          for (var photo in data['photos']) {
            final alt = (photo['alt'] ?? '').toLowerCase();
            final photographer = (photo['photographer'] ?? '').toLowerCase();

            if (alt.contains('bmw') ||
                alt.contains('car') ||
                alt.contains('vehicle') ||
                photographer.contains('bmw') ||
                searchQuery.toLowerCase().contains('bmw')) {
              images.add({
                'id': photo['id'].toString(),
                'photographer': photo['photographer'],
                'thumbnail': photo['src']['medium'],
                'full': photo['src']['original'],
                'portrait': photo['src']['portrait'],
                'description': photo['alt'] ?? query,
                'width': photo['width'],
                'height': photo['height'],
              });
            }
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    }

    return images;
  }
}

class WallpaperPage extends StatefulWidget {
  @override
  _WallpaperPageState createState() => _WallpaperPageState();
}

class _WallpaperPageState extends State<WallpaperPage> {
  final Rasmlar rasmlar = Rasmlar();
  List<Map<String, dynamic>> images = [];
  bool loading = true;
  int currentPage = 1;
  ScrollController scrollController = ScrollController();
  String selectedCategory = 'm5';

  final List<Map<String, String>> categories = [
    {'id': 'm5', 'name': 'M5', 'icon': '🔥', 'query': 'BMW M5 car'},
    {'id': 'm3', 'name': 'M3', 'icon': '⚡', 'query': 'BMW M3 car'},
    {'id': 'm4', 'name': 'M4', 'icon': '💎', 'query': 'BMW M4 car'},
    {'id': 'x5', 'name': 'X5', 'icon': '🚙', 'query': 'BMW X5 SUV'},
    {'id': 'i8', 'name': 'i8', 'icon': '🏎️', 'query': 'BMW i8 sports car'},
    {'id': 'classic', 'name': 'Classic', 'icon': '🏁', 'query': 'BMW classic car'},
  ];

  @override
  void initState() {
    super.initState();
    loadGallery();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          !loading) {
        loadMoreImages();
      }
    });
  }

  Future<void> loadGallery() async {
    setState(() {
      loading = true;
      currentPage = 1;
    });

    final query =
        categories.firstWhere((c) => c['id'] == selectedCategory)['query']!;
    final newImages = await rasmlar.searchBMW(query, currentPage);

    setState(() {
      images = newImages;
      loading = false;
    });
  }

  Future<void> loadMoreImages() async {
    setState(() {
      loading = true;
      currentPage++;
    });

    final query =
        categories.firstWhere((c) => c['id'] == selectedCategory)['query']!;
    final newImages = await rasmlar.searchBMW(query, currentPage);

    setState(() {
      images.addAll(newImages);
      loading = false;
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 140,
              floating: true,
              pinned: true,
              snap: false,
              backgroundColor: Colors.black,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.blue[900]!.withOpacity(0.3),
                        Colors.black,
                      ],
                    ),
                  ),
                ),
              ),
              title: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/bmw-logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  height: 60,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = selectedCategory == cat['id'];

                      return Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = cat['id']!;
                            });
                            loadGallery();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [
                                        Colors.blue[700]!,
                                        Colors.blue[500]!,
                                      ],
                                    )
                                  : null,
                              color: isSelected ? null : Colors.grey[900],
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.blue[400]!
                                    : Colors.grey[800]!,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(cat['icon']!, style: TextStyle(fontSize: 16)),
                                SizedBox(width: 6),
                                Text(
                                  cat['name']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (images.isEmpty && loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
              ),
              child: CircularProgressIndicator(
                color: Colors.blue[400],
                strokeWidth: 3,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Loading BMW wallpapers...',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.directions_car, size: 60, color: Colors.grey[700]),
            ),
            SizedBox(height: 20),
            Text(
              'No BMW wallpapers found',
              style: TextStyle(color: Colors.grey[500], fontSize: 18),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadGallery,
      color: Colors.blue[400],
      backgroundColor: Colors.grey[900],
      child: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemCount: images.length + (loading ? 2 : 0),
        itemBuilder: (context, index) {
          if (index >= images.length) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: CircularProgressIndicator(color: Colors.blue[400]),
              ),
            );
          }

          final image = images[index];
          return _buildWallpaperCard(image);
        },
      ),
    );
  }

  // ✅ YANGILANGAN - Saqlash tugmasi qo'shildi
  Widget _buildWallpaperCard(Map<String, dynamic> image) {
    return Consumer<WallpaperProvider>(
      builder: (context, provider, child) {
        final isSaved = provider.isSaved(image['id']);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FullscreenWallpaper(image: image),
              ),
            );
          },
          child: Hero(
            tag: 'main_${image['id']}',
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Rasm
                    Image.network(
                      image['portrait'] ?? image['thumbnail'],
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[900],
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue[400],
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[900],
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),

                    // ✅ SAQLASH TUGMASI
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () {
                          provider.toggleSave(image);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    isSaved ? Icons.delete : Icons.favorite,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 10),
                                  Text(isSaved ? 'O\'chirildi' : 'Saqlandi! ❤️'),
                                ],
                              ),
                              backgroundColor:
                                  isSaved ? Colors.grey[700] : Colors.green,
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSaved
                                  ? Colors.red
                                  : Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            isSaved ? Icons.favorite : Icons.favorite_border,
                            color: isSaved ? Colors.red : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // Photographer info
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.9),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.blue[400], size: 14),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                image['photographer'],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}