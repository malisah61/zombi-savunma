extends Node2D
## Oyun yöneticisi: menü ↔ koşu geçişi, dalgalar, zombi doğurma, mermiler, ekonomi, kartlar,
## nesne havuzları (kasma olmasın diye mermi/zombi/yazı/parçacık yeniden kullanılır), kalite ayarları.

const ZombiBetik := preload("res://betikler/zombi.gd")
const MermiBetik := preload("res://betikler/mermi.gd")
const LekeBetik := preload("res://betikler/leke.gd")
const KahramanBetik := preload("res://betikler/kahraman.gd")
const BarikatBetik := preload("res://betikler/barikat.gd")
const ArkaPlanBetik := preload("res://betikler/arka_plan.gd")
const ArayuzBetik := preload("res://betikler/arayuz.gd")
const MenuBetik := preload("res://betikler/menu.gd")
const ProfilBetik := preload("res://betikler/profil.gd")
const SeslerBetik := preload("res://betikler/sesler.gd")
const Kartlar := preload("res://betikler/kartlar.gd")
const Veri := preload("res://betikler/veri.gd")

enum Durum { MENU, OYUN, KART, BITTI }

# Kalite ayarına göre (0 düşük, 1 orta, 2 yüksek)
const LEKE_SINIRI := [0, 25, 50]
const PARCACIK_ACIK := [false, true, true]
const TUM_SAYILAR := [false, true, true]

var genislik := 720.0
var yukseklik := 1280.0
var barikat_y := 1010.0

var durum: Durum = Durum.MENU
var dalga := 0
var altin := 0
var oldurme := 0
var st: Dictionary = {}
var kart_seviye: Dictionary = {}
var zombiler: Array = []  # canlı zombiler (betikli düğümler, tipsiz)
var kalite := 2

var _dogacak: Array[String] = []
var _dogum_sayac := 0.0
var _dogum_aralik := 1.2
var _dalga_bitti_sayac := -1.0
var _titresim_sayac := 0.0
var _kosu_odullendi := false

var _leke_katmani: Node2D
var _zombi_katmani: Node2D
var _mermi_katmani: Node2D
var _efekt_katmani: Node2D
var barikat  # barikat.gd
var kahraman  # kahraman.gd
var arayuz  # arayuz.gd
var menu  # menu.gd
var profil  # profil.gd
var _sesler  # sesler.gd
var _kamera: Camera2D
var _sarsinti := 0.0
var _tehlike: ColorRect

# Nesne havuzları
var _zombi_havuzu: Array = []
var _mermi_havuzu: Array = []
var _yazi_havuzu: Array[Label] = []
var _yazi_sira := 0
var _parcacik_havuzu: Dictionary = {}  # tür -> Array[CPUParticles2D]
var _parcacik_sira: Dictionary = {}
var _lekeler: Array = []


func _ready() -> void:
	randomize()
	Input.set_use_accumulated_input(false)
	var boyut := get_viewport_rect().size
	genislik = boyut.x
	yukseklik = boyut.y
	barikat_y = yukseklik - 270.0

	profil = Node.new()
	profil.set_script(ProfilBetik)
	add_child(profil)

	var arka = Node2D.new()
	arka.set_script(ArkaPlanBetik)
	arka.genislik = genislik
	arka.yukseklik = yukseklik
	add_child(arka)
	_leke_katmani = _katman()
	_zombi_katmani = _katman()
	barikat = Node2D.new()
	barikat.set_script(BarikatBetik)
	barikat.oyun = self
	barikat.position = Vector2(0, barikat_y)
	add_child(barikat)
	kahraman = Node2D.new()
	kahraman.set_script(KahramanBetik)
	kahraman.oyun = self
	kahraman.position = Vector2(genislik / 2, barikat_y + 120)
	kahraman.hedef_x = genislik / 2
	kahraman.scale = Vector2(1.3, 1.3)
	add_child(kahraman)
	_mermi_katmani = _katman()
	_efekt_katmani = _katman()

	_kamera = Camera2D.new()
	_kamera.position = boyut / 2
	add_child(_kamera)

	_gorsel_katman_kur()

	_sesler = Node.new()
	_sesler.set_script(SeslerBetik)
	add_child(_sesler)

	arayuz = CanvasLayer.new()
	arayuz.set_script(ArayuzBetik)
	add_child(arayuz)
	arayuz.kart_secildi.connect(_kart_secildi)
	arayuz.onar_istendi.connect(_onar)
	arayuz.basla_istendi.connect(_yeni_oyun)
	arayuz.menu_istendi.connect(_menuye_don)
	arayuz.duraklat_istendi.connect(_duraklat)

	menu = CanvasLayer.new()
	menu.set_script(MenuBetik)
	menu.profil = profil
	add_child(menu)
	menu.oyna_istendi.connect(_yeni_oyun)
	menu.ayarlar_degisti.connect(_ayarlari_uygula)

	_havuzlari_kur()
	_ayarlari_uygula()
	st = profil.kosu_istatistigi()
	barikat.max_can = float(st["barikat_max"])
	barikat.can = barikat.max_can
	_arayuz_guncelle()
	menu.goster()

	for a in OS.get_cmdline_user_args():
		if a.begins_with("--onizleme="):
			_onizleme(a.trim_prefix("--onizleme="))


func _katman() -> Node2D:
	var n := Node2D.new()
	add_child(n)
	return n


func _gorsel_katman_kur() -> void:
	# Vinyet: kenarları karartıp gözü ortaya çeker. Tehlike: barikat zayıfken kırmızı nabız.
	var k := CanvasLayer.new()
	k.layer = 1
	add_child(k)
	var vinyet := TextureRect.new()
	var g := Gradient.new()
	g.set_color(0, Color(0, 0, 0, 0))
	g.set_color(1, Color(0, 0, 0, 0.6))
	g.set_offset(0, 0.55)
	var dok := GradientTexture2D.new()
	dok.gradient = g
	dok.fill = GradientTexture2D.FILL_RADIAL
	dok.fill_from = Vector2(0.5, 0.5)
	dok.fill_to = Vector2(1.05, 0.5)
	dok.width = 128
	dok.height = 128
	vinyet.texture = dok
	vinyet.stretch_mode = TextureRect.STRETCH_SCALE
	vinyet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	k.add_child(vinyet)
	vinyet.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tehlike = ColorRect.new()
	_tehlike.color = Color(0.8, 0.0, 0.0, 0.0)
	_tehlike.mouse_filter = Control.MOUSE_FILTER_IGNORE
	k.add_child(_tehlike)
	_tehlike.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		# Telefon arka plana alınınca: oyunu duraklat, pili koru, ilerlemeyi kaydet
		if durum == Durum.OYUN:
			_duraklat(true)
		Engine.max_fps = 5
		if profil:
			profil.kaydet()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_ayarlari_uygula()


func _ayarlari_uygula() -> void:
	kalite = clampi(int(profil.ayar("grafik")), 0, 2)
	Engine.max_fps = int(profil.ayar("fps"))
	AudioServer.set_bus_mute(0, not bool(profil.ayar("ses")))
	arayuz.fps_goster(bool(profil.ayar("fps_goster")))
	while _lekeler.size() > LEKE_SINIRI[kalite]:
		_lekeler.pop_front().queue_free()


# ================================================================ DÖNGÜ

func _process(delta: float) -> void:
	_sarsinti = maxf(_sarsinti - delta * 30.0, 0.0)
	_kamera.offset = Vector2(randf_range(-_sarsinti, _sarsinti), randf_range(-_sarsinti, _sarsinti))
	_titresim_sayac = maxf(_titresim_sayac - delta, 0.0)
	var oran: float = barikat.can / barikat.max_can
	var hedef_a := 0.0
	if durum == Durum.OYUN and oran < 0.3:
		hedef_a = (0.3 - oran) * 0.5 * (0.6 + 0.4 * sin(Time.get_ticks_msec() / 160.0))
	_tehlike.color.a = move_toward(_tehlike.color.a, hedef_a, delta)
	if durum != Durum.OYUN:
		return

	# ölen zombileri listeden çıkar (döngü içinde silmek atlamaya yol açar)
	if zombiler.any(func(z) -> bool: return z.olu):
		zombiler = zombiler.filter(func(z) -> bool: return not z.olu)

	if float(st["yenilenme"]) > 0.0:
		barikat.onar(float(st["yenilenme"]) * delta)

	if not _dogacak.is_empty():
		_dogum_sayac -= delta
		if _dogum_sayac <= 0.0:
			_dogum_sayac = _dogum_aralik * randf_range(0.6, 1.3)
			_zombi_dogur(_dogacak.pop_front())
	elif zombiler.is_empty():
		if _dalga_bitti_sayac < 0.0:
			_dalga_bitti_sayac = 1.0
		_dalga_bitti_sayac -= delta
		if _dalga_bitti_sayac <= 0.0:
			_dalga_bitti_sayac = -1.0
			_kart_sec()


# ================================================================ KOŞU AKIŞI

func _yeni_oyun() -> void:
	get_tree().paused = false
	_temizle()
	st = profil.kosu_istatistigi()
	kart_seviye.clear()
	barikat.max_can = float(st["barikat_max"])
	barikat.can = barikat.max_can
	kahraman.silah_ayarla(String(st["silah_taban"]))
	kahraman.position.x = genislik / 2
	kahraman.hedef_x = genislik / 2
	dalga = 0
	altin = 0
	oldurme = 0
	_kosu_odullendi = false
	menu.gizle()
	arayuz.oyun_basladi()
	arayuz.bitis_gizle()
	if int(profil.veri["istatistik"]["kosu"]) < 3:
		arayuz.ipucu_goster()
	_sonraki_dalga()


func _temizle() -> void:
	for z in zombiler:
		_zombi_havuza(z)
	zombiler.clear()
	for dugum in _mermi_katmani.get_children():
		var m = dugum
		if m.visible:
			mermi_birak(m)
	_dogacak.clear()
	_dalga_bitti_sayac = -1.0


func _sonraki_dalga() -> void:
	dalga += 1
	durum = Durum.OYUN
	_dogacak.clear()
	var adet := 6 + dalga * 2
	var kosucu_orani := 0.0 if dalga < 3 else minf(0.15 + dalga * 0.03, 0.45)
	for i in adet:
		_dogacak.append("kosucu" if randf() < kosucu_orani else "yuruyen")
	# her 5 dalgada bir yoğun saldırı
	if dalga % 5 == 0:
		for i in dalga:
			_dogacak.append("kosucu")
	_dogum_aralik = maxf(1.25 - dalga * 0.06, 0.35)
	_dogum_sayac = 1.5
	arayuz.dalga_afisi("DALGA %d" % dalga if dalga % 5 != 0 else "DALGA %d\nYOĞUN SALDIRI!" % dalga)
	ses("dalga")
	_arayuz_guncelle()


func _duraklat(acik: bool) -> void:
	if durum != Durum.OYUN and acik:
		return
	get_tree().paused = acik
	arayuz.duraklat_goster(acik)


func _menuye_don() -> void:
	get_tree().paused = false
	if (durum == Durum.OYUN or durum == Durum.KART) and not _kosu_odullendi:
		_kosu_odullendi = true
		profil.kosu_bitti(dalga, oldurme)
	_temizle()
	durum = Durum.MENU
	arayuz.bitis_gizle()
	_arayuz_guncelle()
	menu.goster()


func _oyun_bitti() -> void:
	if durum == Durum.BITTI:
		return
	durum = Durum.BITTI
	var eski_rekor := int(profil.veri["rekor"])
	var ozet: Dictionary = {}
	if not _kosu_odullendi:
		_kosu_odullendi = true
		ozet = profil.kosu_bitti(dalga, oldurme)
	ses("bitis")
	_titret(250)
	_sarsinti = 14.0
	arayuz.bitis_goster(dalga, oldurme, int(profil.veri["rekor"]), dalga > eski_rekor, ozet)
	_arayuz_guncelle()


# ================================================================ ZOMBİLER

func _zombi_dogur(tur: String) -> void:
	var z
	if _zombi_havuzu.is_empty():
		z = Node2D.new()
		z.set_script(ZombiBetik)
		_zombi_katmani.add_child(z)
	else:
		z = _zombi_havuzu.pop_back()
	z.kur(self, tur, 1.0 + 0.12 * (dalga - 1))
	z.position = Vector2(randf_range(70.0, genislik - 70.0), randf_range(-60.0, -20.0))
	zombiler.append(z)


func _zombi_havuza(z) -> void:
	z.olu = true
	z.visible = false
	z.set_process(false)
	if not _zombi_havuzu.has(z):
		_zombi_havuzu.append(z)


func zombi_oldu(z) -> void:
	oldurme += 1
	var kazanc := int(round(z.altin_degeri * float(st["altin_carpan"])))
	altin += kazanc
	_leke_birak(z.position)
	_parcacik("kan_buyuk", z.position)
	_yazi(z.position + Vector2(0, -20), "+%d" % kazanc, Color(1, 0.85, 0.3), 26, true)
	ses("olum")
	var tw: Tween = z.create_tween()
	tw.tween_property(z, "scale", Vector2(1.3, 0.2), 0.18)
	tw.parallel().tween_property(z, "modulate:a", 0.0, 0.18)
	tw.tween_callback(_zombi_havuza.bind(z))
	z.set_meta("tw", tw)
	_arayuz_guncelle()


func barikat_vuruldu(miktar: float, x: float) -> void:
	if durum != Durum.OYUN:
		return
	barikat.hasar_al(miktar)
	_sarsinti = minf(_sarsinti + (2.0 if kalite > 0 else 1.0), 8.0)
	_parcacik("kiymik", Vector2(x, barikat_y - 10))
	_titret(25)
	ses("barikat")
	_arayuz_guncelle()
	if barikat.can <= 0.0:
		_oyun_bitti()


# ================================================================ ATIŞ

func mermi_at(konum: Vector2, yon: Vector2) -> void:
	var m
	if _mermi_havuzu.is_empty():
		m = Node2D.new()
		m.set_script(MermiBetik)
		m.oyun = self
		_mermi_katmani.add_child(m)
	else:
		m = _mermi_havuzu.pop_back()
	var kritik := randf() < float(st["kritik"])
	m.baslat(konum, yon, float(st["mermi_hizi"]),
		float(st["hasar"]) * (float(st["kritik_carpan"]) if kritik else 1.0), kritik, int(st["delme"]))


func mermi_birak(m) -> void:
	m.visible = false
	m.set_process(false)
	if not _mermi_havuzu.has(m):
		_mermi_havuzu.append(m)


func isabet(z, hasar: float, kritik: bool, konum: Vector2) -> void:
	z.vurul(hasar)
	_parcacik("kan_kucuk", konum)
	if kritik or TUM_SAYILAR[kalite]:
		_yazi(konum + Vector2(randf_range(-12, 12), -10), str(int(round(hasar))) + ("!" if kritik else ""),
			Color(1, 0.5, 0.2) if kritik else Color.WHITE, 34 if kritik else 24)
	if kritik:
		_titret(12)
	if not z.olu:
		ses("isabet")


# ================================================================ KARTLAR

func _kart_sec() -> void:
	durum = Durum.KART
	var adaylar: Array[Dictionary] = []
	for k in Kartlar.LISTE:
		if int(kart_seviye.get(k["id"], 0)) < int(k["max"]):
			adaylar.append(k)
	adaylar.shuffle()
	var secenekler: Array[Dictionary] = []
	for i in mini(3, adaylar.size()):
		secenekler.append(adaylar[i])
	if secenekler.is_empty():
		_sonraki_dalga()
		return
	ses("kart")
	arayuz.kartlari_goster(secenekler, kart_seviye)


func _kart_secildi(id: String) -> void:
	if durum != Durum.KART:
		return
	kart_seviye[id] = int(kart_seviye.get(id, 0)) + 1
	_karti_uygula(id)
	_sonraki_dalga()


func _karti_uygula(id: String) -> void:
	match id:
		"ates_hizi":
			st["ates_hizi"] = float(st["ates_hizi"]) * 1.2
		"hasar":
			st["hasar"] = float(st["hasar"]) * 1.25
		"delme":
			st["delme"] = int(st["delme"]) + 1
		"namlu":
			st["namlu"] = int(st["namlu"]) + 1
		"kritik":
			st["kritik"] = float(st["kritik"]) + 0.12
		"menzil":
			st["menzil"] = float(st["menzil"]) * 1.15
			st["mermi_hizi"] = float(st["mermi_hizi"]) * 1.15
		"barikat":
			barikat.max_can *= 1.25
			barikat.can = barikat.max_can
		"altin":
			st["altin_carpan"] = float(st["altin_carpan"]) + 0.3
	_arayuz_guncelle()


func _onar() -> void:
	var fiyat := int(st["onar_fiyat"])
	if altin < fiyat or durum != Durum.OYUN:
		return
	altin -= fiyat
	barikat.onar(float(st["onarim"]))
	ses("altin")
	_yazi(Vector2(genislik / 2, barikat_y - 40), "ONARILDI", Color(0.5, 1, 0.5), 36, true)
	_arayuz_guncelle()


func _arayuz_guncelle() -> void:
	arayuz.guncelle(dalga, altin, oldurme, barikat.can / barikat.max_can, durum == Durum.OYUN, int(st.get("onar_fiyat", 25)))


# ================================================================ GİRDİ

func _unhandled_input(event: InputEvent) -> void:
	if durum != Durum.OYUN:
		return
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		kahraman.hedef_x = (event as InputEventScreenTouch).position.x
	elif event is InputEventScreenDrag:
		kahraman.hedef_x = (event as InputEventScreenDrag).position.x


# ================================================================ EFEKTLER (havuzlu)

func ses(ad: String) -> void:
	_sesler.cal(ad)


func _titret(ms: int) -> void:
	if not bool(profil.ayar("titresim")) or _titresim_sayac > 0.0:
		return
	_titresim_sayac = 0.08
	Input.vibrate_handheld(ms)


func _havuzlari_kur() -> void:
	for i in 32:
		var l := Label.new()
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.size = Vector2(120, 44)
		l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		l.add_theme_constant_override("outline_size", 8)
		l.visible = false
		_efekt_katmani.add_child(l)
		_yazi_havuzu.append(l)
	var turler := {
		"kan_kucuk": {"adet": 6, "renk": Color(0.6, 0.05, 0.05), "hiz": 260.0, "boy": 6.0, "sayi": 10},
		"kan_buyuk": {"adet": 22, "renk": Color(0.55, 0.04, 0.04), "hiz": 300.0, "boy": 7.0, "sayi": 8},
		"kiymik": {"adet": 8, "renk": Color("8b5e3c"), "hiz": 220.0, "boy": 7.0, "sayi": 6},
	}
	for tur in turler:
		var t: Dictionary = turler[tur]
		var liste: Array = []
		for i in int(t["sayi"]):
			var p := CPUParticles2D.new()
			p.one_shot = true
			p.emitting = false
			p.explosiveness = 0.95
			p.amount = int(t["adet"])
			p.lifetime = 0.45
			p.spread = 180.0
			p.initial_velocity_min = float(t["hiz"]) * 0.4
			p.initial_velocity_max = float(t["hiz"])
			p.gravity = Vector2(0, 600)
			p.scale_amount_min = float(t["boy"]) * 0.5
			p.scale_amount_max = float(t["boy"])
			p.color = t["renk"]
			_efekt_katmani.add_child(p)
			liste.append(p)
		_parcacik_havuzu[tur] = liste
		_parcacik_sira[tur] = 0


func _parcacik(tur: String, konum: Vector2) -> void:
	if not PARCACIK_ACIK[kalite]:
		return
	var liste: Array = _parcacik_havuzu[tur]
	var i: int = _parcacik_sira[tur]
	_parcacik_sira[tur] = (i + 1) % liste.size()
	var p: CPUParticles2D = liste[i]
	p.position = konum
	p.restart()


func _leke_birak(konum: Vector2) -> void:
	var sinir: int = LEKE_SINIRI[kalite]
	if sinir == 0:
		return
	var l
	if _lekeler.size() >= sinir:
		l = _lekeler.pop_front()
		l.yenile()
	else:
		l = Node2D.new()
		l.set_script(LekeBetik)
		_leke_katmani.add_child(l)
	l.position = konum
	_lekeler.append(l)


func _yazi(konum: Vector2, metin: String, renk: Color, boyut: int, onemli: bool = false) -> void:
	if not onemli and kalite == 0:
		return
	var l: Label = _yazi_havuzu[_yazi_sira]
	_yazi_sira = (_yazi_sira + 1) % _yazi_havuzu.size()
	if l.has_meta("tw"):
		var eski: Tween = l.get_meta("tw")
		if eski and eski.is_valid():
			eski.kill()
	l.text = metin
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.position = konum - Vector2(60, 22)
	l.modulate.a = 1.0
	l.visible = true
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 60.0, 0.7).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
	tw.tween_callback(func() -> void: l.visible = false)
	l.set_meta("tw", tw)


# ================================================================ ÖNİZLEME (bulutta ekran görüntüsü)

func _onizleme(klasor: String) -> void:
	DirAccess.make_dir_recursive_absolute(klasor)
	# Menü ekranlarını dolu göstermek için örnek ekip, silah ve keşif raporu ekle
	for i in 2:
		var h := Veri.hayatta_kalan_uret(9.0 + i * 2.0, 0.5)
		h["silah"] = ""
		profil.veri["ekip"].append(h)
	for i in 4:
		profil.veri["envanter"].append(Veri.silah_uret("", i + 1 if i < 3 else 0))
	profil.veri["hurda"] = 420
	profil.veri["kesif"]["aktif"] = {"bolge": 1, "bitis": int(Time.get_unix_time_from_system()) - 1}
	profil.kesif_kontrol()
	await _bekle(0.6)
	for s in 5:
		menu.sekme_ac(s)
		if s == 1:
			menu._acik_kart = String(profil.veri["ekip"][0]["uid"])
			menu.sekme_ac(1)
		await _bekle(0.4)
		await _kare(klasor + "/0%d_menu_%s.png" % [s + 1, ["oyna", "ekip", "envanter", "kesif", "ayarlar"][s]])
	_yeni_oyun()
	for i in 14:
		await _bekle(0.5)
		if not zombiler.is_empty():
			kahraman.hedef_x = zombiler[0].position.x
	await _kare(klasor + "/10_oyun.png")
	dalga = 6
	barikat.hasar_al(barikat.max_can * 0.75)
	for i in 14:
		_zombi_dogur("kosucu" if i % 3 == 0 else "yuruyen")
		zombiler[-1].position.y = randf_range(150.0, barikat_y - 40.0)
	await _bekle(1.2)
	await _kare(klasor + "/11_kalabalik.png")
	_duraklat(true)
	await _bekle(0.3)
	await _kare(klasor + "/12_duraklat.png")
	_duraklat(false)
	_temizle()
	_kart_sec()
	await _bekle(0.5)
	await _kare(klasor + "/13_kartlar.png")
	durum = Durum.OYUN
	dalga = 12
	oldurme = 140
	_oyun_bitti()
	await _bekle(0.9)
	await _kare(klasor + "/14_bitis.png")
	get_tree().quit()


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn, true).timeout


func _kare(yol: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(yol)
	print("ONIZLEME kaydedildi: ", yol)
