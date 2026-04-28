import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'models/pocketbase_service.dart';
import 'package:pocketbase/pocketbase.dart';
import 'main_screen.dart';

class DashboardController extends GetxController {
  var isLoading = true.obs;
  var totalSuratMasuk = 0.obs;
  var totalSuratKeluar = 0.obs;
  var totalArsip = 0.obs;
  var totalPengguna = 0.obs;

  var recentDocs = <RecordModel>[].obs;

  var monthlySuratMasuk = List.filled(12, 0).obs;
  var monthlySuratKeluar = List.filled(12, 0).obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    try {
      final pb = PocketBaseService.pb;
      final userRecord = pb.authStore.record; 
      
      final String role = userRecord?.getStringValue('role') ?? '';
      final String bidang = userRecord?.getStringValue('bidang') ?? '';

      String arsipFilter = 'is_deleted = false'; 
      String userFilter = ''; 

      if (role == 'Staff') {
        arsipFilter += ' && bidang = "$bidang"';
        userFilter = 'bidang = "$bidang"'; 
      }

      final resTotalArsip = await pb.collection('arsip').getList(page: 1, perPage: 1, filter: arsipFilter);
      final resTotalPengguna = await pb.collection('users').getList(page: 1, perPage: 1, filter: userFilter);
      final resSuratMasuk = await pb.collection('arsip').getList(page: 1, perPage: 1, filter: '$arsipFilter && kategori_id.nama ?~ "Surat Masuk"');
      final resSuratKeluar = await pb.collection('arsip').getList(page: 1, perPage: 1, filter: '$arsipFilter && kategori_id.nama ?~ "Surat Keluar"');

      final resRecent = await pb.collection('arsip').getList(
        page: 1, 
        perPage: 5,
        sort: '-created', 
        filter: arsipFilter,
        expand: 'kategori_id,pengunggah',
      );

      final currentYear = DateTime.now().year;
      final startOfYear = '$currentYear-01-01 00:00:00.000Z';
      final endOfYear = '$currentYear-12-31 23:59:59.000Z';
      
      final resChart = await pb.collection('arsip').getFullList(
        filter: '$arsipFilter && tanggal_surat >= "$startOfYear" && tanggal_surat <= "$endOfYear"',
        expand: 'kategori_id',
      );

      List<int> tempMasuk = List.filled(12, 0);
      List<int> tempKeluar = List.filled(12, 0);

      for (var doc in resChart) {
        final dateStr = doc.getStringValue('tanggal_surat');
        if (dateStr.isNotEmpty) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            final monthIndex = date.month - 1; 
            final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
            
            if (kategoriNama.contains('Surat Masuk')) {
              tempMasuk[monthIndex]++;
            } else if (kategoriNama.contains('Surat Keluar')) {
              tempKeluar[monthIndex]++;
            }
          }
        }
      }

      totalArsip.value = resTotalArsip.totalItems;
      totalPengguna.value = resTotalPengguna.totalItems;
      totalSuratMasuk.value = resSuratMasuk.totalItems;
      totalSuratKeluar.value = resSuratKeluar.totalItems;
      recentDocs.value = resRecent.items;
      
      monthlySuratMasuk.value = tempMasuk;
      monthlySuratKeluar.value = tempKeluar;

    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());

    final Color bgColor = const Color(0xFFF8F9FE);
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color lightBlue = const Color(0xFFBFDBFE);
    final Color textDark = const Color(0xFF1E293B);
    final Color textGrey = const Color(0xFF64748B);

    final currentYear = DateTime.now().year;

    void showDocDetails(RecordModel doc) {
      final title = doc.getStringValue('judul');
      final noSurat = doc.getStringValue('no_surat');
      final tanggal = doc.getStringValue('tanggal_surat').split(' ').first;
      final bidang = doc.getStringValue('bidang');
      
      final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
      final pengunggahNama = doc.getStringValue('expand.pengunggah.name');

      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.only(top: 12, bottom: 32, left: 24, right: 24),
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
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.picture_as_pdf, color: Color(0xFFDC2626), size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.isNotEmpty ? title : 'Dokumen Tanpa Judul', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(kategoriNama.isNotEmpty ? kategoriNama : 'Arsip', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryBlue)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              _buildDetailRow('Nomor Surat', noSurat.isNotEmpty ? noSurat : '-'),
              _buildDetailRow('Tanggal Surat', tanggal.isNotEmpty ? tanggal : '-'),
              _buildDetailRow('Bidang / Bagian', bidang.isNotEmpty ? bidang : '-'),
              _buildDetailRow('Diupload Oleh', pengunggahNama.isNotEmpty ? pengunggahNama : 'Sistem'),
            ],
          ),
        ),
        isScrollControlled: true,
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchDashboardData, 
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                  }
                  
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildStatCard('SURAT MASUK', controller.totalSuratMasuk.value.toString(), Icons.download_rounded, const Color(0xFFE0E7FF), primaryBlue),
                      _buildStatCard('SURAT KELUAR', controller.totalSuratKeluar.value.toString(), Icons.upload_rounded, const Color(0xFFE0E7FF), primaryBlue),
                      _buildStatCard('TOTAL ARSIP', controller.totalArsip.value.toString(), Icons.archive_rounded, const Color(0xFFF3E8FF), const Color(0xFF9333EA)),
                      _buildStatCard('TOTAL PENGGUNA', controller.totalPengguna.value.toString(), Icons.people_alt_rounded, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                    ],
                  );
                }),
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
                              Text('Januari - Desember $currentYear', style: TextStyle(fontSize: 12, color: textGrey)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      
                      SizedBox(
                        height: 150,
                        width: double.infinity,
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final hasData = controller.monthlySuratMasuk.any((val) => val > 0) || 
                                          controller.monthlySuratKeluar.any((val) => val > 0);

                          if (!hasData) {
                            return Center(child: Text('Belum ada data di tahun $currentYear', style: TextStyle(color: textGrey, fontSize: 12)));
                          }

                          return BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barTouchData: BarTouchData(enabled: false), 
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      const style = TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 10);
                                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Text(months[value.toInt()], style: style),
                                      );
                                    },
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(12, (index) {
                                final masuk = controller.monthlySuratMasuk[index].toDouble();
                                final keluar = controller.monthlySuratKeluar[index].toDouble();
                                final total = masuk + keluar;

                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: total == 0 ? 0.1 : total, 
                                      width: 14,
                                      borderRadius: BorderRadius.circular(4),
                                      color: Colors.transparent, 
                                      rodStackItems: [
                                        if (masuk > 0) BarChartRodStackItem(0, masuk, primaryBlue),
                                        if (keluar > 0) BarChartRodStackItem(masuk, total, lightBlue),
                                      ],
                                    ),
                                  ],
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildLegendItem(primaryBlue, 'Surat Masuk'),
                          const SizedBox(width: 16),
                          _buildLegendItem(lightBlue, 'Surat Keluar'),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Dokumen Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark)),
                    
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          if (Get.isRegistered<MainController>()) {
                            Get.find<MainController>().changeTab(1);
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Row(
                            children: [
                              Text(
                                'Lihat Semua',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 12,
                                color: primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 16),
                
                Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.recentDocs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('Belum ada arsip di bidang Anda.', style: TextStyle(color: textGrey)),
                      ),
                    );
                  }

                  return Column(
                    children: controller.recentDocs.map((doc) {
                      final title = doc.getStringValue('judul');
                      final bidang = doc.getStringValue('bidang');
                      final date = doc.getStringValue('tanggal_surat').split(' ').first; 
                      
                      final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
                      final displayKategori = kategoriNama.isNotEmpty ? kategoriNama : 'Arsip';

                      final fileName = doc.getStringValue('file_dokumen').toLowerCase();
                      
                      IconData fileIcon = Icons.insert_drive_file;
                      Color iconColor = const Color(0xFF64748B); 
                      Color bgColor = const Color(0xFFF1F5F9);

                      if (fileName.endsWith('.pdf')) {
                        fileIcon = Icons.picture_as_pdf;
                        iconColor = const Color(0xFFDC2626);
                        bgColor = const Color(0xFFFEF2F2);
                      } else if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) {
                        fileIcon = Icons.description;
                        iconColor = const Color(0xFF2563EB);
                        bgColor = const Color(0xFFEFF6FF);
                      } else if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx') || fileName.endsWith('.csv')) {
                        fileIcon = Icons.table_chart;
                        iconColor = const Color(0xFF10B981);
                        bgColor = const Color(0xFFECFDF5);
                      } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg') || fileName.endsWith('.png')) {
                        fileIcon = Icons.image;
                        iconColor = const Color(0xFFD97706);
                        bgColor = const Color(0xFFFFFBEB);
                      }
                      
                      return _buildDocItem(
                        title: title.isNotEmpty ? title : 'Dokumen Tanpa Judul',
                        subtitle: '$displayKategori $bidang • $date',
                        icon: fileIcon, 
                        iconColor: iconColor,
                        bgColor: bgColor,
                        onMoreTap: () => showDocDetails(doc),
                      );
                    }).toList(),
                  );
                }),
                
                const SizedBox(height: 80), 
              ],
            ),
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

  Widget _buildDocItem({required String title, required String subtitle, required IconData icon, required Color iconColor, required Color bgColor, required VoidCallback onMoreTap}) {
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
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          const Text(':', style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}