import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/pocketbase_service.dart';

class DisposisiController extends GetxController {
  var isLoading = true.obs;
  var isSaving = false.obs;
  var isFetchingMore = false.obs;
  
  var disposisiList = <RecordModel>[].obs;
  var opsiArsip = <RecordModel>[].obs; 
  
  var activeTab = 'Semua'.obs;
  var searchQuery = ''.obs;
  final searchController = TextEditingController();

  var currentPage = 1.obs;
  var hasMore = true.obs;
  final int perPage = 10;

  String userRole = '';
  String userBidang = '';

  @override
  void onInit() {
    super.onInit();
    final pb = PocketBaseService.pb;
    userRole = pb.authStore.record?.getStringValue('role') ?? 'Staff';
    userBidang = pb.authStore.record?.getStringValue('bidang') ?? 'Umum';

    debounce(searchQuery, (_) => refreshDisposisi(), time: const Duration(milliseconds: 500));
    fetchDisposisi();
  }

  Future<void> refreshDisposisi() async {
    currentPage.value = 1;
    hasMore.value = true;
    disposisiList.clear();
    await fetchDisposisi();
  }

  Future<void> fetchDisposisi({bool isLoadMore = false}) async {
    if (isLoadMore) {
      isFetchingMore.value = true;
    } else {
      isLoading.value = true;
    }

    try {
      String filterQuery = '';
      
      if (userRole == 'Petugas Arsip' || userRole == 'Arsiparis' || userRole == 'Kepala Sekolah') {
        filterQuery = ''; 
      } else {
        filterQuery = 'tujuan_bidang = "$userBidang" && status != "Menunggu Instruksi"';
      }

      final records = await PocketBaseService.pb.collection('disposisi').getList(
        page: currentPage.value,
        perPage: perPage,
        filter: filterQuery,
        sort: '-created',
        expand: 'arsip_id',
      );
      
      if (isLoadMore) {
        disposisiList.addAll(records.items);
      } else {
        disposisiList.value = records.items;
      }
      
      hasMore.value = currentPage.value < records.totalPages;
    } catch (e) {
      debugPrint("Gagal menarik data disposisi: $e");
    } finally {
      isLoading.value = false;
      isFetchingMore.value = false;
    }
  }

  void loadMore() {
    if (hasMore.value && !isFetchingMore.value && !isLoading.value) {
      currentPage.value++;
      fetchDisposisi(isLoadMore: true);
    }
  }

  List<RecordModel> get filteredDisposisi {
    var filtered = disposisiList.toList();

    if (activeTab.value != 'Semua') {
      filtered = filtered.where((item) => item.getStringValue('status') == activeTab.value).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      filtered = filtered.where((item) {
        final instruksi = item.getStringValue('instruksi').toLowerCase();
        final judul = item.getStringValue('expand.arsip_id.judul').toLowerCase();
        final noSurat = item.getStringValue('expand.arsip_id.no_surat').toLowerCase();
        return instruksi.contains(q) || judul.contains(q) || noSurat.contains(q);
      }).toList();
    }

    filtered.sort((a, b) {
      final statusA = a.getStringValue('status');
      final statusB = b.getStringValue('status');
      
      int getPriority(String s) {
        if (s == 'Menunggu Instruksi') return 1;
        if (s == 'Diproses') return 2;
        if (s == 'Selesai') return 3;
        return 99;
      }
      return getPriority(statusA).compareTo(getPriority(statusB));
    });

    return filtered;
  }

  Future<void> lihatSurat(RecordModel disposisiRecord) async {
    List<RecordModel> arsipList = [];
    try { arsipList = disposisiRecord.get<List<RecordModel>>('expand.arsip_id'); } catch (e) {}

    if (arsipList.isEmpty) return;

    final arsip = arsipList.first;
    final fileName = arsip.getStringValue('file_dokumen');
    if (fileName.isEmpty) return;
    
    final encodedFileName = Uri.encodeComponent(fileName);
    final urlString = '${PocketBaseService.baseUrl}/api/files/${arsip.collectionId}/${arsip.id}/$encodedFileName';
    try {
      await launchUrl(Uri.parse(urlString), mode: LaunchMode.externalApplication); 
    } catch (e) {
      Get.snackbar('Error', 'Tidak dapat membuka surat.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void konfirmasiAksi(RecordModel item, String action) {
    final isDelete = action == 'delete';

    final iconData = isDelete ? Icons.cancel_outlined : Icons.check_circle_outline_rounded;
    final mainColor = isDelete ? const Color(0xFFDC2626) : const Color(0xFF10B981);
    final iconBgColor = isDelete ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);
    final titleText = isDelete ? 'Cabut Disposisi?' : 'Selesaikan Instruksi?';
    final descText = isDelete 
        ? 'Apakah Anda yakin ingin mencabut dan menghapus lembar disposisi ini?' 
        : 'Apakah instruksi pimpinan pada surat ini sudah Anda selesaikan?';
    final confirmText = isDelete ? 'Ya, Cabut' : 'Ya, Selesai';
   
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
                decoration: BoxDecoration(
                  color: iconBgColor, 
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  color: mainColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                titleText,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                descText,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
                          if (isDelete) {
                            await PocketBaseService.pb.collection('disposisi').delete(item.id);
                            Get.snackbar(
                              'Berhasil', 
                              'Lembar disposisi berhasil dicabut.', 
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF1E293B),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16)
                            );
                          } else {
                            await PocketBaseService.pb.collection('disposisi').update(item.id, body: {'status': 'Selesai'});
                            Get.snackbar(
                              'Berhasil', 
                              'Status disposisi ditandai Selesai!', 
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF10B981),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16)
                            );
                          }
                          refreshDisposisi();
                        } catch (e) {
                          Get.snackbar(
                            'Error', 
                            'Gagal memproses aksi.', 
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
                        backgroundColor: mainColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
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

  Future<void> openFormModal(String mode, {RecordModel? existingData}) async {
    String arsipId = existingData?.getStringValue('arsip_id') ?? '';
    String tujuanBidang = existingData?.getStringValue('tujuan_bidang') ?? (userRole == 'Kepala Sekolah' ? '' : 'Pimpinan');
    String instruksi = existingData?.getStringValue('instruksi') ?? '';
    String sifat = existingData?.getStringValue('sifat').isNotEmpty == true ? existingData!.getStringValue('sifat') : 'Biasa';
    
    String rawBatasWaktu = existingData?.getStringValue('batas_waktu') ?? '';
    String batasWaktu = rawBatasWaktu.isNotEmpty ? rawBatasWaktu : DateTime.now().toIso8601String();
    
    if (mode == 'create') {
      try {
        final res = await PocketBaseService.pb.collection('arsip').getFullList(
          filter: 'is_deleted = false && file_dokumen ~ ".pdf"', sort: '-created'
        );
        opsiArsip.value = res;
      } catch (e) {}
    }

    final bidangList = ["Tata Usaha", "Kesiswaan", "Kepegawaian", "Keuangan", "Kurikulum", "Sarana dan prasarana", "Humas", "Dapodik"];
    final sifatList = ["Biasa", "Penting", "Segera", "Rahasia"];

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode == 'create' ? 'Mulai Disposisi Baru' : (mode == 'edit' ? 'Revisi Instruksi' : 'Instruksi Kepala Sekolah'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 20),

                  if (mode == 'create') ...[
                    const Text('Pilih Surat Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: arsipId.isEmpty ? null : arsipId,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      hint: const Text('Pilih Dokumen Arsip PDF'),
                      items: opsiArsip.map((a) => DropdownMenuItem(value: a.id, child: Text('${a.getStringValue("no_surat")} - ${a.getStringValue("judul")}', maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
                      onChanged: (v) => setState(() => arsipId = v!),
                    ),
                    if (userRole != 'Kepala Sekolah')
                      Padding(padding: const EdgeInsets.only(top: 8.0), child: Text('Surat akan otomatis diteruskan ke Pimpinan untuk menunggu instruksi.', style: TextStyle(fontSize: 11, color: Colors.amber.shade700))),
                    const SizedBox(height: 16),
                  ],

                  if (mode == 'forward' || mode == 'edit' || (mode == 'create' && userRole == 'Kepala Sekolah')) ...[
                    const Text('Teruskan Ke Bidang', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tujuanBidang.isEmpty || tujuanBidang == 'Pimpinan' ? null : tujuanBidang,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                      hint: const Text('Pilih Bidang Tujuan'),
                      items: bidangList.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                      onChanged: (v) => setState(() => tujuanBidang = v!),
                    ),
                    const SizedBox(height: 16),

                    const Text('Instruksi / Arahan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: instruksi)..selection = TextSelection.collapsed(offset: instruksi.length),
                      onChanged: (v) => instruksi = v,
                      maxLines: 3,
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), hintText: 'Contoh: Segera tindak lanjuti...'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Sifat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<String>(
                                value: sifat,
                                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), contentPadding: const EdgeInsets.symmetric(horizontal: 16)),
                                items: sifatList.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                                onChanged: (v) => setState(() => sifat = v!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Batas Waktu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                              const SizedBox(height: 8),
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context, initialDate: DateTime.parse(batasWaktu.substring(0, 10)), firstDate: DateTime.now(), lastDate: DateTime(2100),
                                  );
                                  if (picked != null) setState(() => batasWaktu = picked.toIso8601String());
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(12)),
                                  child: Text(batasWaktu.substring(0, 10), style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: () async {
                        if (arsipId.isEmpty && mode == 'create') {
                          Get.snackbar('Peringatan', 'Pilih surat terlebih dahulu', backgroundColor: Colors.orange, colorText: Colors.white);
                          return;
                        }
                        
                        bool isFullForm = mode == 'forward' || mode == 'edit' || (mode == 'create' && userRole == 'Kepala Sekolah');
                        if (isFullForm) {
                          if (tujuanBidang.isEmpty || tujuanBidang == 'Pimpinan') {
                            Get.snackbar('Peringatan', 'Pilih Bidang Tujuan!', backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                          if (instruksi.trim().isEmpty) {
                            Get.snackbar('Peringatan', 'Isi instruksi/arahan!', backgroundColor: Colors.orange, colorText: Colors.white);
                            return;
                          }
                        }

                        isSaving.value = true;
                        try {
                          final pb = PocketBaseService.pb;
                          final dateOnly = batasWaktu.substring(0, 10);
                          final bWaktuStr = '$dateOnly 12:00:00.000Z'; 

                          if (mode == 'create') {
                            if (userRole == 'Kepala Sekolah') {
                              await pb.collection('disposisi').create(body: {'arsip_id': arsipId, 'tujuan_bidang': tujuanBidang, 'instruksi': instruksi.trim(), 'sifat': sifat, 'batas_waktu': bWaktuStr, 'status': 'Diproses'});
                            } else {
                              await pb.collection('disposisi').create(body: {'arsip_id': arsipId, 'tujuan_bidang': 'Pimpinan', 'status': 'Menunggu Instruksi'});
                            }
                          } else if (mode == 'forward' || mode == 'edit') {
                            await pb.collection('disposisi').update(existingData!.id, body: {'tujuan_bidang': tujuanBidang, 'instruksi': instruksi.trim(), 'sifat': sifat, 'batas_waktu': bWaktuStr, 'status': existingData.getStringValue('status') == 'Menunggu Instruksi' ? 'Diproses' : existingData.getStringValue('status')});
                          }
                          
                          if (Get.isBottomSheetOpen == true) Get.back();
                          Get.snackbar('Sukses', 'Data disposisi berhasil disimpan!', backgroundColor: Colors.green, colorText: Colors.white);
                          refreshDisposisi(); 
                        } catch (e) {
                          Get.snackbar('Error', 'Gagal menyimpan data.', backgroundColor: Colors.red, colorText: Colors.white);
                        } finally {
                          isSaving.value = false;
                        }
                      },
                      child: Obx(() => isSaving.value 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text('Simpan Disposisi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class DisposisiScreen extends StatelessWidget {
  const DisposisiScreen({super.key});

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '-';
    try {
      final DateTime dt = DateTime.parse(dateStr);
      final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final DisposisiController controller = Get.put(DisposisiController());
    final Color bgColor = const Color(0xFFF8F9FE);

    final double headerMaxHeight = controller.userRole != 'Staff' ? 200.0 : 140.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
              controller.loadMore();
            }
            return false;
          },
          child: RefreshIndicator(
            onRefresh: controller.refreshDisposisi,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                SliverPersistentHeader(
                  pinned: true,
                  delegate: _DisposisiHeaderDelegate(
                    minHeight: 70.0,
                    maxHeight: headerMaxHeight,
                  ),
                ),

                SliverToBoxAdapter(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 16, top: 8),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildTabBtn(controller, 'Semua'),
                        _buildTabBtn(controller, 'Menunggu Instruksi'),
                        _buildTabBtn(controller, 'Diproses'),
                        _buildTabBtn(controller, 'Selesai'),
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

                  final dataList = controller.filteredDisposisi;

                  if (dataList.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Text(
                            controller.searchQuery.value.isNotEmpty ? 'Pencarian tidak ditemukan.' : 'Tidak ada data disposisi.', 
                            style: const TextStyle(color: Colors.grey)
                          )
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == dataList.length) {
                          return Obx(() => controller.isFetchingMore.value
                            ? const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Center(child: CircularProgressIndicator()))
                            : const SizedBox(height: 100)); 
                        }

                        final item = dataList[index];
                        final noSurat = item.getStringValue('expand.arsip_id.no_surat').isNotEmpty ? item.getStringValue('expand.arsip_id.no_surat') : 'Tanpa Nomor';
                        final instruksi = item.getStringValue('instruksi');
                        final bidang = item.getStringValue('tujuan_bidang');
                        final sifat = item.getStringValue('sifat');
                        final status = item.getStringValue('status');
                        
                        final String rawBatas = item.getStringValue('batas_waktu');
                        final String batasWaktuFormatted = _formatDate(rawBatas);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _buildDisposisiCard(controller, item, noSurat, instruksi, bidang, sifat, status, batasWaktuFormatted),
                        );
                      },
                      childCount: dataList.length + 1,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBtn(DisposisiController controller, String title) {
    return Obx(() {
      final isActive = controller.activeTab.value == title;
      final primaryBlue = const Color(0xFF2563EB);
      
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: InkWell(
          onTap: () => controller.activeTab.value = title,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? primaryBlue : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isActive ? null : Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              title, 
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: isActive ? Colors.white : Colors.grey.shade600
              )
            ),
          ),
        ),
      );
    });
  }

  Widget _buildDisposisiCard(
    DisposisiController controller, RecordModel item, 
    String noSurat, String instruksi, String bidang, 
    String sifat, String status, String batasWaktu
  ) {
    
    Color sifatColor = Colors.grey;
    Color sifatBgColor = Colors.grey.shade100;
    if (sifat == 'Segera') { sifatColor = const Color(0xFF2563EB); sifatBgColor = const Color(0xFFDBEAFE); } 
    if (sifat == 'Penting') { sifatColor = const Color(0xFFD97706); sifatBgColor = const Color(0xFFFEF3C7); } 
    if (sifat == 'Rahasia') { sifatColor = const Color(0xFFDC2626); sifatBgColor = const Color(0xFFFEE2E2); } 
    if (sifat == 'Biasa') { sifatColor = const Color(0xFF16A34A); sifatBgColor = const Color(0xFFDCFCE7); } 

    Color statusDotColor = Colors.grey;
    if (status == 'Menunggu Instruksi') statusDotColor = Colors.grey.shade400; 
    if (status == 'Diproses') statusDotColor = const Color(0xFFEAB308); 
    if (status == 'Selesai') statusDotColor = const Color(0xFF22C55E); 

    final textDark = const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 15, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('NO. REFERENSI', style: TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(noSurat, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (sifat.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: sifatBgColor, borderRadius: BorderRadius.circular(20)),
                        child: Text(sifat.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: sifatColor)),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Instruksi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          const SizedBox(height: 4),
                          Text(
                            instruksi.isNotEmpty ? instruksi : 'Menunggu instruksi dari Pimpinan...', 
                            style: TextStyle(
                              fontSize: 14, 
                              color: instruksi.isNotEmpty ? textDark : Colors.grey.shade500,
                              fontStyle: instruksi.isNotEmpty ? FontStyle.normal : FontStyle.italic
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Icon(Icons.domain_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(bidang.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                    
                    const SizedBox(width: 24),
                    
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: statusDotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(status, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade700)),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(height: 1, thickness: 1, color: Colors.grey.shade100),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 6),
                    Text(
                      batasWaktu.isNotEmpty ? batasWaktu : '-',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                  ],
                ),

                Row(
                  children: [
                    _actionBtn(Icons.remove_red_eye_outlined, const Color(0xFF2563EB), const Color(0xFFEFF6FF), () => controller.lihatSurat(item)),
                    
                    if (controller.userRole == 'Kepala Sekolah') ...[
                      const SizedBox(width: 12),
                      if (status == 'Menunggu Instruksi')
                        _actionBtn(Icons.share_outlined, const Color(0xFF4F46E5), const Color(0xFFEEF2FF), () => controller.openFormModal('forward', existingData: item))
                      else
                        _actionBtn(Icons.edit_outlined, const Color(0xFFD97706), const Color(0xFFFEF3C7), () => controller.openFormModal('edit', existingData: item)),
                    ],

                    if (controller.userRole == 'Staff' && status == 'Diproses') ...[
                      const SizedBox(width: 12),
                      _actionBtn(Icons.check, const Color(0xFF16A34A), const Color(0xFFDCFCE7), () => controller.konfirmasiAksi(item, 'complete')),
                    ],

                    if (controller.userRole == 'Petugas Arsip' || controller.userRole == 'Arsiparis') ...[
                      const SizedBox(width: 12),
                      _actionBtn(Icons.delete_outline, const Color(0xFFDC2626), const Color(0xFFFEF2F2), () => controller.konfirmasiAksi(item, 'delete')),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color iconColor, Color bgColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: iconColor.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
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
    final Color textDark = const Color(0xFF1E293B);

    final DisposisiController controller = Get.find<DisposisiController>();

    return Container(
      color: const Color(0xFFF8F9FE), 
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.bottomCenter,
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
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12), 
                          border: Border.all(color: Colors.grey.shade300)
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: (v) => controller.searchQuery.value = v,
                          decoration: InputDecoration(
                            hintText: 'Cari nomor surat atau instruksi...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (controller.userRole != 'Staff') ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.openFormModal('create'),
                            icon: const Icon(Icons.post_add_rounded, size: 20),
                            label: const Text('Buat Disposisi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        const SizedBox(height: 12),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Lembar Disposisi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: primaryBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text('Terbaru', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryBlue)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8), 
                    ],
                  ),
                ),
              ),
            ),

            Opacity(
              opacity: progress,
              child: IgnorePointer(
                ignoring: progress < 0.5,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: controller.searchController,
                            onChanged: (val) => controller.searchQuery.value = val,
                            decoration: InputDecoration(
                              hintText: 'Cari...',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      if (controller.userRole != 'Staff') ...[
                        const SizedBox(width: 12),
                        Container(
                          height: 45, width: 45,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))],
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.post_add_rounded, color: Colors.white, size: 20),
                            onPressed: () => controller.openFormModal('create'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
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