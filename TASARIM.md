# Zombi Savunma — Tasarım Belgesi

> Bu belge yaşayan bir belgedir. Her gece geliştirme görevi önce burayı okur, araştırma yapar,
> yeni fikirleri **Fikir Havuzu**na ekler, **Yol Haritası**nı günceller, sonra kodlar.

## 1. Oyunun Özü
- **Tür:** 2D zombi dalgası savunması + roguelike yetenek seçimi + kalıcı gelişim.
- **Platform:** Android, dikey ekran, tek parmakla oynanır, çevrimdışı.
- **Görünüm:** Üstten bakış. Üs (barikat) ekranın altında, zombiler yukarıdan dalga dalga iner.
- **Bir oyunun akışı (5–15 dk):**
  1. Kahraman barikatın arkasında; parmakla sağa sola sürüklenir, en yakın zombiye **otomatik ateş** eder.
  2. Zombiler barikata ulaşınca vurur; barikat düşerse oyun biter.
  3. Her dalga sonunda **3 yetenek kartından birini** seçersin (Survivor.io / Archero tarzı).
  4. Dalga aralarında altınla **kule** kurar, barikatı **onarırsın**.
  5. Her 5 dalgada bir **boss** dalgası.
  6. Oyun bitince kazanılan **hurda** ile kalıcı yetenek ağacı ve ekipman geliştirilir.

## 2. Araştırmadan Çıkan Dersler
- **Survivor.io / Archero:** Hızlı erken güç artışı bağımlılık yaratır; ama 10. bölüm 1. bölüm gibi
  hissettirirse oyuncu sıkılır → her bölüme **yeni bir kural/mekanik** gerekir. Yeteneklerin
  birleşip **evrimleşmesi** en güçlü “bir tur daha” kancası. Bitirilen bölümleri zor modda tekrar
  oynamak (Deneme modu) uzun vadeli hedef verir.
- **Kingdom Rush:** Her bölümde **1–2 yeni düşman** tanıt, her biri savunmanın belirli bir zayıflığını
  sınasın (hızlı, zırhlı, iyileştiren, uçan). Güçlü varyantlar geç gelsin. Her güçlü şeyin bir
  **dezavantajı** olsun. İlk boss bilerek kolay olsun. Zor dalgalar arasına **nefes dalgaları** koy.
  Erken dalga çağırana ödül ver (risk/ödül).
- **Kule savunma genel:** Yerleşim gerçek bir karar olmalı; düşmanlar tek tip savunmayı cezalandırmalı;
  kuleler birbirinden net farklı rollerde olmalı (tekli hedef, alan, yavaşlatma, özel düşman).

## 3. Düşmanlar (her biri bir zayıflığı sınar)
| Zombi | Özellik | Sınadığı şey | Karşı hamle |
|---|---|---|---|
| Yürüyen | Yavaş, orta can | — (temel) | her şey |
| Koşucu | Çok hızlı, az can | yavaş ateş | otomatik silah, yavaşlatma |
| Zırhlı | Düşük hasarı yok sayar | zayıf silah spam | keskin nişancı, delici mermi |
| Kusan | Uzaktan barikata asit | sadece yakın savunma | menzilli silah, öncelik hedefleme |
| Patlayan | Barikatta patlar, alan hasarı | onarım ekonomisi | onu erken vur |
| Kalkanlı | Önden mermi engeller | düz atış | sekme, alan hasarı, alev |
| Çağırıcı | Yanına zombi doğurur | tek hedef odak | öncelikli hedef |
| Kuzgun sürüsü | Uçar, barikatı aşar | yer kuleleri | hava savunması, elektrik |
| **Boss: Dev** | Çok can, yavaş, barikatı sarsar | ham hasar | tüm güç |
| **Boss: Kraliçe** | Sürekli koşucu doğurur | alan kontrolü | alev, mayın |

## 4. Kahramanlar (her biri farklı oynanır)
- **Asker:** dengeli tüfek; aktif yetenek: el bombası.
- **Avcı:** keskin nişancı, kritik vuruş, delip geçen mermi; aktif: ölümcül nişan.
- **Mühendis:** kuleler ucuz ve güçlü, barikat kendini onarır; aktif: taret kur.
- **Piroman:** alev silahı, yanma hasarı; aktif: alev duvarı.
- **Doktor:** zehir dartları, barikatı iyileştirir; aktif: aşı (zombileri yavaşlatır).
Kahramanlar bölüm bitirerek veya hurdayla açılır.

## 5. Koşu İçi Yetenek Kartları (roguelike)
Örnekler: Ateş hızı +, Çift namlu, Delici mermi, Sekme, Kritik vuruş, Yanma, Zehir, Zincir elektrik,
Mıknatıs (altın çekme), Barikat zırhı, Diken (vurana hasar), Dönen bıçaklar, Drone yardımcı.
**Evrim:** belirli iki kart en üst seviyeye gelince birleşir (ör. Çift namlu + Ateş hızı → Minigun;
Yanma + Patlama → Napalm).

## 6. Kuleler (barikat üzerindeki yuvalara)
Makineli taret (tekli), Havan (alan), Alev kulesi (yanma, kısa menzil), Tesla (zincir, uçanlara iyi),
Dikenli tel (yavaşlatma), Onarım istasyonu (barikatı iyileştirir). Her kule 3 seviye, 3. seviyede
iki dallı uzmanlık (Kingdom Rush gibi).

## 7. Kalıcı Gelişim
- **Yetenek ağacı (Laboratuvar):** 3 dal — Saldırı / Savunma / Ekonomi. Hurda ile açılır.
- **Envanter ve ekipman:** Silah, zırh, aksesuar, 2 tılsım yuvası. Nadirlik: gri → yeşil → mavi → mor → altın.
  Aynı 3 eşya birleşince bir üst nadirliğe çıkar.
- **Başarımlar ve günlük görevler.**

## 7b. Laboratuvar (Gece 2'de uygulandı)
3 dal × 3 düğüm (5 seviye) + dal sonu. Fiyat 40·1.5^sv (40/60/90/135/203, düğüm başı 528), dal sonu 500 hurda ve dalda 6 seviye ister. Toplam ≈ 6250 hurda (12. dalga koşusu ≈ 190 hurda, yani ≈ 33 koşu).
- **Saldırı:** Hasar +%3, Ateş hızı +%2, Kritik +%1.5; son: Sert Açılış (koşu kartla başlar).
- **Savunma:** Barikat +%4, Onarım +%6, Asit/patlama hasarı −%4; son: İkinci Şans (koşu başına bir kez %25 canla kalkar).
- **Ekonomi:** Başlangıç +12 altın, Hurda +%4, Altın +%3; son: Hazır Cephanelik (2 ücretsiz yeniden çekme).
- En üstte toplam DPS ≈ ×1.3. Karar: saf güç yerine "küçük yüzde + kural değiştiren son" (Hades ortası).

## 8. Bölümler ve Zorluk
- Bölümler: Kasaba → Orman → Hastane → Askeri Üs → Şehir Merkezi. Her bölüm yeni bir zombi ve yeni bir
  harita kuralı getirir (ör. Orman: sis, görüş kısa; Hastane: gece, karanlık).
- Zorluk: Kolay / Normal / Zor / Kâbus. Bitirilen bölüm üst zorlukta tekrar oynanabilir, özel ödül verir.
- **Sonsuz mod:** tüm bölümler bitince açılır, rekor tablosu.
- Ölçekleme taslağı: dalga n'de zombi canı ≈ taban × (1 + 0.12·n), sayı ≈ 6 + 2·n; her 5. dalga boss,
  boss sonrası bir nefes dalgası.

## 9. Görsel ve Ses
- Ücretsiz (tercihen CC0) kaynaklar GitHub üzerinden ya da GitHub Actions ile indirilir; lisans ve
  kaynak `assets/KAYNAKLAR.md`'ye yazılır.
- Bulunamayan şeyler kodla çizilir / sesler kodla üretilir.

## 0. Oyuncu İstekleri (önce bunlar yapılır)
Mehmet Ali'nin istekleri. Gece görevi bunları bitirmeden başka işe geçmez; bitenleri silmez, [x] yapar.

### ★ (2026-11-06) EN ÖNCELİKLİ: Yapay zekâ + Grow Castle tarzı + hızlandırma
Mehmet Ali: "Zombiye yapay zekâ ekle, böyle özellikleri düşün, oyunu hızlandırma, Grow Castle gibi olsa daha güzel olur."
Gece görevi bu bloğu **yukarıdan aşağı** sırayla yapar (her gece 3 geliştirme + 3 yeni özellik kuralına bu maddelerden
seçerek). Hepsi internetsiz, ücretsiz, telefonun içinde çalışan oyun yapay zekâsıdır (dil modeli değil).
Mevcut "koşu" modu (roguelike) **silinmez**; Grow Castle tarzı yapı onun yanına eklenir.

- [x] **Hız x1/x2/x3** (2026-11-06, gündüz): HUD'da duraklatmanın yanında, seçim kaydedilir; boss ağır çekimi hıza
  göre ölçeklenir; mermi çarpışması doğru parçası testine çevrildi (x3'te zombinin içinden geçmesin).

**Gece A (ilk): surdaki ekip + ekip yapay zekâsı + yönetmen**
- [x] **B1 Surdaki ekip (yeni)** (2026-11-06, Gece 3 — 2 yuva; bkz. §16c): Barikatın üstünde nöbetçi yuvaları (başta 2, Sur seviyesiyle 6'ya kadar). Ekip
  sekmesinden hayatta kalanlar yuvalara konur; koşuda hepsi aynı anda kendi silahı, rolü ve özellikleriyle ateş eder.
  Parmakla yönettiğin asker "lider" olarak kalır. Yuvadaki kişi de koşu sonunda deneyim/gelişim alır (FM ↔ savaş bağı).
  Performans: nöbetçiler kahraman gibi pişmiş doku + havuzdaki mermiler; 6 nöbetçi × ateş hızı ile çizim çağrısı ölç.
- [x] **A5 Ekip yapay zekâsı (yeni)** (2026-11-06, Gece 3 — Doktor boşta onarır, moral etkisi yok; bkz. §16c): Her nöbetçi rolüne göre hedef seçer: Avcı → boss/zırhlı/kusan, Pompalı/Asker →
  barikata en yakın, Mühendis → boşken barikat onarır (saniyede %0.3), Doktor → yorgunluk/moral. **Aşırı öldürme
  önleme:** her zombiye "beklenen hasar" yazılır; beklenen ≥ kalan can ise diğerleri başka hedef seçer (Bloons/KR
  hedefleme modlarından esinli). Her nöbetçiye ayarlanabilir hedef modu: En yakın / En güçlü / Boss önce.
- [x] **A1 Yönetmen (geliştirme: dalga sistemi)** (2026-11-06, Gece 3 — zorluk tavanı §8 gelince bağlanacak; bkz. §3d): Left 4 Dead'in Yapay Zekâ Yönetmeni gibi "gerilim" ölçer
  (barikat hasar hızı + ekrandaki zombi ağırlığı + son 5 sn'de kaçan zombiler). Döngü: Yükselme → Zirve (3–5 sn) →
  Sönme → Nefes (4–8 sn). Gerilim düşükken doğumu %30'a kadar hızlandırır ya da kanattan 3–5 koşucu sürprizi
  gönderir; yüksekken nefes aldırır. **Adil kural:** dalganın toplam zombisi değişmez, sadece zamanlama ve yön değişir.
  Zorluk seviyesi (§8) yönetmenin tavanını belirler.

**Gece B: Grow Castle kalesi ve kampanya**
- [x] **B2 Sur (kale) kalıcı yükseltme** (2026-11-06, gündüz ek turu 1 — fiyat 30·1.10^(sv−1) olarak ucuzlatıldı; bkz. §16d): Sur seviyesi 1→50; can +%8/sv; her 8 seviyede +1 nöbetçi yuvası;
  maliyet ≈ 40·1.16^(sv−1) hurda. Menüde görsel olarak büyüyen barikat.
- [x] **B3 Kampanya modu (Grow Castle dalga ilerlemesi)** (2026-11-06, gündüz ek turu 1; bkz. §16d): Menüde iki mod: "Hayatta Kalma" (bugünkü koşu) ve
  "Kampanya". Kampanyada dalga sayacı kalıcıdır; her SAVAŞ tek dalga; kazanınca sıradaki açılır, kaybedince aynı
  dalga tekrar (ceza yok); her 10. dalga boss; dalga başına altın + hurda. Kartlar kampanyada kalıcı değil, dalga
  başı 1 kart seçilir.
- [x] **B5 Altınla seviye (geliştirme: ekip)** (2026-11-06, gündüz ek turu 1 — altın = kalıcı kampanya altını; bkz. §16d): Grow Castle'daki kahraman yükseltmesi gibi her hayatta kalanın
  "Güç seviyesi" altınla artar (hasar +%10/sv, maliyet 50·1.18^sv). FM özellikleri (antrenman) ayrı eksen kalır.

**Gece C: akıllı zombiler**
- [x] **A2 Zayıf nokta hedefleme** (2026-11-07, Gece 4 — gedik "üs canı" yerine yanlara ×1.5 taşan hasar olarak yapıldı; bkz. §16e): Barikat 6 bölüme ayrılır, her bölümün canı ayrı ve görünür. Zombiler en zayıf
  bölüme yönelir; bölüm kırılırsa zombi oradan geçip "üs canı"na vurur. Oyuncu kararı: hangi bölüme dokunup onaracak.
- [x] **A3 Sürü davranışı** (2026-11-07, Gece 4 — ayrılma + zırhlı kalkanı + kusan kaçışı; "askerin tersinden kanat" yönetmenin kanat sürprizinde zaten var; bkz. §16e): hafif boids (ayrılma + hizalanma, komşu araması ızgara ile, O(n)); koşucular askerin
  baktığı tarafın tersinden kanat açar; kusan menzilde kalır, hedef alınınca yana kayar; zırhlılar önde sıra olur,
  arkalarına koşucular saklanır (zırhlı ölünce dağılırlar).
- [x] **A4 Boss aşamaları** (2026-11-06, gündüz ek turu 1; bkz. §16d): can %66 / %33'te davranış değişir (hızlanma, çağırma, barikata sıçrama + uyarı işareti).

**Gece D: rahat oyun (Grow Castle hissi)**
- [x] **B4 Otomatik savaş + çevrimdışı kazanç** (2026-11-07, Gece 4 — OTO geçilmiş dalgalarda, TEKRAR ile altın kasma; çevrimdışı kazanç Hurda Madeni'nden; Çiftlik sonra; bkz. §16e): Kampanyada geçilmiş dalgayı otomatik tekrarla (ekip yapay zekâsıyla,
  lider de otomatik nişan alır). Kasaba binaları (Hurda Madeni, Çiftlik) saatte üretir, en fazla 8 saat birikir;
  açılışta "Sen yokken: +X hurda" ekranı. Saat hilesine karşı: geri giden saat → 0 kazanç.
- [x] **A6 Akıllı otomatik kart seçimi** (2026-11-07, Gece 4 — elle oynarken de "★ ÖNERİ" gösterir; bkz. §16e): oto modda kartı yapay zekâ seçer: karşılaşılan zombi karışımına göre
  (zırhlı oranı yüksek → Zırh Delici), evrim yoluna ve ekonomiye göre puanlar. Oyuncu kapatabilir.
- [x] **B6 Kasaba sekmesi:** Atölye, Antrenman Sahası, Revir, Gözcü Kulesi, Maden (§16'daki tesislerle birleşir).
  (2026-11-07, Gece 4: ilk bina **Hurda Madeni** OYNA sekmesinde "KASABA" kartı olarak yapıldı; ayrı sekme ve diğer binalar sırada.)
  (2026-11-08, Gece 5: ayrı **KASABA** sekmesi; Maden + **Çiftlik** (çevrimdışı kampanya altını) + **Antrenman Sahası**, **Revir**, **Atölye**; bkz. §16f. Gözcü Kulesi = Keşif v3 ile birlikte yol haritasında.)
- [x] **B7 Hız kilitleri** (2026-11-06, gündüz ek turu 1 — Hayatta Kalma rekoru 10 da açar; eski kayıtta x3 seçiliyse açık kalır): x2 baştan açık, x3 kampanyada 10. dalgayı geçince açılır (hedef duygusu).
- [x] (2026-11-05) Telefon performansı ve görüntü kalitesi: kasma, hata, donma olmasın. → v1 yapıldı (bkz. §12).
- [x] (2026-11-05) Ana menü. → Oyna / Ekip / Envanter / Keşif / Ayarlar.
- [x] (2026-11-05) FM tarzı gelişim, scout (keşif), envanter, silah, RPG özellikleri. → v1 yapıldı (bkz. §13–15).
- [ ] (2026-11-05, sürekli) Var olan özellikleri **eksiltmeden** geliştir, kaliteli kod yaz.
- [ ] (2026-11-05, sürekli) Her gece oyunda **henüz olmayan** özellikleri araştır, nasıl yapılacağını en ince
  ayrıntısına kadar araştırıp (oyun tasarımı + Godot tekniği) plana yaz ve ekle. Sadece **ücretsiz** kaynak kullan.
- [ ] (2026-11-05, sürekli) **Her gece kuralı:** var olan özelliklerden **3'ünü geliştir** + **3 yeni özellik ekle**.
  Kodlamadan önce oyun mekaniği üzerine **2 derinlemesine oyun analizi** yap, sonuçlarını `ANALIZ.md`'ye yaz
  ve o geceki seçimleri bu analizlere göre yap.
- [ ] (2026-11-05, sürekli) FM tarzı derinliği büyüt: personel, kişilik, sakatlık, tesisler, kısa liste… (bkz. §16).

## 10. Fikir Havuzu (her gece büyür)
- **Yeni araştırılan (Gece 5):**
  - **Kalkanlı zombi (PvZ Screen Door Zombie):** PvZ'de kapı düz atışı tutar, kapı kırılınca zombi normal yürür; lobut/alan hasarı kapıyı aşar. Bizde: 10. dalgadan (kampanyada 12.) çıkar, oran %6 + %1·(n−10), en çok %12. Can 34, hız 46, hasar 8; önden gelen mermiye karşı **kalkan canı 60 × can çarpanı** (kalkan bitince normal zombi, kalkan kırılma parçacığı). Alan hasarı (havan, el bombası, patlayan, yanma) ve **yandan** gelen mermi (yön vektörünün x bileşeni |x| > 0.5: kenardaki nöbetçiler 0.07/0.93 yuvaları) kalkanı aşar → sur yuvalarının konumu ve Havan anlam kazanır. Delici mermi kalkanda 1 delme hakkı harcar. Teknik: `zombi.kalkan_can`; `oyun.isabet`'te mermi yönü parametre olarak gelir; atlasta kalkanlı kare (ayrı tür bölgesi) — yeni çizim çağrısı yok. A6 akıllı kart: kalkanlı oranı → Havan/Yanma +puan.
  - **Komutan Bilgisi (BTD6 Monkey Knowledge):** BTD6'da oyuncu seviyesi başına 1 bilgi puanı, puan seçmeli kalıcı ağaca harcanır (hurdadan ayrı para birimi = seçim, satın alma değil). Bizde: hesap seviyesi = toplam kazanılan XP (koşu dalga×10 + kampanya dalga×4); seviye fiyatı 200·1.12^sv XP; her seviye 1 Bilgi Puanı. 4 dal × 5 düğüm, her düğüm 1–3 puan: "Taretler +%5 menzil", "Nöbetçi verimi +%3 (0.45 → en çok 0.54)", "OTO kart seçimi 2 kart daha görür", "Gedik taşması ×1.3 → ×1.2", "Boss ganimeti +1 nadirlik şansı %10". Puanlar istenince ücretsiz sıfırlanır (BTD6 gibi deneme özgürlüğü). Teknik: `profil.bilgi` {xp, sv, harcanan: {}}; menüde LAB sekmesinin alt bölümü (yeni sekme yok).
- **Uygulandı (Gece 5):** Tehdit Seviyesi, Başarımlar (Gece 2–3 taslaklarından; sayılar §16f'de).
- **Yeni araştırılan (Gece 4):**
  - **Bölüm tuzakları (Orcs Must Die tuzakları + A2 bölümleri):** her barikat bölümünün önüne kampanya altınıyla tek tuzak: Çivi (önünden geçene saniyede 4 × can çarpanı hasar), Katran (önündeki zombiler −%35 hız, zırhlıya etkisi yarım), Patlayıcı Varil (bölüm ilk kez %50'ye inince 120 px alan, dalga başına 1). Tuzak seviyesi 1–10, fiyat 60·1.25^sv altın. Gedik açılan bölümün tuzağı dalga sonuna dek kapanır (onarım değerli). Teknik: barikat bölüm sayısı kadar sabit dizi, zombi `_process`'inde y > barikat_y − 140 iken tek bölüm sorgusu; çizim barikat dokusuna eklenen dikdörtgenler (yeni çizim çağrısı yok).
  - **Günlük meydan okuma (Slay the Spire Daily Climb):** her gün aynı tohumlu (tarih → `seed`) Hayatta Kalma koşusu + 2 rastgele kural (ör. "kartlar 2 seçenekli", "zombiler +%20 hızlı ama +%50 altın", "yalnız Pompalı"). Günde 1 ödüllü deneme; ödül ulaşılan dalga × 8 hurda + 10. dalgada Nadir+ silah. Kendi en iyi 7 günlük sonucu menüde liste (çevrimdışı, lider tablosu yok). Teknik: `seed(hash(tarih))` yalnız dalga bileşimi ve kart çekimi için ayrı `RandomNumberGenerator` (görsel rastgelelik etkilenmez), `profil.gunluk_meydan` {tarih, en_iyi, deneme}.
- **Yeni araştırılan (gündüz ek turu 1):**
  - **Kampanya yıldızları (Kingdom Rush gibi):** her kampanya dalgasına 1–3 yıldız: barikat %100 → 3, %50+ → 2, geçti → 1. Toplam yıldız eşiklerinde (30/60/100) kalıcı ödül (Destansı silah, +1 Lab düğüm sınırı). Geçilmiş dalgayı yeniden oynamaya sebep verir ve B4 otomatik tekrarla birleşir: oto tekrar yalnız 3 yıldızlı dalgalarda açılır. Teknik: `kampanya.yildiz` sözlüğü (dalga → 0–3), zafer ekranında yıldız çizimi.
  - **Kasaba okçuları (Grow Castle "town archers"):** surun önünde nöbetçi olmayan, altınla seviye alan tek bir okçu birliği: 3 okçu, her biri 4 hasar × 1.2 atış/sn, seviye başı +%12 (fiyat 80·1.2^sv altın). Ekibi olmayan yeni oyuncuya erken güç verir, ekip büyüyünce önemi azalır. Teknik: nöbetçi düğüm havuzu kullanılır (yuva dışı), ayrı kaynak no −3.
- **Yeni araştırılan (Gece 3):**
  - **Takım kimyası (FM "team cohesion" / "tight-knit"):** FM'de birlikte oynayan ve aynı dili konuşan oyuncuların uyumu zamanla artar, kadroya çok kişi birden katılınca düşer. Bizde: aynı koşuda birlikte (lider + sur) oynayan her çift için `kimya[uid_a|uid_b]` +1 (en çok 20). Sur ekibinin ortalama kimyası k ise nöbetçi ateş hızı +%0.5·k (en çok +%10). Yeni gelen kişi 0'dan başlar → rotasyon ile kimya arasında gerçek karar. Kişilik: Lider ruhlu kimyayı ×1.5 artırır, Asabi ×0.5. Ekip kartında "Uyum: Ali ile iyi" satırı. Teknik: profil sözlüğü, VARSAYILAN'a `kimya: {}`; koşu sonu tek döngü.
  - **Başarımlar (kalıcı hedef zinciri):** 3 kademeli (bronz/gümüş/altın) 12 başarım: "Dev avcısı 1/5/20", "Kraliçe 1/5/15", "Dalga 15/25/40", "Evrim 1/5/15", "Ekip 3/5/8 kişi", "Sur 1/2 dolu", "Taret uzmanlığı 1/10/30", "Yük: 1000/10000/50000 zombi"… Ödül kademe başına 40/100/250 hurda + profil rozeti. Mobil araştırmalarına göre ödül hemen ve görünür verilmeli, kademeler hedefi her zaman "bir sonraki"ne taşır; angarya olmaması için hepsi normal oynarken dolar. Teknik: `Veri.BASARIMLAR` tablosu, `profil.basarim_ilerlet(id, deger)` (gorev_ilerlet ile aynı yerden), menüde OYNA sekmesinde "en yakın başarım" satırı.
- **Yeni araştırılan (Gece 2):**
  - **Tehdit Seviyesi (Hades Pact of Punishment gibi):** koşu öncesi 4 şalter, her biri 1–3 kademe, her kademe 1–2 tehdit puanı: Kalabalık (+%20 zombi), Dişli (+%20 zombi hasarı), Kalın Deri (+%15 can), Karaborsa (+%40 onarım/taret fiyatı). Ödül: puan başına hurda +%10; yeni en yüksek puan ilk kez geçilince tek seferlik Destansı silah. Hades'in dersi: ödül bir kerelik yeni tepe için verilir, puanı birer birer artırmak ödüllendirilir. Teknik: `profil.tehdit` sözlüğü, `_sonraki_dalga` ve `kur` çarpanları, OYNA sekmesinde şalter satırı. Yeni oyuncu için 15. dalgayı geçince açılsın.
  - **Erken dalga çağırma (Kingdom Rush):** kalan doğacak zombi sıfırsa barikatın üstünde "ERKEN ÇAĞIR" düğmesi: sahadaki zombi başına 2 altın + aktif yetenek bekleme −3 sn. Sahada kalanlar kalır, kart seçimi kısa tutulur. Risk: iki dalga üst üste biner. Kart ekranı kalanlar varken oyunu durdurmalı (şu an `durum=KART` zombileri durdurmuyor, önce tree pause gerekir).
  - **Boss 2 Kraliçe:** 10, 20, 30. dalgada Dev yerine: 900 can, 22 hız, durur ve 4 sn'de 2 koşucu doğurur; öldürülünce 60 altın. Alan hasarını ödüllendirir, Havan ile eşleşir.

- Gündüz/gece döngüsü: gece zombiler güçlü, gündüz kaynak toplama.
- Kurtarılan hayatta kalanlar üste yardımcı olur.
- Hava durumu: yağmur alevi zayıflatır, sis menzili düşürür.
- FM'deki "maç sonrası basın toplantısı" gibi: koşu sonrası ekibe konuşma (moral +/− riskli seçim).
- Hayatta kalanlar arası ilişkiler: iyi anlaşanlar birlikte sahadaysa bonus (takım kimyası).
- Transfer pazarı benzeri: diğer kampların hayatta kalanlarıyla takas (silah ↔ kişi).
- Silah modları: dürbün (menzil), uzatılmış şarjör (ateş hızı), susturucu (kritik).
- Efsanevi silahların benzersiz özelliği (ör. her 10. mermi zincir elektrik).

- **Yeni araştırılan (Gece 1):**
  - **Kule yuvaları (altının 3. harcama yeri):** barikatta 3 yuva; taret 60 altın, 8 hasar/0.6 sn, 3 seviye (+%50, fiyat ×1.6). Kingdom Rush'ta oyuncu parayı konuma harcar; kararı "şimdi onar mı kule mi" yapar. Teknik: yuva başına 1 Node2D, ortak mermi havuzu.
  - **Rol aktif yetenekleri:** sağ altta 25 sn bekleme süreli düğme. Asker el bombası (150 px yarıçap, hasar×6), Avcı ölümcül nişan (5 sn kritik %100), Mühendis acil onarım (%30), Doktor aşı (6 sn zombiler −%40 hız). Oyuncunun koşu içi becerisini artırır (İzleme sorununa ilaç).
  - **Günlük görevler:** 3 görev, gece yarısı yenilenir (ör. "10 zırhlı öldür: 30 hurda"); `Time.get_date_string_from_system()` ile sıfırlama.

## 11. Yol Haritası
(Gece görevi her çalışmada önce Oyuncu İstekleri'ni, sonra en üstteki yapılmamış maddeleri alır.)
- [x] **Gün 0:** Temel oyun: barikat, kahraman, otomatik ateş, yürüyen + koşucu zombi, dalgalar, can/altın, bitiş ekranı.
- [x] Dalga sonu 3 kartlık yetenek seçimi (ilk 8 kart).
- [x] Ana menü, kalıcı profil (JSON + yedek + sürüm göçü), ayarlar, duraklatma.
- [x] FM tarzı ekip v1, keşif v1, silah envanteri v1 (nadirlik, ek özellik, geliştir, birleştir, sat, kuşan).
- [x] Performans v1: nesne havuzları, güvenli zombi silme, kalite ayarı, FPS sınırı, kısmi yeniden çizim.
- [x] (Gece 1) Zırhlı ve kusan zombi; ilk boss (Dev). Boss ganimeti: garanti Ender+ silah.
- [ ] Görsel kalite v2: CC0 üstten görünüm karakter/zombi sprite'ları ve yürüme animasyon kareleri
  (GitHub'da CC0 paket ara; yoksa Actions ile OpenGameArt/Kenney'den indir), kan/patlama efektleri.
- [x] (Gündüz turu) Ses v2 ilk parça: Kenney CC0 para, kırılma, patlama, yerleştirme sesleri.
- [ ] Ses v3: gerçek silah ve zombi sesleri, arka plan müziği (Kenney kitlerindeki blaster sesleri bilim kurgu olduğu için alınmadı).
- [x] (Gece 1) Performans v2: zombi/leke atlası, zemin ve barikat dokuya pişirildi; uyarlamalı kalite; 120 zombilik yük testi karesi.
- [x] (Gece 2) Performans v3: kahraman dokuya pişirildi, 52 CPUParticles2D düğümü tek düğümde toplandı (yük testi 252 → 219 çizim çağrısı).
- [x] (Gece 3) Performans v4 ilk parça: hasar yazıları 32 Label → tek düğüm (`yazilar.gd`, sabit dizi, yazı yoksa çizim yok).
- [ ] Performans v5: barikat tahtalarını sadeleştir, asit dairelerini dikdörtgene çevir, nöbetçi mermilerini ölç.
- [x] (Gece 1) FM v2 (bkz. §16): kişilik, sakatlık ve yorgunluk.
- [x] (Gündüz turu) Mentorluk: 28+ yaş ve Liderlik 12+ kişi, 25 yaş altı gence bağlanır; gelişim +%20, koşu başına %3 kişilik geçişi.
- [x] (Gece 2) FM v3 ilk parça: koşu sonu ekip konuşması (Öv / Sert konuş / Sessiz kal), sonuç beklenti ve kişiliğe bağlı, tekrar yarım etki.
- [x] (Gece 3) FM maç puanı ve form: lider + nöbetçilere 1–10 puan, koşunun yıldızı, son 5 puan form, puan → moral (bkz. §16c).
- [ ] FM v3 kalanı: personel, tesisler, takım kimyası (Fikir Havuzu, Gece 3).
- [x] (Gece 5) Başarımlar: 12 × Bronz/Gümüş/Altın, KASABA sekmesinde Onur Panosu (bkz. §16f).
- [x] (Gündüz turu) Keşif v2 ilk parça: öneri yıldızı (3 + (değer − ekip en iyi)/6, bilgi azsa ±1.5 yanılır) ve kısa liste (raporu korur).
- [ ] Keşif v3: gözlemci personeli (Yetenek / Potansiyel Değerlendirme).
- [ ] Envanter v2: zırh + aksesuar yuvası, silah modları, set bonusları, kötü şans koruması.
- [x] (Gece 2) Patlayan zombi: barikatta 34 hasar, yolda vurulursa çevresini patlatır (bkz. §3b).
- [ ] Sıradaki zombiler: Kalkanlı (önden mermi keser), Çağırıcı (boss olmayan kaynak).
- [x] (Gece 3) Boss 2: Kraliçe (10, 20, 30… dalga; Dev 5, 15, 25…; bkz. §3b).
- [x] (Gündüz turu) Kule yuvaları: 3 yuva, taret 60/96/154 altın, 8×1.5^(sv−1)×(1+0.05·dalga) hasar, 0.6 sn, menzil 520; Mühendis +%30 güç, %20 ucuz.
- [x] (Gece 2) Kule v2: 3. seviyeden sonra 240 altına iki dal: Havan (45×güç alan, 105 px, 2.6 sn, zırhı aşar), Ağır Taret (43×güç, 1.2 sn, zırh yok sayar, 1 delme). Seçim oyunu durdurur, Vazgeç var.
- [ ] Kule v3: alev kulesi, onarım istasyonu.
- [x] (Gündüz ek turu 1) §0 Gece B: Kampanya, Sur, Güç seviyesi; A4 boss aşamaları; B7 x3 kilidi; nöbetçiye silah verme.
- [x] (Gece 4) §0 Gece C (A2 zayıf nokta, A3 sürü), Gece D'den B4 otomatik savaş + çevrimdışı kazanç, A6 akıllı kart, B6'nın ilk binası (Hurda Madeni); Kampanya v2 (yıldız, tekrar, zafer ekranında yükseltme).
- [x] (Gece 5) B6 Kasaba sekmesi (Çiftlik, Antrenman Sahası, Revir, Atölye), Başarımlar, Tehdit Seviyesi; Barikat v3 (gedik ×1.3, HUD bölüm şeridi), Kampanya v3 (OTO TEKRAR), Menü v2 (modlar en üstte).
- [ ] **Sıradaki öncelik (Gece 5 sonrası):** 1) Bölüm tuzakları (Fikir Havuzu, Gece 4) — gedik dengesiyle birlikte; 2) Görsel kalite v2 (CC0 sprite); 3) Günlük meydan okuma; 4) Kalkanlı zombi (Fikir Havuzu, Gece 5); 5) Keşif v3 + Gözcü Kulesi; 6) Komutan Bilgisi (Fikir Havuzu, Gece 5); 7) Erken dalga çağırma.
- [x] (Gece 2) Laboratuvar: bkz. §7b.
- [x] (Gündüz turu) Rol aktif yetenekleri: Asker el bombası (170 px, 8×hasar+25, zırhı aşar, 22 sn), Avcı ölümcül nişan (5 sn, 25 sn), Mühendis acil onarım (%30, 30 sn), Doktor aşı (6 sn %40 yavaş, 28 sn).
- [x] (Gece 5) Tesisler: Atölye (silah geliştirme indirimi), Antrenman sahası (gelişim +), Revir (sakatlık süresi −).
- [ ] Bölümler ve zorluk seçimi; sonsuz mod.
- [x] (Gündüz turu) Günlük görevler: 3 görev, gece yarısı yenilenir, biten ödül kaybolmaz, üçü alınınca bonus Nadir+ silah.
- [x] (Gece 2) Koşu sonu ekranı v2: barikatı en çok yiyen tür + öneri, sıradaki Laboratuvar hedefi; ilk 3 koşuda dalga dalga öğretici ipucu.
- [x] (Gece 5) Tehdit Seviyesi (Fikir Havuzu, Gece 2; bkz. §16f).
- [ ] Erken dalga çağırma (Fikir Havuzu, Gece 2).
- [x] Başarımlar. (Gece 5)
- [ ] Bölüm 2: Orman.

## 3b. Zombi sayıları (Gece 1'de uygulandı)
| Tür | Can | Hız | Hasar | Altın | Özel | İlk dalga |
|---|---|---|---|---|---|---|
| Yürüyen | 30 | 52 | 6 | 2 | — | 1 |
| Koşucu | 15 | 135 | 4 | 3 | oran %15+3·n, en çok %45 | 3 |
| Zırhlı | 46 | 40 | 9 | 5 | zırh 4 + 0.35·dalga; oran %10+1.5·(n−4), en çok %25 | 4 |
| Kusan | 26 | 44 | 9 | 5 | 330 px'te durur, 2.8 sn'de bir asit; öncelik +260; oran %8+1·(n−6), en çok %16 | 6 |
| Patlayan | 20 | 78 | 34 | 6 | barikatta patlar (altın yok); yolda vurulursa 130 px, 40×can çarpanı alan hasarı; öncelik +200; son 260 px yanıp söner; oran %6+1·(n−8), en çok %14 | 8 |
| Kraliçe (boss) | 520 | 22 | 26 | 50 | barikattan 420 px geride durur, 4 sn'de 2 koşucu (6 kez = 12), sonra yürüyüp Dev gibi işaretli vurur; ölünce bekleyen yavrular iptal; güç sırası Dev ile ortak (dalga/5) | 10, 20, 30… |
| Dev (boss) | 480 | 27 | 32 | 40 | zırh 2; 1.3 sn işaretli vuruş; %50 canda 2+2k koşucu; her k. Dev can ×(1+0.6(k−1)), hasar ×(1+0.35(k−1)) | 5, 10, 15… |
- **Zırh formülü:** son hasar = max(hasar − zırh, hasar × 0.2). Düz çıkarma bilerek seçildi: Makineli (5.5) zırha çok takılır, Keskin Nişancı (34) neredeyse etkilenmez;
  böylece silah ve kart seçimi anlam kazanır. Zırh Delici kartı 4 puan siler, Titanyum evrimi tümünü.
- **Can eğrisi:** çarpan = 1 + 0.12(n−1) + 0.03·max(0, n−15)², 25. dalgadan sonra ×1.08^(n−25). Hasar çarpanı 1 + 0.02n.
- **Dalga ritmi:** boss dalgasında normal sayı yarıya iner + n koşucu (yoğun saldırı korunur) + Dev; boss sonrası dalga %60 (nefes).
- **Ekonomi:** onarım fiyatı her kullanımda +5 altın; yeniden çekme 15, +10 artar.

## 3d. Yönetmen (Gece 3'te uygulandı)
- **Gerilim (0–100)** = hasar gerilimi + ekran gerilimi. Hasar: barikatın kaybettiği can oranı × 250 (canın %10'u → +25), saniyede 8 söner.
  Ekran: saniyede 4 kez Σ min(can / (30 × can çarpanı), 6) × (y / barikat_y)² × 4. Yani barikata yakın, kalın zombiler sayılır.
- **Evreler:** Yükselme (gerilim < 25 ise doğum ×1.3) → gerilim ≥ 70: Zirve (3–5 sn, normal) → Sönme (doğum durur, gerilim < 40 ya da 6 sn) → Nefes (4–8 sn, doğum durur) → Yükselme.
  Bir dalgada toplam durma en çok 15 sn (dalga uzayıp sıkmasın).
- **Kanat sürprizi:** Yükselmede gerilim 4 sn boyunca < 15 ise (dalga ≥ 4, en az 3 zombi bekliyorsa) dalganın sıradaki 4 zombisi (önce koşucular) askerin uzak kanadından birlikte gelir, "KANATTAN GELİYORLAR!" yazısı çıkar. Dalga başına bir kez.
- **Adil kural:** dalga listesi hiç büyümez; yalnızca zamanlama ve yön değişir. Önizlemede evre geçişleri `YONETMEN` satırıyla kayda yazılır.

## 3c. Kart evrimleri (Gece 1'de uygulandı)
Ana kart en üst seviye + eş kart gereken seviye → sonraki kart ekranında altın evrim kartı (Survivor.io: silah 5. seviye + eş destek):
Minigun (Seri Ateş 5 + Çift Namlu 2), Napalm (Yanıcı Mermi 3 + Ağır Mermi 3), Titanyum Çekirdek (Delici Mermi 3 + Zırh Delici 2),
Diken Kalesi (Sağlam Barikat 5 + Dikenli Tel 2). Kartlar bitince Altın Kesesi ve Tam Onarım dolgu kartları çıkar.

## 12. Performans ve Görüntü Kalitesi Kuralları (uygulandı / uyulacak)
- Oyun sırasında **düğüm oluşturup silme yok**: mermi, zombi, hasar yazısı, parçacık, kan lekesi havuzdan gelir.
- Diziyi dolaşırken eleman silinmez: ölen zombi `olu` olarak işaretlenir, kare sonunda listeden süzülür.
- Değişmeyen şey her kare yeniden çizilmez (barikat yalnızca can/sarsıntı değişince çizilir; zemin bir kez).
- Ayarlar: Grafik (Düşük: kan izi/parçacık yok, sadece önemli yazılar · Orta · Yüksek), 30/60 FPS, ses,
  titreşim, FPS göstergesi. Telefon arka plana alınınca oyun duraklar, FPS 5'e iner, profil kaydedilir.
- Godot: GL Compatibility; GPUParticles değil **CPUParticles2D** (Compatibility'de GPU parçacıklar çalışmaz);
  ETC2/ASTC doku sıkıştırma açık; `Input.set_use_accumulated_input(false)` (dokunma gecikmesi azalır).
- Görsel: vinyet, barikat zayıfken kırmızı nabız, zombiler sisten belirerek doğar, asker ayak altı ışık halkası,
  silaha göre namlu görünüşü, namlu alevi, kritikte titreşim.
- Profil kaydı: önce `.tmp`'ye yazılır sonra yerine taşınır (yarım yazılmış dosya olmaz), önceki sürüm `.bak`.

- **GL Compatibility dersi (Gece 1 ölçümü):** `draw_circle`/çokgen ve yumuşatılmış çizgiler **birleşmez**, her biri ayrı çizim çağrısıdır; `draw_rect`,
  yumuşatmasız `draw_line` ve aynı dokudan `draw_texture_rect_region` birleşir. Bu yüzden: statik şekiller SubViewport ile dokuya pişirilir, oyun içi yeni çizimlerde daire yerine dikdörtgen/doku.
  Yük testi (120 zombi, yazılım ekranı): yalnız zombi atlası ≈ 1570, zemin+barikat+leke de pişince ≈ 230 çizim çağrısı. 2D MSAA GLES3'te desteklenmiyor (uyarı zararsız).
- Atlas başarısız olursa yedek yol doğrudan çizimdir; `--headless` çalıştırmada bu yol kullanılır.
- Denge aracı: `godot --headless --fixed-fps 60 -- --bot=6` rastgele kartlı bot koşuları yazar.

## 13. Ekip — Football Manager tarzı (v1 uygulandı)
- Her hayatta kalan: ad, rol, yaş, 6 özellik (1–20): Nişancılık (hasar), Refleks (ateş hızı), Soğukkanlılık
  (kritik), Dayanıklılık (barikat canı), Mühendislik (onarım), Liderlik (altın, moral).
- **Yetenek (CA)** = özellikler toplamı; **Potansiyel (PA)** = ulaşabileceği tavan. İkisi de yarım yıldızlı 5 yıldız.
- **Gelişim:** sahadaki kişi koşu deneyimiyle (0.5 + 0.22·dalga puan), diğerleri antrenmanla (0.35 puan) gelişir.
  Yaş çarpanı: <21 ×1.5, <25 ×1.25, <30 ×1.0, <34 ×0.6, üstü ×0.25. Moral çarpanı 0.75–1.25.
  Puanın %50'si **antrenman odağına**, %18'i rolün anahtar özelliklerine, %6'sı diğerlerine gider. PA'ya ulaşınca durur.
  33 yaş üstü fiziksel düşüş (Refleks, Dayanıklılık). Her 10 koşu = 1 sezon, herkes 1 yaş büyür.
- **Moral:** rekor kırınca +10, 8+ dalga +6, ≤3 dalga −8. Moral istatistikleri ±%5 etkiler.
- **Roller:** Asker (hasar +%10), Avcı (kritik +%8, kritik çarpanı 3), Mühendis (onarım ×1.6, ucuz),
  Doktor (barikat saniyede %0.4 yenilenir).

## 14. Keşif — FM gözlemcisi (v1 uygulandı)
- 3 bölge: Terk Edilmiş Kasaba (30 hurda, 2 dk), Askeri Üs (90, 10 dk), Şehir Merkezi (220, 30 dk). Gerçek zamanlı.
- Rapor 2–3 aday + %50 şansla silah getirir. Bölge ne kadar iyi, adaylar o kadar yetenekli/potansiyelli.
- **Bilgi düzeyi:** gözlemci her şeyi bilemez; özellikler aralık olarak görünür (ör. 9–12), yıldızlar soluk aralık.
  15 hurdaya "İncele" → kesin değerler. İşe alma bedeli = 0.8·CA + 0.4·PA hurda.

## 15. Envanter ve Silahlar (v1 uygulandı)
- 5 silah: Tabanca, Saldırı Tüfeği, Pompalı (5 saçma), Keskin Nişancı (delme 2, kritik), Makineli.
- 5 nadirlik: Sıradan / Nadir / Ender / Destansı / Efsanevi — çarpan 1.0/1.15/1.35/1.6/2.0, ek özellik 0–4,
  düşme ağırlığı 55/28/12/4/1, en yüksek seviye 10/15/20/25/30.
- Ekler (Diablo tarzı): hasar, ateş hızı, kritik, menzil, altın, delme, barikat canı.
- Geliştirme: seviye başına +%6 hasar, +%1.5 ateş hızı; fiyat 15·1.35^(sv−1)·(1+0.6·nadirlik).
- Birleştirme: 3 kullanılmayan aynı nadirlik → 1 üst nadirlik. Satış: hurda.
- Ganimet: her 5 dalgada 1 silah; nadirlik şansı dalgayla artar. Envanter sınırı 40 (dolarsa hurdaya çevrilir).

## 16a. FM v2 (Gece 1'de uygulandı)
- **Kişilik (7):** Profesyonel (gelişim +%25), Kararlı (+%15, moral kaybı ½), Lider ruhlu (sahadayken ekip moral +2), Hırslı (+%10, moral kazancı ×1.5, yedekte moral −2),
  Dengeli, Asabi (kayıp ×1.5, kazanç ×1.25), Tembel (−%25). Keşifte bilgi ≥ 0.6 ise görünür, yoksa İncele gerekir. Eski kayıtlara rastgele atanır.
- **Yorgunluk (0–100):** oynayan +10 + 1.6·dalga (tek kişilik ekipte yarısı), yedek −35/koşu, gerçek zamanla −12/saat. Etki: hasar ve ateş hızı −%0.15/puan (100'de −%15).
- **Sakatlık:** barikat düşünce şans = %5 + yorgunluk×%0.2 (en çok %25), 1–3 koşu; sakat sahaya çıkamaz, en iyi sağlam yedek otomatik çıkar. Tek kişilik ekipte olmaz.

## 16b. Ekip konuşması (Gece 2'de uygulandı)
Beklenti = önceki en iyi dalga × 0.7 (en az 3). İyi ≥ beklenti×1.3, normal ≥ beklenti, altı kötü. İlk koşu normal.
Moral: Öv +6/+2/−3, Sert −4/+1/+5, Sessiz 0 ve yorgunluk −8. Kişilik: Profesyonel sert +2, Kararlı sert +3, Hırslı öv +2, Asabi sert −7, Tembel sert +2 öv −2. Üst üste aynı konuşmada olumlu etki yarıya iner. Lider ruhlu olumlu tepki verirse tüm ekip +1.

## 16c. Surdaki ekip, ekip yapay zekâsı, maç puanı (Gece 3'te uygulandı)
- **Yuvalar:** `Veri.NOBETCI_YUVA` = 2 (B2 Sur yükseltmesi 6'ya çıkaracak; düğüm havuzu baştan 6). Lider sura konamaz; sakat olan sura çıkmaz (listede kalır).
  Konumlar ekran genişliğinin 0.35 / 0.65'i (taretlerin arası), sonra kenarlar.
- **Güç:** kendi silahı (yoksa rolünün Sıradan silahı) × özellikler × moral × yorgunluk × **0.45**; dalga başı +%4 (taret gibi); kartlar işlemez. Pompalı surda 3 saçma. Asker +%10 hasar, Avcı +%8 kritik ve ×3 kritik.
- **Koşu sonu:** nöbetçi 0.3 + 0.12·dalga gelişim puanı (yedek 0.35), dalga×5 XP, yorgunluk +5 + 0.8·dalga (dinlenmez), sakatlanmaz.
- **Hedef modları** (Bloons gibi): Rolüne göre (Avcı: boss +3000, kusan +900, zırhlı +800, patlayan +600, yakınlık ×0.3; diğerleri en yakın) / En yakın / En güçlü (can + 25·zırh, boss +5000) / Boss önce.
- **Aşırı öldürme önleme:** her mermi hedefine tahmini hasar (zırh düşülmüş) yazar; mermi çarpınca ya da kaybolunca geri alınır. Beklenen ≥ kalan can ise hedef ancak başka aday yoksa seçilir. Lider ve normal/ağır taret de kullanır.
- **Boşta:** Mühendis nöbetçi saniyede barikatın %0.3'ünü, Doktor %0.2'sini onarır.
- **Maç puanı:** 6.0 + clamp((hasar payı / beklenen pay − 1) × 1.5, −1.5, +2) (beklenen pay ağırlıkla: lider 2, nöbetçi 1; kart alan lider haksız öne geçmesin) + min(öldürme / 25, 1.2) + (iyi sonuç +0.8, kötü −0.8), 3.0–10.0. Puan ≥ 7.5 moral +3, ≤ 5.0 moral −3.
  Son 5 puan "form" olarak saklanır (Ekip kartında). En yüksek puan "koşunun yıldızı" (★). Bomba lidere, havan taretlere sayılır.

## 16d. Kampanya, Sur, Güç seviyesi, boss aşamaları (gündüz ek turu 1'de uygulandı)
- **Kampanya:** `profil.kampanya` = {dalga, en_yuksek, zafer, yenilgi}. Savaş = tek dalga; başta 1 kart; başlangıç altını Lab + 30 + 6n (taret/onarım için).
  Can çarpanı 1 + 0.09(n−1) + 0.002(n−1)² (20. dalga 3.43, 40. 7.6, 50. 10.2). Boss her 10. dalga: 10 Dev, 20 Kraliçe, 30 Dev…; boss gücü sırası n/10. Nefes dalgası yok, yönetmen çalışır.
  Zafer: altın (20 + 6n, boss ×3), hurda 4 + n (+25 boss), boss → garanti Ender+ silah, sıradaki dalga açılır. Yenilgi: aynı dalga, %25 altın + yarım hurda (ceza yok).
  Ekip: lider 0.15 + 0.02n gelişim, +3 yorgunluk; nöbetçi 0.08 + 0.01n, +2 yorgunluk; maç puanı ve form işler. Menüye dönmek ödülsüz, cezasız. Rekor ve koşu sayısı değişmez.
- **Sur:** seviye 1–50, barikat canı +%8/sv (iki modda), yuva = 2 + ⌊(sv−1)/8⌋ (en çok 6: 9, 17, 25, 33. seviyede). Fiyat 30·1.10^(sv−1) hurda: 9. seviyeye ≈ 410, 33'e ≈ 6.7 bin, 50'ye ≈ 35 bin.
  Menüde kat sayısı seviye/6 ile artan, ahşap → taş (17) → çelik (33) çizim; kuleler yuva sayısı kadar.
- **Güç seviyesi:** hayatta kalan başına 0–30, +%10 hasar/sv (lider ve nöbetçi, iki modda). Fiyat 50·1.18^sv kampanya altını (0→10 ≈ 1175).
- **Boss aşamaları:** Dev %66 öfke (hız ×1.5), %33 iniş yerini 0.9 sn işaretleyip 240 px ileri sıçrar (barikata inerse yarım vuruş hasarı; zaten barikattaysa vuruşu hemen gelir). Kraliçe %66'da 2.5 sn'de bir doğurur, %33'te doğurmayı bırakıp hız ×1.6 saldırır. %50 çağrısı sürer.
- **Bot:** `--bot_kampanya=60` (önizleme iş akışında): her savaştan sonra Sur ve lider Gücü alınabildiğince yükseltilir, 10 savaşta bir durum yazılır.

## 16e. Zayıf nokta, sürü, otomatik savaş, kampanya v2, Hurda Madeni (Gece 4'te uygulandı)
- **A2 Barikat bölümleri:** 6 bölüm, her biri max_can/6. Zombi vurduğu x'in bölümüne hasar verir; Dev/Kraliçe vuruşu üç bölüme bölünür. Kırılan bölüm **GEDİK**: oraya gelen hasar ×1.5 olarak en yakın sağlam bölüme taşar (eşitlikte rastgele taraf). Bütün bölümler kırılınca barikat düşer (toplam can = 0, eski kural aynı). `barikat.can` okunur/yazılır (yazınca bölümler aynı orana gelir: eski kod bozulmadı).
  Bölüm üstünde 8 px can çubuğu (yeşil → kırmızı), gedikte kırmızı çerçeve + koyu bölge, "GEDİK!" yazısı, +15 gerilim.
- **Zombi zekâsı:** 0.9–1.5 sn'de bir, `zeka` olasılığıyla hedef bölüm seçer: puan = bölüm oranı + 0.12 × bölüm uzaklığı (en düşük). Yürüyen 0.3, zırhlı 0.5, kusan 0.7, koşucu 0.9, patlayan 1.0; boss düz yürür. Yana kayma hızı ileri hızın %60'ı.
- **ONAR v2 (akıllı onarım):** onarım, Tamirci/Doktor yenilenmesi ve nöbetçi onarımı bölüm canının %5'lik dilimleriyle hep en zayıf bölüme gider; "ONARILDI" yazısı onarılan bölümün üstünde çıkar.
- **A3 Sürü:** 80 px ızgara (bağlı liste, PackedInt32Array; her güncellemede yeni dizi yok), saniyede 10 (Düşük kalite 5) güncelleme. Ayrılma: (r₁+r₂)·0.8'den yakın komşu, örtüşme oranıyla itme × 150 px/sn, en çok 170; boss itilmez. Barikata dayanmış zombi itmenin yarısını alır (duvar boyunca yayılır).
  Kalkan: koşucu, önünde 20–170 px ve yanda 110 px içinde zırhlı görürse onun hızında (×1.05) arkasından yürür; zırhlı ölünce dağılır. Kusan: menzildeyken üstüne mermi geldiğinde (beklenen hasar > 0) 0.45 sn 170 px/sn yana kayar, 3 sn bekleme.
- **B4 OTO savaş:** kampanyada geçilmiş dalgalarda (≤ en yüksek) HUD'da "OTO" düğmesi, seçim kaydedilir. Saniyede 5 karar: lider en tehlikeli zombinin hizasına gider (oyuncu dokunursa 1.5 sn bırakır), en zayıf bölüm < %45 ya da toplam < %60 → ONAR, gerilim > 55 ya da boss → yetenek, onarım parası ayrıldıktan sonra taret (uzmanlık: orta havan, yanlar ağır). Kart 0.8 sn sonra A6 ile seçilir.
- **Kampanya TEKRAR:** en son geçilen dalga yeniden oynanır: ödül ×0.5, boss ganimeti yok, ilerletmez, yıldız yükseltilebilir.
- **A6 akıllı kart:** taban (Hasar/Ateş 10, Namlu 8, Kritik 7, Barikat/Yanma 6, Delme/Tamirci 5, Menzil/Altın/Diken 4, Zırh Delici 3, Kese 2, Tam Onarım 1) + Zırh Delici 40×zırhlı oranı, Delme/Namlu 10×koşucu oranı, barikat kartları 10×(1−can), Tam Onarım 22×(1−can), boss öncesi Yanma +4, evrim eşi +3/sv, kampanyada altın kartları ×0.3, evrim kartı hep ilk. Oran = gelecek dalganın formülü (koşuda 20+ zombi görüldüyse görülenle ortalaması). Kart ekranında "★ ÖNERİ (neden)".
- **Kampanya v2 yıldızları:** barikat %90+ → 3, %50+ → 2, yoksa 1; dalga başına en iyi saklanır (`kampanya.yildiz`). Eşikler: 15 ★ 120 hurda, 30 ★ Destansı silah, 60 ★ 400 hurda, 90 ★ Efsanevi silah, sonra her 45 ★ 500 hurda.
  Zafer/yenilgi ekranında "SUR n→n+1 (hurda)" ve "<lider> GÜÇ n→n+1 (altın)" düğmeleri + kasa satırı.
- **Hurda Madeni (Kasaba, B6 ilk bina):** kurulum 80 hurda, seviye fiyatı 80·1.45^sv (en çok 20). Üretim (6 + 4·sv) × (1 + 0.03 × kampanya en yüksek dalga) hurda/saat, en çok 8 saat birikir. Açılışta 15 dk+ birikim varsa OYNA'nın en üstünde "SEN YOKKEN … TOPLA". Saat geri alınırsa kazanç yok (yalnız referans düzelir).
  Örnek: Sv 1, 10. dalga → 13/sa (8 saatte 104); Sv 5, 20. dalga → 42/sa; Sv 10, 30. dalga → 87/sa (8 saatte ≈ 700).

## 16f. Kasaba v1, Başarımlar, Tehdit, Barikat v3, Oto Tekrar, Menü v2 (Gece 5'te uygulandı)
- **Kasaba sekmesi (7. sekme, yazı 18 pt):** Hurda Madeni buraya taşındı (OYNA'da özet kart + TOPLA kaldı, "Sen yokken" OYNA'nın en üstünde).
  - **Çiftlik:** kurulum 100 hurda, fiyat 100·1.45^sv (en çok 20). Üretim (5 + 3·sv) × (1 + 0.04 × kampanya en yüksek dalga) **kampanya altını**/saat, 8 saat sınırı, saat hilesi koruması Maden'le ortak (`_uretim_guncelle`). Örnek: Sv 2, 7. dalga → 14/sa; Sv 5, 20. dalga → 36/sa (8 saatte ≈ 290 altın ≈ Güç 9→10 fiyatı 50·1.18^9 = 221).
  - **Tesisler** (en çok 10 seviye, fiyat taban·1.5^sv hurda): Antrenman Sahası (taban 100) sahada olmayanların koşu sonu antrenmanı 0.35 × (1 + 0.10·sv); Revir (taban 90) gerçek zaman dinlenmesi ve yedek dinlenmesi × (1 + 0.10·sv), sakatlık şansı × (1 − 0.06·sv); Atölye (taban 120) silah geliştirme fiyatı × (1 − 0.04·sv) (10. seviyede −%40). Tüm tesisler en üste ≈ 3 × 11 bin hurda: uzun vadeli hurda yeri.
- **Başarımlar:** 12 başarım × 3 kademe (Bronz 40, Gümüş 100, Altın 250 hurda; toplam 4680). Eşikler: Dev 1/5/20, Kraliçe 1/5/15, Hayatta Kalma dalgası 15/25/40, kampanya dalgası 10/30/60, toplam zombi 1000/10000/50000, evrim 1/5/15, ekip 3/5/8, Sur 9/17/33, taret uzmanlığı 1/10/30, kampanya ★ 15/60/150, Kasaba toplama 200/2000/10000 hurda, Tehdit 3/6/10. Rekor, kampanya, öldürme, ekip, Sur, yıldız ve tehdit profilden hesaplanır (eski oyuncunun geçmişi sayılır); Dev/Kraliçe/evrim/uzmanlık/toplama Gece 5'ten sonra sayılır. Ödül elle alınır (görünür ödül anı), hazır olanlar listenin üstünde, OYNA'da "sıradaki başarım" satırı.
- **Tehdit Seviyesi (Hayatta Kalma):** Hayatta Kalma rekoru 15 ile açılır. Kalabalık 3 × +%20 zombi sayısı, Dişli 3 × +%20 zombi hasarı (boss dahil), Kalın Deri 3 × +%15 can, Karaborsa 2 × +%40 onarım ve taret fiyatı; her kademe 1 puan, en çok 11. Hurda × (1 + 0.10·puan). 10. dalgaya ulaşan koşuda yeni en yüksek puan → garanti silah (1–3 Ender, 4–7 Destansı, 8+ Efsanevi), Hades'teki gibi puanı birer birer artırmak her adımda ödül verir. Kampanyayı etkilemez.
- **Barikat v3:** gedik taşma çarpanı 1.5 → **1.3**. HUD'da can çubuğunun altında 6 bölümlü şerit (gedikte kırmızı yanıp söner; yalnız gedik varken kendi `_process`'i açık). Gedik varken ONAR düğmesi kırmızı "GEDİK! ONAR".
- **Kampanya v3 — OTO TEKRAR:** TEKRAR savaşı OTO ile kazanılınca sonuç ekranının üstünde "OTO TEKRAR 3 sn (durdur) · seri n, +X altın"; 3 sn sonra aynı dalga kendiliğinden başlar. Yenilgide durur ve seriyi yazar. Düğme: sayarken durdurur (ayarı kapatır), kapalıyken açar (OTO kapalıysa onu da açar). Zafer ekranında yükseltme yapılırsa sayaç 3 sn'ye döner. Ayar `oto_tekrar` (varsayılan açık).
- **Menü v2:** OYNA sırası: Sen yokken → Kampanya → Hayatta Kalma (+ Tehdit) → lider (silah satırı içine alındı) → surdaki ekip → Sur → Kasaba özeti → Görevler → Keşif. İki mod ilk ekranda.

## 16. FM Derinliği — Sıradaki Tasarımlar
- **Kişilik (gizli özellikler):** Kararlılık ve Profesyonellik gelişim hızını ±%30 etkiler; Hırs moral tavanını.
  Keşif raporunda "Kişilik: Profesyonel / Tembel / Lider ruhlu" gibi tek kelimeyle görünür.
- **Sakatlık ve yorgunluk:** barikat düşerse sahadaki kişi %15 ihtimalle 1–3 koşu sakat kalır; art arda oynayan
  yorulur (istatistik −%5/koşu, dinlenince yenilenir). Rotasyon kararı doğar.
- **Mentorluk:** 30+ yaşlı, yüksek Liderlik'li kişi bir gence mentor atanır → gencin gelişimi +%20.
- **Personel:** Antrenör (gelişim), Gözlemci (rapor bilgisi, süre), Doktor (sakatlık), Usta (silah geliştirme).
  Her birinin 1–20 özelliği olur, hurdayla işe alınır.
- **Tesisler:** Antrenman sahası / Atölye / Revir / Gözcü kulesi; seviye atlatmak kalıcı bonus verir.
- **Kısa liste ve öneri:** gözlemci adaya 1–5 yıldız "öneri" verir; oyuncu kısa listeye alıp daha sonra işe alır.

## 17. Araştırma Notları
### 2026-11-08 (Gece 5)
- **Hades Pact of Punishment:** koşul başına kademe ve puan (Hard Labor 5 × +%20 düşman hasarı 1 puan, Jury Summons 3 × +%20 düşman, Calisthenics 2 × +%15 can, Convenience Fee 2 × +%40 fiyat). Ödüller silah başına her yeni Heat için; puanı birer birer artırmak önerilir (atlamak ara ödülleri kaybettirir). En yüksek Heat sayısı sayfalarda yok. — https://www.rpgsite.net/feature/10287-hades-pact-of-punishment-heat-modifiers-and-how-to-maximize-your-rewards , https://ludoatlas.pages.dev/hades/heat/
- **Başarımlar (Kwak, WebSci 2022 — 13.792 PlayStation oyunu, 377.938 kupa):** Bronz 15 / Gümüş 30 / Altın 90 puan; Platin tamamlanma 2008'de %4.2 → 2021'de %39.2; tekrarlı şartlar tamamlanmayı düşürüyor; odak grubunda başarımlar kimine olumlu geri bildirim, kimine "ek iş". Ders: normal oynarken dolan, kademeli, angaryasız. — https://ar5iv.labs.arxiv.org/html/2205.15163
- **Grow Castle kasabası / oto savaş:** kasaba binaları sayıları kaynaklarda bulunamadı (arama sonuçları başka oyunlara gitti); "seviye atlayan bina tek sayıyı büyütür" ilkesi ve tüm sayılar bizim. — https://www.apkmirror.com/apk/raon-games/grow-castle/grow-castle-1-22-1-release
- **PvZ Screen Door Zombie (Kalkanlı zombi fikri):** kapı düz atışları tutar, lobut ve alan saldırıları aşar (sayfalar bu oturumda açılmadı, bilinen oyun bilgisi). — https://plantsvszombies.wiki.gg/wiki/Screen_Door_Zombie
- **BTD6 Monkey Knowledge (Komutan Bilgisi fikri):** oyuncu seviyesi başına bilgi puanı, seçmeli kalıcı ağaç. — https://www.bloonswiki.com/Monkey_Knowledge_(BTD6) , https://www.bloonswiki.com/Monkey_Knowledge_Point
- **Godot 4.3 tekniği:** HUD şeridi `Control._draw` + `draw_rect` (birleşen çizim), yanıp sönme için yalnız gerekince `set_process(true)`; menüde 4 şalter `GridContainer` (2 sütun). Yeni düğüm oyun sırasında oluşturulmuyor.
### 2026-11-07 (Gece 4)
- **Grow Castle** (App Store sayfası, r/GrowCastle rehberleri): kısa dalga, savaş ekranından yükseltme, geçilmiş dalgada otomatik savaş ve kasma. Wiki sayfaları yine açılamadı; sayılar bizim. https://apps.apple.com/gb/app/grow-castle/id1133478462
- **Clicker Heroes çevrimdışı ilerleme:** çıkışta boşta DPS kaydedilir, dönünce kazanç hesaplanır ve elle toplanır; aktif yetenek sayılmaz; sınır yok (biz 8 saat sınırı koyduk ki günde birkaç kez dönülsün; saat hilesi yazıda geçmiyor, bizim kuralımız). https://blog.clickerheroes.com/offline-progression-in-clicker-heroes/
- **Kingdom Rush yıldızları:** kalan cana göre 1–3 yıldız, yıldızla kalıcı yükseltme (wiki sayfası bu oturumdan açılamadı; 18+/6+ eşiği bilinen kural). https://kingdomrushtd.fandom.com/wiki/Star
- **Sürü optimizasyonu (Godot forumu, pikmin benzeri):** fizik düğümleri yerine kendi CPU ızgarası (50 varlık 7 FPS → özel ızgarayla 200 varlık ≈ 90 FPS), mesafe önbelleği, çizimde MultiMesh. https://forum.godotengine.org/t/boid-behavior-and-optimization-for-a-pikmin-like/71608
- **Fikir Havuzu için:** Orcs Must Die tuzak türleri (çivi, katran yavaşlatması, patlayıcı varil) https://orcsmustdie.wiki.gg/wiki/Traps ; Slay the Spire Daily Climb (günlük tohum + kurallar) https://saschb2b.github.io/game-mechanics/games/slay-the-spire/daily-climb
### 2026-11-06 (gündüz ek turu 1)
- Grow Castle rehber sayfaları (fandom Guide/Basics) bu oturumdan açılamadı; kale, kahraman yuvası ve altınla yükseltme döngüsü genel oyun bilgisi, sayılar bizim. — [Grow Castle Wiki: Guide](https://grow-castle.fandom.com/wiki/Guide), [LDPlayer başlangıç rehberi](https://www.ldplayer.net/blog/grow-castle-guide-for-all-the-beginners.html)
- Boss aşama tasarımı: can eşiklerinde davranış değişimi, büyük saldırıdan önce görünür uyarı, son aşamada artan baskı ama adil okunabilirlik. — [Boss Phase Transitions](https://starship-survivors-wiki.pages.dev/gameplay/concepts/boss-phase-transitions), [Wayline: boss savaşları](https://www.wayline.io/blog/crafting-legendary-boss-battles)
- Sur fiyat eğrisi hesabı: §0 taslağındaki 40·1.16^(sv−1) ile 6. yuvaya (33. seviye) ≈ 33 bin hurda gerekiyordu (Hayatta Kalma koşusu ≈ 190 hurda); 30·1.10^(sv−1) ile ≈ 6.7 bin, Laboratuvar'ın tamamıyla aynı ölçekte.

### 2026-11-06 (Gece 3)
- Grow Castle: kale yuvalarına kahraman yerleştirme, kahramanlar kendiliğinden saldırır, altınla seviye; kesin yuva sayıları kaynaklarda yok, 2 → 6 bizim tasarımımız. — [App Store](https://apps.apple.com/au/app/grow-castle/id1133478462)
- Bloons TD hedefleme seçenekleri (First / Last / Close / Strong): oyuncu kule yapay zekâsını tek düğmeyle yönlendirir. Wiki sayfası bu oturumdan açılamadı; seçenek adları bilinen oyun bilgisi. — [Bloons Wiki: Targeting option](https://www.bloonswiki.com/Targeting_option)
- Aşırı öldürme (overkill) önleme: RTS/TD topluluklarında "gelecek hasarı say" yaklaşımı tartışılıyor; ayrıntılı sayfa bot korumasıyla açılamadı, uygulama kendi tasarımımız. — [SpringRTS forumu](https://springrts.com/phpbb/viewtopic.php?p=228189), [Factorio: topçu aşırı öldürme](https://forums.factorio.com/119445)
- FM maç puanı: puanlar oyuncuyu neden iyi/kötü oynadığını açıklamaz, sadece özet verir (FM Projects yazısı); formül yayınlanmamış, bizim formülümüz hasar payı + öldürme + sonuç. — [FM Projects: Match Ratings](https://fmprojects.substack.com/p/match-ratings-in-football-manager), [FM Projects: Morale](https://fmprojects.substack.com/p/morale)
- PvZ Dr. Zomboss: 40 000 can, sol eliyle şeritlere zombi bırakır, kafasını indirip ateş/buz topu atar, 8 000 / 20 000 hasarda görünüşü değişir. Ders: çağırıcı boss oyuncuya "kaynağı vur" önceliği öğretir; aşamalar (A4) için can eşikleri. — [PvZ Wiki: Dr. Zomboss](https://plantsvszombies.wiki.gg/wiki/Dr._Zomboss_(PvZ))
- FM takım uyumu (cohesion): birlikte oynama ve ortak geçmiş artırır, toplu transfer düşürür. — [VideoGamer: FM24 cohesion](https://www.videogamer.com/guides/football-manager-2024-fm24-how-to-improve-team-cohesion)
- Mobil ödül sistemleri: kademeli kilometre taşları ve anında görünen ödül geri dönüşü artırır. — [Tango: gaming incentives](https://www.tangocard.com/resources/gaming-incentive-programs-driving-player-engagement-and-retention-in-mobile-games)
- Godot: `CanvasItem.draw_string` / `draw_string_outline` aynı yazı tipi dokusundan glif çizer; çok sayıda Label yerine tek düğümde çizim. — [Godot Font sınıfı](https://docs.godotengine.org/en/4.2/classes/class_font.html)

### 2026-11-06 (gündüz, yapay zekâ + Grow Castle isteği)
- Left 4 Dead Yapay Zekâ Yönetmeni: oyuncu başına "duygusal yoğunluk" hasar ve yakın ölümlerle artar, zamanla
  söner; döngü Yükselme → Zirveyi koru (3–5 sn) → Zirve sönümü → Rahatlama (30–45 sn); "roller coaster" hissi
  (Valve, Mike Booth GDC 2009 sunumu; ayrıca [Shacknews: Evolve ve L4D yönetmeni](https://shacknews.com/article/82787/how-evolve-assures-action-peaks-and-valleys),
  [Game Developer: The Discomfort Zone](https://www.gamedeveloper.com/design/the-discomfort-zone-the-hidden-potential-of-valve-s-ai-director)).
  Bizim dalgalar kısa olduğu için rahatlama 4–8 sn'ye ölçeklendi.
- Grow Castle: kale yükseltmesi, kalede kahraman yuvaları, kahramanları altınla seviye atlatma, kasaba okçuları,
  koloniler, otomatik savaş, hızlandırma, boss dalgaları; topluluk rehberleri yapı (build) çeşitliliğini ve altın
  kasma döngüsünü öne çıkarıyor ([r/GrowCastle rehber başlığı](https://redlib.ssps.io/r/GrowCastle/comments/nyynyt/official_wave_build_guide_skill_tree_guide_and),
  [App Store](https://apps.apple.com/za/app/grow-castle/id1133478462)). Kesin sayılar kaynaklarda yok; maliyetler bizim tahminimiz,
  bot denge testiyle ayarlanmalı.

### 2026-11-06 (Gece 2)
- Kingdom Rush kalıcı yükseltmeler: 6 ağaç, ağaç başı 5 yükseltme, tekil etki küçük (+%10 can, +%15 hasar), maliyet 1–4 yıldız. — [KR Upgrades](https://kingdomrushtd.fandom.com/wiki/Upgrades)
- Meta çeşitlilik vs güç: Slay the Spire/Balatro taban güç vermez, Hades ortada; saf güç zorluğu kaydırır, saf çeşitlilik kısa oyunda ilerleme hissini zayıflatır. — [Meta as variety](https://saschb2b.github.io/game-mechanics/concepts/meta-as-variety-not-power)
- Fark türü ve ölçeği: sayı artışı ancak oynamayı değiştirirse anlamlı. — [Escapist](https://www.escapistmagazine.com/roguelites-items-power-scale-game-development-vampire-survivors/)
- FM konuşması: sonuç beklentiye göre okunur, tekrar etkiyi düşürür, bazen hiçbir şey dememek doğrudur. Kaynakta sayı yok; sayılarımız bizim seçimimiz. — [FM Scout rehberi](https://www.fmscout.com/a-team-talks-guide-managing-morale-and-confidence.html)
- Hades Heat: kademe başına 1–3 puan (örn. Hard Labor kademe başına +%20 düşman hasarı), ödül yeni tepe için bir kez. — [RPG Site](https://rpgsite.net/feature/10287-hades-pact-of-punishment-heat-modifiers-and-how-to-maximize-your-rewards)
- KR erken çağırma: taban bonus sayısı wikide bulunamadı; Vengeance yükseltmesi %80 ek altın veriyor. Sayılarımız kendi önerimiz. — [KR Gold](https://kingdomrushtd.fandom.com/wiki/Gold), [KR Upgrades](https://kingdomrushtd.fandom.com/wiki/Upgrades)
- Godot: Compatibility'de parçacık için CPU tarafı; biz düğümsüz, sabit dizili kendi sistemimizi yazdık (`parcaciklar.gd`).

### 2026-11-05 (Gündüz turu)
- Kingdom Rush: kulelerin yanında hero/oyuncu büyüleri bekleme süreli; para kule yerine, zamanlama büyüye gider. — [Hero Spell](https://kingdomrushtd.fandom.com/wiki/Hero_Spell), [Call Reinforcements](https://kingdomrushtd.fandom.com/wiki/Call_Reinforcements), [Tower defense kuralları](https://gamedeveloper.com/design/tower-defense-game-rules-part-2-)
- Günlük görevler angaryaya dönüşebilir; kısa ve cezasız tutuldu. — [Daily quests or daily pests](https://www.universityxp.com/research/2024/2/24/daily-quests-or-daily-pests-the-benefits-and-pitfalls-of-engagement-rewards-in-games), [Metriklere etkisi](https://www.indiehackers.com/post/designing-with-data-what-daily-quests-actually-do-to-your-game-metrics-926d83be10)
- FM mentorluk: kişilik gence geçer. — [FM24 mentorluk](https://www.videogamer.com/guides/football-manager-2024-fm24-how-to-mentor-players), [FourFourTwo](https://www.fourfourtwo.com/features/football-manager-2016-how-nurture-hot-prospect-true-wonderkid)
- Yeni araştırılan, yapılmadı: **Laboratuvar** (3 dal, düğüm fiyatı 100·1.5^n hurda, her düğüm +%3–5: meta gücü küçük tut), **Hava olayı** (dalga başına %20 şansla sis menzil −%20 veya yağmur yanma −%50; dalga afişinde söylenir).

### 2026-11-05 (Gece 1)
- Survivor.io evrimi: silah 5. seviye + eş destek yeteneği, boss sandığıyla açılır. Örn. Kunai + Energy Cube → Spirit Shuriken. —
  [BlueStacks evrim rehberi](https://www.bluestacks.com/blog/game-guides/survivor-io/sio-skills-evolution-guide-en.html)
- Kingdom Rush: Dark Knight yavaş, dayanıklı, ağır zırhlı; karşı hamle zırh yarılayan/ büyü hasarı. Sayısal zırh tablosu bu sayfada yok, formülü kendimiz seçtik. —
  [Dark Knight](https://kingdomrushtd.fandom.com/wiki/Dark_Knight)
- FM kişilikleri: Profesyonellik ve Hırs antrenman gelişimini artırır, düşük Profesyonellik (Tembel/Slack) ve Tartışmacılık düşürür. —
  [FM Scout: kişilikler](https://www.fmscout.com/a-guide-to-player-personalities-football-manager.html)
- Meta gelişim: kalıcı güç koşu becerisini güçlendirmeli, gereksizleştirmemeli. —
  [Bugnet](https://bugnet.io/blog/how-to-design-a-roguelite-meta-progression)
- Godot: `SubViewport` tek seferlik render (`UPDATE_ONCE`) ve doku. — [Viewports](https://docs.godotengine.org/en/4.2/tutorials/rendering/viewports.html)

### 2026-11-05
- FM gözlemcileri: Yetenek Değerlendirme (rapor hızı/doğruluğu), Potansiyel Değerlendirme (genç raporları);
  görev kapsamı ülke/lig/oyuncu/kulüp, sonuç rapor merkezinde toplanır. —
  [FMInside: Scouts](https://fminside.net/guides/staff-guides/52-scouts),
  [FM Scout: CA/PA rehberi](https://www.fmscout.com/a-football-manager-current-and-potential-ability-guide.html)
- FM gelişimi: 15–17 yaşta antrenman, 18+ maç deneyimi belirleyici; fiziksel özellikler en hızlı gelişir;
  bireysel antrenman en zayıf rol özelliğine; övgü/eleştiri moral → gelişim; mentorluk ve kişilik (kararlılık,
  profesyonellik) hızlandırır. — [sortitoutsi: gençlik gelişimi](https://sortitoutsi.net/content/61092/football-manager-youth-development-guide-mentoring-and-training-wonderkids)
- Ganimet tabloları: önce nadirlik zarı, sonra o nadirlikten eşya; garantili düşüş (sandık), şans bonusu
  zara eklenir; sınıfa göre ağırlıklandırma ("akıllı ganimet"). —
  [Game Developer: ARPG loot tables](https://www.gamedeveloper.com/design/defining-loot-tables-in-arpg-game-design)
- Godot mobil: 2D için gl_compatibility, CPUParticles, ETC2/ASTC, `Engine.max_fps`, `set_use_accumulated_input(false)`,
  FPS ve çizim çağrısı izleme ile uyarlamalı kalite. — [Godot 4 mobil optimizasyon](https://gtstu.com/godot-4-optimize-android-ios/)
