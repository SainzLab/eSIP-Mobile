import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'archive_screen.dart'; 
import 'category_screen.dart'; 
import 'disposisi_screen.dart';
import 'sampah_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color bgColor = const Color(0xFFF8F9FE);

  final List<Widget> _pages = [
    const DashboardScreen(),
    const ArchiveScreen(),
    const CategoryScreen(),
    const DisposisiScreen(),
    const SampahScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
       
        scrolledUnderElevation: 0, 
        surfaceTintColor: Colors.transparent, 
        
        titleSpacing: 24.0,
        title: Text(
          'eSIP',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryBlue,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.person, color: primaryBlue),
            ),
          ),
        ],
      ),

      body: _pages[_selectedIndex], 

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index; 
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 10,
            unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder_rounded), label: 'Arsip'),
              BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category_rounded), label: 'Kategori'),
              BottomNavigationBarItem(icon: Icon(Icons.move_to_inbox_outlined), activeIcon: Icon(Icons.move_to_inbox_rounded), label: 'Disposisi'),
              BottomNavigationBarItem(icon: Icon(Icons.delete_outline), activeIcon: Icon(Icons.delete_rounded), label: 'Sampah'),
            ],
          ),
        ),
      ),
    );
  }
}