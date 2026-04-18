import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:pocketbase/pocketbase.dart';
import 'models/pocketbase_service.dart';
import 'components/daftar_arsip_kategori_screen.dart';

class CategoryModel {
  final String id;
  final String title;
  final int count;

  CategoryModel({required this.id, required this.title, required this.count});
}

class CategoryController extends GetxController {
  var isLoading = true.obs;
  var categoryList = <CategoryModel>[].obs;
  var filteredCategoryList = <CategoryModel>[].obs;
  var totalKategori = 0.obs;

  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading.value = true;
    try {
      final pb = PocketBaseService.pb;
      final userRecord = pb.authStore.record;
      
      final String role = userRecord?.getStringValue('role') ?? '';
      final String bidang = userRecord?.getStringValue('bidang') ?? '';

      String arsipFilter = 'is_deleted = false'; 
      if (role == 'Staff') {
        arsipFilter += ' && bidang = "$bidang"';
      }

      final categories = await pb.collection('kategori').getFullList(sort: 'nama');
      totalKategori.value = categories.length;

      List<CategoryModel> tempCategories = [];

      await Future.wait(categories.map((cat) async {
        final categoryId = cat.id;
        final categoryName = cat.getStringValue('nama');

        final countRes = await pb.collection('arsip').getList(
          page: 1,
          perPage: 1,
          filter: '$arsipFilter && kategori_id = "$categoryId"',
        );

        tempCategories.add(CategoryModel(
          id: categoryId,
          title: categoryName,
          count: countRes.totalItems,
        ));
      }));

      tempCategories.sort((a, b) => a.title.compareTo(b.title));
      
      categoryList.value = tempCategories;
      filteredCategoryList.value = tempCategories;

    } catch (e) {
      debugPrint("Error fetching categories: $e");
      Get.snackbar('Gagal', 'Terjadi kesalahan saat memuat kategori.',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade600, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategoryList.value = categoryList;
    } else {
      filteredCategoryList.value = categoryList.where((cat) {
        return cat.title.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  Map<String, dynamic> _getCategoryStyle(String title) {
    final name = title.toLowerCase();
    if (name.contains('surat masuk')) return {'icon': Icons.mail_outline, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
    if (name.contains('surat keluar')) return {'icon': Icons.send_outlined, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
    if (name.contains('surat keputusan') || name.contains('sk ')) return {'icon': Icons.gavel_outlined, 'color': const Color(0xFF9333EA), 'bg': const Color(0xFFFAF5FF)};
    if (name.contains('surat perintah')) return {'icon': Icons.assignment_late_outlined, 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEF2F2)};
    if (name.contains('nota dinas')) return {'icon': Icons.description_outlined, 'color': const Color(0xFF9333EA), 'bg': const Color(0xFFFAF5FF)};
    if (name.contains('surat edaran')) return {'icon': Icons.campaign_outlined, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF1F5F9)};
    if (name.contains('berita acara')) return {'icon': Icons.article_outlined, 'color': const Color(0xFF475569), 'bg': const Color(0xFFF1F5F9)};
    if (name.contains('dokumen keuangan') || name.contains('laporan')) return {'icon': Icons.money, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
    
    return {'icon': Icons.folder_open_outlined, 'color': const Color(0xFF2563EB), 'bg': const Color(0xFFEFF6FF)};
  }

  @override
  Widget build(BuildContext context) {
    final CategoryController controller = Get.put(CategoryController());
    final Color bgColor = const Color(0xFFF8F9FE);
    final Color textDark = const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchCategories,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0, bottom: 16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: controller.filterCategories,
                          decoration: InputDecoration(
                            hintText: 'Cari kategori dokumen...',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori Arsip',
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
                              '${controller.totalKategori.value} Kategori',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo.shade400,
                              ),
                            )),
                          ),
                        ],
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

                if (controller.filteredCategoryList.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Center(
                        child: Text(
                          'Kategori tidak ditemukan.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 100.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final cat = controller.filteredCategoryList[index];
                        final style = _getCategoryStyle(cat.title);

                        return _buildCategoryCard(
                          context,
                          title: cat.title,
                          count: _formatCount(cat.count),
                          icon: style['icon'],
                          iconColor: style['color'],
                          iconBgColor: style['bg'],
                        );
                      },
                      childCount: controller.filteredCategoryList.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade400,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(4),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DaftarArsipKategoriScreen(
                      categoryName: title, 
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min, 
                  children: [
                    const Text(
                      'LIHAT ARSIP',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios, 
                      size: 8, 
                      color: const Color(0xFF2563EB).withValues(alpha: 0.8)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}