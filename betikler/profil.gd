extends Node
## Oyuncunun kalıcı profili: hurda, ekip (hayatta kalanlar), envanter (silahlar), keşif, ayarlar, rekorlar.
## user://profil.json'a yazılır; her kayıtta bir önceki sürüm .bak olarak saklanır. Dosya bozulursa
## yedekten açılır. Yeni alan eklerken VARSAYILAN'a ekle: eski kayıtlar otomatik tamamlanır.

const Veri := preload("res://betikler/veri.gd")
const DOSYA := "user://profil.json"
const SURUM := 2

signal degisti

const VARSAYILAN := {
	"surum": SURUM,
	"hurda": 60,
	"ekip": [],
	"envanter": [],
	"aktif": "",
	"kesif": {"aktif": {}, "raporlar": []},
	"ayarlar": {"grafik": 2, "fps": 60, "ses": true, "titresim": true, "fps_goster": false, "oto_kalite": true},
	"rekor": 0,
	"istatistik": {"kosu": 0, "oldurme": 0, "boss": 0},
	"gorulen": [],  # tanıtımı yapılmış zombi türleri
	"son_zaman": 0,  # gerçek zamanla dinlenme için
}

var veri: Dictionary = {}


func _ready() -> void:
	yukle()


# ================================================================ KAYIT

func yukle() -> void:
	var okunan := _oku(DOSYA)
	if okunan.is_empty():
		okunan = _oku(DOSYA + ".bak")
	if okunan.is_empty():
		_yeni_profil()
		kaydet()
		return
	veri = _tamamla(okunan, VARSAYILAN.duplicate(true))
	_eski_rekoru_tasi()
	if veri["ekip"].is_empty():
		_baslangic_ekibi()
	if aktif_kahraman().is_empty():
		veri["aktif"] = veri["ekip"][0]["uid"]
	_hayatta_kalanlari_tamamla()


## Dizi içindeki kayıtları _tamamla göremez: eski hayatta kalanlara yeni alanları burada ekle.
func _hayatta_kalanlari_tamamla() -> void:
	for h in veri["ekip"]:
		if not h.has("kisilik"):
			h["kisilik"] = Veri.kisilik_sec()
		if not h.has("yorgunluk"):
			h["yorgunluk"] = 0.0
		if not h.has("sakat"):
			h["sakat"] = 0


func kaydet() -> void:
	if FileAccess.file_exists(DOSYA):
		DirAccess.copy_absolute(ProjectSettings.globalize_path(DOSYA), ProjectSettings.globalize_path(DOSYA + ".bak"))
	var gecici := DOSYA + ".tmp"
	var f := FileAccess.open(gecici, FileAccess.WRITE)
	if f == null:
		push_warning("Profil yazılamadı: %s" % FileAccess.get_open_error())
		return
	f.store_string(JSON.stringify(veri))
	f.close()
	DirAccess.rename_absolute(ProjectSettings.globalize_path(gecici), ProjectSettings.globalize_path(DOSYA))
	degisti.emit()


func _oku(yol: String) -> Dictionary:
	if not FileAccess.file_exists(yol):
		return {}
	var f := FileAccess.open(yol, FileAccess.READ)
	if f == null:
		return {}
	var sonuc = JSON.parse_string(f.get_as_text())
	return sonuc if sonuc is Dictionary else {}


## Eksik anahtarları varsayılanla doldurur (eski sürüm kayıtları için).
func _tamamla(okunan: Dictionary, varsayilan: Dictionary) -> Dictionary:
	for k in varsayilan:
		if not okunan.has(k):
			okunan[k] = varsayilan[k]
		elif okunan[k] is Dictionary and varsayilan[k] is Dictionary and not (varsayilan[k] as Dictionary).is_empty():
			okunan[k] = _tamamla(okunan[k], varsayilan[k])
	okunan["surum"] = SURUM
	return okunan


func _eski_rekoru_tasi() -> void:
	# İlk sürüm rekoru user://kayit.cfg'de tutuyordu
	var cf := ConfigFile.new()
	if cf.load("user://kayit.cfg") == OK:
		veri["rekor"] = maxi(int(veri["rekor"]), int(cf.get_value("oyun", "rekor", 0)))


func _yeni_profil() -> void:
	veri = VARSAYILAN.duplicate(true)
	_eski_rekoru_tasi()
	_baslangic_ekibi()


func _baslangic_ekibi() -> void:
	var h := Veri.hayatta_kalan_uret(8.0, 0.4, "asker")
	h["yas"] = 24
	var s := Veri.silah_uret("tabanca", 0)
	var t := Veri.silah_uret("tufek", 0)
	h["silah"] = s["uid"]
	veri["ekip"] = [h]
	veri["envanter"] = [s, t]
	veri["aktif"] = h["uid"]


# ================================================================ ERİŞİM

func ayar(ad: String):
	return veri["ayarlar"].get(ad)


func ayar_degistir(ad: String, deger) -> void:
	veri["ayarlar"][ad] = deger
	kaydet()


func hurda() -> int:
	return int(veri["hurda"])


func hurda_ekle(m: int) -> void:
	veri["hurda"] = maxi(0, hurda() + m)


func aktif_kahraman() -> Dictionary:
	return kahraman_bul(String(veri["aktif"]))


func kahraman_bul(uid: String) -> Dictionary:
	for h in veri["ekip"]:
		if h["uid"] == uid:
			return h
	return {}


func silah_bul(uid: String) -> Dictionary:
	for s in veri["envanter"]:
		if s["uid"] == uid:
			return s
	return {}


func kahraman_silahi(h: Dictionary) -> Dictionary:
	var s := silah_bul(String(h.get("silah", "")))
	if s.is_empty() and not veri["envanter"].is_empty():
		s = veri["envanter"][0]
		h["silah"] = s["uid"]
	return s


func silahi_kullanan(silah_uid: String) -> Dictionary:
	for h in veri["ekip"]:
		if h.get("silah", "") == silah_uid:
			return h
	return {}


# ================================================================ KOŞU

## Bir koşunun başlangıç istatistikleri: silah × hayatta kalanın özellikleri × rol × moral.
func kosu_istatistigi() -> Dictionary:
	var h := aktif_kahraman()
	var s := kahraman_silahi(h)
	var si := Veri.silah_istatistik(s) if not s.is_empty() else Veri.silah_istatistik(Veri.silah_uret("tabanca", 0))
	var oz: Dictionary = h["oz"]
	var moral := 1.0 + (float(h["moral"]) - 50.0) / 50.0 * 0.05
	var yorgun := Veri.yorgunluk_carpani(float(h.get("yorgunluk", 0.0)))
	moral *= yorgun
	var st := {
		"silah_taban": s.get("taban", "tabanca"),
		"hasar": float(si["hasar"]) * (1.0 + (float(oz["nisancilik"]) - 10.0) * 0.035) * moral,
		"ates_hizi": float(si["ates"]) * (1.0 + (float(oz["refleks"]) - 10.0) * 0.025) * moral,
		"kritik": float(si["kritik"]) + (float(oz["sogukkanlilik"]) - 10.0) * 0.008,
		"kritik_carpan": 2.5,
		"menzil": float(si["menzil"]),
		"mermi_hizi": float(si["mermi_hizi"]),
		"namlu": int(si["namlu"]),
		"yayilim": float(si["yayilim"]),
		"delme": int(si["delme"]),
		"altin_carpan": 1.0 + float(si["altin"]) + (float(oz["liderlik"]) - 10.0) * 0.03,
		"barikat_max": 300.0 * (1.0 + float(si["barikat"])) * (1.0 + (float(oz["dayaniklilik"]) - 10.0) * 0.04),
		"onarim": 0.25 * (1.0 + (float(oz["muhendislik"]) - 10.0) * 0.05),
		"onar_fiyat": 25,
		"yenilenme": 0.0,
		"zirh_delme": 0.0,
		"zirh_yok": false,
		"yanma": 0.0,
		"yanma_yayilim": false,
		"diken": 0.0,
	}
	match String(h["rol"]):
		"asker":
			st["hasar"] *= 1.1
		"avci":
			st["kritik"] += 0.08
			st["kritik_carpan"] = 3.0
		"muhendis":
			st["onarim"] *= 1.6
			st["onar_fiyat"] = 18
		"doktor":
			st["yenilenme"] = 0.004
	st["kritik"] = clampf(st["kritik"], 0.0, 0.75)
	st["altin_carpan"] = maxf(st["altin_carpan"], 0.5)
	return st


## Koşu bitince çağrılır: ödüller, ganimet, gelişim (FM tarzı), moral. Özet sözlüğü döndürür.
func kosu_bitti(dalga: int, oldurme: int, boss_sayisi: int = 0, barikat_dustu: bool = false) -> Dictionary:
	var ozet := {"hurda": 0, "silahlar": [], "gelisim": [], "seviye_atladi": false, "moral": 0, "sakat": {}, "yorgunluk": ""}
	var kazanc := dalga * 6 + int(oldurme / 2.0) + boss_sayisi * 25
	hurda_ekle(kazanc)
	ozet["hurda"] = kazanc

	# Ganimet: her 5 dalgada bir silah; nadirlik şansı dalgayla artar
	for i in int(dalga / 5.0):
		var s := Veri.silah_uret("", Veri.nadirlik_sec(dalga * 0.05))
		if veri["envanter"].size() < Veri.ENVANTER_SINIRI:
			veri["envanter"].append(s)
			ozet["silahlar"].append(s)
		else:
			hurda_ekle(silah_satis_degeri(s))

	# Boss ganimeti: öldürülen her Dev için garanti Ender veya üstü silah
	for i in boss_sayisi:
		var s := Veri.silah_uret("", maxi(2, Veri.nadirlik_sec(0.3 + dalga * 0.05)))
		if veri["envanter"].size() < Veri.ENVANTER_SINIRI:
			veri["envanter"].append(s)
			ozet["silahlar"].append(s)
		else:
			hurda_ekle(silah_satis_degeri(s))
	veri["istatistik"]["boss"] = int(veri["istatistik"]["boss"]) + boss_sayisi

	var h := aktif_kahraman()
	var onceki_en_iyi := int(h.get("en_iyi_dalga", 0))
	h["kosu"] = int(h.get("kosu", 0)) + 1
	h["en_iyi_dalga"] = maxi(onceki_en_iyi, dalga)
	h["xp"] = int(h["xp"]) + dalga * 10 + oldurme
	while int(h["xp"]) >= int(h["seviye"]) * 100:
		h["xp"] = int(h["xp"]) - int(h["seviye"]) * 100
		h["seviye"] = int(h["seviye"]) + 1
		ozet["seviye_atladi"] = true

	# Moral: iyi geçen koşu yükseltir, kötü geçen düşürür (FM'deki gibi performans → moral)
	var eski_moral := int(h["moral"])
	var degisim := 0
	if dalga > onceki_en_iyi and onceki_en_iyi > 0:
		degisim += 10
	if dalga >= 8:
		degisim += 6
	elif dalga <= 3:
		degisim -= 8
	var ks := Veri.kisilik(h)
	if degisim > 0:
		degisim = int(round(degisim * float(ks["kazanc"])))
	elif degisim < 0:
		degisim = int(round(degisim * float(ks["kayip"])))
	h["moral"] = clampi(eski_moral + degisim, 5, 100)
	ozet["moral"] = int(h["moral"]) - eski_moral
	_ekip_kosu_sonu(h, dalga, barikat_dustu, ozet)

	# Gelişim: oynayan hayatta kalan maç deneyimiyle, diğerleri antrenmanla (daha az) gelişir
	ozet["gelisim"] = _gelistir(h, 0.5 + dalga * 0.22)
	for diger in veri["ekip"]:
		if diger["uid"] != h["uid"]:
			_gelistir(diger, 0.35)
		# her 10 koşuda bir "sezon" geçer, herkes yaşlanır
	veri["istatistik"]["kosu"] = int(veri["istatistik"]["kosu"]) + 1
	veri["istatistik"]["oldurme"] = int(veri["istatistik"]["oldurme"]) + oldurme
	if int(veri["istatistik"]["kosu"]) % 10 == 0:
		for x in veri["ekip"]:
			x["yas"] = int(x["yas"]) + 1
	if dalga > int(veri["rekor"]):
		veri["rekor"] = dalga
	kaydet()
	return ozet


## Koşu sonu rotasyon etkileri: oynayan yorulur, yedekler dinlenir, sakatlıklar iyileşir, kişilik moralleri.
func _ekip_kosu_sonu(h: Dictionary, dalga: int, barikat_dustu: bool, ozet: Dictionary) -> void:
	var tek_kisi: bool = veri["ekip"].size() <= 1
	var lider := String(Veri.kisilik(h).get("ad", "")) == "Lider ruhlu"
	for x in veri["ekip"]:
		if x["uid"] == h["uid"]:
			continue
		x["sakat"] = maxi(int(x.get("sakat", 0)) - 1, 0)
		x["yorgunluk"] = maxf(float(x.get("yorgunluk", 0.0)) - 35.0, 0.0)
		if lider:
			x["moral"] = mini(int(x["moral"]) + 2, 100)
		if String(x.get("kisilik", "")) == "hirsli":
			x["moral"] = maxi(int(x["moral"]) - 2, 5)
	# Tek kişilik ekip rotasyon yapamaz: yarım yorulur, sakatlanmaz
	var yorgun_artis := (10.0 + dalga * 1.6) * (0.5 if tek_kisi else 1.0)
	var yorgunluk := minf(float(h.get("yorgunluk", 0.0)) + yorgun_artis, 100.0)
	h["yorgunluk"] = yorgunluk
	ozet["yorgunluk"] = Veri.yorgunluk_metni(yorgunluk)
	if barikat_dustu and not tek_kisi and randf() < 0.05 + yorgunluk * 0.002:
		var sure := randi_range(1, 3)
		h["sakat"] = sure
		ozet["sakat"] = {"ad": h["ad"], "sure": sure}
		var yedek := _en_iyi_saglam(String(h["uid"]))
		if not yedek.is_empty():
			veri["aktif"] = yedek["uid"]
			ozet["sakat"]["yedek"] = yedek["ad"]


func _en_iyi_saglam(haric: String) -> Dictionary:
	var en_iyi := {}
	for x in veri["ekip"]:
		if x["uid"] == haric or int(x.get("sakat", 0)) > 0:
			continue
		if en_iyi.is_empty() or Veri.toplam_ozellik(x) > Veri.toplam_ozellik(en_iyi):
			en_iyi = x
	return en_iyi


## Gerçek zamanla dinlenme: saatte 12 yorgunluk gider, 4 saatte 1 sakatlık koşusu iyileşir.
## Oyuncu geri döndüğünde ekibini dinç bulur (cezasız geri dönüş).
func zaman_dinlenmesi() -> void:
	var simdi := int(Time.get_unix_time_from_system())
	var son := int(veri["son_zaman"])
	veri["son_zaman"] = simdi
	if son <= 0 or simdi <= son:
		return
	var saat := float(simdi - son) / 3600.0
	for x in veri["ekip"]:
		x["yorgunluk"] = maxf(float(x.get("yorgunluk", 0.0)) - saat * 12.0, 0.0)
		x["sakat"] = maxi(int(x.get("sakat", 0)) - int(saat / 4.0), 0)
	var aktif := aktif_kahraman()
	if int(aktif.get("sakat", 0)) > 0:
		var y := _en_iyi_saglam(String(aktif["uid"]))
		if not y.is_empty():
			veri["aktif"] = y["uid"]


## Gelişim puanını özelliklere dağıtır. Yaş, moral ve potansiyel tavanı etkiler. Gelişen özellikleri döndürür.
func _gelistir(h: Dictionary, puan: float) -> Array:
	var yas := int(h["yas"])
	var yas_carpan := 1.5 if yas < 21 else (1.25 if yas < 25 else (1.0 if yas < 30 else (0.6 if yas < 34 else 0.25)))
	var moral_carpan := 0.75 + float(h["moral"]) / 200.0
	var toplam := Veri.toplam_ozellik(h)
	var pot := int(h["potansiyel"])
	var gelisenler: Array = []
	if not h.has("ilerleme"):
		h["ilerleme"] = {}
	var ilerleme: Dictionary = h["ilerleme"]
	if toplam < pot:
		puan *= yas_carpan * moral_carpan * float(Veri.kisilik(h)["gelisim"])
		var anahtar: Array = Veri.ROLLER[h["rol"]]["anahtar"]
		var odak := String(h.get("odak", anahtar[0]))
		for o in Veri.OZELLIKLER:
			var id: String = o["id"]
			var pay := 0.06
			if id == odak:
				pay = 0.5
			elif anahtar.has(id):
				pay = 0.18
			ilerleme[id] = float(ilerleme.get(id, 0.0)) + puan * pay
			while float(ilerleme[id]) >= 1.0 and toplam < pot and int(h["oz"][id]) < 20:
				ilerleme[id] = float(ilerleme[id]) - 1.0
				h["oz"][id] = int(h["oz"][id]) + 1
				toplam += 1
				gelisenler.append(id)
	# 33 yaş üstünde fiziksel düşüş
	if yas > 33 and randf() < (yas - 33) * 0.06:
		for id in ["refleks", "dayaniklilik"]:
			if int(h["oz"][id]) > 1 and randf() < 0.5:
				h["oz"][id] = int(h["oz"][id]) - 1
	return gelisenler


# ================================================================ EKİP

func aktif_yap(uid: String) -> void:
	var h := kahraman_bul(uid)
	if not h.is_empty() and int(h.get("sakat", 0)) <= 0:
		veri["aktif"] = uid
		kaydet()


func odak_degistir(uid: String, ozellik: String) -> void:
	var h := kahraman_bul(uid)
	if not h.is_empty():
		h["odak"] = ozellik
		kaydet()


func kov(uid: String) -> bool:
	if veri["ekip"].size() <= 1 or uid == String(veri["aktif"]):
		return false
	var h := kahraman_bul(uid)
	veri["ekip"].erase(h)
	kaydet()
	return true


# ================================================================ ENVANTER

func kusan(silah_uid: String) -> void:
	var h := aktif_kahraman()
	var onceki := silahi_kullanan(silah_uid)
	if not onceki.is_empty() and onceki["uid"] != h["uid"]:
		onceki["silah"] = h.get("silah", "")
	h["silah"] = silah_uid
	kaydet()


func silah_gelistir(uid: String) -> bool:
	var s := silah_bul(uid)
	if s.is_empty():
		return false
	var max_sv := int(Veri.NADIRLIK[int(s["nadirlik"])]["max_sv"])
	var fiyat := Veri.gelistirme_fiyati(s)
	if int(s["seviye"]) >= max_sv or hurda() < fiyat:
		return false
	hurda_ekle(-fiyat)
	s["seviye"] = int(s["seviye"]) + 1
	kaydet()
	return true


func silah_satis_degeri(s: Dictionary) -> int:
	return int(round(6.0 * (1.0 + int(s["nadirlik"]) * 2.0) * (1.0 + (int(s["seviye"]) - 1) * 0.5)))


func silah_sat(uid: String) -> bool:
	var s := silah_bul(uid)
	if s.is_empty() or not silahi_kullanan(uid).is_empty():
		return false
	hurda_ekle(silah_satis_degeri(s))
	veri["envanter"].erase(s)
	kaydet()
	return true


## Kullanılmayan, aynı nadirlikte 3 silahı bir üst nadirlikte rastgele bir silaha dönüştürür.
func birlestirilebilir(nadirlik: int) -> Array:
	var liste: Array = []
	for s in veri["envanter"]:
		if int(s["nadirlik"]) == nadirlik and silahi_kullanan(s["uid"]).is_empty():
			liste.append(s)
	liste.sort_custom(func(a, b) -> bool: return int(a["seviye"]) < int(b["seviye"]))
	return liste


func birlestir(nadirlik: int) -> Dictionary:
	if nadirlik >= Veri.NADIRLIK.size() - 1:
		return {}
	var liste := birlestirilebilir(nadirlik)
	if liste.size() < 3:
		return {}
	for i in 3:
		veri["envanter"].erase(liste[i])
	var yeni := Veri.silah_uret("", nadirlik + 1)
	veri["envanter"].append(yeni)
	kaydet()
	return yeni


# ================================================================ KEŞİF (FM tarzı gözlemci)

func kesif_aktif() -> Dictionary:
	return veri["kesif"]["aktif"]


func kesif_kalan_sure() -> int:
	var a := kesif_aktif()
	if a.is_empty():
		return -1
	return maxi(0, int(a["bitis"]) - int(Time.get_unix_time_from_system()))


func kesif_baslat(bolge: int) -> bool:
	var b: Dictionary = Veri.BOLGELER[bolge]
	if not kesif_aktif().is_empty() or hurda() < int(b["fiyat"]):
		return false
	hurda_ekle(-int(b["fiyat"]))
	veri["kesif"]["aktif"] = {"bolge": bolge, "bitis": int(Time.get_unix_time_from_system()) + int(b["sure"])}
	kaydet()
	return true


## Süresi dolan keşfi rapora çevirir. Yeni rapor çıktıysa true döner.
func kesif_kontrol() -> bool:
	var a := kesif_aktif()
	if a.is_empty() or kesif_kalan_sure() > 0:
		return false
	var b: Dictionary = Veri.BOLGELER[int(a["bolge"])]
	var adaylar: Array = []
	for i in randi_range(2, 3):
		var h := Veri.hayatta_kalan_uret(float(b["kalite"]), float(b["pot"]))
		adaylar.append({"h": h, "bilgi": float(b["bilgi"]) + randf_range(-0.1, 0.1),
			"fiyat": int(Veri.toplam_ozellik(h) * 0.8 + int(h["potansiyel"]) * 0.4)})
	var silah = null
	if randf() < 0.5:
		silah = Veri.silah_uret("", Veri.nadirlik_sec(float(int(a["bolge"])) * 0.6))
	veri["kesif"]["raporlar"].push_front({"uid": Veri._uid(), "bolge": b["ad"], "adaylar": adaylar, "silah": silah})
	while veri["kesif"]["raporlar"].size() > 6:
		veri["kesif"]["raporlar"].pop_back()
	veri["kesif"]["aktif"] = {}
	kaydet()
	return true


## FM'deki gibi: gözlemci bilgisi azsa özellikler aralık olarak görünür.
func aday_aralik(aday: Dictionary, deger: int, tohum: String) -> Vector2i:
	var bilgi := clampf(float(aday["bilgi"]), 0.0, 1.0)
	if bilgi >= 0.99:
		return Vector2i(deger, deger)
	var yayilim := int(round((1.0 - bilgi) * 7.0))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(String(aday["h"]["uid"]) + tohum)
	var alt := clampi(deger - rng.randi_range(0, yayilim), 1, 20)
	return Vector2i(alt, clampi(alt + yayilim, deger, 20))


func aday_incele(rapor_uid: String, aday_idx: int) -> bool:
	var r := _rapor_bul(rapor_uid)
	if r.is_empty() or hurda() < 15:
		return false
	hurda_ekle(-15)
	r["adaylar"][aday_idx]["bilgi"] = 1.0
	kaydet()
	return true


func aday_al(rapor_uid: String, aday_idx: int) -> String:
	var r := _rapor_bul(rapor_uid)
	if r.is_empty():
		return "Rapor bulunamadı"
	if veri["ekip"].size() >= Veri.EKIP_SINIRI:
		return "Ekip dolu (en fazla %d kişi)" % Veri.EKIP_SINIRI
	var aday: Dictionary = r["adaylar"][aday_idx]
	if hurda() < int(aday["fiyat"]):
		return "Yeterli hurda yok"
	hurda_ekle(-int(aday["fiyat"]))
	var h: Dictionary = aday["h"]
	veri["ekip"].append(h)
	_hayatta_kalanlari_tamamla()
	r["adaylar"].remove_at(aday_idx)
	if r["adaylar"].is_empty() and r["silah"] == null:
		veri["kesif"]["raporlar"].erase(r)
	kaydet()
	return ""


func rapor_silah_al(rapor_uid: String) -> String:
	var r := _rapor_bul(rapor_uid)
	if r.is_empty() or r["silah"] == null:
		return "Silah yok"
	if veri["envanter"].size() >= Veri.ENVANTER_SINIRI:
		return "Envanter dolu"
	veri["envanter"].append(r["silah"])
	r["silah"] = null
	if r["adaylar"].is_empty():
		veri["kesif"]["raporlar"].erase(r)
	kaydet()
	return ""


func rapor_sil(rapor_uid: String) -> void:
	var r := _rapor_bul(rapor_uid)
	if not r.is_empty():
		veri["kesif"]["raporlar"].erase(r)
		kaydet()


func _rapor_bul(uid: String) -> Dictionary:
	for r in veri["kesif"]["raporlar"]:
		if r["uid"] == uid:
			return r
	return {}
