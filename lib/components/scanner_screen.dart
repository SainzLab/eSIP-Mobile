import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'unggah_arsip_screen.dart';

class ScannerController extends GetxController {
  var isProcessing = false.obs;

  Future<void> startScan() async {
    try {
      List<String>? pictures = await CunningDocumentScanner.getPictures();
      
      if (pictures != null && pictures.isNotEmpty) {
        isProcessing.value = true;
        
        final pdf = pw.Document();
        for (var imgPath in pictures) {
          final image = pw.MemoryImage(File(imgPath).readAsBytesSync());
          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              margin: pw.EdgeInsets.zero, 
              build: (pw.Context context) {
                return pw.Center(child: pw.Image(image, fit: pw.BoxFit.contain));
              },
            ),
          );
        }
        
        final output = await getApplicationDocumentsDirectory(); 
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String newFileName = "SCAN_$timestamp.pdf";
        final file = File("${output.path}/$newFileName");
        await file.writeAsBytes(await pdf.save());
        
        isProcessing.value = false;
        
        if (Get.isRegistered<UnggahArsipController>()) {
          final uploadCtrl = Get.find<UnggahArsipController>();
          uploadCtrl.fileName.value = newFileName;
          uploadCtrl.filePath.value = file.path;
          
          Get.back();
          
          Get.snackbar(
            'Berhasil', 
            'Dokumen scan berhasil ditambahkan ke form.', 
            backgroundColor: Colors.green, 
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          Get.off(() => UnggahArsipScreen(
            initialFilePath: file.path,
            initialFileName: newFileName,
          ));
        }
        
      }
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar('Gagal', 'Terjadi kesalahan saat memproses scan.', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ScannerController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Smart Scanner', style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: Obx(() {
          if (controller.isProcessing.value) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Color(0xFF2563EB)),
                const SizedBox(height: 24),
                const Text('Membuat dokumen PDF...', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Harap tunggu sebentar', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              ],
            );
          }

          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 150, height: 150,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner_rounded, size: 80, color: Color(0xFF2563EB)),
                ),
                const SizedBox(height: 32),
                const Text('Scan Dokumen Fisik', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                const SizedBox(height: 12),
                Text(
                  'Gunakan kamera HP Anda untuk memindai dokumen fisik. Sistem otomatis mendeteksi tepi kertas dan mengubahnya menjadi file PDF.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: controller.startScan,
                    icon: const Icon(Icons.camera_alt_rounded, size: 22),
                    label: const Text('Buka Kamera & Scan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}