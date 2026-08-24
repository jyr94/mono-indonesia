# Checklist sebelum submit

## Sudah siap

- Ikon Play Store 512 × 512 PNG
- Feature graphic 1024 × 500 JPEG
- Tiga screenshot ponsel 1080 × 1920 JPEG
- Judul, deskripsi singkat, dan deskripsi lengkap Indonesia
- Listing bahasa Inggris
- Alt text aset
- Catatan rilis versi 1.0.0
- Nama launcher Android: `Monopoli Indonesia`

## Wajib diselesaikan sebelum produksi

- Ganti signing debug dengan upload key/release keystore
- Pastikan application ID final `com.monopoli.monopoli_indonesia` memang dipilih
- Buat URL kebijakan privasi publik
- Isi Data safety sesuai Firebase, Analytics, Crashlytics, Auth, dan iklan
- Isi deklarasi iklan karena aplikasi memakai Google Mobile Ads
- Selesaikan content rating dan target audience
- Uji internal testing sebelum production rollout
- Naikkan version code untuk setiap upload berikutnya

## Build setelah signing selesai

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

Hasil:

`build/app/outputs/bundle/release/app-release.aab`
