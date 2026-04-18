import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'models/pocketbase_service.dart';

class SampahController extends GetxController {
  var isLoading = true.obs;
  var isFetchingMore = false.obs;
  
  var sampahList = <RecordModel>[].obs;
  var totalSampah = 0.obs;
  
  var currentPage = 1.obs;
  var hasMore = true.obs;
  final int perPage = 10;
  
  final searchController = TextEditingController();
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => refreshSampahData(), time: const Duration(milliseconds: 500));
    fetchSampahData();
  }

  Future<void> refreshSampahData() async {
    currentPage.value = 1;
    hasMore.value = true;
    sampahList.clear();
    await fetchSampahData();
  }

  Future<void> fetchSampahData({bool isLoadMore = false}) async {
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

      String sampahFilter = 'is_deleted = true'; 

      if (role == 'Staff') {
        sampahFilter += ' && bidang = "$bidang"';
      }

      if (searchQuery.value.isNotEmpty) {
        sampahFilter += ' && (judul ~ "${searchQuery.value}" || no_surat ~ "${searchQuery.value}")';
      }

      final resSampah = await pb.collection('arsip').getList(
        page: currentPage.value, 
        perPage: perPage, 
        sort: '-updated',
        filter: sampahFilter,
        expand: 'kategori_id,pengunggah', 
      );

      if (isLoadMore) {
        sampahList.addAll(resSampah.items);
      } else {
        sampahList.value = resSampah.items;
        totalSampah.value = resSampah.totalItems;
      }

      hasMore.value = currentPage.value < resSampah.totalPages;

    } catch (e) {
      debugPrint("Error fetching sampah data: $e");
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  void loadMore() {
    if (hasMore.value && !isFetchingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchSampahData(isLoadMore: true);
    }
  }

  void restoreArsip(RecordModel doc) {
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
                  color: Color(0xFFEFF6FF), 
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restore_page_outlined,
                  color: Color(0xFF2563EB),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Pulihkan Dokumen?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Dokumen ini akan dikembalikan ke daftar Manajemen Arsip utama dan dapat diakses kembali.',
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
                              .update(doc.id, body: {'is_deleted': false});
                          
                          sampahList.removeWhere((item) => item.id == doc.id);
                          totalSampah.value--;
                          
                          Get.snackbar(
                            'Berhasil', 
                            'Arsip berhasil dipulihkan.', 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: const Color(0xFF10B981), 
                            colorText: Colors.white, 
                            margin: const EdgeInsets.all(16)
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Gagal', 
                            'Terjadi kesalahan saat memulihkan arsip.', 
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
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Pulihkan',
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

  void deletePermanent(RecordModel doc) {
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
                  Icons.delete_forever_rounded,
                  color: Color(0xFFDC2626),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Hapus Permanen?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Tindakan ini tidak dapat dibatalkan. Dokumen dan file fisiknya akan dihapus selamanya dari database.',
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
                          await PocketBaseService.pb.collection('arsip').delete(doc.id);
                          
                          sampahList.removeWhere((item) => item.id == doc.id);
                          totalSampah.value--;
                          
                          Get.snackbar(
                            'Terhapus', 
                            'Arsip telah dihapus secara permanen.', 
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
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Hapus Permanen',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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

  void emptyTrash() {
  if (sampahList.isEmpty) return;

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
                  Icons.delete_forever_rounded,
                  color: Color(0xFFB91C1C),
                  size: 44,
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Kosongkan Tong Sampah?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Semua dokumen di tong sampah bidang Anda akan dihapus permanen. Tindakan ini tidak dapat dibatalkan!',
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
                          final pb = PocketBaseService.pb;
                          final userRecord = pb.authStore.record; 
                          final String role = userRecord?.getStringValue('role') ?? '';
                          final String bidang = userRecord?.getStringValue('bidang') ?? '';

                          String sampahFilter = 'is_deleted = true'; 
                          if (role == 'Staff') {
                            sampahFilter += ' && bidang = "$bidang"';
                          }

                          final recordsToDelete = await pb.collection('arsip').getFullList(
                            filter: sampahFilter,
                          );

                          await Future.wait(recordsToDelete.map((record) async {
                            await pb.collection('arsip').delete(record.id);
                          }));

                          sampahList.clear();
                          totalSampah.value = 0;

                          Get.snackbar(
                            'Selesai', 
                            'Tong sampah berhasil dikosongkan.', 
                            snackPosition: SnackPosition.BOTTOM, 
                            backgroundColor: const Color(0xFF10B981), 
                            colorText: Colors.white, 
                            margin: const EdgeInsets.all(16)
                          );
                        } catch (e) {
                          Get.snackbar(
                            'Gagal', 
                            'Terjadi kesalahan saat mengosongkan tong sampah.', 
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
                        backgroundColor: const Color(0xFFB91C1C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Ya, Kosongkan',
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

class SampahScreen extends StatelessWidget {
  const SampahScreen({super.key});

  Color _getBadgeColor(String kategori) {
    return const Color.fromARGB(255, 169, 164, 164); 
  }

  Color _getBadgeBgColor(Color badgeColor) {
    return badgeColor.withValues(alpha: 0.1);
  }

  IconData _getFileIcon(String fileName) {
    final name = fileName.toLowerCase();
    if (name.endsWith('.pdf')) return Icons.picture_as_pdf_outlined; 
    if (name.endsWith('.doc') || name.endsWith('.docx')) return Icons.description_outlined; 
    if (name.endsWith('.xls') || name.endsWith('.xlsx')) return Icons.table_chart_outlined; 
    if (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg')) return Icons.image_outlined; 
    return Icons.insert_drive_file_outlined; 
  }

  @override
  Widget build(BuildContext context) {
    final SampahController controller = Get.put(SampahController());
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
              onRefresh: controller.refreshSampahData,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  SliverPersistentHeader(
                    pinned: true, 
                    delegate: _TrashHeaderDelegate(
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
                            'Tong Sampah',
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
                              '${controller.totalSampah.value} Total',
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

                    if (controller.sampahList.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Center(
                            child: Text(
                              controller.searchQuery.value.isNotEmpty 
                                ? 'Pencarian tidak ditemukan.' 
                                : 'Tong sampah kosong.', 
                              style: TextStyle(color: Colors.grey.shade600)
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.sampahList.length) {
                            return Obx(() => controller.isFetchingMore.value
                              ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                              : const SizedBox(height: 100)); 
                          }

                          final doc = controller.sampahList[index];
                          final title = doc.getStringValue('judul');
                          final fileName = doc.getStringValue('file_dokumen');
                          final date = doc.getStringValue('tanggal_surat').split(' ').first;
                          final bidang = doc.getStringValue('bidang');
                          
                          final kategoriNama = doc.getStringValue('expand.kategori_id.nama');
                          final displayKategori = kategoriNama.isNotEmpty ? kategoriNama : 'ARSIP';
                          
                          final badgeColor = _getBadgeColor(displayKategori);
                          final badgeBgColor = _getBadgeBgColor(badgeColor);
                          final iconData = _getFileIcon(fileName);

                          return _buildTrashCard(
                            title: title.isNotEmpty ? title : (fileName.isNotEmpty ? fileName : 'Dokumen Tanpa Judul'),
                            badgeText: displayKategori.toUpperCase(),
                            badgeColor: badgeColor,
                            badgeBgColor: badgeBgColor,
                            department: bidang.isNotEmpty ? bidang.toUpperCase() : 'UMUM',
                            dateTime: date,
                            iconData: iconData,
                            onRestoreTap: () => controller.restoreArsip(doc),
                            onDeleteTap: () => controller.deletePermanent(doc),
                          );
                        },
                        childCount: controller.sampahList.length + 1, 
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

  Widget _buildTrashCard({
    required String title,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBgColor,
    required String department,
    required String dateTime,
    required IconData iconData,
    required VoidCallback onRestoreTap,
    required VoidCallback onDeleteTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: badgeColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: badgeColor, letterSpacing: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.domain_outlined, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        department, 
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 6),
                  Text(dateTime, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          
          Row(
            children: [
              Expanded(
                child: Material(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onRestoreTap,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.unarchive_outlined, color: Color(0xFF2563EB), size: 16),
                          SizedBox(width: 6),
                          Text('Restore', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              Expanded(
                child: Material(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: onDeleteTap,
                    borderRadius: BorderRadius.circular(12),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_fire_department_outlined, color: Color(0xFFDC2626), size: 16), 
                          SizedBox(width: 6),
                          Text('Delete', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrashHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;

  _TrashHeaderDelegate({required this.minHeight, required this.maxHeight});

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    double progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final Color dangerRed = const Color(0xFFB91C1C);

    final SampahController controller = Get.find<SampahController>();

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
                            hintText: 'Cari dokumen di sampah...',
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
                          onPressed: controller.emptyTrash,
                          icon: const Icon(Icons.cleaning_services_outlined, size: 20),
                          label: const Text('Kosongkan Semua', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dangerRed,
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
                    const SizedBox(width: 12),

                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                        color: dangerRed,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(color: dangerRed.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white, size: 20),
                        onPressed: controller.emptyTrash, 
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
  bool shouldRebuild(_TrashHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight;
  }
}