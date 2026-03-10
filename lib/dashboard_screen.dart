import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Row(
          children: [
            Icon(Icons.folder_shared, color: Color(0xFF2563EB)),
            SizedBox(width: 8),
            Text('eSIP', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          const Center(
            child: Text('Humas', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: const Text('HU', style: TextStyle(color: Color(0xFF2563EB))),
          ),
          const SizedBox(width: 16),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(child: Text('Menu eSIP')),
            ListTile(leading: Icon(Icons.dashboard), title: Text('Dashboard')),
            ListTile(leading: Icon(Icons.folder), title: Text('Manajemen Arsip')),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Surat Masuk', '0', Icons.inbox_outlined, Colors.blue),
                _buildStatCard('Surat Keluar', '2', Icons.send_outlined, Colors.green),
                _buildStatCard('Total Arsip', '3', Icons.inventory_2_outlined, Colors.orange),
                _buildStatCard('Total Pengguna', '6', Icons.people_outline, Colors.purple),
              ],
            ),
            const SizedBox(height: 24),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistik Surat Masuk & Keluar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  const Text('Akumulasi dokumen berdasarkan bulan pada tahun 2026.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: Text('[ Area Grafik fl_chart ]', style: TextStyle(color: Colors.green))),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dokumen Terbaru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      TextButton(onPressed: () {}, child: const Text('Lihat Semua →')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  _buildDocItem('900.1.1/A1/B12?2026', 'Surat Permintaan Dana', 'NOTA DINAS', '06 Mar 2026'),
                  const Divider(),
                  _buildDocItem('A.1/KEL/A/III/2026', 'Permohonan Perbaikan Internet', 'SURAT KELUAR', '06 Mar 2026'),
                  const Divider(),
                  _buildDocItem('A.1/KEL/B/III/2026', 'Permohonan Ganti Alat Internet', 'SURAT KELUAR', '23 Mar 2026'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.grey.shade600, size: 20),
              Text(count, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildDocItem(String noSurat, String perihal, String kategori, String tanggal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(perihal, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('No: $noSurat • $kategori', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(tanggal, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('Diarsipkan', style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
    );
  }
}