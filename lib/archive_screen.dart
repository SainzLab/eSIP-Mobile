import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/pocketbase_service.dart';
import 'components/unggah_arsip_screen.dart';

class ArchiveController extends GetxController {
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  
  var arsipList = <RecordModel>[].obs;
  var totalArsip = 0.obs;

  var currentUserRole = ''.obs; 
  
  var currentPage = 1.obs;
  var hasMore = true.obs;
  final int perPage = 15; 
  
  final searchController = TextEditingController();
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    final userRecord = PocketBaseService.pb.authStore.record;
    currentUserRole.value = userRecord?.getStringValue('role') ?? '';
    
    debounce(searchQuery, (_) => refreshArsipData(), time: const Duration(milliseconds: 500));
    fetchArsipData();
  }

  Future<void> refreshArsipData() async {
    currentPage.value = 1;
    hasMore.value = true;
    arsipList.clear();
    await fetchArsipData();
  }

  Future<void> fetchArsipData({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isFetchingMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      final pb = PocketBaseService.pb;
      final userRecord = pb.authStore.record; 
      
      final String role = userRecord?.getStringValue('role') ?? '';
      final String bidang = userRecord?.getStringValue('bidang') ?? '';

      String arsipFilter = 'is_deleted = false'; 

      if (role == 'Staff') {
        arsipFilter += ' && bidang = "$bidang"';
      }

      if (searchQuery.value.isNotEmpty) {
        arsipFilter += ' && (judul ~ "${searchQuery.value}" || no_surat ~ "${searchQuery.value}")';
      }

      final resArsip = await pb.collection('arsip').getList(
        page: currentPage.value, 
        perPage: perPage, 
        sort: '-created', 
        filter: arsipFilter,
        expand: 'kategori_id,pengunggah', 
      );

      if (isLoadMore) {
        arsipList.addAll(resArsip.items);
      } else {
        arsipList.value = resArsip.items;
        totalArsip.value = resArsip.totalItems;
      }

      hasMore.value = currentPage.value < resArsip.totalPages;

    } catch (e) {
      debugPrint("Error fetching arsip data: $e");
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  void loadMore() {
    if (hasMore.value && !isFetchingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchArsipData(isLoadMore: true);
    }
  }

  Future<void> previewArsip(RecordModel doc) async {
    final fileName = doc.getStringValue('file_dokumen');
    if (fileName.isEmpty) return;
    
    final encodedFileName = Uri.encodeComponent(fileName);
    final urlString = '${PocketBaseService.baseUrl}/api/files/${doc.collectionId}/${doc.id}/$encodedFileName';
    final Uri url = Uri.parse(urlString);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication); 
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat membuka browser untuk preview.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }

  Future<void> downloadArsip(RecordModel doc) async {
    final fileName = doc.getStringValue('file_dokumen');
    if (fileName.isEmpty) {
      Get.snackbar('Gagal', 'File dokumen tidak ditemukan.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
      return;
    }

    Get.snackbar('Mengunduh...', 'Proses pengunduhan sedang disiapkan.', snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF2563EB), colorText: Colors.white, margin: const EdgeInsets.all(16));
    
    final encodedFileName = Uri.encodeComponent(fileName);
    final urlString = '${PocketBaseService.baseUrl}/api/files/${doc.collectionId}/${doc.id}/$encodedFileName?download=1';
    final Uri url = Uri.parse(urlString);

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication); 
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat mengunduh file.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
    }
  }

  void editArsip(RecordModel doc) {
    Get.to(() => UnggahArsipScreen(existingDoc: doc));
  }

  void deleteArsip(RecordModel doc) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Hapus Dokumen?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Dokumen ini akan dipindahkan ke menu Sampah dan tidak terlihat lagi di daftar Arsip.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); 
                        isLoading.value = true;
                        try {
                          await PocketBaseService.pb
                              .collection('arsip')
                              .update(doc.id, body: {'is_deleted': true});
                              
                          arsipList.removeWhere((item) => item.id == doc.id);
                          totalArsip.value--;
                          
                          Get.snackbar(
                            'Berhasil', 
                            'Arsip berhasil dipindahkan ke Sampah.', 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: const Color(0xFF10B981), 
                            colorText: Colors.white, 
                            margin: const EdgeInsets.all(16)
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Gagal', 
                            'Terjadi kesalahan saat menghapus arsip.', 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: const Color(0xFFEF4444), 
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16)
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Hapus',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  Color _getBadgeColor(String kategori) {
    if (kategori.toLowerCase().contains('perintah')) return Colors.purple;
    if (kategori.toLowerCase().contains('keputusan') || kategori.toLowerCase().contains('sk ')) return const Color(0xFF2563EB);
    if (kategori.toLowerCase().contains('laporan')) return Colors.indigo;
    if (kategori.toLowerCase().contains('acara')) return Colors.orange;
    if (kategori.toLowerCase().contains('rahasia')) return Colors.teal.shade700;
    return Colors.teal; 
  }

  Map<String, dynamic> _getFileIconInfo(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return {'icon': Icons.picture_as_pdf, 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEF2F2)}; 
    if (name.endsWith('.doc') || name.endsWith('.docx')) return {'icon': Icons.description, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)}; 
    if (name.endsWith('.xls') || name.endsWith('.xlsx')) return {'icon': Icons.table_chart, 'color': const Color(0xFF10B981), 'bg': const Color(0xFFECFDF5)}; 
    if (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg')) return {'icon': Icons.image, 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFFFBEB)}; 
    return {'icon': Icons.insert_drive_file, 'color': const Color(0xFF64748B), 'bg': const Color(0xFFF1F5F9)}; 
  }

  void _showDocDetails(BuildContext context, RecordModel doc) {
    final title = doc.getStringValue('judul');
    final noSurat = doc.getStringValue('no_surat');
    final tanggal = doc.getStringValue('tanggal_surat').split(' ').first;
    final bidang = doc.getStringValue('bidang');
    final fileName = doc.getStringValue('file_dokumen'); 
    
    final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
    final pengunggahNama = doc.getStringValue('expand.pengunggah.name');

    final iconInfo = _getFileIconInfo(fileName);

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
                  decoration: BoxDecoration(color: iconInfo['bg'], borderRadius: BorderRadius.circular(12)),
                  child: Icon(iconInfo['icon'], color: iconInfo['color'], size: 32),
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
                        decoration: BoxDecoration(color: const Color(0xFF2563EB).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                        child: Text(kategoriNama.isNotEmpty ? kategoriNama.toUpperCase() : 'ARSIP', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
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
            _buildDetailRow('Nama File Asli', fileName.isNotEmpty ? fileName : '-'), 
          ],
        ),
      ),
      isScrollControlled: true,
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

  @override
  Widget build(BuildContext context) {
    final ArchiveController controller = Get.put(ArchiveController());
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color textDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                controller.loadMore();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: controller.refreshArsipData, 
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(), 
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  Obx(() => SliverPersistentHeader(
                    pinned: true, 
                    delegate: _ArchiveHeaderDelegate(
                      minHeight: 60.0, 
                      maxHeight: controller.currentUserRole.value == 'Kepala Sekolah' ? 60.0 : 130.0,
                      isKepsek: controller.currentUserRole.value == 'Kepala Sekolah',
                    ),
                  )),
                  
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
                            child: Obx(() => Text(
                              '${controller.totalArsip.value} Total',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade400,
                              ),
                            )),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Obx(() {
                    if (controller.isLoading.value) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 50.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    if (controller.arsipList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text(
                              controller.searchQuery.value.isNotEmpty 
                                ? 'Pencarian tidak ditemukan.' 
                                : 'Belum ada dokumen arsip yang ditemukan.', 
                              style: TextStyle(color: Colors.grey.shade600)
                            ),
                          ),
                        ),
                      );
                    }

                    final bool isKepsek = controller.currentUserRole.value == 'Kepala Sekolah';
                   
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.arsipList.length) {
                            return Obx(() => controller.isFetchingMore.value
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 100)); 
                          }

                          final doc = controller.arsipList[index];
                          final title = doc.getStringValue('judul');
                          final fileName = doc.getStringValue('file_dokumen'); 
                          final date = doc.getStringValue('tanggal_surat').split(' ').first;
                          
                          final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
                          final displayKategori = kategoriNama.isNotEmpty ? kategoriNama : 'ARSIP';
                          
                          final badgeColor = _getBadgeColor(displayKategori);
                          final iconInfo = _getFileIconInfo(fileName);
                          final subtitle = displayKategori.isNotEmpty ? displayKategori : "Arsip";

                          return _buildArchiveCard(
                            title: title.isNotEmpty ? title : (fileName.isNotEmpty ? fileName : 'Dokumen Tanpa Judul'),
                            subtitle: subtitle, 
                            badgeColor: badgeColor,
                            date: date,
                            iconData: iconInfo['icon'],
                            iconColor: iconInfo['color'],
                            iconBgColor: iconInfo['bg'],
                            showEditDelete: !isKepsek,
                            onPreviewTap: () => controller.previewArsip(doc), 
                            onDownloadTap: () => controller.downloadArsip(doc),
                            onEditTap: () => controller.editArsip(doc),
                            onDeleteTap: () => controller.deleteArsip(doc),
                            onMenuTap: () => _showDocDetails(context, doc), 
                          );
                        },
                        childCount: controller.arsipList.length + 1, 
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArchiveCard({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required String date,
    required IconData iconData,
    required Color iconColor,
    required Color iconBgColor,
    required bool showEditDelete,
    required VoidCallback onPreviewTap,
    required VoidCallback onDownloadTap,
    required VoidCallback onEditTap,
    required VoidCallback onDeleteTap,
    required VoidCallback onMenuTap,
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
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPreviewTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: iconColor, size: 24),
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
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  subtitle.toUpperCase(), 
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.file_download_outlined, color: Color(0xFF2563EB), size: 20), onPressed: onDownloadTap),
                
                if (showEditDelete) ...[
                  IconButton(icon: const Icon(Icons.edit_outlined, color: Color(0xFF64748B), size: 20), onPressed: onEditTap),
                  IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 20), onPressed: onDeleteTap),
                ],
                
                IconButton(icon: const Icon(Icons.more_vert, color: Color(0xFF1E293B), size: 20), onPressed: onMenuTap),
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
  final bool isKepsek;

  _ArchiveHeaderDelegate({
    required this.minHeight, 
    required this.maxHeight,
    required this.isKepsek,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final Color primaryBlue = const Color(0xFF2563EB);

    final ArchiveController controller = Get.find<ArchiveController>();

    void goToUploadForm() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const UnggahArsipScreen()),
      );
    }

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
                          controller: controller.searchController, 
                          onChanged: (val) => controller.searchQuery.value = val, 
                          decoration: InputDecoration(
                            hintText: 'Cari berdasarkan judul atau No Surat...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      
                      if (!isKepsek) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: goToUploadForm, 
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
                      ]
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
                          controller: controller.searchController, 
                          onChanged: (val) => controller.searchQuery.value = val, 
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
                    
                    if (!isKepsek) ...[
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
                          icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 20),
                          onPressed: goToUploadForm,
                        ),
                      ),
                    ]
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
    return maxHeight != oldDelegate.maxHeight || 
           minHeight != oldDelegate.minHeight ||
           isKepsek != oldDelegate.isKepsek;
  }
}