import 'package:flutter/material.dart';

class DaftarArsipKategoriScreen extends StatelessWidget {
  final String categoryName;

  const DaftarArsipKategoriScreen({
    super.key, 
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color bgColor = const Color(0xFFF1F5F9); 
    final Color textDark = const Color(0xFF0F172A);
    final Color textGrey = const Color(0xFF64748B);
    final Color borderGrey = const Color(0xFFE2E8F0);
    final Color dangerRed = const Color(0xFFEF4444);

    final List<Map<String, dynamic>> dummyData = [
      {'title': 'Dokumen_01_final_rev', 'date': '17 Apr 2026', 'size': '2.4 MB'},
      {'title': 'Laporan_Evaluasi_Tahunan', 'date': '10 Apr 2026', 'size': '1.8 MB'},
      {'title': 'Lampiran_Data_Pendukung', 'date': '02 Apr 2026', 'size': '5.1 MB'},
      {'title': 'Draft_Awal_v2', 'date': '28 Mar 2026', 'size': '800 KB'},
      {'title': 'Revisi_Anggaran_Q1', 'date': '15 Mar 2026', 'size': '1.2 MB'},
      {'title': 'Notulen_Rapat_Pleno', 'date': '05 Mar 2026', 'size': '450 KB'},
    ];

    return Scaffold(
      backgroundColor: bgColor,
      
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05), 
                                blurRadius: 5,
                              )
                            ]
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
                        ),
                      ),
                    ),
                    Text(
                      categoryName,
                      style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16), 
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderGrey, width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari di $categoryName...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search_rounded, color: primaryBlue.withValues(alpha: 0.7), size: 22),
                            prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 22),
                            border: InputBorder.none,
                            isCollapsed: true, 
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Dokumen',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${dummyData.length} Ditemukan',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue),
                      ),
                    ),
                  ],
                ),
              ),

              ListView.separated(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: dummyData.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final data = dummyData[index];
                  return _buildArchiveCard(
                    title: data['title'],
                    badgeText: categoryName.toUpperCase(),
                    badgeColor: primaryBlue,
                    date: data['date'],
                    size: data['size'],
                    primaryBlue: primaryBlue,
                    textDark: textDark,
                    textGrey: textGrey,
                    borderGrey: borderGrey,
                    dangerRed: dangerRed,
                  );
                },
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
    required Color primaryBlue,
    required Color textDark,
    required Color textGrey,
    required Color borderGrey,
    required Color dangerRed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03), 
            blurRadius: 15, 
            offset: const Offset(0, 6)
          ),
        ],
        border: Border.all(color: borderGrey.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: dangerRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.picture_as_pdf_rounded, color: dangerRed, size: 28),
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
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: textDark, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: badgeColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 14, color: textGrey),
                          const SizedBox(width: 4),
                          Text(date, style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
                          
                          const SizedBox(width: 16),
                          
                          Icon(Icons.sd_storage_rounded, size: 14, color: textGrey),
                          const SizedBox(width: 4),
                          Text(size, style: TextStyle(fontSize: 12, color: textGrey, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 1, color: borderGrey.withValues(alpha: 0.6)),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit_rounded, 
                  color: textGrey, 
                  bgColor: Colors.grey.shade100, 
                  onTap: () {}
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded, 
                  color: dangerRed, 
                  bgColor: dangerRed.withValues(alpha: 0.1), 
                  onTap: () {}
                ),
                const SizedBox(width: 12),
                _buildActionButton(
                  icon: Icons.file_download_rounded, 
                  color: primaryBlue, 
                  bgColor: primaryBlue.withValues(alpha: 0.1), 
                  onTap: () {}
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon, 
    required Color color, 
    required Color bgColor, 
    required VoidCallback onTap
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }
}