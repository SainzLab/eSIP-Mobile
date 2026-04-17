import 'package:flutter/material.dart';

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color textDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0, bottom: 100.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  _buildStatCard(
                    title: 'TOTAL ARSIP',
                    value: '25',
                    subtitle: 'Status: Aktif',
                    subColor: primaryBlue,
                    icon: Icons.archive_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: primaryBlue,
                  ),
                  _buildStatCard(
                    title: 'DISPOSISI',
                    value: '9',
                    subtitle: 'Butuh Tindakan',
                    subColor: const Color(0xFF9D174D),
                    icon: Icons.assignment_late_outlined,
                    iconBg: const Color(0xFFFDF2F8),
                    iconColor: const Color(0xFF9D174D),
                  ),
                  _buildStatCard(
                    title: 'KATEGORI',
                    value: '12',
                    subtitle: 'Klasifikasi Aktif',
                    subColor: primaryBlue,
                    icon: Icons.category_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: primaryBlue,
                  ),
                  _buildStatCard(
                    title: 'PENGGUNA',
                    value: '7',
                    subtitle: 'Administrator',
                    subColor: primaryBlue,
                    icon: Icons.people_alt_outlined,
                    iconBg: const Color(0xFFEFF6FF),
                    iconColor: primaryBlue,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildChartContainer(
                title: 'Rasio Penyelesaian Disposisi',
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: 1.0, 
                            strokeWidth: 16,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('100.0%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                            Text('SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(const Color(0xFF22C55E), 'Selesai (9)'),
                        const SizedBox(width: 16),
                        _buildLegendItem(Colors.grey.shade200, 'Proses (0)'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildChartContainer(
                title: 'Sebaran Arsip per Bidang',
                actionWidget: const Text('Total: 25', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildHorizontalBar('Kepegawaian', '8', 0.6, primaryBlue),
                    _buildHorizontalBar('Humas', '6', 0.45, primaryBlue.withValues(alpha: 0.6)),
                    _buildHorizontalBar('Kurikulum', '3', 0.25, primaryBlue.withValues(alpha: 0.4)),
                    _buildHorizontalBar('Kesiswaan', '8', 0.6, primaryBlue),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildChartContainer(
                title: 'Rekapitulasi Tren Arsip',
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildVerticalBar('JAN', 30, primaryBlue.withValues(alpha: 0.3)),
                        _buildVerticalBar('FEB', 40, primaryBlue.withValues(alpha: 0.4)),
                        _buildVerticalBar('MAR', 65, primaryBlue.withValues(alpha: 0.6)),
                        _buildVerticalBar('APR', 90, primaryBlue),
                        _buildVerticalBar('MEI', 75, primaryBlue.withValues(alpha: 0.8)),
                        _buildVerticalBar('JUN', 100, primaryBlue.withValues(alpha: 0.5)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Insight', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                          Text('+12% Kenaikan dari kuartal 1', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required String subtitle, required Color subColor, required IconData icon, required Color iconBg, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: subColor, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildChartContainer({required String title, required Widget child, Widget? actionWidget}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
              if (actionWidget != null) actionWidget,
            ],
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildHorizontalBar(String label, String value, double widthFactor, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
              Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBar(String label, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }
}