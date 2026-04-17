import 'package:flutter/material.dart';

class BuatDisposisiScreen extends StatefulWidget {
  const BuatDisposisiScreen({super.key});

  @override
  State<BuatDisposisiScreen> createState() => _BuatDisposisiScreenState();
}

class _BuatDisposisiScreenState extends State<BuatDisposisiScreen> {
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color darkBlue = const Color(0xFF1E3A8A);
  final Color bgColor = const Color(0xFFF1F5F9); 
  final Color textDark = const Color(0xFF0F172A);
  final Color textGrey = const Color(0xFF64748B);
  final Color borderGrey = const Color(0xFFE2E8F0);
  
  final Color infoBgColor = const Color(0xFFFFFBEB);
  final Color infoBorderColor = const Color(0xFFFDE68A);
  final Color infoTextColor = const Color(0xFFD97706);

  String? _selectedSurat;

  final List<String> _suratList = [
    'szcasd - zxczxc',
    'asd - asds',
    'NTD/11/Kemendikbud/2026 - Nota Dinas',
    'SP/1112/KEMENDIKBUD/2026 - SP KEPALA SEKOLAH',
    'HA.B1/211/HUMAS/KEMENDIKBUD/III/2026 - Surat Permohonan pelaporan dana BOS',
    'Akasdasd - asdasd',
    'laporan_keuangan_q3 - Laporan'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05), 
                  blurRadius: 5,
                )
              ]
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Buat Disposisi Baru',
          style: TextStyle(color: textDark, fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
      
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Pilih Dokumen Arsip', Icons.folder_shared_outlined),
              const SizedBox(height: 24),

              _buildLabel('SURAT MASUK (HANYA PDF)'),
              DropdownButtonFormField<String>(
                value: _selectedSurat,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey.shade600),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.picture_as_pdf_outlined, color: primaryBlue.withValues(alpha: 0.7), size: 22),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  filled: true,
                  fillColor: bgColor.withValues(alpha: 0.5),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: borderGrey)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: primaryBlue, width: 1.5)),
                ),
                hint: Text('Pilih Dokumen PDF', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                items: _suratList.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item, 
                    child: Text(item, style: TextStyle(color: textDark, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedSurat = val),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: infoBgColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: infoBorderColor, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: infoTextColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Disposisi',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: infoTextColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Surat yang dipilih akan otomatis diteruskan ke Pimpinan untuk menunggu instruksi selanjutnya.',
                            style: TextStyle(fontSize: 12, color: infoTextColor, fontWeight: FontWeight.w500, height: 1.4),
                          ),
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

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), 
              blurRadius: 15, 
              offset: const Offset(0, -5),
            )
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
                      BoxShadow(
                        color: primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Simpan Disposisi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textGrey, letterSpacing: 0.5),
      ),
    );
  }
}