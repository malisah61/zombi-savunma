# Geliştirme Günlüğü

Her gece görevi buraya en üste bir kayıt ekler: ne araştırdı, ne ekledi, ne kaldı, sorunlar.

## 2026-11-05 — Gece 1
- **Analizler:** (1) Altın tek yere gidiyor, onarım bedava can gibi; oyuncu kararı az; 28. dalgada kartlar bitiyor, geç oyun bitmiyor; ekipte gerçek karar yok.
  (2) Evrim planı, tanıtılan düşman, boss anı, reroll ve FM kişilik/rotasyon eksik. Ölçüm: asıl çizim yükü çokgenlermiş.
- **Araştırılanlar:** Survivor.io evrimi, Kingdom Rush zırh/boss, FM kişilik, meta gelişim, Godot SubViewport pişirme; fikir havuzuna kule yuvaları, aktif yetenekler, günlük görevler sayılarıyla.
- **3 geliştirme:** Performans v2 (atlas + zemin/barikat/leke pişirme, otomatik kalite, 120 zombi testi: 1567 → 232 çizim çağrısı, yazılım ekranında 11 → 23 FPS, bulutta 31.6 FPS); Kart v2 (4 yeni kart, 4 evrim, yeniden çekme, dolgu kartları, seviye noktaları); Dalga/ekonomi v2 (artan onarım fiyatı, nefes dalgası, tanıtım paneli, geç oyun can eğrisi).
- **3 yeni özellik:** Zırhlı + Kusan zombi (asit, hedef önceliği); Boss Dev (işaretli vuruş, can çubuğu, yardım çağrısı, garanti Ender+ ganimet, ağır çekim); FM v2 kişilik + yorgunluk + sakatlık (rotasyon).
- **Bot denge sonucu:** rastgele kartlı bot 8 koşuda 15–35. dalgada düştü, ölümler boss dalgalarında toplanıyor.
- **Varlık:** Yeni zombiler mevcut kod çizim stiliyle yapıldı, ücretli/harici varlık eklenmedi. Atlas sayesinde CC0 sprite'a geçiş artık tek dokuyu değiştirmek kadar kolay.
- **Bilinen sorunlar:** Yazılım ekranında yük testi FPS'i gerçek telefonu temsil etmez; gerçek cihazda bakılmalı. Sakatlık yalnızca barikat düşünce olur, menüye dönmek korur (bilinçli).
- **Sıradaki:** Rol aktif yetenekleri, kule yuvaları, CC0 sprite/ses.

## 2026-11-05 — Gün 0b (Mehmet Ali'nin isteği: performans, menü, FM tarzı sistemler)
- **Araştırma:** FM gözlemci ve CA/PA sistemi, FM oyuncu gelişimi (yaş, antrenman odağı, moral, kişilik),
  ARPG ganimet tabloları ve nadirlik, Godot 4 mobil performans → `TASARIM.md` §12–17.
- **Eklenenler:** Ana menü (Oyna/Ekip/Envanter/Keşif/Ayarlar); kalıcı profil (`profil.gd`, JSON + yedek);
  FM tarzı ekip (6 özellik, yetenek/potansiyel yıldızları, yaş, moral, antrenman odağı, gelişim);
  keşif (3 bölge, gerçek zamanlı, aralıklı rapor, inceleme, işe alma); silahlar (5 tür, 5 nadirlik, ekler,
  geliştir/birleştir/sat/kuşan); koşu sonu ödüller (hurda, ganimet, gelişim, seviye, moral); duraklatma;
  kalite ayarları, 30/60 FPS, ses, titreşim, FPS göstergesi; nesne havuzları; vinyet ve tehlike efekti.
- **Bilinen sorunlar:** Görseller hâlâ kodla çiziliyor; sesler kodla üretiliyor.
- **Sıradaki:** Zırhlı + kusan zombi ve ilk boss; ardından CC0 sprite ve sesler.

## 2026-11-05 — Gün 0 (ilk sürüm)
- **Araştırma:** Survivor.io/Archero (kart seçimi, evrim, tekrar oynanabilirlik), Kingdom Rush (düşman
  tanıtma, nefes dalgaları, zorluk), genel kule savunma ilkeleri → `TASARIM.md`.
- **Eklenenler:** Barikat (kırılan tahtalar, sarsıntı), asker (sürükleyerek hareket, otomatik nişan ve ateş,
  namlu alevi), yürüyen ve koşucu zombi, dalga sistemi (her 5. dalga yoğun saldırı), 8 yetenek kartı
  (seviyeli), altın ve barikat onarımı, kan lekeleri, parçacıklar, hasar sayıları, kodla üretilen sesler,
  başlangıç / kart / bitiş ekranları, rekor kaydı, bulutta önizleme ve APK derleme.
- **Sıradaki:** Yol haritasındaki 3. madde (zırhlı + kusan zombi, ilk boss).
