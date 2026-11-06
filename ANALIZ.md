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
