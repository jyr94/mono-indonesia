# Paket Google Play

Folder `assets/` berisi:

- `app-icon-512.png` — ikon Play Store 512 × 512
- `feature-graphic-1024x500.jpg` — feature graphic
- `phone-01-gameplay-1080x1920.jpg`
- `phone-02-modes-1080x1920.jpg`
- `phone-03-room-1080x1920.jpg`

Teks listing tersedia di `listing-id.md`.

Sebelum upload produksi:

1. Gunakan signing key release, bukan debug key.
2. Naikkan `versionCode` dan `versionName`.
3. Build dengan `flutter build appbundle --release`.
4. Isi kebijakan privasi, data safety, content rating, target audience, dan ads.
5. Verifikasi application ID final.
