# PRD: Monopoli Indonesia (Flutter + WebSocket)

Versi digital Monopoli bertema Indonesia — playable di Android dan Web (PWA) menggunakan satu codebase Flutter, multiplayer real-time via WebSocket, dioptimalkan untuk pengembangan cepat oleh solo developer dengan biaya deployment rendah dan monetisasi lewat ads.

## Ringkasan
- Target: pemain kasual Indonesia (usia 12+). 
- Platform: Android (APK/AAB) & Web (PWA via Flutter Web).
- Prioritas: Rilis MVP secepat mungkin dengan biaya minimal, fokus rewarded ads sebagai monetisasi awal.

## Tujuan Produk
- Akuisisi cepat pengguna lokal.
- Retensi mingguan melalui gameplay sosial dan event sederhana.
- Monetisasi awal: rewarded ads + interstitial terbatas.

## Success Metrics
- MAU 3 bulan pertama: target 10k (estimasi awal).
- Retensi D1/D7/D30: target 35% / 15% / 8%.
- Konversi rewarded ad: >5% per pengguna aktif.
- Match completion rate: >95%.

## Requirement Ringkas (MVP)
- Board tunggal bertema Indonesia (contoh landmark: Monas, Borobudur) dengan 24 properti + 2 utilitas.
- Multiplayer 2–4 pemain online (turn‑based). 
- Lobby sederhana + invite link / room code.
- Dice roll, move, buy, pay rent, auction dasar, houses (sederhana).
- Chat singkat (preset + emoji). 
- Guest login + optional Google Sign-In.
- Integrasi AdMob (rewarded + interstitial).
- Firebase Analytics + Crashlytics.
- Web PWA & Android build.

## Batasan (solo developer + biaya rendah)
- Batasi pemain per match (2–4) untuk mengurangi kompleksitas jaringan.
- Tunda fitur kompleks: trading terperinci, auction AI canggih, leaderboard global (phase 2).
- Prioritaskan server ringan: Node.js WebSocket atau, bila ingin tanpa server, gunakan Firebase Realtime/Firestore (dengan tradeoffs pada authoritativeness).

## Fitur Gameplay Inti
- Turn flow: server menentukan giliran dan roll dice (otoritatif). 
- Action per turn: roll, buy (jika available), build house (saat memiliki set), accept/decline trade (basic), end turn.
- Auction: ketika pemain menolak membeli, tawarkan auction sederhana.
- Timers: default 60 detik per turn; auto-skip jika timeout.

## Multiplayer & Social
- Room model: host/creator or quick-match pairing.
- Invite via room code / link (PWA link untuk join di browser/Android).
- Chat in-room (non-persistent) + quick emotes.
- Friends & spectate: tunda untuk phase 2.

## Monetisasi
- Primary: Rewarded ads (extra roll, small coin pack) — non-intrusive.
- Secondary: Interstitials di menu atau setelah match (batas frekuensi).
- IAP cosmetic (skin dice, board theme) di phase 2.

## UX / Tema / Lokal
- Bahasa: Bahasa Indonesia default, English fallback.
- Visual: ilustrasi landmark Indonesia, warna hangat, ikon batik ringan.
- Audio: musik latar yang ringan (gamelan/modern fusion), efek klik/dice.
- Onboarding: 3-step interactive tutorial (roll + buy + build).

## Teknologi & Arsitektur
- Client: Flutter (single codebase untuk Android & Web). 
- Realtime: Node.js + ws or Socket.IO (server otoritatif untuk dice & money).
- Alternative serverless: Firebase Realtime / Firestore + Cloud Functions (lebih cepat deploy, tradeoff: less authoritative control).
- Auth & Persistence: Firebase Auth + Firestore untuk profil dan minimal persistence.
- Ads & Analytics: Google AdMob, Firebase Analytics, Crashlytics.
- Hosting backend murah: DigitalOcean droplet ($5/mo) atau Firebase (pay-as-you-go, utilizable free tier).

## Deployment & Estimasi Biaya
- Development phase: gunakan Firebase free tier + test AdMob accounts.
- Production minimal: Firebase pay-as-you-go (variable) OR DigitalOcean droplet $5–10/mo + managed DB if needed.
- CDN/Assets: Firebase Hosting or static assets on CDN (low cost).

## Security & Integrity
- Authoritative server enforces dice rolls and transactions.
- Validate all client actions server-side.
- Rate-limiting and basic anti-cheat checks (duplicates, negative balances).

## Timeline (Solo Developer, Full-time Estimate)
- Week 0 (setup): scaffold Flutter project (Android+Web), prototype board UI, pick backend approach.
- Week 1–2: implement core board logic, single-player flow, local UI.
- Week 3–4: implement WebSocket server, lobby, basic multiplayer sync (2–4 players).
- Week 5: integrate AdMob + analytics, polish UI, localization.
- Week 6: testing, bugfix, prepare APK & PWA staging.
Estimasi MVP: 4–6 minggu.

## Risks & Mitigasi
- Cheating / desync: mitigasi via authoritative server dan server-side dice.
- Cost spikes (Firebase): monitor usage, set budget alerts; fallback ke $5 droplet jika perlu predictable cost.
- Web performance: keep assets light, provide lower-fidelity mode for web.

## Deliverables (MVP)
- `PRD-Monopoli-Indonesia.md` (this file).
- Flutter repo scaffold with core gameplay (if requested).
- Node.js WebSocket skeleton (if requested).
- Deployment notes + README.

## Next Steps
Pilih salah satu untuk saya lanjutkan:

- **A**: Commit PRD ini ke repo (saya sudah membuat file). 
- **B**: Buat scaffold repo Flutter minimal + README + simple WebSocket server skeleton.
- **C**: Buat langkah per sprint terperinci dan task list untuk implementasi (issues-ready).

Jika mau saya langsung buat scaffold (pilih B), saya akan membuat proyek Flutter minimal dan folder `server/` dengan Node.js WebSocket skeleton. Untuk opsi B saya butuh konfirmasi apakah mau menggunakan Firebase (serverless) atau Node.js pada droplet kecil.

---
_Dokumen dibuat cepat untuk MVP solo‑dev; minta revisi spesifik bila butuh penyesuaian._
