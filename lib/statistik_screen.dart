import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pocketbase/pocketbase.dart';
import 'models/pocketbase_service.dart';

class StatistikController extends GetxController {
  var isLoading = true.obs;

  var totalArsip = 0.obs;
  var totalKategori = 0.obs;
  var totalPengguna = 0.obs;
  
  var totalDisposisi = 0.obs;
  var disposisiSelesai = 0.obs;
  var disposisiProses = 0.obs;

  var arsipPerBidang = <String, int>{}.obs;
  var arsipPerBulan = List.filled(12, 0).obs;

  @override
  void onInit() {
    super.onInit();
    fetchStatistik();
  }

  Future<void> fetchStatistik() async {
    isLoading.value = true;
    try {
      final pb = PocketBaseService.pb;
      final userRecord = pb.authStore.record; 
      
      final String role = userRecord?.getStringValue('role') ?? '';
      final String bidang = userRecord?.getStringValue('bidang') ?? '';
      final String userId = userRecord?.id ?? '';

      String arsipFilter = 'is_deleted = false'; 
      String userFilter = ''; 
      String disposisiFilter = '';

      if (role == 'Staff') {
        arsipFilter += ' && bidang = "$bidang"';
        userFilter = 'bidang = "$bidang"';
        disposisiFilter = 'penerima = "$userId"'; 
      }

      final resArsip = await pb.collection('arsip').getList(page: 1, perPage: 1, filter: arsipFilter);
      final resKategori = await pb.collection('kategori').getList(page: 1, perPage: 1);
      final resUser = await pb.collection('users').getList(page: 1, perPage: 1, filter: userFilter);

      totalArsip.value = resArsip.totalItems;
      totalKategori.value = resKategori.totalItems;
      totalPengguna.value = resUser.totalItems;

      try {
        final resDispSelesai = await pb.collection('disposisi').getList(
          page: 1, perPage: 1, filter: disposisiFilter.isNotEmpty ? '$disposisiFilter && status = "Selesai"' : 'status = "Selesai"'
        );
        final resDispProses = await pb.collection('disposisi').getList(
          page: 1, perPage: 1, filter: disposisiFilter.isNotEmpty ? '$disposisiFilter && status != "Selesai"' : 'status != "Selesai"'
        );
        
        disposisiSelesai.value = resDispSelesai.totalItems;
        disposisiProses.value = resDispProses.totalItems;
        totalDisposisi.value = disposisiSelesai.value + disposisiProses.value;
      } catch (e) {
        debugPrint('Tabel disposisi mungkin belum siap: $e');
      }

      final currentYear = DateTime.now().year;
      final startOfYear = '$currentYear-01-01 00:00:00.000Z';
      final endOfYear = '$currentYear-12-31 23:59:59.000Z';

      final fullArsip = await pb.collection('arsip').getFullList(
        filter: '$arsipFilter && tanggal_surat >= "$startOfYear" && tanggal_surat <= "$endOfYear"',
      );

      Map<String, int> tempBidang = {};
      List<int> tempBulan = List.filled(12, 0);

      for (var doc in fullArsip) {
        final docBidang = doc.getStringValue('bidang');
        if (docBidang.isNotEmpty) {
          tempBidang[docBidang] = (tempBidang[docBidang] ?? 0) + 1;
        } else {
          tempBidang['Umum'] = (tempBidang['Umum'] ?? 0) + 1;
        }

        final dateStr = doc.getStringValue('tanggal_surat');
        if (dateStr.isNotEmpty) {
          final date = DateTime.tryParse(dateStr);
          if (date != null) {
            tempBulan[date.month - 1] += 1;
          }
        }
      }

      arsipPerBidang.value = tempBidang;
      arsipPerBulan.value = tempBulan;

    } catch (e) {
      debugPrint("Error fetching statistik: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

class StatistikScreen extends StatelessWidget {
  const StatistikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final StatistikController controller = Get.put(StatistikController());

    final Color bgColor = const Color(0xFFF8F9FE);
    final Color primaryBlue = const Color(0xFF2563EB);
    final Color textDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchStatistik,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0, bottom: 100.0),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
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
                        value: controller.totalArsip.value.toString(),
                        subtitle: 'Status: Aktif',
                        subColor: primaryBlue,
                        icon: Icons.archive_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: primaryBlue,
                      ),
                      _buildStatCard(
                        title: 'DISPOSISI',
                        value: controller.totalDisposisi.value.toString(),
                        subtitle: '${controller.disposisiProses.value} Butuh Tindakan',
                        subColor: const Color(0xFF9D174D),
                        icon: Icons.assignment_late_outlined,
                        iconBg: const Color(0xFFFDF2F8),
                        iconColor: const Color(0xFF9D174D),
                      ),
                      _buildStatCard(
                        title: 'KATEGORI',
                        value: controller.totalKategori.value.toString(),
                        subtitle: 'Klasifikasi Aktif',
                        subColor: primaryBlue,
                        icon: Icons.category_outlined,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: primaryBlue,
                      ),
                      _buildStatCard(
                        title: 'PENGGUNA',
                        value: controller.totalPengguna.value.toString(),
                        subtitle: 'Terdaftar',
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
                    child: Builder(
                      builder: (context) {
                        final total = controller.totalDisposisi.value;
                        final selesai = controller.disposisiSelesai.value;
                        final double progress = total > 0 ? (selesai / total) : 0.0;
                        final String persentase = total > 0 ? '${(progress * 100).toStringAsFixed(1)}%' : '0%';

                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 140,
                                  height: 140,
                                  child: CircularProgressIndicator(
                                    value: progress, 
                                    strokeWidth: 16,
                                    backgroundColor: Colors.grey.shade100,
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF22C55E)),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(persentase, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF22C55E))),
                                    Text('SELESAI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLegendItem(const Color(0xFF22C55E), 'Selesai ($selesai)'),
                                const SizedBox(width: 16),
                                _buildLegendItem(Colors.grey.shade200, 'Proses (${controller.disposisiProses.value})'),
                              ],
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildChartContainer(
                    title: 'Arsip per Bidang',
                    actionWidget: Text('Total: ${controller.totalArsip.value}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                    child: Builder(
                      builder: (context) {
                        if (controller.arsipPerBidang.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(child: Text("Belum ada data arsip.")),
                          );
                        }

                        final int maxCount = controller.arsipPerBidang.values.reduce((a, b) => a > b ? a : b);

                        return Column(
                          children: [
                            const SizedBox(height: 16),
                            ...controller.arsipPerBidang.entries.map((entry) {
                              final double widthFactor = maxCount > 0 ? (entry.value / maxCount) : 0.0;
                              final Color barColor = primaryBlue.withValues(alpha: widthFactor < 0.3 ? 0.3 : (widthFactor < 0.7 ? 0.6 : 1.0));
                              
                              return _buildHorizontalBar(entry.key, entry.value.toString(), widthFactor, barColor);
                            }),
                          ],
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildChartContainer(
                    title: 'Rekapitulasi Arsip',
                    child: Builder(
                      builder: (context) {
                        final dataBulan = controller.arsipPerBulan.sublist(0, 6); 
                        final int maxBulan = dataBulan.reduce((a, b) => a > b ? a : b);
                        final double scale = maxBulan > 0 ? 100.0 / maxBulan : 1.0; 

                        return Column(
                          children: [
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildVerticalBar('JAN', (dataBulan[0] * scale), primaryBlue.withValues(alpha: dataBulan[0] == maxBulan ? 1.0 : 0.3)),
                                _buildVerticalBar('FEB', (dataBulan[1] * scale), primaryBlue.withValues(alpha: dataBulan[1] == maxBulan ? 1.0 : 0.4)),
                                _buildVerticalBar('MAR', (dataBulan[2] * scale), primaryBlue.withValues(alpha: dataBulan[2] == maxBulan ? 1.0 : 0.6)),
                                _buildVerticalBar('APR', (dataBulan[3] * scale), primaryBlue.withValues(alpha: dataBulan[3] == maxBulan ? 1.0 : 0.8)),
                                _buildVerticalBar('MEI', (dataBulan[4] * scale), primaryBlue.withValues(alpha: dataBulan[4] == maxBulan ? 1.0 : 0.5)),
                                _buildVerticalBar('JUN', (dataBulan[5] * scale), primaryBlue.withValues(alpha: dataBulan[5] == maxBulan ? 1.0 : 0.7)),
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
                                  Text('Tahun ${DateTime.now().year}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  Text('Data 6 Bulan Pertama', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryBlue)),
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                ],
              );
            }),
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
              Expanded(
                child: Row(
                  children: [
                    Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 8),
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
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
    final double safeHeight = height < 5 ? 5 : height; 
    
    return Column(
      children: [
        Container(
          width: 12,
          height: safeHeight,
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