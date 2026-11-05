extends CanvasLayer
## Ekran arayüzü: üst bilgi çubuğu, barikat canı, onar düğmesi, kart seçimi,
## başlangıç ve oyun sonu ekranları. Her şey koddan kurulur.

signal kart_secildi(id: String)
signal onar_istendi
signal basla_istendi
signal menu_istendi
signal duraklat_istendi(duraklat: bool)

const Veri := preload("res://betikler/veri.gd")

var onar_fiyat := 25

var _dalga_etiket: Label
var _altin_etiket: Label
var _oldurme_etiket: Label
var _can_cubugu: ProgressBar
var _onar_dugme: Button
var _afis: Label
var _kart_paneli: Control
var _kart_kutusu: VBoxContainer
var _duraklat_dugme: Button
var _duraklat_paneli: Control
var _fps_etiket: Label
var _ipucu: Label
var _odul_kutusu: VBoxContainer
var _bitis: Control
var _bitis_metin: Label
var _ust_bosluk := 30.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var guvenli := DisplayServer.get_display_safe_area()
	var pencere := DisplayServer.window_get_size()
	if pencere.y > 0:
		_ust_bosluk += guvenli.position.y * get_viewport().get_visible_rect().size.y / pencere.y
	_ust_cubuk_kur()
	_onar_kur()
	_afis_kur()
	_kart_paneli_kur()
	_duraklat_kur()
	_bitis_kur()


# ---------------------------------------------------------------- kurulum

func _etiket(boyut: int, renk: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 10)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


func _kutu_stili(renk: Color, kenar: Color, yaricap: int = 18) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = renk
	s.border_color = kenar
	s.set_border_width_all(4)
	s.set_corner_radius_all(yaricap)
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 14
	s.content_margin_bottom = 14
	return s


func _ust_cubuk_kur() -> void:
	var serit := ColorRect.new()
	serit.color = Color(0, 0, 0, 0.45)
	serit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(serit)
	serit.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	serit.offset_bottom = _ust_bosluk + 96

	_dalga_etiket = _etiket(38)
	add_child(_dalga_etiket)
	_dalga_etiket.position = Vector2(24, _ust_bosluk)

	_oldurme_etiket = _etiket(26, Color(0.85, 0.85, 0.85))
	add_child(_oldurme_etiket)
	_oldurme_etiket.position = Vector2(24, _ust_bosluk + 48)

	_altin_etiket = _etiket(38, Color(1.0, 0.84, 0.25))
	add_child(_altin_etiket)
	_altin_etiket.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_altin_etiket.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_altin_etiket.offset_left = -300
	_altin_etiket.offset_right = -24
	_altin_etiket.offset_top = _ust_bosluk

	_can_cubugu = ProgressBar.new()
	_can_cubugu.show_percentage = false
	_can_cubugu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var arka := StyleBoxFlat.new()
	arka.bg_color = Color(0.15, 0.05, 0.05, 0.85)
	arka.set_corner_radius_all(8)
	var dolu := StyleBoxFlat.new()
	dolu.bg_color = Color(0.3, 0.8, 0.35)
	dolu.set_corner_radius_all(8)
	_can_cubugu.add_theme_stylebox_override("background", arka)
	_can_cubugu.add_theme_stylebox_override("fill", dolu)
	add_child(_can_cubugu)
	_can_cubugu.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_can_cubugu.offset_left = -300
	_can_cubugu.offset_right = -24
	_can_cubugu.offset_top = _ust_bosluk + 54
	_can_cubugu.offset_bottom = _ust_bosluk + 78


func _onar_kur() -> void:
	_onar_dugme = Button.new()
	_onar_dugme.text = "ONAR  %d altın" % onar_fiyat
	_onar_dugme.add_theme_font_size_override("font_size", 26)
	_onar_dugme.add_theme_stylebox_override("normal", _kutu_stili(Color(0.35, 0.22, 0.1, 0.92), Color(0.9, 0.7, 0.35), 14))
	_onar_dugme.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.5, 0.32, 0.15), Color(1, 0.85, 0.5), 14))
	_onar_dugme.add_theme_stylebox_override("hover", _kutu_stili(Color(0.35, 0.22, 0.1, 0.92), Color(0.9, 0.7, 0.35), 14))
	_onar_dugme.add_theme_stylebox_override("disabled", _kutu_stili(Color(0.2, 0.2, 0.2, 0.7), Color(0.4, 0.4, 0.4), 14))
	_onar_dugme.focus_mode = Control.FOCUS_NONE
	add_child(_onar_dugme)
	_onar_dugme.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_onar_dugme.offset_left = -250
	_onar_dugme.offset_top = -86
	_onar_dugme.offset_right = -20
	_onar_dugme.offset_bottom = -20
	_onar_dugme.pressed.connect(func() -> void: onar_istendi.emit())


func _afis_kur() -> void:
	_afis = _etiket(84, Color(1.0, 0.35, 0.3))
	add_child(_afis)
	_afis.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_afis.offset_left = -360
	_afis.offset_right = 360
	_afis.offset_top = -260
	_afis.offset_bottom = -140
	_afis.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_afis.modulate.a = 0.0


func _kart_paneli_kur() -> void:
	_kart_paneli = ColorRect.new()
	(_kart_paneli as ColorRect).color = Color(0, 0, 0, 0.72)
	add_child(_kart_paneli)
	_kart_paneli.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var baslik := _etiket(48, Color(1, 0.9, 0.5))
	baslik.text = "Bir yetenek seç"
	_kart_paneli.add_child(baslik)
	baslik.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	baslik.offset_left = -360
	baslik.offset_right = 360
	baslik.offset_top = 230
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kart_kutusu = VBoxContainer.new()
	_kart_kutusu.add_theme_constant_override("separation", 26)
	_kart_paneli.add_child(_kart_kutusu)
	_kart_kutusu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_kart_kutusu.offset_left = -300
	_kart_kutusu.offset_right = 300
	_kart_kutusu.offset_top = -330
	_kart_kutusu.offset_bottom = 330
	_kart_kutusu.alignment = BoxContainer.ALIGNMENT_CENTER
	_kart_paneli.visible = false


func _tam_ekran_panel(renk: Color) -> Control:
	var p := ColorRect.new()
	p.color = renk
	add_child(p)
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return p


func _duraklat_kur() -> void:
	_duraklat_dugme = Button.new()
	_duraklat_dugme.text = "II"
	_duraklat_dugme.focus_mode = Control.FOCUS_NONE
	_duraklat_dugme.add_theme_font_size_override("font_size", 34)
	var st := _kutu_stili(Color(0, 0, 0, 0.5), Color(1, 1, 1, 0.6), 14)
	_duraklat_dugme.add_theme_stylebox_override("normal", st)
	_duraklat_dugme.add_theme_stylebox_override("hover", st)
	_duraklat_dugme.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.3, 0.3, 0.3, 0.7), Color.WHITE, 14))
	add_child(_duraklat_dugme)
	_duraklat_dugme.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_duraklat_dugme.offset_left = -40
	_duraklat_dugme.offset_right = 40
	_duraklat_dugme.offset_top = _ust_bosluk + 4
	_duraklat_dugme.offset_bottom = _ust_bosluk + 80
	_duraklat_dugme.pressed.connect(func() -> void: duraklat_istendi.emit(true))

	_duraklat_paneli = _tam_ekran_panel(Color(0, 0, 0, 0.7))
	var baslik := _etiket(80, Color(0.9, 0.9, 0.9))
	baslik.text = "DURAKLATILDI"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_duraklat_paneli.add_child(baslik)
	baslik.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	baslik.offset_left = -360
	baslik.offset_right = 360
	baslik.offset_top = 330
	_duraklat_paneli.add_child(_buyuk_dugme("DEVAM", Color(0.25, 0.55, 0.2), func() -> void: duraklat_istendi.emit(false), 560))
	_duraklat_paneli.add_child(_buyuk_dugme("MENÜYE DÖN", Color(0.5, 0.25, 0.2), func() -> void: menu_istendi.emit(), 400))
	var uyari := _etiket(24, Color(0.8, 0.8, 0.8))
	uyari.text = "Menüye dönersen bu koşunun ödülleri yine verilir."
	uyari.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_duraklat_paneli.add_child(uyari)
	uyari.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	uyari.offset_left = -340
	uyari.offset_right = 340
	uyari.offset_top = -270
	_duraklat_paneli.visible = false

	_fps_etiket = _etiket(22, Color(0.6, 1, 0.6))
	add_child(_fps_etiket)
	_fps_etiket.position = Vector2(24, _ust_bosluk + 104)
	_fps_etiket.visible = false

	_ipucu = _etiket(30, Color(1, 1, 0.85))
	_ipucu.text = "Parmağını sağa sola kaydır.\nAsker en yakın zombiye kendisi ateş eder."
	_ipucu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_ipucu)
	_ipucu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_ipucu.offset_left = -340
	_ipucu.offset_right = 340
	_ipucu.offset_top = 40
	_ipucu.offset_bottom = 160
	_ipucu.modulate.a = 0.0


func ipucu_goster() -> void:
	var tw := create_tween()
	tw.tween_property(_ipucu, "modulate:a", 1.0, 0.4)
	tw.tween_interval(3.0)
	tw.tween_property(_ipucu, "modulate:a", 0.0, 0.6)


func duraklat_goster(acik: bool) -> void:
	_duraklat_paneli.visible = acik


func fps_goster(acik: bool) -> void:
	_fps_etiket.visible = acik


func _process(_delta: float) -> void:
	if _fps_etiket.visible:
		_fps_etiket.text = "%d FPS" % Engine.get_frames_per_second()


func _bitis_kur() -> void:
	_bitis = _tam_ekran_panel(Color(0.12, 0.0, 0.0, 0.78))
	var baslik := _etiket(88, Color(1, 0.3, 0.25))
	baslik.text = "BARİKAT\nDÜŞTÜ"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bitis.add_child(baslik)
	baslik.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	baslik.offset_left = -360
	baslik.offset_right = 360
	baslik.offset_top = 150
	_bitis_metin = _etiket(34)
	_bitis_metin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bitis.add_child(_bitis_metin)
	_bitis_metin.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_bitis_metin.offset_left = -360
	_bitis_metin.offset_right = 360
	_bitis_metin.offset_top = -260
	_bitis_metin.offset_bottom = -60
	_odul_kutusu = VBoxContainer.new()
	_odul_kutusu.add_theme_constant_override("separation", 6)
	_bitis.add_child(_odul_kutusu)
	_odul_kutusu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_odul_kutusu.offset_left = -330
	_odul_kutusu.offset_right = 330
	_odul_kutusu.offset_top = -40
	_odul_kutusu.offset_bottom = 300
	var tekrar := _buyuk_dugme("TEKRAR", Color(0.6, 0.2, 0.15), func() -> void: basla_istendi.emit(), 230)
	tekrar.offset_left = -330
	tekrar.offset_right = -10
	_bitis.add_child(tekrar)
	var menu := _buyuk_dugme("MENÜ", Color(0.3, 0.4, 0.3), func() -> void: menu_istendi.emit(), 230)
	menu.offset_left = 10
	menu.offset_right = 330
	_bitis.add_child(menu)
	_bitis.visible = false


func _buyuk_dugme(metin: String, renk: Color, eylem: Callable, alttan_ust: float) -> Button:
	var d := Button.new()
	d.text = metin
	d.focus_mode = Control.FOCUS_NONE
	d.add_theme_font_size_override("font_size", 44)
	d.add_theme_stylebox_override("normal", _kutu_stili(renk, renk.lightened(0.4), 24))
	d.add_theme_stylebox_override("hover", _kutu_stili(renk, renk.lightened(0.4), 24))
	d.add_theme_stylebox_override("pressed", _kutu_stili(renk.lightened(0.2), Color.WHITE, 24))
	d.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	d.offset_left = -200
	d.offset_right = 200
	d.offset_top = -alttan_ust
	d.offset_bottom = -alttan_ust + 110
	d.pressed.connect(eylem)
	return d


# ---------------------------------------------------------------- güncelleme

func guncelle(dalga: int, altin: int, oldurme: int, can_orani: float, oyunda: bool, fiyat: int = 25) -> void:
	if fiyat != onar_fiyat:
		onar_fiyat = fiyat
		_onar_dugme.text = "ONAR  %d altın" % onar_fiyat
	_duraklat_dugme.visible = oyunda
	_dalga_etiket.text = "DALGA %d" % dalga
	_altin_etiket.text = "%d ALTIN" % altin
	_oldurme_etiket.text = "%d zombi" % oldurme
	_can_cubugu.value = can_orani * 100.0
	var dolu := _can_cubugu.get_theme_stylebox("fill") as StyleBoxFlat
	dolu.bg_color = Color(0.85, 0.2, 0.2).lerp(Color(0.3, 0.8, 0.35), can_orani)
	_onar_dugme.visible = oyunda
	_onar_dugme.disabled = altin < onar_fiyat or can_orani >= 0.999


func dalga_afisi(metin: String) -> void:
	_afis.text = metin
	var tw := create_tween()
	_afis.modulate.a = 0.0
	_afis.scale = Vector2(1.3, 1.3)
	_afis.pivot_offset = _afis.size / 2
	tw.tween_property(_afis, "modulate:a", 1.0, 0.25)
	tw.parallel().tween_property(_afis, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK)
	tw.tween_interval(1.0)
	tw.tween_property(_afis, "modulate:a", 0.0, 0.5)


func kartlari_goster(secenekler: Array[Dictionary], seviyeler: Dictionary) -> void:
	for c in _kart_kutusu.get_children():
		c.queue_free()
	for k in secenekler:
		var renk: Color = k["renk"]
		var sv := int(seviyeler.get(k["id"], 0))
		var d := Button.new()
		d.focus_mode = Control.FOCUS_NONE
		d.custom_minimum_size = Vector2(600, 170)
		d.text = "%s   (Sv %d → %d)\n%s" % [k["ad"], sv, sv + 1, k["aciklama"]]
		d.add_theme_font_size_override("font_size", 32)
		d.add_theme_stylebox_override("normal", _kutu_stili(renk.darkened(0.55), renk, 22))
		d.add_theme_stylebox_override("hover", _kutu_stili(renk.darkened(0.55), renk, 22))
		d.add_theme_stylebox_override("pressed", _kutu_stili(renk.darkened(0.2), Color.WHITE, 22))
		var id: String = k["id"]
		d.pressed.connect(func() -> void: _kart_tiklandi(id))
		_kart_kutusu.add_child(d)
	_kart_paneli.visible = true
	_kart_paneli.modulate.a = 0.0
	create_tween().tween_property(_kart_paneli, "modulate:a", 1.0, 0.25)


func _kart_tiklandi(id: String) -> void:
	_kart_paneli.visible = false
	kart_secildi.emit(id)


func oyun_basladi() -> void:
	_duraklat_paneli.visible = false
	_bitis.visible = false
	_kart_paneli.visible = false


func bitis_goster(dalga: int, oldurme: int, rekor: int, yeni_rekor: bool, ozet: Dictionary) -> void:
	var metin := "%d. dalgaya kadar dayandın\n%d zombi öldürdün · En iyi: %d" % [dalga, oldurme, rekor]
	if yeni_rekor:
		metin += "\nYENİ REKOR!"
	_bitis_metin.text = metin
	for c in _odul_kutusu.get_children():
		c.queue_free()
	_odul_ekle("ÖDÜLLER", Color(1, 0.85, 0.4), 32)
	_odul_ekle("+%d hurda" % int(ozet.get("hurda", 0)), Color(1, 0.8, 0.35), 30)
	for sl in ozet.get("silahlar", []):
		var n: Dictionary = Veri.NADIRLIK[int(sl["nadirlik"])]
		_odul_ekle("Silah: %s %s" % [n["ad"], Veri.SILAHLAR[sl["taban"]]["ad"]], n["renk"], 28)
	var gelisen: Array = ozet.get("gelisim", [])
	if not gelisen.is_empty():
		var sayim := {}
		for g in gelisen:
			sayim[g] = int(sayim.get(g, 0)) + 1
		var parcalar: Array[String] = []
		for o in Veri.OZELLIKLER:
			if sayim.has(o["id"]):
				parcalar.append("%s +%d" % [o["ad"], sayim[o["id"]]])
		_odul_ekle("Gelişim: " + ", ".join(parcalar), Color(0.55, 0.85, 1.0), 26)
	if bool(ozet.get("seviye_atladi", false)):
		_odul_ekle("Seviye atladı!", Color(0.6, 1, 0.5), 28)
	var m := int(ozet.get("moral", 0))
	if m != 0:
		_odul_ekle("Moral %s%d" % ["+" if m > 0 else "", m], Color(0.6, 1, 0.5) if m > 0 else Color(1, 0.55, 0.45), 26)
	_kart_paneli.visible = false
	_duraklat_paneli.visible = false
	_bitis.visible = true
	_bitis.modulate.a = 0.0
	create_tween().tween_property(_bitis, "modulate:a", 1.0, 0.6)


func bitis_gizle() -> void:
	_bitis.visible = false
	_kart_paneli.visible = false
	_duraklat_paneli.visible = false


func _odul_ekle(metin: String, renk: Color, boyut: int) -> void:
	var l := _etiket(boyut, renk)
	l.text = metin
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_odul_kutusu.add_child(l)
