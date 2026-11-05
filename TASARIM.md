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
- [ ] Performans v3: kahraman çizimini de pişir; parçacıkları tek düğümde topla; barikat tahtalarını sadeleştir.
- [x] (Gece 1) FM v2 (bkz. §16): kişilik, sakatlık ve yorgunluk.
- [x] (Gündüz turu) Mentorluk: 28+ yaş ve Liderlik 12+ kişi, 25 yaş altı gence bağlanır; gelişim +%20, koşu başına %3 kişilik geçişi.
- [ ] FM v3: koşu sonu ekip konuşması, personel, tesisler.
- [x] (Gündüz turu) Keşif v2 ilk parça: öneri yıldızı (3 + (değer − ekip en iyi)/6, bilgi azsa ±1.5 yanılır) ve kısa liste (raporu korur).
- [ ] Keşif v3: gözlemci personeli (Yetenek / Potansiyel Değerlendirme).
- [ ] Envanter v2: zırh + aksesuar yuvası, silah modları, set bonusları, kötü şans koruması.
- [ ] Sıradaki zombiler: Patlayan (barikatta alan hasarı), Kalkanlı (önden mermi keser, 8. bölüm), Çağırıcı (boss olmayan kaynak).
- [ ] Boss 2: Kraliçe (her 10. dalgada Dev ile sırayla; sürekli koşucu doğurur).
- [x] (Gündüz turu) Kule yuvaları: 3 yuva, taret 60/96/154 altın, 8×1.5^(sv−1)×(1+0.05·dalga) hasar, 0.6 sn, menzil 520; Mühendis +%30 güç, %20 ucuz.
- [ ] Kule v2: havan (alan) ve alev kulesi, 3. seviyede iki dal.
- [ ] **Sıradaki öncelik:** Laboratuvar (hurdanın kalıcı harcama yeri) ve Patlayan zombi.
- [ ] Kalıcı yetenek ağacı (Laboratuvar): Saldırı / Savunma / Ekonomi.
- [x] (Gündüz turu) Rol aktif yetenekleri: Asker el bombası (170 px, 8×hasar+25, zırhı aşar, 22 sn), Avcı ölümcül nişan (5 sn, 25 sn), Mühendis acil onarım (%30, 30 sn), Doktor aşı (6 sn %40 yavaş, 28 sn).
- [ ] Tesisler: Atölye (silah geliştirme indirimi), Antrenman sahası (gelişim +), Revir (sakatlık süresi −).
- [ ] Bölümler ve zorluk seçimi; sonsuz mod.
- [x] (Gündüz turu) Günlük görevler: 3 görev, gece yarısı yenilenir, biten ödül kaybolmaz, üçü alınınca bonus Nadir+ silah.
- [ ] Başarımlar.
- [ ] Bölüm 2: Orman.

## 3b. Zombi sayıları (Gece 1'de uygulandı)
| Tür | Can | Hız | Hasar | Altın | Özel | İlk dalga |
|---|---|---|---|---|---|---|
| Yürüyen | 30 | 52 | 6 | 2 | — | 1 |
| Koşucu | 15 | 135 | 4 | 3 | oran %15+3·n, en çok %45 | 3 |
| Zırhlı | 46 | 40 | 9 | 5 | zırh 4 + 0.35·dalga; oran %10+1.5·(n−4), en çok %25 | 4 |
| Kusan | 26 | 44 | 9 | 5 | 330 px'te durur, 2.8 sn'de bir asit; öncelik +260; oran %8+1·(n−6), en çok %16 | 6 |
| Dev (boss) | 480 | 27 | 32 | 40 | zırh 2; 1.3 sn işaretli vuruş; %50 canda 2+2k koşucu; her k. Dev can ×(1+0.6(k−1)), hasar ×(1+0.35(k−1)) | 5, 10, 15… |
- **Zırh formülü:** son hasar = max(hasar − zırh, hasar × 0.2). Düz çıkarma bilerek seçildi: Makineli (5.5) zırha çok takılır, Keskin Nişancı (34) neredeyse etkilenmez;
  böylece silah ve kart seçimi anlam kazanır. Zırh Delici kartı 4 puan siler, Titanyum evrimi tümünü.
- **Can eğrisi:** çarpan = 1 + 0.12(n−1) + 0.03·max(0, n−15)², 25. dalgadan sonra ×1.08^(n−25). Hasar çarpanı 1 + 0.02n.
- **Dalga ritmi:** boss dalgasında normal sayı yarıya iner + n koşucu (yoğun saldırı korunur) + Dev; boss sonrası dalga %60 (nefes).
- **Ekonomi:** onarım fiyatı her kullanımda +5 altın; yeniden çekme 15, +10 artar.

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
