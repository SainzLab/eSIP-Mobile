import 'package:flutter/material.dart';
import 'components/buat_disposisi_screen.dart';

class DisposisiScreen extends StatelessWidget {
  const DisposisiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color textDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              SliverPersistentHeader(
                pinned: true,
                delegate: _DisposisiHeaderDelegate(
                  minHeight: 60.0,
                  maxHeight: 130.0,
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lembar Disposisi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Terbaru',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.only(bottom: 100.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDisposisiCard(
                      refNumber: 'NTD/11/Kemendikbud/2026',
                      badgeText: 'RAHASIA',
                      badgeColor: const Color(0xFFDC2626), 
                      badgeBgColor: const Color(0xFFFEF2F2),
                      instruction: 'Segera tindak lanjuti laporan tahunan keuangan sebelum audit eksternal.',
                      department: 'HUMAS',
                      status: 'Selesai',
                      statusColor: Colors.green,
                      iconData: Icons.description_outlined,
                    ),
                    _buildDisposisiCard(
                      refNumber: 'ND/02/ARSIP/XII/2025',
                      badgeText: 'SEGERA',
                      badgeColor: const Color(0xFF2563EB),
                      badgeBgColor: const Color(0xFFEFF6FF),
                      instruction: 'Mohon berikan tanggapan terkait draf kurikulum baru.',
                      department: 'KURIKULUM',
                      status: 'Proses',
                      statusColor: Colors.amber.shade600,
                      iconData: Icons.chat_bubble_outline_rounded,
                    ),
                    _buildDisposisiCard(
                      refNumber: 'SURAT/KEP/IV/2026',
                      badgeText: 'BIASA',
                      badgeColor: const Color(0xFF64748B), 
                      badgeBgColor: const Color(0xFFF1F5F9),
                      instruction: 'Arsipkan dokumen sesuai dengan kategori tahun berjalan.',
                      department: 'UMUM',
                      status: 'Selesai',
                      statusColor: Colors.green,
                      iconData: Icons.video_camera_back_outlined, 
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String mainValue,
    required String subValue,
    required Color subValueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB), letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                mainValue,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  subValue,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subValueColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDisposisiCard({
    required String refNumber,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String instruction,
    required String department,
    required String status,
    required Color statusColor,
    required IconData iconData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NO. REFERENSI',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB), letterSpacing: 0.5),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  refNumber,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 16),
                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E8FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: const Color(0xFF9333EA), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Instruksi', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                          const SizedBox(height: 2),
                          Text(
                            instruction,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Icon(Icons.domain_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(department, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.remove_red_eye_outlined, color: Color(0xFF2563EB), size: 18),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 18),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DisposisiHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _DisposisiHeaderDelegate({required this.minHeight, required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final Color primaryBlue = const Color(0xFF2563EB);

    return Container(
      color: const Color(0xFFF8F9FE), 
      alignment: Alignment.center,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1.0 - progress,
              child: IgnorePointer(
                ignoring: progress > 0.5, 
                child: OverflowBox(
                  minHeight: maxHeight,
                  maxHeight: maxHeight,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari nomor surat atau instruksi...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BuatDisposisiScreen()),
                            );
                          },
                          icon: const Icon(Icons.post_add_rounded, size: 20),
                          label: const Text('Buat Disposisi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Opacity(
              opacity: progress,
              child: IgnorePointer(
                ignoring: progress < 0.5, 
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            prefixIconConstraints: const BoxConstraints(minWidth: 30, minHeight: 20),
                            border: InputBorder.none,
                            isCollapsed: true, 
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: primaryBlue,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.post_add_rounded, color: Colors.white, size: 20),
                        onPressed: () {}, 
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_DisposisiHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
  }
}