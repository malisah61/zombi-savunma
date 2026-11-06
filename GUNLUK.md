# Geliştirme Günlüğü

Her gece görevi buraya en üste bir kayıt ekler: ne araştırdı, ne ekledi, ne kaldı, sorunlar.

## 2026-11-06 — Gündüz ek turu 1/3 (Mehmet Ali uçaktayken elle başlatıldı)
- **Analizler:** (1) Tek mod 10–15 dakikalık koşu; kısa oturum yok. Altın koşu bitince sıfırlanıyor, kalıcı yeri yok. Yuva sayısı 2'de sabit. Nöbetçi silahı değiştirilemiyor. Boss'un son %30'u tek düze. Kampanya eğrisi hesaplandı: tek kartla Hayatta Kalma can eğrisi kaldırılamaz, yumuşak eğri + kalıcı güç gerekiyor. (2) Grow Castle kısa savaş + yükselt + tekrar döngüsü, iki modun birbirini yememesi, boss aşamalarında uyarılı saldırı, kilidi açılan hız = hedef.
- **Araştırılanlar:** Grow Castle (wiki açılamadı, sayılar bizim), boss aşama tasarımı, Sur fiyat eğrisi (taslak 33 bin hurdaydı, 6.7 bine çekildi). Fikir Havuzu'na sayılarıyla **Kampanya yıldızları** ve **Kasaba okçuları** eklendi.
- **3 geliştirme:** Güç seviyesi (kampanya altınıyla, +%10 hasar/sv, lider ve nöbetçi); nöbetçiye silah verme (Envanter'de "Sura: Ad", takaslı); boss aşamaları (Dev %66 öfke, %33 işaretli sıçrama; Kraliçe %66 sık doğum, %33 saldırı).
- **3 yeni özellik:** Kampanya modu (kalıcı dalga, tek dalga savaş, 1 kart, ZAFER ekranı, her 10. dalga boss, yenilgide teselli); Sur yükseltmesi (50 seviye, +%8 can/sv, 9/17/25/33. seviyede yeni yuva, menüde büyüyen sur çizimi); x3 hız kilidi (kampanya 10. dalga ya da rekor 10; eski kayıtta x3 seçiliyse açık).
- **Doğrulama (bulut):** derleme ve önizleme başarılı, "SCRIPT ERROR / Parse Error" yok. Yük testi 120 zombi + 6 nöbetçi 26.4 FPS, 244 çağrı (değişmedi). Kampanya önizlemesi 7. dalgayı kazandı, ZAFER ekranı ve ödüller doğru. Ekran görüntüsünde boss aşama yazısı "YARDIM ÇAĞIRDI" ile üst üste bindi; aşama yazısı üst uyarı şeridine taşındı.
- **Kampanya botu (60 savaş, tek kişilik ekip, Lab yok):** 10 savaşta 11. dalga, 20'de 19, 30'da 20 (Kraliçe 10 denemede geçildi), 40'ta 27, 50 ve 60'ta 30. dalga (Dev duvarı, Sur 19, Güç 19). Duvarlar boss dalgalarında, bilerek; nöbetçi ve Lab'lı gerçek oyuncu daha hızlı geçer. 30. dalga duvarı izlenecek.
- **Hayatta Kalma botu:** 35/45 ve 35/44. dalga (Sur ve Güç sıfır olduğu için önceki turla aynı aralık).
- **Bilinen sorunlar:** Kampanyada geçilmiş dalgayı tekrar oynama yok (B4 otomatik tekrarla gelecek). Güç seviyesinin altını yalnız kampanyadan gelir. Gerçek telefonda FPS hâlâ ölçülmedi.
- **Sıradaki (ek tur 2):** §0 Gece C kalanı: A2 zayıf nokta hedefleme, A3 sürü davranışı; Gece D: B4 otomatik savaş + çevrimdışı kazanç, A6 akıllı kart.

## 2026-11-06 — Gece 3
- **Analizler:** (1) Ekip derinliği savaşa hiç çıkmıyor: 8 kişilik ekipten sahada 1 kişi var; dalga içinde doğum tekdüze; kalabalıkta lider + taretler aynı zombiye ateş edip atışların ≈ %45'ini boşa harcıyor; her boss dalgası aynı (Dev). (2) Grow Castle kale yuvaları, Bloons hedefleme modları, aşırı öldürme önleme, L4D yönetmeni, FM maç puanı/form, PvZ Zomboss'un çağırıcı boss dersi.
- **Araştırılanlar:** yukarıdakiler + FM takım uyumu ve başarım/ödül tasarımı; Fikir Havuzu'na sayılarıyla **Takım kimyası** ve **Başarımlar** yazıldı. Bazı kaynak sayfaları (Bloons wiki, SpringRTS) bot korumasıyla açılamadı; formüller bizim tasarımımız, TASARIM §17'de belirtildi.
- **3 geliştirme:** Yönetmen (dalga sistemi: gerilim, zirve/sönme/nefes, kanattan sürpriz, toplam zombi sabit, dalga başı en çok 15 sn mola); Performans v4 (32 Label → tek düğüm `yazilar.gd`); Koşu sonu v3 / FM maç puanı (1–10 puan, koşunun yıldızı, son 5 puan form, puan → moral).
- **3 yeni özellik:** Surdaki ekip (2 nöbetçi yuvası, Ekip'ten "Sura koy", kendi silahıyla %45 verim + dalga başı %4, koşu sonu yarı deneyim + yorgunluk); Ekip yapay zekâsı (rol hedeflemesi, 4 hedef modu, aşırı öldürme önleme lider ve taretlerde de, boşta Mühendis/Doktor onarır); Boss 2 Kraliçe (10/20/30. dalga, geride durup 6 kez 2 koşucu doğurur, sonra saldırır).
- **Ölçüm (bulut, yazılım ekranı):** 120 zombi + 6 nöbetçi: 29.0 FPS, 244 çizim çağrısı (önceki test 120 zombi, nöbetçisiz: 25.8 FPS, 220 çağrı). Yani 6 yeni atıcı ve mermileri eklendiği hâlde yazıların tek düğüme inmesiyle FPS düşmedi.
- **Bot (boş kayıt, bulut, iki tur):** nöbetçisiz 35/40 ve 35/40. dalga; 2 nöbetçiyle 40/38 ve 35/35. Nöbetçiler dengeyi bozmuyor (bot en güçlü kart yolunu bulduğu için fark küçük); 35. dalga duvarı hâlâ sık, izlenecek. Son yük testi: 53 FPS, 262 çağrı (bulut makinesi değişken).
- **Hata düzeltmesi aynı gece:** ilk sürümde Kraliçe geride dururken uzaktan barikata vuruyordu; düzeltildi. Maç puanında lider kart aldığı için nöbetçiler hep düşük çıkıyordu; beklenen pay ağırlıklı yapıldı (lider 2, nöbetçi 1).
- **Bilinen sorunlar:** Gerçek telefonda FPS hâlâ ölçülmedi. Nöbetçi silahı yalnızca kişinin üstündeki silahtır; nöbetçiye silah kuşandırma ekranı yok (Envanter yalnız lidere kuşandırıyor). Yönetmenin zorluk tavanı, zorluk seçimi (§8) gelince bağlanacak. Kraliçe'nin yavruları görev "boss" sayımına girmez (bilinçli).
- **Sıradaki:** §0 Gece B: Sur kalıcı yükseltmesi (yuva 2 → 6), Kampanya modu, altınla seviye; nöbetçiye silah kuşandırma; Takım kimyası.

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
