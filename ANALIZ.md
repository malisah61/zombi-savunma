# Oyun Analizleri

Gece görevi her çalışmada buraya en üste iki derinlemesine analiz ekler ve o gecenin kararlarını
bunlara dayandırır.

- **Analiz 1 — Oynanış simülasyonu:** Oyunu kafanda baştan sona oyna (ilk 5 dakika, 5–15. dalga, geç oyun,
  menü/meta döngüsü). Her aşamada: oyuncu ne karar veriyor, karar anlamlı mı, ne sıkıcı, ne kafa karıştırıcı,
  zorluk ve ekonomi eğrisi nerede kırılıyor, telefonda his (dokunma, okunabilirlik, akıcılık) nasıl.
- **Analiz 2 — Karşılaştırma ve psikoloji:** Benzer başarılı oyunlarla (FM, Survivor.io, Archero, Kingdom Rush,
  Vampire Survivors, Brotato, PvZ vb.) karşılaştır; oyuncuyu geri getiren hedefler, ödül zamanlaması,
  uzun vadeli gelişim ve çeşitlilik açısından eksikler neler.
- **Karar:** Analizlerden çıkan en değerli 3 geliştirme + 3 yeni özellik, gerekçeleriyle.

## 2026-11-08 — Gece 5

### Analiz 1 — Oynanış simülasyonu (kod, ekran görüntüsü ve sayılarla)
- **İlk açılış (menü):** OYNA sekmesi yukarıdan aşağı: lider kartı, silah, surdaki ekip, Hayatta Kalma, Kampanya, Sur, Kasaba, Görevler, Keşif. Önizlemede Kampanya düğmesine ulaşmak için **760 px**, Kasaba'ya **1250 px** kaydırmak gerekiyor (`29_menu_kampanya_sur`, `38_kasaba_maden`). Telefonda oyuncu ilk ekranda iki oyun modundan yalnızca birini görüyor; asıl kararı (hangi mod) en alta itilmiş. Uygulamayı her açışta 2–3 kaydırma = sürtünme.
- **İlk 5 dakika (gedik):** Sur 1'de barikat 300 can → bölüm başına **50**. 8. dalgada patlayan 34 × (1 + 0.02·8) ≈ **39** hasar = bir bölümün %79'u. İki patlayan aynı bölüme → gedik. Gedikte hasar ×1.5 yanlara taşıyor, üstelik zekâlı zombiler (koşucu 0.9, patlayan 1.0) en düşük orana = **gediğe** yöneliyor. Yani bir gedik, kendi kendini büyüten bir döngü: yürüyen 6 hasarlık vuruş gedikten 9 olarak komşuya gidiyor, komşu 50/9 ≈ 5.5 vuruşta düşüyor. `33_gedik_suru.png`'de tek aşırı hasar üç bölümü birden yıktı. Üstte HUD can çubuğu ise hâlâ %70 gösteriyor: **oyuncu hangi bölümün öldüğünü üst çubuktan okuyamıyor**, gözü aşağıdaki 8 px çubuklara gitmek zorunda.
- **5–15. dalga (Hayatta Kalma):** Rekor bot verisi 35–45. dalga. Laboratuvar biten (≈ 6250 hurda) oyuncu için Hayatta Kalma her koşuda aynı zorlukta; "daha zor ama daha ödüllü" seçeneği yok. Geç oyunda koşu yalnızca rekor kovalamak; Hades'in Heat'i gibi bir zorluk merdiveni eksik.
- **Kampanya döngüsü:** Gece 4 TEKRAR + OTO ile altın kasmayı açtı ama her tekrardan sonra oyuncu "TEKRAR" düğmesine basmak zorunda; 30. dalga duvarında 10 tekrar = 10 dokunuş + her seferinde 0.8 sn kart bekleyişi. Grow Castle oyuncusunun beklediği "bırak oynasın" döngüsü yarım. Sayı: 29. dalga tekrarı ½ × (20 + 6·29) = 97 altın; Güç 15→16 fiyatı 50·1.18^15 ≈ 600 altın → **≈ 6 tekrar** = 6 ekran dokunuşu + 6 bekleme.
- **Meta ekonomisi:** Hurda tek yerde (Lab, Sur, maden, silah) birikiyor ama **kampanya altınının** tek kaynağı savaş. Kasaba'da yalnızca Hurda Madeni var; FM tarafındaki "tesisler" (antrenman, revir) hiç yok: yorgunluk saatte −12 sabit, antrenman 0.35 puan sabit, silah geliştirme fiyatı sabit. Ekip yönetimi kararlarına etki eden kalıcı bir yatırım yok.
- **Uzun vadeli hedef:** Görevler günlük, yıldızlar kampanyaya özel. "Toplam 1000 zombi", "5 Dev", "Sur 17" gibi kilometre taşları yok; oyuncunun geçmişte yaptıkları hiçbir yerde birikmiş bir başarı olarak görünmüyor.
- **Performans riski (bu gecenin işleri):** Kasaba ve başarımlar yalnızca menüde (oyun döngüsüne iş eklemez). Tehdit yalnız koşu başında çarpan. HUD bölüm şeridi 6 dikdörtgen, yalnızca can değişince yeniden çizilir. Oto tekrar sayacı tek bir float.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Hades — Pact of Punishment (Heat):** 15 şalter, her kademe 1–3 puan (Hard Labor 5 kademe × +%20 düşman hasarı, Jury Summons 3 × +%20 düşman, Calisthenics 2 × +%15 can, Convenience Fee 2 × +%40 fiyat). Ödül silah başına **yeni Heat** için verilir; puanı birer birer artırmak ödüllendirilir, büyük atlamak ara ödülleri kaybettirir. Ders: zorluğu oyuncu seçer, ödül "yeni tepe" anına bağlıdır → bitmiş Hayatta Kalma'ya bir tur daha sebebi.
- **Başarımlar (Kwak 2022, 13.792 PlayStation oyunu):** Bronz/Gümüş/Altın kademeli kupalar; tekrarlı şartlar tamamlanma oranını düşürüyor, oyuncuların bir kısmı başarımları "ek iş" olarak görüyor (Cruz 2017). Ders: normal oynarken kendiliğinden dolan, kademeli (her zaman "bir sonraki" görünen) ve ödülü hemen alınan başarımlar; angarya şartı yok.
- **Grow Castle kasabası / FM tesisleri:** Kale dışında seviye atlayan binalar, her biri tek bir sayıyı (üretim, eğitim, iyileşme) büyütür; FM'de antrenman tesisi gelişimi, sağlık tesisi sakatlık süresini etkiler. Bizde FM tarafı derin ama tesis ekseni boş.
- **Grow Castle oto savaş:** geçilmiş dalgada oyun kendini tekrarlar; oyuncu telefonu bırakır, döner, yükseltir. "Bırak oynasın" ile "dönünce yükselt" birleşimi idle türünün çekirdeği.
- **PvZ Screen Door / BTD6 Monkey Knowledge (Fikir Havuzu için):** kalkan düz atışı keser, alan hasarı geçer; oyuncu seviyesi başına 1 bilgi puanı ile seçmeli kalıcı ağaç.
- **Psikoloji özeti:** (1) En önemli karar ilk ekranda olmalı. (2) Zorluk seçme özgürlüğü + yeni tepe ödülü. (3) Geçmiş başarı görünür birikim olmalı. (4) Gedik gibi "felaket" anları adil, okunur ve geri çevrilebilir olmalı; kendi kendini besleyen döngü öfke yaratır.

### Karar (bu gece)
**3 geliştirme**
1. **Barikat v3 — gedik dengesi ve okunurluk:** gedik taşma çarpanı 1.5 → 1.3; HUD can çubuğunun altında 6 bölümlü şerit (gedik kırmızı yanıp söner); gedik varken ONAR düğmesi kırmızı "GEDİK! ONAR" olur (akıllı onarım zaten önce gediği kapatıyor; ölçüm: tek onarım gediği 0 → %37'ye çıkardı). *Gerekçe:* Analiz 1'deki kendi kendini besleyen gedik döngüsü ve okunmayan HUD.
2. **Kampanya v3 — OTO TEKRAR döngüsü:** TEKRAR + OTO zaferinden sonra 3 sn geri sayımla aynı dalga kendiliğinden yeniden başlar; yenilgide ya da düğmeyle durur; seri sayısı ve toplam altın gösterilir. *Gerekçe:* Grow Castle oto savaşı; 6 tekrar = 6 dokunuş sürtünmesi.
3. **Menü v2 — OYNA sekmesi sadeleşir:** iki mod en üstte, lider kartı kısalır, Kasaba kendi sekmesine taşınır (OYNA'da tek satırlık özet + TOPLA kalır), en yakın başarım satırı. *Gerekçe:* Analiz 1, 760/1250 px kaydırma.

**3 yeni özellik**
1. **B6 Kasaba sekmesi:** Hurda Madeni (taşındı) + **Çiftlik** (çevrimdışı kampanya altını), **Antrenman Sahası** (yedek gelişimi +%10/sv), **Revir** (dinlenme +%10/sv, sakatlık şansı −%6/sv), **Atölye** (silah geliştirme −%4/sv). *Gerekçe:* §0 B6 son açık madde; FM tesisleri.
2. **Başarımlar:** 12 başarım × Bronz/Gümüş/Altın, ödül 40/100/250 hurda, normal oyunla dolar, elle AL. *Gerekçe:* Analiz 2, kalıcı hedef zinciri (Yol Haritası Gece 3'ten beri).
3. **Tehdit Seviyesi (Hayatta Kalma):** 4 şalter (Kalabalık, Dişli, Kalın Deri, Karaborsa), en çok 11 puan, puan başına +%10 hurda, yeni tepe (10. dalga+) ilk kez → garanti silah. 15. dalga rekoruyla açılır. *Gerekçe:* Hades Heat; bitmiş meta için zorluk merdiveni.

## 2026-11-07 — Gece 4

### Analiz 1 — Oynanış simülasyonu (kod, ekran görüntüsü ve sayılarla)
- **İlk 5 dakika:** Barikat tek bir can havuzu (300 × Sur). 8. dalgada yürüyen 6 × 1.16 ≈ 7 hasar/sn vuruyor; hangi sütunda vurduğu hiç fark etmiyor. Asker parmakla sağa sola gidiyor ama konum yalnızca menzili etkiliyor: **barikatın neresinin tehlikede olduğu diye bir bilgi ve karar yok.** ONAR düğmesi "tüm barikata %25" verdiği için onarım da yer seçmiyor. Kingdom Rush'ta "şu yol sızıyor" hissi oyunun yarısı; bizde yok.
- **5–15. dalga:** `11_kalabalik.png`'de zombiler üst üste biniyor (sol kenarda 4–5 zombi tek yığın); 120 zombilik testte de aynı. Telefon ekranında yığın tek zombi gibi okunuyor, oyuncu kalabalığın boyunu ölçemiyor. Hareket yalnızca `sin` ile salınım: zombiler birbirini görmüyor, zırhlı ile koşucu arasında hiçbir ilişki yok; Analiz 3'ün (Gece 3) "düşmanlar hep aynı şeyi sınıyor" bulgusu hareket katmanında hâlâ geçerli.
- **Kampanya döngüsü (en önemli bulgu):** Zafer ekranı (`30_kampanya_zafer.png`) "SONRAKİ / MENÜ" ve iki satır ödül. Yükseltme yapmak için: MENÜ → OYNA sekmesinde 760 px aşağı kaydır → Sur kartı → Yükselt → yukarı kaydır → Kampanya. Döngü başına ≈ 5 dokunuş + 2 kaydırma. Grow Castle'da yükseltme düğmeleri savaş ekranının hemen altında: "bir yükseltme, bir dalga" saniyeler sürer. Ayrıca zafer ekranı **nasıl** kazandığını söylemiyor: barikat %100 ile kazanmak ile %5 ile kazanmak aynı ödül → geçilmiş dalgayı daha iyi oynamak için sebep yok.
- **Kampanya ekonomisi:** 20. dalgada zafer 140 altın; Güç 10→11 fiyatı 50·1.18^10 ≈ 262 altın → iki zafer = bir Güç seviyesi. Yenilgide %25 = 35 altın. Bot 50–60. savaşta 30. dalgaya takılıyor (Dev duvarı): 10 savaşlık takılmada oyuncu aynı dalgayı elle 10 kez oynuyor. Tekrarlı ve yorucu; Grow Castle bunu **otomatik savaş** ve geçilmiş dalgayı tekrar oynayarak altın kasma ile çözüyor.
- **Uygulama dışı:** Oyunu açmak için tek sebep oynamak; keşif en çok 30 dk'lık bir sayaç. Oyuncu 8 saat sonra döndüğünde hiçbir şey birikmemiş. Idle türünün "dönünce birikmiş kazanç" kancası (Clicker Heroes, Grow Castle) yok.
- **Performans riski:** Sürü davranışı her kare n² komşu araması yaparsa 120 zombide 14.400 mesafe/kare: yasak. Izgara (64 px hücre) + saniyede 10 güncelleme ile ≈ 120 × 9 hücre × birkaç komşu: önemsiz. Barikat bölümleri 6 dikdörtgen + bölüm başına can çubuğu: çizim çağrısı birleşir, yalnızca can değişince çizilir.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Grow Castle:** Savaş ekranından çıkmadan yükseltme, otomatik savaş (geçilmiş dalgalarda), kale ve kahraman yükseltmesi; "kısa savaş + hemen yükselt" döngüsü. Bizim kampanyamız kısa savaşa sahip ama yükseltme 2 ekran uzakta: **ödülün hemen harcanabilmesi** (anında tatmin) eksik.
- **Kingdom Rush yıldızları:** Bölüm sonunda kalan cana göre 1–3 yıldız (bilinen kural: 20 candan 18+ → 3, 6+ → 2, yoksa 1; wiki bu oturumdan açılamadı). Yıldızlar kalıcı yükseltmeye harcanır; oyuncu 2 yıldızlı bölüme mükemmel oynamak için geri döner. Bizde kampanyada "daha iyi kazanma" sebebi yok.
- **Clicker Heroes çevrimdışı ilerleme:** Çıkışta "boşta DPS" kaydedilir, dönünce kazanç hesaplanıp **elle toplanır** (topla düğmesi = ödül anı). Aktif yetenekler çevrimdışı sayılmaz. Bizde de çevrimdışı kazanç oyun içi güce bağlı olmalı (kampanyada ulaşılan dalga), sınırlı olmalı (8 saat) ki oyuncu günde 2–3 kez dönsün; saat geri alınırsa 0 (hile önleme).
- **Vampire Survivors / Brotato kalabalıkları:** Düşmanlar birbirini iter (ayrılma), kalabalık şekli okunur; "duvar" ve "akın" ayrımı oyuncuya konum kararı verir. Godot forumunda (pikmin benzeri sürü) fizik motoru yerine kendi CPU ızgarası öneriliyor: fizik düğümleriyle 50 varlık 7 FPS, özel ızgara ile 200 varlık ≈ 90 FPS.
- **Kingdom Rush / PvZ zayıf nokta:** Düşmanın en zayıf şeridi seçmesi oyuncuya "hangi şeridi güçlendireyim" kararı verir. Bizim barikatta şerit yok; 6 bölüm + "en zayıfa saldır" yapay zekâsı bu kararı getirir, ONAR da "en zayıf bölümü önce" yaparsa tek düğme akıllı kalır.
- **Oyuncu psikolojisi özeti:** (1) Ödül → harcama mesafesi kısalmalı. (2) Geçilmiş içeriğe dönme sebebi (yıldız, kasma) lazım. (3) Uygulama dışında birikim, dönüş kancası. (4) Düşman hareketi okunur ve anlamlı olmalı.

### Karar (bu gece)
**3 geliştirme**
1. **A3 Sürü davranışı (zombi hareketi):** ızgaralı ayrılma (üst üste binme biter), koşucular yakındaki zırhlının arkasına saklanır (zırhlı ölünce dağılır), kusan hedef alınınca yana kayar. *Gerekçe:* §0 Gece C; Analiz 1'deki okunabilirlik sorunu.
2. **Kampanya v2: yıldızlar + zafer ekranında yükseltme:** dalga başına 1–3 yıldız (barikat %90+ → 3, %50+ → 2), yıldız eşiklerinde ödül; zafer/yenilgi ekranında doğrudan "Sur +1" ve "Güç +1" düğmeleri. *Gerekçe:* Analiz 1'in en önemli bulgusu; KR yıldızları ve Grow Castle'ın anında yükseltmesi.
3. **ONAR v2 (akıllı onarım) + Performans v5:** onarım ve ekip/Doktor yenilenmesi önce en zayıf bölüme gider; barikat tahtaları bölüm başına çizilir, yalnızca değişince. *Gerekçe:* A2 ile birlikte; tek düğme akıllı kalır.

**3 yeni özellik**
1. **A2 Zayıf nokta hedefleme:** barikat 6 bölüm, her bölümün canı ve çubuğu görünür; zombiler (türüne göre zekâ) en zayıf bölüme yönelir; kırılan bölümde (GEDİK) hasar ×1.5 yanlara taşar. *Gerekçe:* §0 Gece C; konuma anlam.
2. **B4 Otomatik savaş + A6 akıllı kart:** kampanyada geçilmiş dalgalarda OTO düğmesi; lider kendi gider, yetenek ve onarım kendiliğinden, kartı yapay zekâ seçer (zombi karışımına, evrim yoluna göre puan). Ayrıca "geçilmiş dalgayı tekrar oyna" (altın kasma, %50 ödül). *Gerekçe:* §0 Gece D; duvarda tekrar yorgunluğu.
3. **B6 Kasaba ilk bina: Hurda Madeni + çevrimdışı kazanç:** seviyeli maden saatte hurda üretir, en çok 8 saat birikir, kazanç kampanya dalgasıyla büyür; açılışta "Sen yokken" kartı ve TOPLA düğmesi; saat geri giderse 0. *Gerekçe:* §0 Gece D; dönüş kancası.

## 2026-11-06 — Gündüz ek turu 1/3

### Analiz 1 — Oynanış simülasyonu (kod ve sayılarla)
- **İlk açılış:** Tek mod var: Hayatta Kalma koşusu. 10–15 dakikalık koşu, telefonda "2 dakikam var" anına uymuyor. Grow Castle'ın gücü kısa savaş: bir dalga ≈ 30–60 sn, kaybetsen de bir şey yükseltip hemen tekrar.
- **Kalıcı güç kaynakları:** Laboratuvar (toplam ≈ ×1.3 DPS, ≈ 6250 hurda) ve silah geliştirme. Barikat canını kalıcı büyütmenin tek yolu Lab'ın %4'lük düğümü (en çok +%20). Surdaki ekipte yuva sayısı 2'de sabit; yeni ekip üyesinin bir sınırı var ama bu sınırı açan bir hedef yok.
- **Altın:** Koşu içi para; koşu bitince sıfırlanıyor. Grow Castle'daki "altın biriktir → kahramanı yükselt" döngüsü bizde yok, oysa FM ekibi tam bunun için uygun: her kişinin ayrı yükseltme ekseni olursa kimi yükselteceğin bir karar olur.
- **Nöbetçi silahı:** Envanter yalnızca lidere kuşandırıyor; nöbetçi rolünün Sıradan silahıyla oynuyor (Gece 3'ün bilinen sorunu). 40 silahlık envanterin çoğu boşta.
- **Boss:** Dev ve Kraliçe tek davranışlı; %50'de bir çağrı dışında can azaldıkça hiçbir şey değişmiyor. Dev'in son %30'u sıkıcı bir "ham DPS" sınavı.
- **Kampanya sayıları (tasarım hesabı):** Tek kartla 20. dalga: can çarpanı Hayatta Kalma formülüyle 4.03; tek kartlı oyuncu bunu kaldıramaz. Kampanya için yumuşak eğri: 1 + 0.09(n−1) + 0.002(n−1)² → 20. dalga 3.43, 40. dalga 7.6. Oyuncunun gücü Güç seviyesinden (+%10/sv, 50·1.18^sv altın) ve Sur'dan (+%8 can/sv) gelir. Dalga başı altın 20 + 6n (boss ×3): 1–15. dalga ≈ 1020 altın ≈ Güç 0→9 (≈ ×1.9 hasar). Duvarlar bilerek boss dalgalarında olacak; yenilgide %25 altın + yarım hurda verildiği için tekrar oynamak hep ilerletir.
- **Performans riski:** Yeni şeylerin hepsi menü ya da olay anında çalışıyor (sur çizimi bir kez, aşama kontrolü yalnız boss vurulunca). Oyun döngüsüne her kare iş eklenmiyor.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Grow Castle:** Kısa dalga savaşları, kaybedince aynı dalga, kale (can + yuva) ve kahraman yükseltmesi altınla; "bir yükseltme daha, bir dalga daha" döngüsü. Wiki sayfaları bu oturumdan açılamadı; sayılar bizim tasarımımız (§0'daki taslak formüller, Sur fiyatı daha ucuz bir eğriye çekildi: 40·1.16^sv ile 6 yuva ≈ 33 bin hurda tutuyordu, 30·1.10^sv ile ≈ 6.7 bin).
- **Hades / roguelite ile karşılaştırma:** İki mod iki ihtiyaca cevap verir: koşu (çeşitlilik, kart kararları) ve kampanya (kesintisiz ilerleme). Kampanya kartı 1'e indirip gücü kalıcı yükseltmelere bağlamak iki modun birbirini yemesini önler.
- **Boss aşamaları (genel boss tasarımı yazıları):** Can eşiklerinde davranış değişimi, uyarı işaretiyle (telegraph) gelen büyük saldırı ve "öfke" anı, uzun boss savaşını bölümlere ayırır; adil olması için her yeni tehlike önceden gösterilmeli. Dev'in sıçraması iniş yerini 0.9 sn önce işaretler.
- **Kilitli özellik = hedef:** x3 hızın bir başarıya bağlanması hedef duygusu verir (Grow Castle'da hızlandırma ilerlemeyle gelir). Var olanı eksiltmemek için eski oyuncunun x3'ü açık bırakılır.

### Karar (bu tur)
**3 geliştirme**
1. **B5 Güç seviyesi (ekip):** her hayatta kalana kampanya altınıyla Güç seviyesi (+%10 hasar/sv, 50·1.18^sv). *Gerekçe:* §0 Gece B; altının kalıcı yeri, FM ekibine ikinci eksen.
2. **Envanter: nöbetçiye silah verme:** silah kartında surdaki her kişi için "Sura: Ad" düğmesi, takaslı. *Gerekçe:* Gece 3'ün bilinen eksiği.
3. **A4 Boss aşamaları:** Dev %66 öfke (hız ×1.5), %33 işaretli sıçrama; Kraliçe %66 sık doğum, %33 saldırı. *Gerekçe:* §0 Gece C; ham DPS sınavını bölmek.

**3 yeni özellik**
1. **B3 Kampanya modu:** kalıcı dalga sayacı, tek dalga savaş, 1 kart, zafer/yenilgi ekranı, her 10. dalga boss. *Gerekçe:* §0 Gece B; kısa mobil oturum.
2. **B2 Sur kalıcı yükseltmesi:** 50 seviye, can +%8/sv, her 8 seviyede +1 nöbetçi yuvası (6'ya kadar), menüde büyüyen sur çizimi. *Gerekçe:* §0 Gece B; yuva sınırına hedef.
3. **B7 Hız kilitleri:** x3 kampanyada 10. dalgada (ya da Hayatta Kalma rekoru 10) açılır; eski oyuncuya dokunulmaz. *Gerekçe:* §0 Gece D, kampanya geldiği için artık yapılabilir.

## 2026-11-06 — Gece 3

### Analiz 1 — Oynanış simülasyonu (kod ve sayılarla)
- **İlk 5 dakika:** Tabanca 10 hasar × 1.8 atış ≈ 18 DPS (Asker +%10 → 20). 1. dalga 8 yürüyen × 30 can = 240 can, ~12 sn'de temizlenir. Doğum aralığı 1.25 − 0.06n sn, sabit ve tekdüze: dalganın içinde hiç "dalga" yok, zombiler eşit aralıkla damlıyor. İlk 4 dalga bu yüzden "izleme" hissi veriyor; oyuncunun parmağı boşta.
- **5–15. dalga:** 8. dalgada can çarpanı 1 + 0.12·7 = 1.84 → koşucu ≈ 28 can. Lider (20) + 3 Sv1 taret (8 × 1.4 ≈ 11) aynı anda **aynı** "barikata en yakın" zombiyi hedefliyor: 28 canlık koşucuya 20 + 3·11 = 53 hasar yollanıyor, yani bu anlarda atışların **≈ %45'i boşa** (aşırı öldürme). Kalabalıkta en çok ihtiyaç duyulan anda verim düşüyor. Ayrıca her 5 dalgada aynı boss (Dev) geliyor: 5, 10, 15. dalgaların hepsi aynı sınav.
- **Geç oyun:** Bot verisi 35. dalgada duvar gösteriyordu. Duvarı aşmanın tek yolu kart ve taret; koşu dışında biriktirdiğin ekibin (8 kişiye kadar) geç oyuna **hiçbir katkısı yok**.
- **Meta / ekip (en önemli bulgu):** Ekip sekmesinde 6 özellik, kişilik, yorgunluk, mentor, konuşma var; ama savaşa yalnızca **1 kişi** çıkıyor. Keşifte 220 hurda verip bulduğun 2. ve 3. kişi yalnızca "yedek" ve antrenmanla 0.35 puan gelişiyor. FM derinliği ile savaş arasında köprü yok: oyuncu ekibini sahada görmüyor, kimin iyi oynadığını bilmiyor. Grow Castle'ın kalbi tam tersi: kaledeki her kahraman yuvası savaşta görünür ve oyuncu "kimi koysam" diye düşünür.
- **Ekonomi:** Bir nöbetçi (Saldırı Tüfeği 7 × 3.6 = 25 ham DPS) %45 verimle ≈ 11 DPS, 10. dalgada (+%4/dalga) ≈ 16 DPS; bu, Sv1 taretin (13 → 20 DPS) seviyesinde. İki nöbetçi erken oyunda DPS'i ≈ %60–80 artırır ama bunun bedeli keşif hurdası ve yorgunluk: kart/taret ekonomisini bozmadan meta kazancı.
- **Telefonda his / performans:** Hasar yazıları 32 ayrı Label; her biri yazı + dış çizgi ≈ 2 çizim çağrısı ve kendi Tween'i. Kalabalıkta 30 yazı aynı anda açık → ≈ 60 çağrı, yük testindeki 220 çağrının büyük parçası. 6 nöbetçi eklenince mermi ve yazı sayısı artacağı için bu darboğaz önce kapanmalı.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Grow Castle:** Kalenin üstündeki kahraman yuvaları, kahramanların kendiliğinden saldırması ve altınla seviye atlatma; oyuncunun ana kararı **kimi hangi yuvaya koyacağı** ve kimi geliştireceği. Bizde ekip var ama yuva yok. Ders: ekibi sura çıkar, kararı yuva sayısıyla kıt tut (2 yuva → Sur yükseltmesiyle 6).
- **Bloons TD hedefleme seçenekleri (First / Last / Close / Strong):** Oyuncu yapay zekâyı mikro yönetmeden **yönlendirir**: tek dokunuşla "en güçlü" veya "en yakın". Bizim nöbetçilere aynı tek düğme yeter: Rolüne göre / En yakın / En güçlü / Boss önce.
- **Aşırı öldürme önleme (RTS ve TD topluluk tartışmaları):** Her mermi hedefine "gelecek hasar" yazar, kalan canı karşılanan hedef başkalarınca seçilmez. Oyuncu bunu görmez ama "ekip akıllı" hisseder; kalabalıkta DPS artar.
- **Left 4 Dead Yönetmeni:** Sabit akış yerine gerilim → zirve → sönme → rahatlama. Bizim dalgalar kısa, rahatlama 4–8 sn; adil kural: toplam zombi değişmez. Oyuncu rahatsa "kanattan sürpriz" ile parmağına iş çıkar.
- **Football Manager maç puanı ve form:** Her maçtan sonra oyuncu başına 1–10 puan, son 5 maçın ortalaması "form", maçın en iyisi yıldız; puan moral ve gelişimi etkiler. Bizim koşu sonunda kimin ne yaptığı görünmüyor: puan ve "koşunun yıldızı", nöbetçi seçimine veri sağlar (kim surda kalmalı?).
- **PvZ Dr. Zomboss / KR çağırıcı bosslar:** Zombi indiren boss, oyuncuya "kaynağı öldür" önceliğini öğretir; Dev'in ham DPS sınavından farklı bir sınav. Havan ve bombaya anlam verir.

### Karar (bu gece)
**3 geliştirme**
1. **Dalga sistemi → Yönetmen (A1):** gerilim ölçümü, zirve/sönme/nefes evreleri, sakin oyuncuya kanattan sürpriz, toplam zombi sabit. *Gerekçe:* §0 Gece A; tekdüze doğum ve "izleme" sorunu.
2. **Performans v4:** hasar yazıları 32 Label → tek düğüm (`yazilar.gd`), yük testine 6 nöbetçi eklendi. *Gerekçe:* Mehmet Ali'nin 1 numaralı kuralı; yeni nöbetçi mermileri yükü artıracak.
3. **Koşu sonu v3 / FM: maç puanı ve form:** lider ve nöbetçilere 1–10 puan, koşunun yıldızı, son 5 puan form, puan → moral. *Gerekçe:* Ekip ↔ savaş köprüsü, nöbetçi seçimine bilgi.

**3 yeni özellik**
1. **Surdaki ekip (B1):** barikatta 2 nöbetçi yuvası; Ekip sekmesinden "Sura koy"; kendi silahı, rolü, özellikleriyle ateş eder; koşu sonunda gelişir ve yorulur. *Gerekçe:* §0 Gece A'nın ilk maddesi, Analiz 1'in en önemli bulgusu.
2. **Ekip yapay zekâsı (A5):** rol bazlı hedefleme, nöbetçi başına hedef modu, aşırı öldürme önleme (lider ve taretler dahil), boşta Mühendis/Doktor onarımı. *Gerekçe:* §0 Gece A; boşa giden atışlar.
3. **Boss 2: Kraliçe:** 10, 20, 30. dalgada Dev yerine; geride durur, 4 sn'de 2 koşucu doğurur, 6 doğumdan sonra barikata yürür. *Gerekçe:* Yol haritasında "sıradaki öncelik"; her boss dalgasının aynı olması.

## 2026-11-06 — Gece 2

### Analiz 1 — Oynanış simülasyonu (kod ve sayılarla)
- **İlk 5 dakika:** Başlangıç ≈ 18–20 DPS. 5. dalga Dev'i: 480 × 1.48 ≈ 710 can, zırh 2.5 → tabancanın 10 hasarı 7.5'e düşer, net ≈ 15 DPS, yalın 47 sn. Dev barikata 37 sn'de varır, sonra 2.8 sn'de 32 hasar (≈ 11 DPS), 300 can 26 sn dayanır. 4 kartla kazanılır, ilk boss bilerek kolay: doğru. Sorun öğretimde: ipucu yalnız "kaydır" diyor; ONAR, aktif yetenek ve taret hiç anlatılmıyor. Bir de düğme tuzağı: taret düğmesi üstünden başlayan sürükleme askeri oynatmıyor, oyuncu parmağını doğal yerine koyunca oyun tepki vermiyor.
- **5–15. dalga:** Dalga başı zombi 6 + 2n, tür başına altın 2–5. 15. dalgaya dek ≈ 900 altın; taretler (60+96+154)×3 = 930 ile bunu tam yutuyor. Tasarım burada iyi. **Ama tek tür düşman sınaması var: hepsi yürür, ya vurulur ya vurur.** Hedefleme de otomatik, yani konum hâlâ önemsiz. Kalabalıkta oyuncuyu "şunu şimdi öldür" ya da "şurada patlat" kararına sokan bir şey yok.
- **Geç oyun (15–35):** 25. dalgada toplam altın ≈ 2200; taretler 930, onarım fiyatı artsa da 10 onarım ≈ 475. Yani ≈ 800 altın boşa birikiyor: **Gece 1'in ekonomi kırığı geç oyunda geri geldi.** Taret de tek tip (tekli hedef): dalga 25'te zırh 4 + 0.35·25 = 12.75, 3. seviye taretin 18×2.25 hasarı dert değil ama zırhlı yığına alan hasarı yok.
- **Koşu sonu/meta (en önemli bulgu):** Dalga 12 koşusu 192 hurda veriyor. Hurdanın iki yeri var: silah geliştirme (Sıradan silahı Sv10'a ≈ 600 hurda) ve keşif. Ama silah değişince harcanan hurda boşa gider, oyuncu ödül ekranından sonra "şimdi ne alsam" diye kalmıyor; **koşular arası uzun vadeli, kalıcı, seçim isteyen bir hedef yok.** Laboratuvar iki gecedir "sıradaki" diye bekliyor. Bitiş ekranı ödülleri sayıyor ama **"neden öldüm" demiyor**: oyuncu kusana mı Dev'e mi yenildiğini bilmiyor, bir sonraki kart seçimi öğrenmiyor. Ekip tarafında moral otomatik; koşu sonu oyuncunun tek söz hakkı yok.
- **Telefonda his / performans riski:** Kahraman her kare 13 daire + 2 yumuşatılmış çizgi: birleşmediği için ≈ 15 ayrı çizim çağrısı, tek karakter için. 52 ayrı CPUParticles2D düğümü var, her biri kendi çizim çağrısı ve işlem yükü. Bunlar yük testindeki 232 çağrının büyük parçası olmalı. Yol haritasında Performans v3 duruyor.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Kingdom Rush kalıcı ağacı:** 6 ağaç, ağaç başı 5 yükseltme, tek yükseltme küçük (+%10 can, +%15 büyü). Yıldızı bölüm bitirerek kazanırsın. Ders: küçük adımlar, görünür ağaç, kaçırılmayan ilerleme.
- **Meta çeşitlilik mi güç mü (Slay the Spire, Balatro, Hades):** Saf güç metası koşuyu değersizleştirir ve zorluk kayar; saf çeşitlilik ise bizim gibi kısa mobil koşuda "her ölüm ilerleme" hissini vermez. Hades ortada durur: az kalıcı güç, çok seçim. Bizim için doğru yer ortası: küçük yüzdeler + dal sonunda **oynanışı değiştiren** düğüm ("ikinci şans", "ücretsiz çekim").
- **Fark türü vs fark ölçeği:** Escapist yazısının dersi: +5 hasar ancak oynamayı değiştiriyorsa anlamlı (iki vuruş → tek vuruş). "Kind" farklar daha akılda kalır. Taret uzmanlığı (alan vs zırh delme) tam bu; 4. seviye bir sayı artışı olmamalı.
- **Football Manager takım konuşması:** Etkiyi belirleyen şey sonucun **beklentiye** göre durumu ve oyuncunun kişiliği; aynı konuşmayı tekrarlamak etkisini yitirir; bazen hiçbir şey dememek doğrudur. Bizde moral sadece dalgaya bağlı, konuşma yok. Küçük bir karar ekleyerek ekip "tablo" olmaktan çıkar, hikâye üretir.
- **PvZ / Vampire Survivors patlayan düşman mantığı:** Patlayıcı düşman iki yönlü: yanlış yerde felaket, doğru yerde silah. Hedefleme otomatik olsa bile, kritik hedefi öncelikli yapmak ve patlamasının kalabalığı da vurması "güzel an" üretir.
- **Ölüm özeti (roguelite ortak dili):** İyi roguelitelar ölüm anında "bir dahakine şunu yap" bilgisini verir. Oyuncu yenilgiyi kendi hatasına ve çözülebilir bir soruna bağlarsa bir tur daha başlatır.

### Karar (bu gece)
**3 geliştirme**
1. **Performans v3** — parçacıklar tek düğümde toplu çizilir (52 düğüm → 1), kahraman dokuya pişirilir. *Gerekçe:* Mehmet Ali'nin 1 numaralı isteği; her kare ölçülebilir kazanç.
2. **Kule v2: uzmanlık** — 3. seviye taret 240 altına Havan (alan, zırhı aşar) veya Ağır Taret'e (tek hedef, zırh deler) dönüşür. *Gerekçe:* Geç oyundaki 800 boş altın + "fark türü" kuralı.
3. **Koşu sonu ekranı v2 + ilk koşu öğretimi** — ölüm özeti (barikatın canını en çok ne yedi, ne yapmalı), sonraki hedef, ipuçları ONAR/aktif/taret'i de anlatır, taret düğmesi üstünden sürükleme hatası kapanır. *Gerekçe:* Öğrenme döngüsü ve "bir tur daha".

**3 yeni özellik**
1. **Laboratuvar** — hurdanın kalıcı yeri: 3 dal, dal başı 3 düğüm (5 seviye) + oynanışı değiştiren dal sonu. *Gerekçe:* Analiz 1'in en önemli bulgusu, yol haritasında sıradaki.
2. **Patlayan zombi** — 8. dalgada gelir, barikatta alan hasarı verir; yolda vurulursa çevresindeki zombileri patlatır. *Gerekçe:* Yol haritası; kalabalığa ilk konum/zamanlama kararı.
3. **Koşu sonu ekip konuşması (FM v3 ilk parça)** — Öv / Sert konuş / Sessiz kal; sonuç performans-beklenti ve kişiliğe bağlı, tekrar edince zayıflar. *Gerekçe:* §0 FM isteği.

## 2026-11-05 — Gündüz turu (elle başlatılan 2. döngü)

### Analiz 1 — Oynanış simülasyonu
- **İlk 5 dakika:** Boss, zırhlı ve tanıtım paneli ilk koşuya olay getirdi. Ama parmağın tek işi hâlâ kaydırmak. Hedefi asker seçtiği için konum neredeyse etkisiz: oyuncu çoğu saniye izliyor.
  Gece 1'in en büyük açığı bu: **ekonomi düzeldi, eylem düzelmedi.**
- **5–15. dalga:** 10 dalgada ≈ 390 altın düşüyor; artan fiyatla bu ≈ 9 onarım eder (25+30+…+65). Yeniden çekme de altın istiyor, güzel. Yine de 2 harcama yeri aynı soruya cevap: "şu an ölüyor muyum?"
  **Yatırım** kararı yok: şimdi harcayıp sonra kazanmak mümkün değil. 3 yuva × 3 seviyeli taret (60/96/154 = 930 altın) tam bu boşluğu dolduruyor: 15. dalgaya kadar kazanılan altının (≈ 900) neredeyse tamamını yutar.
- **Geç oyun:** Bot verisi 15–35. dalga, ölümler boss dalgalarında. Boss, oyuncunun müdahale edemediği bir DPS sınavı: onarım dışında elinden gelen yok. Aktif yetenek bu anı oyuncunun anına çevirir.
- **Koşu sonu/meta:** Yorgunluk rotasyon getirdi, ama yedeklerin gelişim kararı zayıf (mentor yok). Keşif raporu: 6 sayfa sayı var ama "bunu alayım mı?" sorusuna cevap vermiyor. Rapor 7. keşifte en eskisi siliniyor, beğendiğin adayı saklayamıyorsun.
- **Geri dönüş:** Telefonu açmak için bir neden sadece keşif süresi. Günlük hedef yok.
- **Ses/his:** Bütün sesler sentez; para ve kırılma sesleri zayıf. Kenney'in CC0 starter kit depolarında işe yarar sesler var.
- **Performans riski:** Yeni taretler en fazla 3 düğüm + hedef arama, 0.2 sn'ye seyreltilirse ihmal edilebilir. El bombası yalnızca bir kere dolaşır.

### Analiz 2 — Karşılaştırma ve psikoloji
- **Kingdom Rush:** Oyuncu kuleleri kurar, ama asıl heyecan bekleme süreli büyüler (Rain of Fire, Reinforcements): **"tam zamanında bastım"** duygusu. Kule yeri + para = yatırım; büyü = beceri anı. İkisi ayrı döngü, ikisi de bizde eksik.
- **Archero / Survivor.io:** Otomatik ateşli oyunlarda bile oyuncunun bir eylemi vardır (kaçmak). Bizde yok, aktif düğme bunun en ucuz karşılığı.
- **Günlük görevler:** Araştırma iki yönlü: kısa ve seçenekli olunca geri dönüşü artırır, angarya olunca zarar verir. Kural: az görev (3), oynarken kendiliğinden biten hedefler, kaçırınca ceza yok.
- **FM mentorluk:** Yaşlı oyuncu gence bağlanır, kişiliği zamanla gence geçer. Hikâye üretir ("Selin, Kerem'i profesyonel yaptı") ve yaşlılara kadro değeri verir. Bizde 35 yaşındaki biri işe yaramaz.
- **FM gözlemci:** Rapor tek bir öneri notu verir, kısa liste saklar. Bilgi az olsa da oyuncuya kanaat verir.

### Karar
**3 geliştirme:** (1) **Ses v2:** Kenney CC0 sesleri (para, kırılma, darbe, yerleştirme). (2) **Ekip gelişimi:** mentorluk ile yaşlı personele yeni rol. (3) **Keşif v2:** gözlemci önerisi ve kısa liste.

**3 yeni özellik:** (1) **Rol aktif yetenekleri:** oyuncuya beceri anı. Analizin 1 numaralı bulgusu. (2) **Kule yuvaları:** altının yatırım yeri. (3) **Günlük görevler:** geri dönüş hedefi.

## 2026-11-05 — Gece 1

### Analiz 1 — Oynanış simülasyonu (kod ve sayılarla)
- **İlk 5 dakika:** Menü net, "SAVAŞA BAŞLA" tek dokunuş. Başlangıç askeri ≈ 12 hasar × 1.7 atış/sn ≈ **20 DPS**.
  1. dalga: 8 yürüyen × 30 can = 240 can, ≈ 9–13 sn'de doğuyor, 19 sn'de barikata varıyor → yürüme payı sayesinde 20 DPS yetiyor. İyi.
  Asıl sorun: oyuncunun tek kararı "sağa sola kaydırmak"; nişan otomatik olduğu ve hedef hep "en alttaki" olduğu için
  konum neredeyse önemsiz. İlk 5 dakika **izleme** oyunu.
- **5–15. dalga:** Gereken DPS (toplam can / doğum süresi) 5. dalgada ≈ 38, 10.'da ≈ 71, 15.'te ≈ 168, 20.'de ≈ 205.
  Dengeli kart alan oyuncu ≈ 30 / 90 / 90–200 / 200. Barikat ve onarım bu farkı örtüyor.
  Eğri makul ama **tek bir sayıya** bağlı: DPS. Sadece 2 zombi türü var; ikisi de aynı şeyi sınıyor. Hangi kartı aldığın
  fark etmiyor, her şey "daha çok DPS". 5. dalgadaki "yoğun saldırı" bir sayı artışı; olay değil. Tasarımda vaat edilen boss yok.
- **Ekonomi kırığı (en önemli bulgu):** İlk 10 dalgada ≈ 390 altın düşüyor. Altının **tek** harcama yeri 25 altınlık sabit onarım:
  10 dalgada 15 onarım = barikatın %375'i. Yani altın karar değil, bedava can. Barikat çoğu zaman doluysa altın boşa birikiyor.
- **Geç oyun:** 8 kart toplam 28 seviye; 28. dalgada kart biter ve ekran sessizce atlanır (ödül yok, boş his).
  Oyuncu gücü üstel (20→400+ DPS, delme ve kritikle daha fazla), zombi canı doğrusal (1+0.12n), doğum aralığı 0.35'te duruyor. Gereken DPS 30–40. dalgada ≈ 280–350;
  iyi kartla koşu **hiç bitmeyebilir**. Evrim yok, kartlar birleşmiyor.
- **Koşu sonu/meta:** Hurda yeterli, ödül ekranı temiz. Ama ekipte karar yok: en iyi kişiyi seçip hep onu oynatmak her zaman doğru.
  Kişilik yok, yorgunluk yok, sakatlık yok → FM hissi tablodan ibaret. Keşifteki "İncele"nin tek faydası sayıları netleştirmek.
- **Telefonda his / performans riski:** Her zombi her kare ≈ 25 çizim komutu üretiyor (`queue_redraw` + daireler/çizgiler);
  60 zombi ≈ 1500 komut/kare ve her zombi ayrı parti. `zombiler.any(lambda)` her kare. Eski telefonda en büyük kasma adayı bu.
  Otomatik kalite düşürme yok: telefon ısınınca oyuncu kendi ayar bulmalı.

### Analiz 2 — Karşılaştırma ve oyuncu psikolojisi
- **Survivor.io:** Evrim = silah 5. seviye + eşli destek yeteneği; boss sandığı evrimi açar. Oyuncu kart seçerken 3 kart sonrasını düşünür:
  **"şunu da alırsam evrimleşir"** planı en güçlü bir-tur-daha kancası. Bizde hiç yok.
- **Kingdom Rush:** Her yeni düşman, tek bir zayıflığı sınar; zırh fiziksel hasarı keser ve "ağır vuruş" gerektirir. İlk boss bilerek kolay,
  zor dalga sonrası nefes. Yeni düşman **tanıtılır** (ansiklopedi kartı). Bizde bunların hiçbiri yok.
- **Archero / Brotato:** Yeniden çekme (reroll) para harcatır ve "kötü şans" hissini oyuncunun kontrolüne verir. Bu, bizim altın kırığının ilacı.
- **Vampire Survivors:** Koşu içinde görünür büyük anlar (evrim sandığı). Bizim ekran 10 dakika boyunca aynı ritimde: büyük an yok.
- **Football Manager:** Bir oyuncu 3 şeyle hatırlanır: kişilik (profesyonel/asabi), form/yorgunluk, sakatlık. Profesyonellik ve hırs gelişimi hızlandırır,
  düşük profesyonellik ve tartışmacılık yavaşlatır. Rotasyon kararı sistemi canlı yapar. Bizde en iyi kişi sonsuza dek oynar.
- **Roguelite meta kuralı:** Kalıcı güç, koşudaki beceriyi **güçlendirmeli**, gereksizleştirmemeli. Boss ganimeti (garanti Ender+) koşu başına net hedef verir:
  "bu sefer Dev'i öldüreyim".

### Karar (bu gece)
**3 geliştirme**
1. **Performans v2** — zombiler bir kez dokuya pişirilir (atlas), tek çizim partisi; can çubukları tek düğümde; lambdasız süzme; otomatik kalite düşürme;
   120 zombilik yük testi. *Gerekçe:* Mehmet Ali'nin 1 numaralı isteği, en büyük kasma riski.
2. **Kart sistemi v2** — 4 yeni kart, 4 evrim, altınla yeniden çekme, kart bitince boş kalmama, seviye göstergesi. *Gerekçe:* "bir tur daha" kancası + altına ikinci harcama yeri + 28. dalga boşluğu.
3. **Dalga ve ekonomi v2** — artan onarım fiyatı, nefes dalgası, yeni zombi tanıtım afişi, geç oyun can eğrisi, zombi hasarı artışı. *Gerekçe:* Analiz 1'deki iki kırık (bedava onarım, biten geç oyun).

**3 yeni özellik**
1. **Zırhlı ve Kusan zombi** — düz zırh düşük hasarı keser (hızlı ateş ≠ her zaman iyi), kusan uzaktan barikata asit atar ve öncelikli hedeftir. *Gerekçe:* Yol haritası 1. madde; kart seçimini anlamlı yapar.
2. **Boss: Dev + garanti ganimet** — her 5 dalgada, can çubuklu, işaretli vuruşlu, yarı canda koşucu çağıran boss; garanti Ender+ silah. *Gerekçe:* Yol haritası + koşuya büyük an ve hedef.
3. **FM v2: Kişilik, yorgunluk, sakatlık** — 7 kişilik, rotasyon kararı, keşifte kişilik bilgisi. *Gerekçe:* §0'daki sürekli FM isteği; ekipte gerçek karar doğurur.

**Not (kodlama sırasında ölçüldü):** Asıl çizim çağrısı kaynağı zombiler değil, GL Compatibility'de **birleşmeyen çokgenlermiş**:
zemin (1100+ daire), barikat ve kan lekeleri her kare 1500+ çizim çağrısı üretiyordu. Bu yüzden Performans v2 kapsamı zemin, barikat ve lekeleri de pişirmeye genişletildi.
