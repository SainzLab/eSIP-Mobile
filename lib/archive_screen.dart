import 'package:flutter/material.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

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
                delegate: _ArchiveHeaderDelegate(
                  minHeight: 60.0, 
                  maxHeight: 130.0, 
                ),
              ),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Manajemen Arsip',
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
                          '12 Total',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  _buildArchiveCard(
                    title: 'sp_rektorat_2023_final_rev...',
                    badgeText: 'SURAT PERINTAH',
                    badgeColor: Colors.purple,
                    date: '12 Oct 2023',
                    size: '2.4 MB',
                  ),
                  _buildArchiveCard(
                    title: 'keputusan_dekan_f_01',
                    badgeText: 'SK DEKAN',
                    badgeColor: const Color(0xFF2563EB),
                    date: '05 Oct 2023',
                    size: '1.8 MB',
                  ),
                  _buildArchiveCard(
                    title: 'laporan_keuangan_q3',
                    badgeText: 'LAPORAN',
                    badgeColor: Colors.indigo,
                    date: '28 Sep 2023',
                    size: '5.1 MB',
                  ),
                  _buildArchiveCard(
                    title: 'berita_acara_serah_terima',
                    badgeText: 'BERITA ACARA',
                    badgeColor: Colors.orange,
                    date: '15 Sep 2023',
                    size: '1.2 MB',
                  ),
                  _buildArchiveCard(
                    title: 'undangan_rapat_tahunan',
                    badgeText: 'UNDANGAN',
                    badgeColor: Colors.teal,
                    date: '02 Sep 2023',
                    size: '800 KB',
                  ),
                  const SizedBox(height: 100),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required String date,
    required String size,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(date, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          const SizedBox(width: 16),
                          Icon(Icons.layers_outlined, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(size, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                        ],
                      ),
                    ],
                  ),
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
                IconButton(icon: const Icon(Icons.file_download_outlined, color: Color(0xFF2563EB), size: 20), onPressed: () {}),
                IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 20), onPressed: () {}),
                IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20), onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchiveHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _ArchiveHeaderDelegate({required this.minHeight, required this.maxHeight});

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
                            hintText: 'Cari arsip dokumen...',
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
                          onPressed: () {},
                          icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                          label: const Text('Unggah Arsip', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade400,
                              size: 20,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 30,
                              minHeight: 20,
                            ),
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
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.cloud_upload_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_ArchiveHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
  }
}