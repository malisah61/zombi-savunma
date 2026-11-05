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
]


static func bul(id: String) -> Dictionary:
	for k in LISTE:
		if k["id"] == id:
			return k
	return {}
