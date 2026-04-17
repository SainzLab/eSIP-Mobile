import 'package:flutter/material.dart';

class UnggahArsipScreen extends StatefulWidget {
  const UnggahArsipScreen({super.key});

  @override
  State<UnggahArsipScreen> createState() => _UnggahArsipScreenState();
}

class _UnggahArsipScreenState extends State<UnggahArsipScreen> {
  final Color primaryBlue = const Color(0xFF2563EB);
  final Color darkBlue = const Color(0xFF1E3A8A);
  final Color bgColor = const Color(0xFFF1F5F9);
  final Color textDark = const Color(0xFF0F172A);
  final Color textGrey = const Color(0xFF64748B);
  final Color borderGrey = const Color(0xFFE2E8F0);

  String? _selectedKategori;
  String? _selectedBidang;
  DateTime? _selectedDate;

  final List<String> _kategoriList = [
    'Surat Masuk', 'Surat Keluar', 'Surat Keputusan', 'Surat Perintah', 
    'Nota Dinas', 'Surat Edaran', 'Berita Acara', 'Laporan'
  ];

  final List<String> _bidangList = [
    'Tata Usaha', 'Kesiswaan', 'Kepegawaian', 'Keuangan', 
    'Kurikulum', 'Sarana dan Prasarana', 'Humas', 'Perpustakaan', 
    'Pimpinan', 'Dapodik'
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      
      body: SafeArea(
        child: SingleChildScrollView(
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
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05), 
                                blurRadius: 5,
                              )
                            ]
                          ),
                          child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
                        ),
                      ),
                    ),
                    Text(
                      'Unggah Arsip Baru',
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
                    _buildSectionTitle('Informasi Dokumen', Icons.info_outline),
                    const SizedBox(height: 20),

                    _buildLabel('NOMOR SURAT'),
                    _buildTextField(
                      hint: 'Contoh: 001/SK/2026', 
                      prefixIcon: Icons.tag_rounded,
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('TANGGAL SURAT'),
                    InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: IgnorePointer(
                        child: _buildTextField(
                          hint: _selectedDate == null 
                              ? 'Pilih Tanggal' 
                              : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
                          prefixIcon: Icons.calendar_month_rounded,
                          suffixIcon: Icons.keyboard_arrow_down_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('JUDUL DOKUMEN'),
                    _buildTextField(
                      hint: 'Contoh: SK Pembagian Tugas',
                      prefixIcon: Icons.description_outlined,
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Klasifikasi', Icons.category_outlined),
                    const SizedBox(height: 20),

                    _buildLabel('KATEGORI ARSIP'),
                    _buildDropdown(
                      value: _selectedKategori,
                      items: _kategoriList,
                      hint: 'Pilih Kategori',
                      prefixIcon: Icons.folder_outlined,
                      onChanged: (val) => setState(() => _selectedKategori = val),
                    ),
                    const SizedBox(height: 20),

                    _buildLabel('BIDANG / BAGIAN'),
                    _buildDropdown(
                      value: _selectedBidang,
                      items: _bidangList,
                      hint: 'Pilih Bidang',
                      prefixIcon: Icons.corporate_fare_rounded,
                      onChanged: (val) => setState(() => _selectedBidang = val),
                    ),
                    const SizedBox(height: 32),

                    _buildSectionTitle('Lampiran', Icons.attachment_rounded),
                    const SizedBox(height: 16),
                    
                    _buildFileDropzone(),
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
                    child: const Text('Simpan Arsip', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildTextField({required String hint, required IconData prefixIcon, IconData? suffixIcon}) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(prefixIcon, color: primaryBlue.withValues(alpha: 0.7), size: 22),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade500, size: 22) : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        filled: true,
        fillColor: bgColor.withValues(alpha: 0.5),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value, 
    required List<String> items, 
    required String hint, 
    required IconData prefixIcon,
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
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item, style: TextStyle(color: textDark, fontSize: 14)));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildFileDropzone() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: primaryBlue.withValues(alpha: 0.1),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          decoration: BoxDecoration(
            color: Colors.blue.shade50.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primaryBlue.withValues(alpha: 0.3), 
              width: 1.5, 
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
                child: Icon(Icons.cloud_upload_rounded, color: primaryBlue, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Klik untuk memilih file', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: primaryBlue)),
              const SizedBox(height: 6),
              Text('Format didukung: PDF, DOCX, XLSX', style: TextStyle(fontSize: 12, color: textGrey)),
              const SizedBox(height: 2),
              Text('Maksimal ukuran file: 10MB', style: TextStyle(fontSize: 12, color: textGrey)),
            ],
          ),
        ),
      ),
    );
  }
}