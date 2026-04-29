![Capstone Project Glitch](./glitch.svg)

# 📱 eSIP Mobile (Sistem Informasi Pengelolaan Arsip)

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![PocketBase](https://img.shields.io/badge/PocketBase-B8E986?style=for-the-badge&logo=pocketbase&logoColor=16161a)
![MinIO](https://img.shields.io/badge/MinIO-C7202C?style=for-the-badge&logo=minio&logoColor=white)
![Ollama](https://img.shields.io/badge/Ollama-000000?style=for-the-badge&logo=ollama&logoColor=white)
![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white)

**eSIP Mobile** adalah aplikasi klien berbasis pintar (*smartphone*) untuk platform digitalisasi dan manajemen arsip terpadu. Aplikasi ini dibangun untuk meningkatkan mobilitas dan efisiensi administrasi sekolah (studi kasus: SMPN 1 Pabuaran). Dengan eSIP Mobile, pengelolaan, pencarian, dan peninjauan dokumen penting dapat dilakukan dengan mudah dan aman langsung dari genggaman.

## ✨ Fitur Utama

* 📱 **Akses Mobilitas Tinggi:** Antarmuka (UI/UX) yang dioptimalkan untuk perangkat *mobile* (Android/iOS) menggunakan Flutter.
* 🔐 **Role-Based Access Control (RBAC):** Autentikasi dan hak akses spesifik untuk *Kepala Sekolah*, *Arsiparis*, dan *Staff* yang terhubung langsung dengan backend.
* 🤖 **Asisten AI Terintegrasi:** Fitur *chat* cerdas untuk bertanya seputar kearsipan, didukung oleh *Local LLM* secara terpusat.
* ☁️ **Preview Dokumen S3:** Integrasi mulus untuk melihat atau mengunduh file arsip bervolume besar yang disimpan secara aman di *object storage*.
* 🐳 **Infrastruktur Terpusat:** Dukungan konektivitas ke *backend*, AI, dan *storage* yang di-*deploy* dalam *container* untuk skalabilitas.

## 🛠️ Tech Stack

Aplikasi ini merupakan bagian dari ekosistem kearsipan digital dengan teknologi:
* **Frontend Mobile:** [Flutter](https://flutter.dev/) (Dart)
* **Backend & Auth:** [PocketBase](https://pocketbase.io/) (Lightweight backend)
* **File Storage:** [MinIO](https://min.io/) (Self-hosted S3 Object Storage)
* **AI Engine:** [Ollama](https://ollama.ai/) (Local LLM via API backend)
* **Infrastructure:** [Docker](https://www.docker.com/) (Untuk *deployment* ekosistem layanan *backend*, *storage*, dan AI)

---

## 🚀 Panduan Instalasi (Development)

### Prasyarat:
Pastikan Anda telah menginstal **Flutter SDK** terbaru dan memiliki Android Studio atau VS Code yang sudah dikonfigurasi untuk *development* Flutter. Pastikan juga layanan *backend* (Dockerized PocketBase, MinIO, Ollama) sudah berjalan di server atau *local environment* Anda.

### 1. Clone & Setup Proyek
Clone repositori ini dan masuk ke direktori proyek:
```bash
git clone <url-repo-anda>
cd mobile_earsip
```

### 2. Instalasi Dependensi
Unduh semua *package* Dart yang dibutuhkan:
```bash
flutter pub get
```

### 3. Konfigurasi Environment (Lingkungan)
Buat file `.env` di *root directory* proyek (sejajar dengan `pubspec.yaml`) untuk menghubungkan aplikasi ke layanan *backend*:
```env
# Contoh isi file .env
API_BASE_URL=http://<IP_SERVER_ATAU_LOCALHOST>:8090
S3_ENDPOINT=http://<IP_SERVER_ATAU_LOCALHOST>:9000
```
*(Catatan: Sesuaikan IP dan Port dengan konfigurasi PocketBase dan MinIO Docker Anda).*

### 4. Jalankan Aplikasi
Hubungkan perangkat *mobile* fisik atau jalankan emulator/simulator, kemudian eksekusi perintah berikut:
```bash
flutter run
```

---

## 🐳 Panduan Singkat Deployment Ekosistem (Backend)
Bagi administrator yang ingin menjalankan sisi *server*, disarankan menggunakan `docker-compose.yml` untuk menjalankan PocketBase, MinIO, dan Ollama secara bersamaan:
```bash
docker-compose up -d
```
*(Pastikan melihat dokumentasi repositori backend/infrastruktur untuk konfigurasi Docker yang lebih rinci).*

## 👥 Kredit & Dukungan
Dikembangkan sebagai bagian dari **Capstone Project Universitas Subang (Unsub)**. 
*Support By: Mahasiswa Ilmu Komputer Unsub untuk SMP Negeri 1 Pabuaran.*
