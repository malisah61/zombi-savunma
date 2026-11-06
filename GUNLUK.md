# Geliştirme Günlüğü

Her gece görevi buraya en üste bir kayıt ekler: ne araştırdı, ne ekledi, ne kaldı, sorunlar.

## 2026-11-06 — Gündüz (Mehmet Ali'nin isteği: yapay zekâ, Grow Castle tarzı, hızlandırma)
- **Eklenen:** Oyun hızı x1/x2/x3 düğmesi (HUD, duraklatmanın yanında; seçim kaydedilir). x3'te mermiler zombinin
  içinden geçmesin diye çarpışma doğru parçası testine çevrildi; boss ağır çekimi hıza göre ölçekleniyor.
- **Plan:** `TASARIM.md` §0'a en öncelikli blok yazıldı: surdaki ekip (nöbetçi yuvaları), ekip yapay zekâsı, yönetmen,
  sur yükseltmesi, kampanya modu, altınla seviye, zayıf nokta hedefleme, sürü davranışı, boss aşamaları,
  otomatik savaş + çevrimdışı kazanç, akıllı kart seçimi, kasaba, hız kilitleri. Gece görevi bunları sırayla yapar.

## 2026-11-06 — Gece 2
- **Analizler:** (1) Taretler 15. dalgaya kadar altını yutuyor ama sonrasında ≈ 800 altın boşa birikiyor; hurdanın uzun vadeli yeri yok; bitiş ekranı neden öldüğünü söylemiyor; düşmanların hepsi aynı şeyi sınıyor. (2) KR'de küçük kalıcı adımlar, Hades'te "az güç + çok seçim", FM'de beklentiye ve kişiliğe göre konuşma, patlayıcı düşmanın iki yönlü olması.
- **Araştırılanlar:** KR yükseltme ağacı, meta çeşitlilik/güç dengesi, fark türü ve ölçeği, FM konuşması, Hades Heat, KR erken çağırma; plana sayılarıyla Tehdit Seviyesi, Erken dalga çağırma, Boss Kraliçe yazıldı.
- **3 geliştirme:** Performans v3 (52 parçacık düğümü → 1 düğüm, kahraman dokuya pişti); Kule v2 (3. seviyeden sonra 240 altına Havan veya Ağır Taret, seçim oyunu durdurur); Koşu sonu v2 (barikatı en çok yiyen tür + öneri, sıradaki Laboratuvar hedefi, ilk 3 koşuda dalga dalga ipucu). Ayrıca taret düğmesi üstünden sürükleme hatası kapandı.
- **3 yeni özellik:** Laboratuvar (yeni LAB sekmesi, 3 dal, 9 düğüm + 3 kural değiştiren son); Patlayan zombi (8. dalga; barikatta 34 hasar, kalabalıkta vurulursa zincirleme alan hasarı); Koşu sonu ekip konuşması (Öv / Sert konuş / Sessiz kal). Görev havuzuna "patlayan öldür" eklendi.
- **Ölçüm:** Aynı makinede eski/yeni yük testi: çizim çağrısı 252 → 219, yazılım ekranında FPS değişmedi (≈ 21.5; bu ölçüm işlemci render'ına bağlı, gerçek telefonu temsil etmez). Bulut: 25.8 FPS, 220 çağrı, yeni testte 2 uzman taret ve 8 patlama da var. Kalan çağrıların önemli kısmı hasar yazıları (Label).
- **Bot:** Boş kayıtla 4 koşu, hepsi 35. dalgada (7. Dev) düştü, 13–14 kart. Bot altını hep doğru harcıyor ve yeteneği hep basıyor; gerçek oyuncu daha erken düşer. Tüm botların aynı dalgada düşmesi 35. dalgada sert bir duvar var demek, izlenecek.
- **Bilinen sorunlar:** Gerçek telefonda FPS hâlâ ölçülmedi. Patlayanın yanıp sönmesi sadece renk, sesi yok. `menüye dön` ile biten koşuda konuşma ekranı çıkmaz (bilinçli). Ekip konuşması sayıları bizim tahminimiz, denge verisi yok.
- **Sıradaki:** Boss Kraliçe (Havan ile eşleşir), CC0 sprite (Görsel v2), Tehdit Seviyesi.

## 2026-11-05 — Gündüz turu (elle başlatıldı, Gece 1'den birkaç saat sonra)
- **Analizler:** (1) Ekonomi düzeldi ama oyuncunun eylemi yok, altının yatırım yeri yok, keşif raporu kanaat vermiyor. (2) KR'deki büyü + kule ayrımı, FM mentorluk ve gözlemci notu, cezasız günlük hedef eksik.
- **Araştırılanlar:** KR büyü ve kule döngüsü, günlük görev riskleri, FM mentorluk, Kenney CC0 sesleri; ek olarak Laboratuvar ve hava olayı sayılarıyla plana yazıldı.
- **3 geliştirme:** Ses v2 (4 CC0 ses), Mentorluk, Keşif v2 (öneri yıldızı, kısa liste).
- **3 yeni özellik:** Rol aktif yetenekleri, 3 yuvalı taretler, günlük görevler.
- **Bot:** taret ve aktif yetenek kullanan bot 3 koşuda 30–35. dalga. Yüksek geliştirilmiş kayıtla ölçüldü, yeni oyuncu değeri değil.
- **Bilinen sorunlar:** Taret düğmesi görünürken tam üstünden başlayan sürükleme askeri oynatmaz. Gerçek telefonda FPS hâlâ ölçülmedi.
- **Sıradaki:** Laboratuvar, Patlayan zombi, Ses v3.

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
