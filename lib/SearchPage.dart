import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:walpeper_bmw_4_yangi/FullscreenWallpaper.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  
  List<Map<String, dynamic>> searchResults = [];
  List<String> recentSearches = ['M5', 'M3', 'X6', 'i8', 'M8'];
  List<String> popularSearches = ['BMW M Power', 'BMW Night', 'BMW Racing', 'BMW Classic', 'BMW Sports'];
  
  bool isLoading = false;
  bool hasSearched = false;
  int currentPage = 1;
  String currentQuery = '';
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _animationController.forward();
    
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchFocusNode.requestFocus();
    });
    
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 300 &&
          !isLoading &&
          hasSearched) {
        loadMoreResults();
      }
    });
  }

  Future<void> searchWallpapers(String query) async {
    if (query.trim().isEmpty) return;
    
    setState(() {
      isLoading = true;
      hasSearched = true;
      currentPage = 1;
      currentQuery = query;
      searchResults = [];
    });
    
    // Add to recent searches
    if (!recentSearches.contains(query)) {
      recentSearches.insert(0, query);
      if (recentSearches.length > 10) {
        recentSearches.removeLast();
      }
    }
    
    final results = await _fetchImages('BMW $query car', currentPage);
    
    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  Future<void> loadMoreResults() async {
    if (currentQuery.isEmpty) return;
    
    setState(() {
      isLoading = true;
      currentPage++;
    });
    
    final results = await _fetchImages('BMW $currentQuery car', currentPage);
    
    setState(() {
      searchResults.addAll(results);
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchImages(String query, int page) async {
    List<Map<String, dynamic>> images = [];
    
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(query)}&per_page=30&page=$page&orientation=portrait',
        ),
        headers: {
          'Authorization': 'DBXMj46y3oqXASOxktUYRgpig2vJK1uzWlyI0ehOtCjDYAbiEUB49PQJ'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['photos'] != null) {
          for (var photo in data['photos']) {
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
    } catch (e) {
      print('Error: $e');
    }
    
    return images;
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              // Search Header
              _buildSearchHeader(),
              
              // Content
              Expanded(
                child: hasSearched ? _buildSearchResults() : _buildSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              SizedBox(width: 12),
              
              // Search Field
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey[900]!,
                        Colors.grey[850]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: searchFocusNode.hasFocus 
                          ? Colors.blue[400]! 
                          : Colors.grey[800]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    focusNode: searchFocusNode,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search BMW models...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Container(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.search, color: Colors.blue[400], size: 22),
                      ),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close, color: Colors.grey[500]),
                              onPressed: () {
                                searchController.clear();
                                setState(() {
                                  hasSearched = false;
                                  searchResults = [];
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                    onSubmitted: searchWallpapers,
                    onChanged: (value) => setState(() {}),
                  ),
                ),
              ),
            ],
          ),
          
          // Search button
          if (searchController.text.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => searchWallpapers(searchController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Search "${searchController.text}"',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (recentSearches.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.history, color: Colors.grey[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'Recent Searches',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((search) {
                return GestureDetector(
                  onTap: () {
                    searchController.text = search;
                    searchWallpapers(search);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.history, color: Colors.grey[600], size: 16),
                        SizedBox(width: 8),
                        Text(
                          search,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 30),
          ],
          
          // Popular Searches
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.blue[400], size: 20),
              SizedBox(width: 8),
              Text(
                'Popular Searches',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...popularSearches.map((search) {
            return GestureDetector(
              onTap: () {
                searchController.text = search;
                searchWallpapers(search);
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 8),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.grey[900]!,
                      Colors.grey[850]!,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[800]!),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_fire_department,
                        color: Colors.blue[400],
                        size: 18,
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        search,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey[700],
                      size: 16,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          
          SizedBox(height: 30),
          
          // Quick Tips
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue[900]!.withOpacity(0.3),
                  Colors.blue[800]!.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.amber, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Search Tips',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                _buildTip('🚗', 'Try model names: M5, M3, X6'),
                _buildTip('🎨', 'Add colors: Blue M4, Red M5'),
                _buildTip('🌙', 'Try themes: Night, Racing, Sport'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (isLoading && searchResults.isEmpty) {
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
              'Searching for "$currentQuery"...',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (searchResults.isEmpty) {
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
              child: Icon(
                Icons.search_off,
                size: 60,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'No results for "$currentQuery"',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 18,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try different keywords',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  hasSearched = false;
                  searchResults = [];
                });
                searchController.clear();
              },
              icon: Icon(Icons.arrow_back, color: Colors.blue[400]),
              label: Text(
                'Back to suggestions',
                style: TextStyle(color: Colors.blue[400]),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results count
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                '${searchResults.length}+ results',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    hasSearched = false;
                    searchResults = [];
                  });
                  searchController.clear();
                },
                child: Text(
                  'Clear',
                  style: TextStyle(
                    color: Colors.blue[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Grid
        Expanded(
          child: GridView.builder(
            controller: scrollController,
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.65,
            ),
            itemCount: searchResults.length + (isLoading ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= searchResults.length) {
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

              final image = searchResults[index];
              return _buildWallpaperCard(image, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWallpaperCard(Map<String, dynamic> image, int index) {
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
        tag: 'search_${image['id']}',
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300 + (index * 50)),
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
  }
}