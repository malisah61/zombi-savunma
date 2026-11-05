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
- (Şimdilik yok. Mehmet Ali'nin istek ve hata bildirimleri buraya yazılır.)

## 10. Fikir Havuzu (her gece büyür)
- Gündüz/gece döngüsü: gece zombiler güçlü, gündüz kaynak toplama.
- Kurtarılan hayatta kalanlar üste yardımcı olur.
- Hava durumu: yağmur alevi zayıflatır, sis menzili düşürür.

## 11. Yol Haritası
(Gece görevi her çalışmada en üstteki yapılmamış maddeleri alır, bitirince işaretler.)
- [x] **Gün 0:** Temel oyun: barikat, kahraman, otomatik ateş, yürüyen + koşucu zombi, dalgalar, can/altın, bitiş ekranı.
- [x] Dalga sonu 3 kartlık yetenek seçimi (ilk 8 kart).
- [ ] Zırhlı ve kusan zombi; ilk boss (Dev).
- [ ] Kule yuvaları: makineli taret ve dikenli tel.
- [ ] Ana menü, zorluk seçimi, kayıt sistemi.
- [ ] Hurda ve yetenek ağacı (Laboratuvar).
- [ ] Gerçek karakter/zombi çizimleri ve animasyonlar, sesler.
- [ ] Kahraman seçimi (Asker + Avcı).
- [ ] Envanter ve ekipman.
- [ ] Bölüm 2: Orman.
