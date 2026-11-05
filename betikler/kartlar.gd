extends RefCounted
## Koşu içi yetenek kartları. Yeni kart eklemek için listeye bir sözlük ekle ve
## oyun.gd içindeki _karti_uygula() fonksiyonuna etkisini yaz.

const LISTE: Array[Dictionary] = [
	{"id": "ates_hizi", "ad": "Seri Ateş", "aciklama": "Ateş hızı +%20", "max": 5, "renk": Color("e8a33d")},
	{"id": "hasar", "ad": "Ağır Mermi", "aciklama": "Hasar +%25", "max": 5, "renk": Color("d9534f")},
	{"id": "delme", "ad": "Delici Mermi", "aciklama": "Mermi 1 zombiyi daha deler", "max": 3, "renk": Color("8e6cc9")},
	{"id": "namlu", "ad": "Çift Namlu", "aciklama": "Her atışta +1 mermi", "max": 3, "renk": Color("5b8def")},
	{"id": "kritik", "ad": "Kritik Vuruş", "aciklama": "%12 şansla 2.5 kat hasar", "max": 4, "renk": Color("f0c419")},
	{"id": "menzil", "ad": "Dürbün", "aciklama": "Menzil ve mermi hızı +%15", "max": 3, "renk": Color("3fb68b")},
	{"id": "barikat", "ad": "Sağlam Barikat", "aciklama": "Barikat canı +%25, tamamen onarılır", "max": 5, "renk": Color("a0703c")},
	{"id": "altin", "ad": "Hazine Avcısı", "aciklama": "Zombilerden +%30 altın", "max": 3, "renk": Color("d4af37")},
	{"id": "yanma", "ad": "Yanıcı Mermi", "aciklama": "Vurulan zombi 3 sn yanar (zırhı aşar)", "max": 3, "renk": Color("e8622c")},
	{"id": "zirh_delici", "ad": "Zırh Delici", "aciklama": "Zırhın 4 puanını yok sayar", "max": 3, "renk": Color("9aa7b5")},
	{"id": "diken", "ad": "Dikenli Tel", "aciklama": "Barikata vuran zombi 10 hasar alır", "max": 3, "renk": Color("7f9c5a")},
	{"id": "tamirci", "ad": "Tamirci", "aciklama": "Barikat saniyede %0.5 yenilenir", "max": 3, "renk": Color("4fb0a5")},
]

# Kartlar bitince boş kalmasın (dolgu kartları, sınırsız)
const DOLGU: Array[Dictionary] = [
	{"id": "kese", "ad": "Altın Kesesi", "aciklama": "Dalga başına 8 altın kazan", "max": 9999, "renk": Color("d4af37")},
	{"id": "tam_onarim", "ad": "Tam Onarım", "aciklama": "Barikat tamamen onarılır", "max": 9999, "renk": Color("6fb36a")},
]

# Evrim (Survivor.io): ana kart en üst seviyede + eş kart gereken seviyede → altın kart çıkar.
const EVRIMLER: Array[Dictionary] = [
	{"id": "minigun", "ad": "MİNİGUN", "ana": "ates_hizi", "es": "namlu", "es_sv": 2,
		"aciklama": "Ateş hızı +%50, hasar +%10"},
	{"id": "napalm", "ad": "NAPALM", "ana": "yanma", "es": "hasar", "es_sv": 3,
		"aciklama": "Yanma ×2.5, ölen zombi yanındakileri tutuşturur"},
	{"id": "titanyum", "ad": "TİTANYUM ÇEKİRDEK", "ana": "delme", "es": "zirh_delici", "es_sv": 2,
		"aciklama": "Mermiler zırhı tamamen yok sayar, delme +2"},
	{"id": "kale", "ad": "DİKEN KALESİ", "ana": "barikat", "es": "diken", "es_sv": 2,
		"aciklama": "Diken hasarı ×3, barikat canı +%30, tam onarım"},
]
const EVRIM_RENK := Color("ffcf4a")


static func bul(id: String) -> Dictionary:
	for k in LISTE:
		if k["id"] == id:
			return k
	return {}


## Şartı sağlanmış, henüz alınmamış evrimleri kart sözlüğü olarak döndürür.
static func hazir_evrimler(seviyeler: Dictionary) -> Array[Dictionary]:
	var sonuc: Array[Dictionary] = []
	for e in EVRIMLER:
		if seviyeler.has(e["id"]):
			continue
		var ana := bul(e["ana"])
		if int(seviyeler.get(e["ana"], 0)) >= int(ana["max"]) and int(seviyeler.get(e["es"], 0)) >= int(e["es_sv"]):
			sonuc.append({"id": e["id"], "ad": e["ad"], "aciklama": e["aciklama"], "max": 1, "renk": EVRIM_RENK, "evrim": true})
	return sonuc


## Karttaki küçük ipucu: bu kart hangi evrime yarıyor?
static func evrim_ipucu(id: String, seviyeler: Dictionary) -> String:
	for e in EVRIMLER:
		if seviyeler.has(e["id"]):
			continue
		if e["ana"] == id:
			return "Evrim: %s (+ %s)" % [e["ad"], bul(e["es"])["ad"]]
		if e["es"] == id:
			return "Evrim: %s (+ %s)" % [e["ad"], bul(e["ana"])["ad"]]
	return ""
