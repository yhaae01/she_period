# ShePeriod 💗

ShePeriod adalah aplikasi Flutter untuk membantu pengguna mencatat siklus menstruasi, melihat prediksi fase, dan membuat catatan harian dengan antarmuka pink yang lembut.

## Fitur

- **Dashboard siklus:** menampilkan fase siklus, hitung mundur haid, prediksi ovulasi dan masa subur, serta tips harian.
- **Maskot kelinci interaktif:** ketuk kelinci untuk melihat animasi bounce dan pesan penyemangat yang berubah.
- **Kalender bulanan:** pilih tanggal untuk melihat fase siklus dan membuat atau mengedit catatan.
- **Catatan harian:** simpan teks bebas dan mood cepat (😊, 🥱, 🍫, ⚡); catatan ditandai di kalender dan ditampilkan pada detail tanggal.
- **Pencatatan mood dan gejala:** pilih mood serta gejala yang dirasakan dari Dashboard.
- **Riwayat dan pengaturan siklus:** kelola HPHT, panjang siklus, lama haid, dan pengingat.
- **Penyimpanan lokal:** data siklus dan catatan disimpan di perangkat menggunakan `shared_preferences`.

## Menjalankan aplikasi

Pastikan Flutter SDK tersedia, lalu jalankan perintah berikut dari root proyek:

```bash
flutter pub get
flutter run
```

## Menjalankan pemeriksaan

```bash
flutter analyze
flutter test
```

## Teknologi utama

- Flutter dan Dart
- `shared_preferences` untuk penyimpanan lokal
- `lottie` untuk animasi maskot
- `flutter_local_notifications` untuk pengingat
