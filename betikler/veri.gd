extends RefCounted
## Oyunun sabit verileri ve üreticileri: silahlar, nadirlik, ekler, hayatta kalan rolleri,
## özellikler, isimler, keşif bölgeleri. Yeni içerik eklemek için buradaki tablolara kayıt ekle.

# ---------------------------------------------------------------- NADİRLİK
# carpan: temel istatistik çarpanı, ek: rastgele ek özellik sayısı, agirlik: düşme olasılığı ağırlığı,
# max_sv: geliştirilebileceği en yüksek seviye
const NADIRLIK: Array[Dictionary] = [
	{"ad": "Sıradan", "renk": Color("b8b8b8"), "carpan": 1.0, "ek": 0, "agirlik": 55.0, "max_sv": 10},
	{"ad": "Nadir", "renk": Color("5fcf5f"), "carpan": 1.15, "ek": 1, "agirlik": 28.0, "max_sv": 15},
	{"ad": "Ender", "renk": Color("4f9bff"), "carpan": 1.35, "ek": 2, "agirlik": 12.0, "max_sv": 20},
	{"ad": "Destansı", "renk": Color("b06cff"), "carpan": 1.6, "ek": 3, "agirlik": 4.0, "max_sv": 25},
	{"ad": "Efsanevi", "renk": Color("ffb52e"), "carpan": 2.0, "ek": 4, "agirlik": 1.0, "max_sv": 30},
]

# ---------------------------------------------------------------- SİLAHLAR
# hasar: mermi başına, ates: saniyedeki atış, menzil: piksel, namlu: atış başına mermi,
# yayilim: namlular arası açı (radyan), delme: kaç zombiyi deler, mermi_hizi
const SILAHLAR: Dictionary = {
	"tabanca": {"ad": "Tabanca", "hasar": 10.0, "ates": 1.8, "menzil": 620.0, "namlu": 1, "yayilim": 0.09,
		"delme": 0, "mermi_hizi": 1100.0, "kritik": 0.03, "boy": 26.0, "aciklama": "Dengeli, güvenilir."},
	"tufek": {"ad": "Saldırı Tüfeği", "hasar": 7.0, "ates": 3.6, "menzil": 680.0, "namlu": 1, "yayilim": 0.09,
		"delme": 0, "mermi_hizi": 1250.0, "kritik": 0.03, "boy": 40.0, "aciklama": "Hızlı ateş, koşuculara iyi."},
	"pompali": {"ad": "Pompalı", "hasar": 7.0, "ates": 1.0, "menzil": 430.0, "namlu": 5, "yayilim": 0.12,
		"delme": 0, "mermi_hizi": 1000.0, "kritik": 0.02, "boy": 36.0, "aciklama": "Yakında yıkıcı, menzili kısa."},
	"keskin": {"ad": "Keskin Nişancı", "hasar": 34.0, "ates": 0.65, "menzil": 1000.0, "namlu": 1, "yayilim": 0.0,
		"delme": 2, "mermi_hizi": 1700.0, "kritik": 0.12, "boy": 52.0, "aciklama": "Delip geçer, kritik ustası."},
	"makineli": {"ad": "Makineli", "hasar": 5.5, "ates": 6.5, "menzil": 600.0, "namlu": 1, "yayilim": 0.14,
		"delme": 0, "mermi_hizi": 1150.0, "kritik": 0.02, "boy": 46.0, "aciklama": "Durmaksızın mermi yağmuru."},
}

# Silahlara rastgele gelen ek özellikler (Diablo tarzı). deger: ek başına aralık.
const EKLER: Array[Dictionary] = [
	{"id": "hasar", "ad": "Hasar", "min": 0.06, "max": 0.15, "yuzde": true},
	{"id": "ates", "ad": "Ateş hızı", "min": 0.05, "max": 0.12, "yuzde": true},
	{"id": "kritik", "ad": "Kritik şansı", "min": 0.02, "max": 0.06, "yuzde": true},
	{"id": "menzil", "ad": "Menzil", "min": 0.05, "max": 0.12, "yuzde": true},
	{"id": "altin", "ad": "Altın kazancı", "min": 0.08, "max": 0.2, "yuzde": true},
	{"id": "delme", "ad": "Delme", "min": 1.0, "max": 1.0, "yuzde": false},
	{"id": "barikat", "ad": "Barikat canı", "min": 0.05, "max": 0.12, "yuzde": true},
]

# ---------------------------------------------------------------- HAYATTA KALANLAR (FM tarzı)
# Özellikler 1-20 arası (Football Manager ölçeği).
const OZELLIKLER: Array[Dictionary] = [
	{"id": "nisancilik", "ad": "Nişancılık", "etki": "Mermi hasarı"},
	{"id": "refleks", "ad": "Refleks", "etki": "Ateş hızı ve nişan alma"},
	{"id": "sogukkanlilik", "ad": "Soğukkanlılık", "etki": "Kritik vuruş şansı"},
	{"id": "dayaniklilik", "ad": "Dayanıklılık", "etki": "Barikat canı"},
	{"id": "muhendislik", "ad": "Mühendislik", "etki": "Onarım gücü"},
	{"id": "liderlik", "ad": "Liderlik", "etki": "Altın kazancı ve moral"},
]

# rol: oyun tarzı + pasif yetenek. anahtar: rolün önem verdiği özellikler (gelişimde öncelik).
const ROLLER: Dictionary = {
	"asker": {"ad": "Asker", "renk": Color("6b8237"), "pasif": "Hasar +%10",
		"anahtar": ["nisancilik", "refleks"], "silah": "tufek"},
	"avci": {"ad": "Avcı", "renk": Color("8a6d3b"), "pasif": "Kritik şansı +%8, kritik hasarı +%50",
		"anahtar": ["sogukkanlilik", "nisancilik"], "silah": "keskin"},
	"muhendis": {"ad": "Mühendis", "renk": Color("c9902a"), "pasif": "Onarım %60 daha etkili, onarım %30 ucuz",
		"anahtar": ["muhendislik", "dayaniklilik"], "silah": "pompali"},
	"doktor": {"ad": "Doktor", "renk": Color("3f9e9e"), "pasif": "Barikat her saniye canının %0.4'ünü yeniler",
		"anahtar": ["dayaniklilik", "liderlik"], "silah": "tabanca"},
}

const ISIMLER := ["Ali", "Ayşe", "Mehmet", "Zeynep", "Mustafa", "Elif", "Emre", "Selin", "Burak", "Deniz",
	"Kerem", "Ece", "Murat", "Derya", "Okan", "Gizem", "Cem", "Nazlı", "Tolga", "İrem", "Serkan", "Pınar",
	"Hakan", "Seda", "Kaan", "Buse", "Volkan", "Esra", "Barış", "Melis"]
const SOYISIMLER := ["Yılmaz", "Kaya", "Demir", "Şahin", "Çelik", "Yıldız", "Aydın", "Öztürk", "Arslan",
	"Doğan", "Kılıç", "Aslan", "Koç", "Kurt", "Özdemir", "Polat", "Korkmaz", "Erdem", "Tekin", "Bulut"]

# ---------------------------------------------------------------- KEŞİF BÖLGELERİ
# sure: saniye, kalite: ortalama özellik seviyesi, pot: potansiyel tavanı ekleri,
# bilgi: raporun ne kadar net olduğu (0-1; 1 = tüm değerler kesin)
const BOLGELER: Array[Dictionary] = [
	{"id": "kasaba", "ad": "Terk Edilmiş Kasaba", "fiyat": 30, "sure": 120, "kalite": 7.0, "pot": 0.0, "bilgi": 0.35,
		"aciklama": "Kısa ve ucuz. Çoğu sıradan insan."},
	{"id": "us", "ad": "Askeri Üs", "fiyat": 90, "sure": 600, "kalite": 9.5, "pot": 0.5, "bilgi": 0.55,
		"aciklama": "Eğitimli hayatta kalanlar, iyi silahlar."},
	{"id": "sehir", "ad": "Şehir Merkezi", "fiyat": 220, "sure": 1800, "kalite": 11.0, "pot": 1.2, "bilgi": 0.7,
		"aciklama": "Tehlikeli ama yüksek potansiyelli yetenekler."},
]

const EKIP_SINIRI := 8
const ENVANTER_SINIRI := 40


# ================================================================ ÜRETİCİLER

static func nadirlik_sec(sans_bonus: float = 0.0) -> int:
	# sans_bonus: yüksek nadirliklerin ağırlığını çarpar (dalga ilerledikçe artar)
	var toplam := 0.0
	var agirliklar: Array[float] = []
	for i in NADIRLIK.size():
		var a: float = NADIRLIK[i]["agirlik"] * (1.0 + sans_bonus * i)
		agirliklar.append(a)
		toplam += a
	var r := randf() * toplam
	for i in agirliklar.size():
		r -= agirliklar[i]
		if r <= 0.0:
			return i
	return 0


static func silah_uret(taban: String = "", nadirlik: int = -1) -> Dictionary:
	if taban == "":
		taban = SILAHLAR.keys().pick_random()
	if nadirlik < 0:
		nadirlik = nadirlik_sec()
	var ekler: Array = []
	var havuz := EKLER.duplicate()
	havuz.shuffle()
	for i in mini(int(NADIRLIK[nadirlik]["ek"]), havuz.size()):
		var e: Dictionary = havuz[i]
		ekler.append({"id": e["id"], "deger": snappedf(randf_range(e["min"], e["max"]), 0.01)})
	return {"uid": _uid(), "tur": "silah", "taban": taban, "nadirlik": nadirlik, "seviye": 1, "ekler": ekler}


## Silahın son istatistikleri: taban × nadirlik × seviye + ekler.
static func silah_istatistik(s: Dictionary) -> Dictionary:
	var t: Dictionary = SILAHLAR[s["taban"]]
	var n: Dictionary = NADIRLIK[int(s["nadirlik"])]
	var sv := int(s["seviye"])
	var carpan: float = float(n["carpan"]) * (1.0 + 0.06 * (sv - 1))
	var st := {
		"hasar": float(t["hasar"]) * carpan,
		"ates": float(t["ates"]) * (1.0 + 0.015 * (sv - 1)),
		"menzil": float(t["menzil"]),
		"namlu": int(t["namlu"]),
		"yayilim": float(t["yayilim"]),
		"delme": int(t["delme"]),
		"mermi_hizi": float(t["mermi_hizi"]),
		"kritik": float(t["kritik"]),
		"altin": 0.0,
		"barikat": 0.0,
	}
	for e in s["ekler"]:
		match String(e["id"]):
			"hasar": st["hasar"] *= 1.0 + float(e["deger"])
			"ates": st["ates"] *= 1.0 + float(e["deger"])
			"kritik": st["kritik"] += float(e["deger"])
			"menzil": st["menzil"] *= 1.0 + float(e["deger"])
			"altin": st["altin"] += float(e["deger"])
			"delme": st["delme"] += int(e["deger"])
			"barikat": st["barikat"] += float(e["deger"])
	return st


static func silah_gucu(s: Dictionary) -> int:
	var st := silah_istatistik(s)
	var dps: float = st["hasar"] * st["ates"] * st["namlu"] * (1.0 + st["kritik"] * 1.5) * (1.0 + st["delme"] * 0.35)
	return int(round(dps * 10.0))


static func gelistirme_fiyati(s: Dictionary) -> int:
	return int(round(15.0 * pow(1.35, int(s["seviye"]) - 1) * (1.0 + int(s["nadirlik"]) * 0.6)))


static func ek_metni(e: Dictionary) -> String:
	for t in EKLER:
		if t["id"] == e["id"]:
			if bool(t["yuzde"]):
				return "+%d%% %s" % [int(round(float(e["deger"]) * 100.0)), t["ad"]]
			return "+%d %s" % [int(e["deger"]), t["ad"]]
	return ""


static func hayatta_kalan_uret(kalite: float = 7.0, pot_bonus: float = 0.0, rol: String = "") -> Dictionary:
	if rol == "":
		rol = ROLLER.keys().pick_random()
	var yas := randi_range(17, 42)
	var oz := {}
	var anahtar: Array = ROLLER[rol]["anahtar"]
	for o in OZELLIKLER:
		var temel := kalite + randf_range(-3.0, 3.0)
		if anahtar.has(o["id"]):
			temel += 2.5
		oz[o["id"]] = clampi(int(round(temel)), 1, 20)
	# Potansiyel (FM'deki PA): toplam özelliğin ulaşabileceği tavan. Gençlerde daha yüksek olabilir.
	var mevcut := 0
	for k in oz:
		mevcut += int(oz[k])
	var genclik := clampf((30.0 - yas) / 13.0, 0.0, 1.0)
	var pot := mevcut + int(round(randf_range(2.0, 10.0) + genclik * randf_range(4.0, 22.0) + pot_bonus * 8.0))
	pot = mini(pot, 20 * OZELLIKLER.size())
	return {
		"uid": _uid(), "ad": "%s %s" % [ISIMLER.pick_random(), SOYISIMLER.pick_random()],
		"rol": rol, "yas": yas, "oz": oz, "potansiyel": pot, "moral": 60, "xp": 0, "seviye": 1,
		"odak": anahtar[0], "kosu": 0, "en_iyi_dalga": 0,
	}


static func toplam_ozellik(h: Dictionary) -> int:
	var t := 0
	for k in h["oz"]:
		t += int(h["oz"][k])
	return t


## Yetenek (FM'deki CA) ve potansiyel (PA) yıldızları: 0.5 - 5 arası.
static func yildiz(deger: int) -> float:
	return clampf(snappedf((float(deger) - 30.0) / 66.0 * 5.0, 0.5), 0.5, 5.0)


static func moral_metni(m: int) -> String:
	if m >= 85:
		return "Çok iyi"
	if m >= 65:
		return "İyi"
	if m >= 45:
		return "Normal"
	if m >= 25:
		return "Düşük"
	return "Çok düşük"


static func _uid() -> String:
	return "%d_%d" % [Time.get_ticks_usec(), randi() % 100000]
