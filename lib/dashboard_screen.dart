import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color textDark = const Color(0xFF1E293B);
    final Color textGrey = const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildStatCard('SURAT MASUK', '1,284', Icons.download_rounded, const Color(0xFFE0E7FF), primaryBlue),
                  _buildStatCard('SURAT KELUAR', '842', Icons.upload_rounded, const Color(0xFFE0E7FF), primaryBlue),
                  _buildStatCard('TOTAL ARSIP', '4,120', Icons.archive_rounded, const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                  _buildStatCard('TOTAL PENGGUNA', '12', Icons.people_alt_rounded, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                ],
              ),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Statistik Surat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                            const SizedBox(height: 4),
                            Text('Januari - Desember 2023', style: TextStyle(fontSize: 12, color: textGrey)),
                          ],
                        ),
                        Text('Detail >', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100), 
                      ),
                      child: Center(
                        child: Text(
                          '[ Area Fl_Chart Stacked Bar ]\n',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: primaryBlue.withValues(alpha: 0.7), fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildLegendItem(primaryBlue, 'Surat Masuk'),
                        const SizedBox(width: 16),
                        _buildLegendItem(const Color(0xFFBFDBFE), 'Surat Keluar'),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Documents', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                  Icon(Icons.filter_list, color: textDark),
                ],
              ),
              const SizedBox(height: 16),
              _buildDocItem(
                title: 'Undangan Rapat Kelulusa...',
                subtitle: 'Arsip Surat Masuk • 12 Okt 2023',
                icon: Icons.picture_as_pdf,
                iconColor: const Color(0xFFDC2626),
                bgColor: const Color(0xFFFEF2F2),
              ),
              _buildDocItem(
                title: 'Laporan Keuangan Q3.docx',
                subtitle: 'Arsip Kepegawaian • 10 Okt 2023',
                icon: Icons.description,
                iconColor: const Color(0xFF2563EB),
                bgColor: const Color(0xFFEFF6FF),
              ),
              _buildDocItem(
                title: 'Dokumentasi LDKS 2023.jpg',
                subtitle: 'Arsip Kesiswaan • 08 Okt 2023',
                icon: Icons.image,
                iconColor: const Color(0xFFD97706),
                bgColor: const Color(0xFFFFFBEB),
              ),
              const SizedBox(height: 80), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconBgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildDocItem({required String title, required String subtitle, required IconData icon, required Color iconColor, required Color bgColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}