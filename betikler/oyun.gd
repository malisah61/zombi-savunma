extends Node2D
## Oyun yöneticisi: dalgalar, zombi doğurma, mermiler, ekonomi, kartlar, kayıt.

const ZombiBetik := preload("res://betikler/zombi.gd")
const MermiBetik := preload("res://betikler/mermi.gd")
const LekeBetik := preload("res://betikler/leke.gd")
const KahramanBetik := preload("res://betikler/kahraman.gd")
const BarikatBetik := preload("res://betikler/barikat.gd")
const ArkaPlanBetik := preload("res://betikler/arka_plan.gd")
const ArayuzBetik := preload("res://betikler/arayuz.gd")
const SeslerBetik := preload("res://betikler/sesler.gd")
const Kartlar := preload("res://betikler/kartlar.gd")

enum Durum { BASLANGIC, OYUN, KART, BITTI }

const TEMEL_ISTATISTIK := {
	"ates_hizi": 1.8, "hasar": 10.0, "delme": 0, "namlu": 1,
	"kritik": 0.0, "menzil": 640.0, "mermi_hizi": 1100.0, "altin_carpan": 1.0,
}

var genislik := 720.0
var yukseklik := 1280.0
var barikat_y := 1010.0

var durum: Durum = Durum.BASLANGIC
var dalga := 0
var altin := 0
var oldurme := 0
var rekor := 0
var st: Dictionary = {}
var kart_seviye: Dictionary = {}
var zombiler: Array = []  # zombi düğümleri (betikli, tipsiz tutulur)

var _dogacak: Array[String] = []
var _dogum_sayac := 0.0
var _dogum_aralik := 1.2
var _dalga_bitti_sayac := -1.0

var _leke_katmani: Node2D
var _zombi_katmani: Node2D
var _mermi_katmani: Node2D
var _efekt_katmani: Node2D
var barikat  # barikat.gd
var kahraman  # kahraman.gd
var arayuz  # arayuz.gd
var _sesler  # sesler.gd
var _kamera: Camera2D
var _sarsinti := 0.0


func _ready() -> void:
	randomize()
	var boyut := get_viewport_rect().size
	genislik = boyut.x
	yukseklik = boyut.y
	barikat_y = yukseklik - 270.0
	_rekor_yukle()

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

	_sesler = Node.new()
	_sesler.set_script(SeslerBetik)
	add_child(_sesler)

	arayuz = CanvasLayer.new()
	arayuz.set_script(ArayuzBetik)
	add_child(arayuz)
	arayuz.kart_secildi.connect(_kart_secildi)
	arayuz.onar_istendi.connect(_onar)
	arayuz.basla_istendi.connect(_yeni_oyun)

	st = TEMEL_ISTATISTIK.duplicate()
	set_process(true)
	arayuz.baslangic_goster(rekor)
	_arayuz_guncelle()

	for a in OS.get_cmdline_user_args():
		if a.begins_with("--onizleme="):
			_onizleme(a.trim_prefix("--onizleme="))


func _katman() -> Node2D:
	var n := Node2D.new()
	add_child(n)
	return n


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		Engine.max_fps = 5
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		Engine.max_fps = 0


# ================================================================ DÖNGÜ

func _process(delta: float) -> void:
	_sarsinti = maxf(_sarsinti - delta * 30.0, 0.0)
	_kamera.offset = Vector2(randf_range(-_sarsinti, _sarsinti), randf_range(-_sarsinti, _sarsinti))
	if durum != Durum.OYUN:
		return

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


# ================================================================ DALGALAR

func _yeni_oyun() -> void:
	for z in zombiler:
		z.queue_free()
	zombiler.clear()
	for c in _mermi_katmani.get_children():
		c.queue_free()
	for c in _leke_katmani.get_children():
		c.queue_free()
	st = TEMEL_ISTATISTIK.duplicate()
	kart_seviye.clear()
	barikat.max_can = 300.0
	barikat.can = 300.0
	dalga = 0
	altin = 0
	oldurme = 0
	arayuz.oyun_basladi()
	_sonraki_dalga()


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


func _zombi_dogur(tur: String) -> void:
	var z = Node2D.new()
	z.set_script(ZombiBetik)
	z.kur(self, tur, 1.0 + 0.12 * (dalga - 1))
	z.position = Vector2(randf_range(70.0, genislik - 70.0), randf_range(-60.0, -20.0))
	_zombi_katmani.add_child(z)
	zombiler.append(z)


func zombi_oldu(z) -> void:
	zombiler.erase(z)
	oldurme += 1
	var kazanc := int(round(z.altin_degeri * float(st["altin_carpan"])))
	altin += kazanc
	_leke_birak(z.position)
	_kan_sicrat(z.position, 22)
	_yazi(z.position + Vector2(0, -20), "+%d" % kazanc, Color(1, 0.85, 0.3), 26)
	ses("olum")
	var tw: Tween = z.create_tween()
	tw.tween_property(z, "scale", Vector2(1.3, 0.2), 0.18)
	tw.parallel().tween_property(z, "modulate:a", 0.0, 0.18)
	tw.tween_callback(z.queue_free)
	_arayuz_guncelle()


func barikat_vuruldu(miktar: float, x: float) -> void:
	if durum != Durum.OYUN:
		return
	barikat.hasar_al(miktar)
	_sarsinti = minf(_sarsinti + 2.0, 8.0)
	_kiymik(Vector2(x, barikat_y - 10))
	ses("barikat")
	_arayuz_guncelle()
	if barikat.can <= 0.0:
		_oyun_bitti()


# ================================================================ ATIŞ

func mermi_at(konum: Vector2, yon: Vector2) -> void:
	var m = Node2D.new()
	m.set_script(MermiBetik)
	m.oyun = self
	m.position = konum
	m.yon = yon
	m.rotation = yon.angle() + PI / 2
	m.hiz = float(st["mermi_hizi"])
	var kritik := randf() < float(st["kritik"])
	m.kritik = kritik
	m.hasar = float(st["hasar"]) * (2.5 if kritik else 1.0)
	m.delme_kalan = int(st["delme"])
	_mermi_katmani.add_child(m)


func isabet(z, hasar: float, kritik: bool, konum: Vector2) -> void:
	z.vurul(hasar)
	_kan_sicrat(konum, 6)
	_yazi(konum + Vector2(randf_range(-12, 12), -10), str(int(round(hasar))) + ("!" if kritik else ""),
		Color(1, 0.5, 0.2) if kritik else Color.WHITE, 34 if kritik else 24)
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
	if altin < arayuz.ONAR_FIYAT or durum != Durum.OYUN:
		return
	altin -= arayuz.ONAR_FIYAT
	barikat.onar(0.25)
	ses("altin")
	_yazi(Vector2(genislik / 2, barikat_y - 40), "ONARILDI", Color(0.5, 1, 0.5), 36)
	_arayuz_guncelle()


# ================================================================ BİTİŞ

func _oyun_bitti() -> void:
	durum = Durum.BITTI
	var yeni := dalga > rekor
	if yeni:
		rekor = dalga
		_rekor_kaydet()
	ses("bitis")
	_sarsinti = 14.0
	arayuz.bitis_goster(dalga, oldurme, rekor, yeni)
	_arayuz_guncelle()


func _arayuz_guncelle() -> void:
	arayuz.guncelle(dalga, altin, oldurme, barikat.can / barikat.max_can, durum == Durum.OYUN)


# ================================================================ GİRDİ

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and (event as InputEventScreenTouch).pressed:
		kahraman.hedef_x = (event as InputEventScreenTouch).position.x
	elif event is InputEventScreenDrag:
		kahraman.hedef_x = (event as InputEventScreenDrag).position.x


# ================================================================ EFEKTLER

func ses(ad: String) -> void:
	_sesler.cal(ad)


func _leke_birak(konum: Vector2) -> void:
	var l = Node2D.new()
	l.set_script(LekeBetik)
	l.position = konum
	_leke_katmani.add_child(l)
	if _leke_katmani.get_child_count() > 50:
		_leke_katmani.get_child(0).queue_free()


func _parcacik(konum: Vector2, adet: int, renk: Color, hiz: float, boyut: float) -> void:
	var p := CPUParticles2D.new()
	p.position = konum
	p.one_shot = true
	p.explosiveness = 0.95
	p.amount = adet
	p.lifetime = 0.45
	p.spread = 180.0
	p.initial_velocity_min = hiz * 0.4
	p.initial_velocity_max = hiz
	p.gravity = Vector2(0, 600)
	p.scale_amount_min = boyut * 0.5
	p.scale_amount_max = boyut
	p.color = renk
	_efekt_katmani.add_child(p)
	p.emitting = true
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)


func _kan_sicrat(konum: Vector2, adet: int) -> void:
	_parcacik(konum, adet, Color(0.6, 0.05, 0.05), 260.0, 6.0)


func _kiymik(konum: Vector2) -> void:
	_parcacik(konum, 8, Color("8b5e3c"), 220.0, 7.0)


func _yazi(konum: Vector2, metin: String, renk: Color, boyut: int) -> void:
	var l := Label.new()
	l.text = metin
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.position = konum - Vector2(40, 20)
	l.size = Vector2(80, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_efekt_katmani.add_child(l)
	var tw := l.create_tween()
	tw.tween_property(l, "position:y", l.position.y - 60.0, 0.7).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.7).set_delay(0.25)
	tw.tween_callback(l.queue_free)


# ================================================================ KAYIT

func _rekor_yukle() -> void:
	var cf := ConfigFile.new()
	if cf.load("user://kayit.cfg") == OK:
		rekor = int(cf.get_value("oyun", "rekor", 0))


func _rekor_kaydet() -> void:
	var cf := ConfigFile.new()
	cf.load("user://kayit.cfg")
	cf.set_value("oyun", "rekor", rekor)
	cf.save("user://kayit.cfg")


# ================================================================ ÖNİZLEME (bulutta ekran görüntüsü)

func _onizleme(klasor: String) -> void:
	DirAccess.make_dir_recursive_absolute(klasor)
	await _bekle(0.6)
	await _kare(klasor + "/1_baslangic.png")
	_yeni_oyun()
	# askeri zombilerin altına götür ki ateş etsin
	for i in 14:
		await _bekle(0.5)
		if not zombiler.is_empty():
			kahraman.hedef_x = zombiler[0].position.x
	await _kare(klasor + "/2_oyun.png")
	# ileri bir dalgayı göster
	dalga = 6
	barikat.hasar_al(barikat.max_can * 0.45)
	for i in 14:
		_zombi_dogur("kosucu" if i % 3 == 0 else "yuruyen")
		zombiler[-1].position.y = randf_range(150.0, barikat_y - 40.0)
	await _bekle(1.2)
	await _kare(klasor + "/3_kalabalik.png")
	for z in zombiler.duplicate():
		z.queue_free()
	zombiler.clear()
	_dogacak.clear()
	_kart_sec()
	await _bekle(0.5)
	await _kare(klasor + "/4_kartlar.png")
	_oyun_bitti()
	await _bekle(0.9)
	await _kare(klasor + "/5_bitis.png")
	get_tree().quit()


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn).timeout


func _kare(yol: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(yol)
	print("ONIZLEME kaydedildi: ", yol)
