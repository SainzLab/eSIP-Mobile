import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http; 
import 'package:pocketbase/pocketbase.dart';
import '../models/pocketbase_service.dart';
import '../archive_screen.dart'; 

class UnggahArsipController extends GetxController {
  final RecordModel? existingDoc;
  UnggahArsipController({this.existingDoc});

  var isLoading = false.obs;
  var isUploading = false.obs;

  final noSuratController = TextEditingController();
  final judulController = TextEditingController();

  var selectedDate = Rxn<DateTime>();
  var selectedKategoriId = RxnString();
  var selectedBidang = RxnString();
  
  var fileName = ''.obs;
  var filePath = ''.obs;

  var kategoriList = <RecordModel>[].obs;

  final List<String> bidangList = [
    "Tata Usaha", "Kesiswaan", "Kepegawaian", "Keuangan", 
    "Kurikulum", "Sarana dan Prasarana", "Humas", 
    "Perpustakaan", "Pimpinan", "Dapodik"
  ];

  @override
  void onInit() {
    super.onInit();
    _fetchKategori();
    
    if (existingDoc != null) {
      _prefillData();
    }
  }

  void _prefillData() {
    noSuratController.text = existingDoc!.getStringValue('no_surat');
    judulController.text = existingDoc!.getStringValue('judul');
    
    final tglString = existingDoc!.getStringValue('tanggal_surat');
    if (tglString.isNotEmpty) {
      selectedDate.value = DateTime.tryParse(tglString);
    }
    
    selectedKategoriId.value = existingDoc!.getStringValue('kategori_id');
    selectedBidang.value = existingDoc!.getStringValue('bidang');
    fileName.value = existingDoc!.getStringValue('file_dokumen'); 
  }

  Future<void> _fetchKategori() async {
    isLoading.value = true;
    try {
      final res = await PocketBaseService.pb.collection('kategori').getFullList();
      kategoriList.value = res;
    } catch (e) {
      debugPrint('Gagal mengambil kategori: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'png', 'jpeg'],
      );

      if (result != null && result.files.isNotEmpty) {
        fileName.value = result.files.single.name;
        filePath.value = result.files.single.path ?? '';
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Gagal memilih file.', 
        snackPosition: SnackPosition.BOTTOM, 
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
    }
  }

  Future<void> simpanArsip() async {
    if (noSuratController.text.isEmpty || judulController.text.isEmpty || 
        selectedDate.value == null || selectedKategoriId.value == null || 
        selectedBidang.value == null) {
      Get.snackbar('Perhatian', 'Harap lengkapi semua kolom informasi!', 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    if (existingDoc == null && filePath.value.isEmpty) {
      Get.snackbar('Perhatian', 'Harap pilih file dokumen yang akan diunggah!', 
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange.shade700, colorText: Colors.white);
      return;
    }

    try {
      isUploading.value = true;
      final pb = PocketBaseService.pb;
      final userId = pb.authStore.record!.id;

      final body = <String, dynamic>{
        'no_surat': noSuratController.text.trim(),
        'judul': judulController.text.trim(),
        'tanggal_surat': selectedDate.value!.toIso8601String(),
        'kategori_id': selectedKategoriId.value,
        'bidang': selectedBidang.value,
        'pengunggah': userId,
        'is_deleted': false,
      };

      List<http.MultipartFile> files = [];
      if (filePath.value.isNotEmpty) {
        files.add(await http.MultipartFile.fromPath('file_dokumen', filePath.value));
      }

      if (existingDoc == null) {
        await pb.collection('arsip').create(body: body, files: files);
        Get.back(); 
        Get.snackbar(
          'Sukses', 
          'Dokumen arsip berhasil diunggah.', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      } else {
        await pb.collection('arsip').update(existingDoc!.id, body: body, files: files.isNotEmpty ? files : []);
        Get.back(); 
        Get.snackbar(
          'Sukses', 
          'Dokumen arsip berhasil diperbarui.', 
          snackPosition: SnackPosition.BOTTOM, 
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      }

      if (Get.isRegistered<ArchiveController>()) {
        Get.find<ArchiveController>().fetchArsipData();
      }

    } catch (e) {
      debugPrint('Error Upload: $e');
      Get.snackbar('Gagal', 'Terjadi kesalahan saat menyimpan arsip.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isUploading.value = false;
    }
  }

  @override
  void onClose() {
    noSuratController.dispose();
    judulController.dispose();
    super.onClose();
  }
}

class UnggahArsipScreen extends StatelessWidget {
  final RecordModel? existingDoc;

  const UnggahArsipScreen({super.key, this.existingDoc});

  @override
  Widget build(BuildContext context) {
    final UnggahArsipController controller = Get.put(UnggahArsipController(existingDoc: existingDoc));

    final Color primaryBlue = const Color(0xFF2563EB);
    final Color darkBlue = const Color(0xFF1E3A8A);
    final Color bgColor = const Color(0xFFF1F5F9);
    final Color textDark = const Color(0xFF0F172A);
    final Color textGrey = const Color(0xFF64748B);
    final Color borderGrey = const Color(0xFFE2E8F0);

    Future<void> selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: controller.selectedDate.value ?? DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: primaryBlue, 
                onPrimary: Colors.white, 
                onSurface: textDark,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        controller.selectedDate.value = picked;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
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
                                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)
                              ]
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
                          ),
                        ),
                      ),
                      Text(
                        existingDoc == null ? 'Unggah Arsip Baru' : 'Edit Arsip',
                        style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildSectionTitle('Informasi Dokumen', Icons.info_outline, primaryBlue, textDark),
                      const SizedBox(height: 20),

                      _buildLabel('NOMOR SURAT', textGrey),
                      _buildTextField(
                        controller: controller.noSuratController,
                        hint: 'Contoh: 001/SK/2026', 
                        prefixIcon: Icons.tag_rounded,
                        bgColor: bgColor, borderGrey: borderGrey, primaryBlue: primaryBlue,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('TANGGAL SURAT', textGrey),
                      InkWell(
                        onTap: () => selectDate(context),
                        borderRadius: BorderRadius.circular(14),
                        child: IgnorePointer(
                          child: _buildTextField(
                            controller: TextEditingController(),
                            hint: controller.selectedDate.value == null 
                                ? 'Pilih Tanggal' 
                                : '${controller.selectedDate.value!.day.toString().padLeft(2, '0')}/${controller.selectedDate.value!.month.toString().padLeft(2, '0')}/${controller.selectedDate.value!.year}',
                            prefixIcon: Icons.calendar_month_rounded,
                            suffixIcon: Icons.keyboard_arrow_down_rounded,
                            hintColor: controller.selectedDate.value == null ? null : textDark,
                            bgColor: bgColor, borderGrey: borderGrey, primaryBlue: primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('JUDUL DOKUMEN', textGrey),
                      _buildTextField(
                        controller: controller.judulController,
                        hint: 'Contoh: SK Pembagian Tugas',
                        prefixIcon: Icons.description_outlined,
                        bgColor: bgColor, borderGrey: borderGrey, primaryBlue: primaryBlue,
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Klasifikasi', Icons.category_outlined, primaryBlue, textDark),
                      const SizedBox(height: 20),

                      _buildLabel('KATEGORI ARSIP', textGrey),
                      _buildDropdown(
                        value: controller.selectedKategoriId.value,
                        items: controller.kategoriList.map((kategori) {
                          return DropdownMenuItem<String>(
                            value: kategori.id,
                            child: Text(kategori.getStringValue('nama'), style: TextStyle(color: textDark, fontSize: 14)),
                          );
                        }).toList(),
                        hint: 'Pilih Kategori',
                        prefixIcon: Icons.folder_outlined,
                        bgColor: bgColor, borderGrey: borderGrey, primaryBlue: primaryBlue, textDark: textDark,
                        onChanged: (val) => controller.selectedKategoriId.value = val,
                      ),
                      const SizedBox(height: 20),

                      _buildLabel('BIDANG / BAGIAN', textGrey),
                      _buildDropdown(
                        value: controller.selectedBidang.value,
                        items: controller.bidangList.map((String item) {
                          return DropdownMenuItem<String>(value: item, child: Text(item, style: TextStyle(color: textDark, fontSize: 14)));
                        }).toList(),
                        hint: 'Pilih Bidang',
                        prefixIcon: Icons.corporate_fare_rounded,
                        bgColor: bgColor, borderGrey: borderGrey, primaryBlue: primaryBlue, textDark: textDark,
                        onChanged: (val) => controller.selectedBidang.value = val,
                      ),
                      const SizedBox(height: 32),

                      _buildSectionTitle('Lampiran', Icons.attachment_rounded, primaryBlue, textDark),
                      const SizedBox(height: 16),
                      
                      _buildFileDropzone(controller, primaryBlue, textGrey, textDark),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15, offset: const Offset(0, -5))
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: borderGrey, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Batal', style: TextStyle(color: textGrey, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: [primaryBlue, darkBlue],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: primaryBlue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isUploading.value ? null : controller.simpanArsip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: controller.isUploading.value 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(existingDoc == null ? 'Simpan Arsip' : 'Update Arsip', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color primaryBlue, Color textDark) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
      ],
    );
  }

  Widget _buildLabel(String text, Color textGrey) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textGrey, letterSpacing: 0.5)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint, 
    required IconData prefixIcon, 
    IconData? suffixIcon,
    Color? hintColor,
    required Color bgColor,
    required Color borderGrey,
    required Color primaryBlue,
  }) {
    return TextField(
      controller: controller,
      style: hintColor != null ? TextStyle(color: hintColor) : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: hintColor ?? Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: primaryBlue.withValues(alpha: 0.7), size: 22),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade500, size: 22) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: bgColor.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderGrey, width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value, 
    required List<DropdownMenuItem<String>> items, 
    required String hint, 
    required IconData prefixIcon,
    required Color bgColor,
    required Color borderGrey,
    required Color primaryBlue,
    required Color textDark,
    required Function(String?) onChanged
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
      decoration: InputDecoration(
        prefixIcon: Icon(prefixIcon, color: primaryBlue.withValues(alpha: 0.7), size: 22),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: bgColor.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderGrey)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
      ),
      hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildFileDropzone(UnggahArsipController controller, Color primaryBlue, Color textGrey, Color textDark) {
    final isSelected = controller.fileName.value.isNotEmpty;
    final baseColor = isSelected ? Colors.green : primaryBlue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: controller.pickFile,
        borderRadius: BorderRadius.circular(16),
        splashColor: baseColor.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.blue.shade50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Colors.green : primaryBlue.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: baseColor.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)
                  ]
                ),
                child: Icon(isSelected ? Icons.check_circle_rounded : Icons.cloud_upload_rounded, color: baseColor, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                isSelected ? controller.fileName.value : 'Klik untuk memilih file', 
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isSelected ? Colors.green.shade700 : primaryBlue)
              ),
              const SizedBox(height: 6),
              Text(
                isSelected ? 'File siap diunggah/diperbarui' : 'Format didukung: PDF, DOCX, XLSX, JPG', 
                style: TextStyle(fontSize: 12, color: textGrey)
              ),
              if (!isSelected) ...[
                const SizedBox(height: 2),
                Text('Maksimal ukuran file: 10MB', style: TextStyle(fontSize: 12, color: textGrey)),
              ]
            ],
          ),
        ),
      ),
    );
  }
}