# Desain UI Monopoli Indonesia

Dokumen ini mendeskripsikan referensi desain layar utama game berdasarkan gambar contoh. Tujuannya adalah memberi arahan visual dan struktur komponen untuk tim development saat membangun UI mobile.

## Konsep Utama

Layar utama adalah game board mobile bertema Monopoli Indonesia dengan gaya visual colorful, playful, dan 3D cartoon. Fokus utama layar adalah papan monopoli perspektif/isometric yang dikelilingi elemen budaya dan wisata Indonesia seperti pantai, laut, pura, monumen, gunung, dan bangunan khas daerah.

Nuansa UI harus terasa ringan, ramah keluarga, kompetitif, dan mudah dipahami oleh pemain casual.

## Struktur Layar

### 1. Status Bar

Bagian paling atas mengikuti status bar mobile.

Konten:

- Jam.
- Sinyal.
- Koneksi data.
- Baterai.

Catatan:

- Background status bar menyatu dengan langit biru pada game.
- Pastikan konten tidak tertutup notch atau safe area.

### 2. Player Info Panel

Di bagian atas layar terdapat dua panel pemain.

Panel kiri:

- Nama: `ANDA`
- Token: `KOMODO`
- Saldo: `IDR 1,250,000`
- Avatar laki-laki berbentuk lingkaran.
- Warna dominan biru.

Panel kanan:

- Nama: `MAYA`
- Token: `BECAK`
- Saldo: `IDR 850,000`
- Avatar perempuan berbentuk lingkaran.
- Warna dominan merah.

Detail visual:

- Card berbentuk rounded rectangle.
- Avatar berada di sisi luar panel.
- Avatar memakai border putih.
- Saldo menggunakan warna kuning/emas agar mudah dibaca.
- Nama pemain menggunakan teks putih bold.

### 3. Turn Indicator

Di bawah player info terdapat indikator giliran.

Konten:

- Teks utama: `GILIRAN ANDA!`
- Timer: `0:09`
- Ikon stopwatch di sebelah timer.

Detail visual:

- Banner putih dengan shadow halus.
- Teks utama bold dan centered.
- Timer berada dalam pill kecil berwarna gelap.
- Timer harus terlihat jelas karena bersifat gameplay-critical.

### 4. Board Area

Board menjadi elemen utama di tengah layar.

Karakteristik:

- Papan berbentuk kotak dengan perspektif isometric.
- Petak properti mengelilingi papan seperti Monopoly klasik.
- Setiap sisi papan berisi beberapa petak properti, event, transportasi, dan special tile.
- Tengah papan menampilkan logo `MONOPOLI INDONESIA`.
- Tengah papan juga berisi ilustrasi Indonesia seperti pantai, laut, pulau, Monas, candi, dan karakter.

Jenis tile yang terlihat:

- Properti dengan warna kategori.
- Tile tanda tanya.
- Tile transportasi.
- Tile pajak/event.
- Tile start atau special corner.

Catatan teknis:

- Board dapat dibuat sebagai custom widget/layer besar.
- Untuk versi awal, board boleh menggunakan asset image.
- Untuk versi interaktif, setiap tile sebaiknya memiliki posisi dan hit area sendiri.
- Board harus tetap menjadi fokus utama dan tidak tertutup panel bawah.

### 5. Dice Result Area

Di bagian bawah board terdapat panel hasil dadu.

Konten:

- Dua dadu 3D.
- Teks total: `Total 6`.
- Timer kecil di atas panel: `0:09`.

Detail visual:

- Panel semi-transparent gelap.
- Dadu berwarna putih dengan dot hitam.
- Teks total menggunakan putih bold.
- Panel berada di atas area bottom action bar.

State yang dibutuhkan:

- Idle sebelum lempar dadu.
- Rolling animation.
- Result muncul setelah dadu berhenti.
- Disabled saat bukan giliran pemain.

### 6. Floating Action Buttons

Ada dua tombol floating di sisi bawah board.

Tombol kiri:

- Posisi kiri bawah board.
- Warna oranye.
- Ikon aksi, bisa berupa ikon tangan atau gesture.

Tombol kanan:

- Posisi kanan bawah board.
- Warna oranye.
- Ikon daftar/menu.

Detail visual:

- Bentuk rounded square.
- Border putih.
- Shadow halus.
- Ukuran cukup besar untuk touch target mobile.

### 7. Bottom Action Bar

Bagian paling bawah berisi empat tombol aksi utama.

Tombol:

- `LEMPAR DADU`
  - Ikon dadu.
  - Warna biru.
- `BELI PROPERTI`
  - Ikon rumah.
  - Warna hijau.
  - Tampak sebagai aksi aktif/utama.
- `BANGUN GEDUNG`
  - Ikon bangunan.
  - Warna biru.
- `CHAT/TRADE`
  - Ikon chat.
  - Warna biru.

Detail visual:

- Setiap tombol memiliki ikon besar di atas teks.
- Teks putih bold dengan outline/shadow.
- Tombol memakai efek 3D ringan.
- Bottom bar harus selalu terlihat.
- Area harus mengikuti safe area bawah perangkat.

## Visual Style

Gaya visual:

- 3D cartoon.
- Colorful.
- Rounded.
- High contrast.
- Friendly casual game.

Palet warna utama:

- Biru langit untuk background.
- Hijau untuk pulau dan aksi positif.
- Merah untuk lawan atau highlight kompetitif.
- Oranye untuk tombol floating dan event.
- Putih untuk panel informasi.
- Kuning/emas untuk saldo dan angka penting.

Tipografi:

- Gunakan font rounded dan bold.
- Teks gameplay utama harus mudah dibaca pada layar kecil.
- Hindari teks panjang di tombol.
- Gunakan uppercase untuk label aksi utama.

Efek visual:

- Soft shadow.
- Border putih.
- Highlight glossy ringan.
- Depth pada card dan tombol.
- Board memakai perspektif/isometric.

## Komponen Yang Perlu Dibuat

- `GameScreen`
- `PlayerStatusCard`
- `AvatarBadge`
- `TurnBanner`
- `CountdownTimer`
- `GameBoard`
- `BoardTile`
- `DiceResultPanel`
- `DiceWidget`
- `FloatingActionButton`
- `BottomActionBar`
- `GameActionButton`

## State UI

### Turn State

- Giliran pemain.
- Giliran lawan.
- Menunggu aksi.
- Timer hampir habis.
- Timer habis.

### Dice State

- Belum dilempar.
- Sedang rolling.
- Hasil muncul.
- Dadu disabled.

### Property State

- Bisa dibeli.
- Sudah dimiliki pemain.
- Sudah dimiliki lawan.
- Bisa dibangun.
- Tidak cukup saldo.

### Button State

- Enabled.
- Disabled.
- Selected.
- Loading.
- Cooldown.

## Responsiveness

Target utama adalah mobile portrait.

Ukuran referensi:

- Lebar: 360px sampai 430px.
- Rasio layar tinggi seperti perangkat modern.

Aturan responsive:

- Gunakan safe area untuk notch dan home indicator.
- Player panel tidak boleh bertabrakan dengan notch.
- Bottom action bar harus tetap terlihat.
- Board boleh mengecil secara proporsional pada layar kecil.
- Teks tombol harus tetap terbaca dan tidak overflow.
- Floating button tidak boleh menutup tile penting.

## Prioritas Implementasi

### Fase 1

- Layout utama.
- Player info.
- Turn indicator.
- Board sebagai static asset.
- Dice panel.
- Bottom action bar.

### Fase 2

- Tile board interaktif.
- Animasi lempar dadu.
- Highlight posisi pemain.
- State tombol berdasarkan giliran.
- Timer berjalan.

### Fase 3

- Animasi token bergerak.
- Modal beli properti.
- Modal bangun gedung.
- Chat/trade screen.
- Efek suara dan feedback visual.

## Catatan UX

- Pemain harus langsung tahu giliran siapa.
- Aksi utama pada giliran pemain harus sangat jelas.
- Informasi saldo harus mudah ditemukan.
- Tombol penting harus berada di jangkauan ibu jari.
- Jangan menaruh terlalu banyak teks di layar utama.
- Feedback visual perlu cepat setelah pemain menekan tombol.

## Referensi Copy UI

Gunakan copy berikut untuk versi awal:

- `GILIRAN ANDA!`
- `LEMPAR DADU`
- `BELI PROPERTI`
- `BANGUN GEDUNG`
- `CHAT/TRADE`
- `Total 6`
- `IDR 1,250,000`
- `IDR 850,000`

## Catatan Untuk Tim Development

Untuk implementasi awal Flutter, gunakan struktur `Stack` agar board, HUD atas, dice panel, floating button, dan bottom action bar bisa ditata sebagai layer. Pastikan semua elemen memakai `SafeArea`, terutama bagian atas dan bawah.

Jika board masih berupa gambar, pisahkan asset board dari overlay UI agar nanti mudah diganti menjadi board interaktif.
