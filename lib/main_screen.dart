import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'components/scanner_screen.dart';
import 'dashboard_screen.dart';
import 'archive_screen.dart'; 
import 'category_screen.dart'; 
import 'disposisi_screen.dart';
import 'sampah_screen.dart';
import 'statistik_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color bgColor = const Color(0xFFF8F9FE);
  final Color textDark = const Color(0xFF1E293B);

  // ------------------------------------------------------------
  final String currentRole = 'staff'; // kepsek atau staff
  final String userName = 'arsiparis';
  final String userEmail = 'arsiparis@dev.com';
  final String userRoleDisplay = 'PETUGAS ARSIP';
  final String userDept = 'Kepegawaian';
  // ------------------------------------------------------------

  List<Widget> _getPages() {
    return [
      const DashboardScreen(),
      const ArchiveScreen(),
      const CategoryScreen(),
      const DisposisiScreen(),
      currentRole == 'kepsek' ? const StatistikScreen() : const SampahScreen(),
    ];
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 24, left: 24, right: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue.shade100,
                    child: Icon(Icons.person, color: primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 16),

              const Text(
                'PERAN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF), 
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userRoleDisplay,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'BIDANG / BAGIAN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  userDept,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textDark),
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.grey.shade200, thickness: 1),
              const SizedBox(height: 8),

              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Keluar Sistem',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85, 
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF2563EB).withValues(alpha: 0.1),
                            child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF2563EB)),
                          ),
                          const SizedBox(width: 12),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
                            ],
                          )
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildChatBubble(
                        text: 'Halo! Saya asisten AI eSIP. Ada dokumen atau informasi arsip yang sedang Anda cari?', 
                        isBot: true
                      ),
                      const SizedBox(height: 16),
                      _buildChatBubble(
                        text: 'Tolong carikan surat keputusan terbaru dari kepala sekolah.', 
                        isBot: false
                      ),
                      const SizedBox(height: 16),
                      _buildChatBubble(
                        text: 'Baik, saya menemukan 3 Surat Keputusan terbaru dari bulan ini. Apakah Anda ingin melihat daftarnya atau langsung mengunduh yang paling baru?', 
                        isBot: true
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F5FA),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const TextField(
                            decoration: InputDecoration(
                              hintText: 'Tanya sesuatu...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF2563EB),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 18),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatBubble({required String text, required bool isBot}) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 250), 
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isBot ? const Color(0xFFF8F9FE) : const Color(0xFF2563EB),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isBot ? 0 : 16),
            bottomRight: Radius.circular(isBot ? 16 : 0),
          ),
          border: isBot ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isBot ? const Color(0xFF1E293B) : Colors.white,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = _getPages(); 

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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryBlue, letterSpacing: 1.0),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => _showProfileMenu(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, color: primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      body: pages[_selectedIndex], 

      floatingActionButton: currentRole == 'kepsek' 
          ? null 
          : SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close, 
              spacing: 16, 
              spaceBetweenChildren: 16, 
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              activeBackgroundColor: const Color(0xFFEF4444), 
              activeForegroundColor: Colors.white,
              elevation: 6.0, 
              animationCurve: Curves.easeOutBack, 
              animationDuration: const Duration(milliseconds: 300),
              overlayColor: Colors.black, 
              overlayOpacity: 0.4, 
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.document_scanner_outlined, color: Colors.white, size: 26),
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 4.0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ScannerScreen()),
                    );
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 26),
                  backgroundColor: const Color(0xFF2563EB),
                  elevation: 4.0,
                  onTap: () {
                    _showChatbot(context);
                  },
                ),
              ],
            ),
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -5)
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
            child: GNav(
              rippleColor: Colors.grey.shade200, 
              hoverColor: Colors.grey.shade100, 
              gap: 6, 
              activeColor: primaryBlue, 
              iconSize: 22, 
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), 
              duration: const Duration(milliseconds: 400), 
              tabBackgroundColor: Colors.blue.shade50, 
              color: Colors.grey.shade500, 
              tabs: [
                const IGNavButton(icon: LineIcons.home, text: 'Home'),
                const IGNavButton(icon: LineIcons.archive, text: 'Arsip'),
                const IGNavButton(icon: LineIcons.folderOpen, text: 'Kategori'),
                const IGNavButton(icon: LineIcons.inbox, text: 'Disposisi'),
                if (currentRole == 'kepsek')
                  const IGNavButton(icon: LineIcons.barChart, text: 'Stats')
                else
                  const IGNavButton(icon: LineIcons.trash, text: 'Sampah'),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class IGNavButton extends GButton {
  const IGNavButton({
    super.key,
    required super.icon,
    required super.text,
  }) : super(
         textStyle: const TextStyle(
           fontSize: 12, 
           fontWeight: FontWeight.bold, 
           color: Color(0xFF2563EB)
         ),
       );
}