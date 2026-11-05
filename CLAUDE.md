# Zombi Savunma — proje notları

- 2D zombi dalgası savunma oyunu. Motor: Godot 4.3, renderer: GL Compatibility. Android, dikey ekran, arm64.
- Kullanıcıyla ve oyun içinde **Türkçe**. Kod adları da Türkçe (mevcut düzeni koru).
- **Önce oku:** `TASARIM.md` (tasarım, fikir havuzu, yol haritası) ve `GUNLUK.md` (geçmiş geceler ne yaptı).
- Betikler `betikler/` altında; sahne kodla kurulur (`oyun.gd` yönetici). Diğer betiklere referanslar
  bilerek tipsiz (`var oyun`) tutulur — tipli Node2D üzerinden özel alanlara erişmek derleme hatası verir.
- Varlıklar `assets/` altında; her yeni varlığın kaynağı ve lisansı `assets/KAYNAKLAR.md`'ye yazılır.
  Sadece CC0 / CC-BY (atıf yazılarak) kullan. Ses dosyası `assets/sesler/<ad>.ogg` olarak konursa
  `sesler.gd` onu kodla üretilen sesin yerine otomatik kullanır.
- Derleme: `main`'e her gönderimde `android.yml` APK derler ve `son-surum` sürümüne yükler:
  https://github.com/malisah61/zombi-savunma/releases/download/son-surum/ZombiSavunma.apk
- Kontrol: `onizleme.yml` oyunu bulutta açıp `onizleme/oyun/*.png` ekran görüntülerini depoya yazar.
  Görüntüleri mutlaka aç ve bak; derleme kaydında "SCRIPT ERROR" / "Parse Error" olmamalı.
  Yeni özellik eklersen `oyun.gd` içindeki `_onizleme()` akışına onu gösteren bir kare ekle.
- Kalıcı veri `profil.gd` (user://profil.json). Yeni alan eklerken `VARSAYILAN`'a ekle; eski kayıtlar
  otomatik tamamlanır. Var olan kayıtları bozacak değişiklik yapma (oyuncunun ilerlemesi gider).
- İçerik tabloları `veri.gd` (silahlar, nadirlik, ekler, roller, özellikler, bölgeler), kartlar `kartlar.gd`.
- **Performans kuralları (TASARIM.md §12):** oyun sırasında düğüm oluşturup silme yok, havuz kullan;
  dizi dolaşırken silme yok; değişmeyeni her kare çizme; kalite ayarına (0/1/2) uy.
- **Var olan özellikleri eksiltme.** Bir şeyi değiştirirken eskisinin yaptığı her şey çalışmaya devam etmeli.
- Godot ipuçları için `.claude/skills/` altındaki becerilere bak (dalga döngüsü, kule savunma, roguelike,
  hayatta kalma, envanter, kayıt, parçacık, ses, tween, arayüz, mobil, performans).
