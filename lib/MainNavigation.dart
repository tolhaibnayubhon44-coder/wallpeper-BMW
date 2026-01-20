// lib/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:walpeper_bmw_4_yangi/WallpaperProvider.dart';
import 'WallpaperPage.dart';
import 'SavedPage.dart';
import 'SearchPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    WallpaperPage(),
    SearchPage(),
    SavedPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.blue[400],
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Bosh sahifa',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Qidiruv',
            ),
            BottomNavigationBarItem(
              icon: Consumer<WallpaperProvider>(
                builder: (context, provider, child) {
                  final count = provider.savedWallpapers.length;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.favorite_outline),
                  );
                },
              ),
              activeIcon: Consumer<WallpaperProvider>(
                builder: (context, provider, child) {
                  final count = provider.savedWallpapers.length;
                  return Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    backgroundColor: Colors.red,
                    child: const Icon(Icons.favorite),
                  );
                },
              ),
              label: 'Saqlangan',
            ),
          ],
        ),
      ),
    );
  }
}