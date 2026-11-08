extends CanvasLayer
## Ekran arayüzü: üst bilgi çubuğu, barikat canı, onar düğmesi, kart seçimi,
## başlangıç ve oyun sonu ekranları. Her şey koddan kurulur.

signal kart_secildi(id: String)
signal onar_istendi
signal basla_istendi
signal menu_istendi
signal duraklat_istendi(duraklat: bool)
signal hiz_istendi
signal yeniden_cek_istendi
signal aktif_istendi
signal kule_istendi(i: int)
signal konusma_istendi(secim: String)
signal oto_istendi
signal yukselt_istendi(tur: String)  # kampanya sonu: "sur" ya da "guc"
signal oto_tekrar_istendi  # Kampanya v3: sonuç ekranında OTO TEKRAR aç/kapa/durdur

const Veri := preload("res://betikler/veri.gd")
const Kartlar := preload("res://betikler/kartlar.gd")

var onar_fiyat := 25

var _dalga_etiket: Label
var _altin_etiket: Label
var _oldurme_etiket: Label
var _can_cubugu: ProgressBar
var _onar_dugme: Button
var _afis: Label
var _kart_paneli: Control
var _kart_kutusu: VBoxContainer
var _kart_baslik: Label
var _duraklat_dugme: Button
var _hiz_dugme: Button
var _duraklat_paneli: Control
var _fps_etiket: Label
var _ipucu: Label
var _odul_kutusu: VBoxContainer
var _bitis: Control
var _bitis_metin: Label
var _ust_bosluk := 30.0
var _cek_dugme: Button
var _boss_ad: Label
var _boss_cubugu: ProgressBar
var _tanitim: PanelContainer
var _tanitim_baslik: Label
var _tanitim_metin: Label
var _uyari: Label
var _bitis_baslik: Label
var _tekrar_dugme: Button
var _aktif_dugme: Button
var _aktif_ad := ""
var _aktif_son := -1
var _kule_dugmeler: Array[Button] = []
var _konusma_kutu: VBoxContainer
var _konusma_satir: HBoxContainer
var _konusma_metin: Label
var _oto_dugme: Button
var _oto_izin := false
var _yukselt_kutu: VBoxContainer
var _yukselt_sur: Button
var _yukselt_guc: Button
var _yukselt_bilgi: Label
var _bolum_serit: BolumSeridi
var _gedik := 0
var _oto_tekrar_dugme: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var guvenli := DisplayServer.get_display_safe_area()
	var pencere := DisplayServer.window_get_size()
	if pencere.y > 0:
		_ust_bosluk += guvenli.position.y * get_viewport().get_visible_rect().size.y / pencere.y
	_ust_cubuk_kur()
	_onar_kur()
	_aktif_kur()
	_afis_kur()
	_kart_paneli_kur()
	_duraklat_kur()
	_bitis_kur()
	_boss_kur()
	_tanitim_kur()


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
	# Barikat v3: can çubuğunun altında 6 bölümlü şerit; gedik kırmızı yanıp söner
	_bolum_serit = BolumSeridi.new()
	_bolum_serit.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_bolum_serit)
	_bolum_serit.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_bolum_serit.offset_left = -300
	_bolum_serit.offset_right = -24
	_bolum_serit.offset_top = _ust_bosluk + 82
	_bolum_serit.offset_bottom = _ust_bosluk + 92


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


## Aktif yetenek: sol altta, ONAR'ın karşısında. Başparmakla rahat ulaşılır.
func _aktif_kur() -> void:
	_aktif_dugme = Button.new()
	_aktif_dugme.add_theme_font_size_override("font_size", 24)
	var dolu := Color(0.6, 0.25, 0.12, 0.95)
	_aktif_dugme.add_theme_stylebox_override("normal", _kutu_stili(dolu, Color(1, 0.75, 0.35), 14))
	_aktif_dugme.add_theme_stylebox_override("hover", _kutu_stili(dolu, Color(1, 0.75, 0.35), 14))
	_aktif_dugme.add_theme_stylebox_override("pressed", _kutu_stili(dolu.lightened(0.3), Color.WHITE, 14))
	_aktif_dugme.add_theme_stylebox_override("disabled", _kutu_stili(Color(0.2, 0.2, 0.2, 0.7), Color(0.4, 0.4, 0.4), 14))
	_aktif_dugme.focus_mode = Control.FOCUS_NONE
	add_child(_aktif_dugme)
	_aktif_dugme.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	_aktif_dugme.offset_left = 20
	_aktif_dugme.offset_right = 250
	_aktif_dugme.offset_top = -86
	_aktif_dugme.offset_bottom = -20
	_aktif_dugme.pressed.connect(func() -> void: aktif_istendi.emit())


func aktif_ayarla(ad: String) -> void:
	_aktif_ad = ad
	_aktif_son = -1
	aktif_guncelle(0.0)


## Yazı yalnızca saniye değişince güncellenir.
func aktif_guncelle(kalan: float) -> void:
	var sn := ceili(kalan)
	if sn == _aktif_son:
		return
	_aktif_son = sn
	_aktif_dugme.disabled = sn > 0
	_aktif_dugme.text = _aktif_ad if sn <= 0 else "Bekle: %d sn" % sn


## Barikattaki yuvaların altında satın alma düğmeleri; yalnız para yetince görünür.
func kule_dugmeleri_kur(konumlar: Array) -> void:
	for i in konumlar.size():
		var d := Button.new()
		d.focus_mode = Control.FOCUS_NONE
		d.add_theme_font_size_override("font_size", 22)
		var st := _kutu_stili(Color(0.15, 0.2, 0.12, 0.88), Color(0.95, 0.8, 0.35), 12)
		st.content_margin_top = 4
		st.content_margin_bottom = 4
		st.content_margin_left = 6
		st.content_margin_right = 6
		d.add_theme_stylebox_override("normal", st)
		d.add_theme_stylebox_override("hover", st)
		d.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.35, 0.4, 0.2), Color.WHITE, 12))
		d.position = konumlar[i] + Vector2(-70, 48)
		d.size = Vector2(140, 52)
		var idx: int = i
		d.pressed.connect(func() -> void: kule_istendi.emit(idx))
		d.visible = false
		add_child(d)
		_kule_dugmeler.append(d)


func kule_guncelle(fiyatlar: Array, altin: int, oyunda: bool, uzman: Array = []) -> void:
	for i in _kule_dugmeler.size():
		var f: int = fiyatlar[i]
		_kule_dugmeler[i].visible = oyunda and f > 0 and altin >= f
		_kule_dugmeler[i].text = ("UZMAN %d" if i < uzman.size() and uzman[i] else "TARET %d") % f


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
	_kart_baslik = _etiket(48, Color(1, 0.9, 0.5))
	_kart_baslik.text = "Bir yetenek seç"
	_kart_paneli.add_child(_kart_baslik)
	_kart_baslik.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_kart_baslik.offset_left = -360
	_kart_baslik.offset_right = 360
	_kart_baslik.offset_top = 230
	_kart_baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_kart_kutusu = VBoxContainer.new()
	_kart_kutusu.add_theme_constant_override("separation", 26)
	_kart_paneli.add_child(_kart_kutusu)
	_kart_kutusu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_kart_kutusu.offset_left = -300
	_kart_kutusu.offset_right = 300
	_kart_kutusu.offset_top = -330
	_kart_kutusu.offset_bottom = 330
	_kart_kutusu.alignment = BoxContainer.ALIGNMENT_CENTER
	_cek_dugme = Button.new()
	_cek_dugme.focus_mode = Control.FOCUS_NONE
	_cek_dugme.add_theme_font_size_override("font_size", 26)
	_cek_dugme.add_theme_stylebox_override("normal", _kutu_stili(Color(0.2, 0.25, 0.32), Color(0.5, 0.7, 0.9), 14))
	_cek_dugme.add_theme_stylebox_override("hover", _kutu_stili(Color(0.2, 0.25, 0.32), Color(0.5, 0.7, 0.9), 14))
	_cek_dugme.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.3, 0.38, 0.48), Color.WHITE, 14))
	_cek_dugme.add_theme_stylebox_override("disabled", _kutu_stili(Color(0.17, 0.17, 0.17), Color(0.35, 0.35, 0.35), 14))
	_kart_paneli.add_child(_cek_dugme)
	_cek_dugme.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_cek_dugme.offset_left = -220
	_cek_dugme.offset_right = 220
	_cek_dugme.offset_top = -170
	_cek_dugme.offset_bottom = -96
	_cek_dugme.pressed.connect(func() -> void: yeniden_cek_istendi.emit())
	_kart_paneli.visible = false


func _boss_kur() -> void:
	_boss_ad = _etiket(26, Color(1, 0.45, 0.35))
	_boss_ad.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_boss_ad)
	_boss_ad.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_boss_ad.offset_top = _ust_bosluk + 96
	_boss_cubugu = ProgressBar.new()
	_boss_cubugu.show_percentage = false
	_boss_cubugu.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var arka := StyleBoxFlat.new()
	arka.bg_color = Color(0.1, 0.02, 0.02, 0.9)
	arka.set_corner_radius_all(6)
	var dolu := StyleBoxFlat.new()
	dolu.bg_color = Color(0.9, 0.18, 0.12)
	dolu.set_corner_radius_all(6)
	_boss_cubugu.add_theme_stylebox_override("background", arka)
	_boss_cubugu.add_theme_stylebox_override("fill", dolu)
	add_child(_boss_cubugu)
	_boss_cubugu.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_boss_cubugu.offset_left = 60
	_boss_cubugu.offset_right = -60
	_boss_cubugu.offset_top = _ust_bosluk + 134
	_boss_cubugu.offset_bottom = _ust_bosluk + 156
	boss_gizle()


func boss_goster(ad: String, oran: float) -> void:
	_boss_ad.text = ad
	_boss_ad.visible = true
	_boss_cubugu.visible = true
	_boss_cubugu.value = oran * 100.0


func boss_gizle() -> void:
	if _boss_ad:
		_boss_ad.visible = false
		_boss_cubugu.visible = false


## Yeni zombi tanıtımı (Kingdom Rush): oyunu durdurmadan üstte birkaç saniye kalır.
func _tanitim_kur() -> void:
	_tanitim = PanelContainer.new()
	_tanitim.add_theme_stylebox_override("panel", _kutu_stili(Color(0.08, 0.1, 0.08, 0.92), Color(0.9, 0.75, 0.3), 16))
	_tanitim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_tanitim)
	_tanitim.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_tanitim.offset_left = 24
	_tanitim.offset_right = -24
	_tanitim.offset_top = _ust_bosluk + 170
	_tanitim.offset_bottom = _ust_bosluk + 290
	var v := VBoxContainer.new()
	v.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tanitim.add_child(v)
	_tanitim_baslik = _etiket(28, Color(1, 0.85, 0.4))
	v.add_child(_tanitim_baslik)
	_tanitim_metin = _etiket(24)
	_tanitim_metin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_tanitim_metin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(_tanitim_metin)
	_tanitim.visible = false
	_uyari = _etiket(26, Color(1, 0.9, 0.6))
	_uyari.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_uyari)
	_uyari.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	_uyari.offset_top = _ust_bosluk + 300
	_uyari.modulate.a = 0.0


func tanitim_goster(ad: String, metin: String) -> void:
	_tanitim_baslik.text = "YENİ ZOMBİ: " + ad
	_tanitim_metin.text = metin
	_tanitim.visible = true
	_tanitim.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(5.0)
	tw.tween_property(_tanitim, "modulate:a", 0.0, 0.5)
	tw.tween_callback(func() -> void: _tanitim.visible = false)


func uyari_goster(metin: String) -> void:
	_uyari.text = metin
	_uyari.modulate.a = 1.0
	var tw := create_tween()
	tw.tween_interval(2.5)
	tw.tween_property(_uyari, "modulate:a", 0.0, 0.5)


func _tam_ekran_panel(renk: Color) -> Control:
	var p := ColorRect.new()
	p.color = renk
	add_child(p)
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return p


func hiz_goster(h: int) -> void:
	_hiz_dugme.text = "x%d" % h
	var renk := Color(1, 1, 1) if h == 1 else (Color(1, 0.85, 0.3) if h == 2 else Color(1, 0.45, 0.3))
	_hiz_dugme.add_theme_color_override("font_color", renk)
	_hiz_dugme.add_theme_color_override("font_pressed_color", renk)
	_hiz_dugme.add_theme_color_override("font_hover_color", renk)


## izin: bu savaşta otomatik savaş kullanılabilir mi (kampanyada geçilmiş dalga).
func oto_goster(izin: bool, acik: bool) -> void:
	_oto_izin = izin
	_oto_dugme.visible = izin
	_oto_dugme.text = "OTO: AÇIK" if acik else "OTO: KAPALI"
	var renk := Color(0.5, 1, 0.6) if acik else Color(0.85, 0.85, 0.8)
	_oto_dugme.add_theme_color_override("font_color", renk)
	_oto_dugme.add_theme_color_override("font_pressed_color", renk)
	_oto_dugme.add_theme_color_override("font_hover_color", renk)


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

	# Oyun hızı (Grow Castle'daki gibi): x1 → x2 → x3
	_hiz_dugme = Button.new()
	_hiz_dugme.text = "x1"
	_hiz_dugme.focus_mode = Control.FOCUS_NONE
	_hiz_dugme.add_theme_font_size_override("font_size", 30)
	_hiz_dugme.add_theme_stylebox_override("normal", st)
	_hiz_dugme.add_theme_stylebox_override("hover", st)
	_hiz_dugme.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.3, 0.3, 0.3, 0.7), Color.WHITE, 14))
	add_child(_hiz_dugme)
	_hiz_dugme.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_hiz_dugme.offset_left = -130
	_hiz_dugme.offset_right = -50
	_hiz_dugme.offset_top = _ust_bosluk + 4
	_hiz_dugme.offset_bottom = _ust_bosluk + 80
	_hiz_dugme.pressed.connect(func() -> void: hiz_istendi.emit())

	# B4 Otomatik savaş: kampanyada geçilmiş dalgalarda, üst şeridin hemen altında solda
	_oto_dugme = Button.new()
	_oto_dugme.text = "OTO"
	_oto_dugme.focus_mode = Control.FOCUS_NONE
	_oto_dugme.add_theme_font_size_override("font_size", 24)
	_oto_dugme.add_theme_stylebox_override("normal", st)
	_oto_dugme.add_theme_stylebox_override("hover", st)
	_oto_dugme.add_theme_stylebox_override("pressed", _kutu_stili(Color(0.3, 0.3, 0.3, 0.7), Color.WHITE, 14))
	add_child(_oto_dugme)
	_oto_dugme.position = Vector2(20, _ust_bosluk + 106)
	_oto_dugme.size = Vector2(170, 58)
	_oto_dugme.visible = false
	_oto_dugme.pressed.connect(func() -> void: oto_istendi.emit())

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
	_ipucu.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(_ipucu)
	_ipucu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_ipucu.offset_left = -340
	_ipucu.offset_right = 340
	_ipucu.offset_top = 40
	_ipucu.offset_bottom = 160
	_ipucu.modulate.a = 0.0


func ipucu_goster(metin: String) -> void:
	_ipucu.text = metin
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
	var baslik := _etiket(70, Color(1, 0.3, 0.25))
	_bitis_baslik = baslik
	baslik.text = "BARİKAT DÜŞTÜ"
	baslik.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bitis.add_child(baslik)
	baslik.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	baslik.offset_left = -360
	baslik.offset_right = 360
	baslik.offset_top = 90
	_bitis_metin = _etiket(30)
	_bitis_metin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bitis.add_child(_bitis_metin)
	_bitis_metin.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_bitis_metin.offset_left = -360
	_bitis_metin.offset_right = 360
	_bitis_metin.offset_top = -440
	_bitis_metin.offset_bottom = -270
	_odul_kutusu = VBoxContainer.new()
	_odul_kutusu.add_theme_constant_override("separation", 2)
	_bitis.add_child(_odul_kutusu)
	_odul_kutusu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_odul_kutusu.offset_left = -330
	_odul_kutusu.offset_right = 330
	_odul_kutusu.offset_top = -290
	_odul_kutusu.offset_bottom = 220
	var tekrar := _buyuk_dugme("TEKRAR", Color(0.6, 0.2, 0.15), func() -> void: basla_istendi.emit(), 230)
	_tekrar_dugme = tekrar
	tekrar.offset_left = -330
	tekrar.offset_right = -10
	_bitis.add_child(tekrar)
	var menu := _buyuk_dugme("MENÜ", Color(0.3, 0.4, 0.3), func() -> void: menu_istendi.emit(), 230)
	menu.offset_left = 10
	menu.offset_right = 330
	_bitis.add_child(menu)
	_konusma_kur()
	_yukselt_kur()
	_oto_tekrar_dugme = Button.new()
	_oto_tekrar_dugme.focus_mode = Control.FOCUS_NONE
	_oto_tekrar_dugme.add_theme_font_size_override("font_size", 24)
	var ot := Color(0.2, 0.42, 0.5)
	_oto_tekrar_dugme.add_theme_stylebox_override("normal", _kutu_stili(ot, ot.lightened(0.4), 14))
	_oto_tekrar_dugme.add_theme_stylebox_override("hover", _kutu_stili(ot, ot.lightened(0.4), 14))
	_oto_tekrar_dugme.add_theme_stylebox_override("pressed", _kutu_stili(ot.lightened(0.2), Color.WHITE, 14))
	_bitis.add_child(_oto_tekrar_dugme)
	_oto_tekrar_dugme.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_oto_tekrar_dugme.offset_left = -330
	_oto_tekrar_dugme.offset_right = 330
	_oto_tekrar_dugme.offset_top = _ust_bosluk
	_oto_tekrar_dugme.offset_bottom = _ust_bosluk + 56
	_oto_tekrar_dugme.pressed.connect(func() -> void: oto_tekrar_istendi.emit())
	_oto_tekrar_dugme.visible = false
	_bitis.visible = false


## Kampanya v2: zafer/yenilgi ekranında hemen yükseltme (Grow Castle: "bir yükseltme, bir dalga").
## Konuşma kutusuyla aynı yerde durur; kampanyada konuşma yok, ikisi birlikte görünmez.
func _yukselt_kur() -> void:
	_yukselt_kutu = VBoxContainer.new()
	_yukselt_kutu.add_theme_constant_override("separation", 8)
	_bitis.add_child(_yukselt_kutu)
	_yukselt_kutu.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_yukselt_kutu.offset_left = -330
	_yukselt_kutu.offset_right = 330
	_yukselt_kutu.offset_top = -405
	_yukselt_kutu.offset_bottom = -240
	_yukselt_bilgi = _etiket(24, Color(0.85, 0.85, 0.8))
	_yukselt_bilgi.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_yukselt_bilgi.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_yukselt_kutu.add_child(_yukselt_bilgi)
	var satir := HBoxContainer.new()
	satir.add_theme_constant_override("separation", 10)
	_yukselt_kutu.add_child(satir)
	_yukselt_sur = _yukselt_dugmesi(Color(0.45, 0.38, 0.25), "sur")
	satir.add_child(_yukselt_sur)
	_yukselt_guc = _yukselt_dugmesi(Color(0.55, 0.3, 0.15), "guc")
	satir.add_child(_yukselt_guc)
	_yukselt_kutu.visible = false


func _yukselt_dugmesi(r: Color, tur: String) -> Button:
	var d := Button.new()
	d.focus_mode = Control.FOCUS_NONE
	d.custom_minimum_size.y = 84
	d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	d.add_theme_font_size_override("font_size", 24)
	d.add_theme_stylebox_override("normal", _kutu_stili(r, r.lightened(0.4), 14))
	d.add_theme_stylebox_override("hover", _kutu_stili(r, r.lightened(0.4), 14))
	d.add_theme_stylebox_override("pressed", _kutu_stili(r.lightened(0.2), Color.WHITE, 14))
	d.add_theme_stylebox_override("disabled", _kutu_stili(Color(0.2, 0.2, 0.2, 0.8), Color(0.4, 0.4, 0.4), 14))
	d.pressed.connect(func() -> void: yukselt_istendi.emit(tur))
	return d


## Yükseltme düğmelerinin metni ve etkinliği (oyun.gd her alımdan sonra yeniden çağırır).
func yukselt_guncelle(sur_metin: String, sur_etkin: bool, guc_metin: String, guc_etkin: bool, bilgi: String) -> void:
	_yukselt_kutu.visible = true
	_yukselt_sur.text = sur_metin
	_yukselt_sur.disabled = not sur_etkin
	_yukselt_guc.text = guc_metin
	_yukselt_guc.disabled = not guc_etkin
	_yukselt_bilgi.text = bilgi


## Koşu sonu ekip konuşması: TEKRAR/MENÜ'nün hemen üstünde, cevap aynı yere yazılır.
func _konusma_kur() -> void:
	_konusma_kutu = VBoxContainer.new()
	_konusma_kutu.add_theme_constant_override("separation", 8)
	_bitis.add_child(_konusma_kutu)
	_konusma_kutu.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_konusma_kutu.offset_left = -330
	_konusma_kutu.offset_right = 330
	_konusma_kutu.offset_top = -405
	_konusma_kutu.offset_bottom = -240
	_konusma_metin = _etiket(25, Color(0.85, 0.85, 0.8))
	_konusma_metin.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_konusma_metin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_konusma_kutu.add_child(_konusma_metin)
	_konusma_satir = HBoxContainer.new()
	_konusma_satir.add_theme_constant_override("separation", 10)
	_konusma_kutu.add_child(_konusma_satir)
	for secim in Veri.KONUSMALAR:
		var d := Button.new()
		d.text = String(Veri.KONUSMALAR[secim]["ad"])
		d.focus_mode = Control.FOCUS_NONE
		d.custom_minimum_size.y = 72
		d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		d.add_theme_font_size_override("font_size", 28)
		var r := Color(0.28, 0.33, 0.42)
		d.add_theme_stylebox_override("normal", _kutu_stili(r, r.lightened(0.4), 14))
		d.add_theme_stylebox_override("hover", _kutu_stili(r, r.lightened(0.4), 14))
		d.add_theme_stylebox_override("pressed", _kutu_stili(r.lightened(0.2), Color.WHITE, 14))
		var s: String = secim
		d.pressed.connect(func() -> void: konusma_istendi.emit(s))
		_konusma_satir.add_child(d)


func konusma_sonuc(metin: String, renk: Color) -> void:
	_konusma_satir.visible = false
	_konusma_metin.text = metin
	_konusma_metin.add_theme_color_override("font_color", renk)


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
		_onar_metni()
	_duraklat_dugme.visible = oyunda
	_hiz_dugme.visible = oyunda
	_dalga_etiket.text = "DALGA %d" % dalga
	_altin_etiket.text = "%d ALTIN" % altin
	_oldurme_etiket.text = "%d zombi" % oldurme
	_can_cubugu.value = can_orani * 100.0
	var dolu := _can_cubugu.get_theme_stylebox("fill") as StyleBoxFlat
	dolu.bg_color = Color(0.85, 0.2, 0.2).lerp(Color(0.3, 0.8, 0.35), can_orani)
	_onar_dugme.visible = oyunda
	_aktif_dugme.visible = oyunda
	_oto_dugme.visible = oyunda and _oto_izin
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


## oneri: A6 akıllı kart seçiminin en yüksek puanlı kartı; kartın üstünde "★ ÖNERİ" yazar.
func kartlari_goster(secenekler: Array[Dictionary], seviyeler: Dictionary, cekme_fiyat: int = 15, altin: int = 0, oneri: String = "", oneri_neden: String = "") -> void:
	_tanitim.visible = false
	for c in _kart_kutusu.get_children():
		c.queue_free()
	_kart_baslik.text = "Bir yetenek seç"
	_cek_dugme.text = "Yeniden çek: ücretsiz" if cekme_fiyat == 0 else "Yeniden çek  %d altın  (%d var)" % [cekme_fiyat, altin]
	_cek_dugme.disabled = altin < cekme_fiyat
	for k in secenekler:
		var renk: Color = k["renk"]
		var sv := int(seviyeler.get(k["id"], 0))
		var evrim: bool = k.has("evrim")
		var d := Button.new()
		d.focus_mode = Control.FOCUS_NONE
		d.custom_minimum_size = Vector2(600, 170)
		d.alignment = HORIZONTAL_ALIGNMENT_CENTER
		d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var ipucu: String = Kartlar.evrim_ipucu(k["id"], seviyeler)
		if evrim:
			d.text = "EVRİM: %s\n%s" % [k["ad"], k["aciklama"]]
		elif int(k["max"]) > 1000:
			d.text = "%s\n%s" % [k["ad"], k["aciklama"]]
		else:
			d.text = "%s   %s\n%s" % [k["ad"], "●".repeat(sv) + "○".repeat(int(k["max"]) - sv), k["aciklama"]]
		if ipucu != "":
			d.text += "\n" + ipucu
		if oneri != "" and k["id"] == oneri and not evrim:
			d.text = "★ ÖNERİ%s\n%s" % ["  (" + oneri_neden + ")" if oneri_neden != "" else "", d.text]
		d.add_theme_font_size_override("font_size", 34 if evrim else 28)
		var dolgu := renk.darkened(0.25 if evrim else 0.55)
		d.add_theme_stylebox_override("normal", _kutu_stili(dolgu, Color.WHITE if evrim else renk, 22))
		d.add_theme_stylebox_override("hover", _kutu_stili(dolgu, Color.WHITE if evrim else renk, 22))
		d.add_theme_stylebox_override("pressed", _kutu_stili(renk.darkened(0.2), Color.WHITE, 22))
		var id: String = k["id"]
		d.pressed.connect(func() -> void: _kart_tiklandi(id))
		_kart_kutusu.add_child(d)
	if not _kart_paneli.visible:
		_kart_paneli.visible = true
		_kart_paneli.modulate.a = 0.0
		create_tween().tween_property(_kart_paneli, "modulate:a", 1.0, 0.25)


## Taret uzmanlığı aynı kart ekranını kullanır; alttaki düğme "Vazgeç" olur.
func uzman_goster(secenekler: Array[Dictionary], fiyat: int) -> void:
	kartlari_goster(secenekler, {}, 0, 0)
	_kart_baslik.text = "Uzmanlık seç: %d altın" % fiyat
	_cek_dugme.text = "Vazgeç"
	_cek_dugme.disabled = false


func kart_kapat() -> void:
	_kart_paneli.visible = false


func _kart_tiklandi(id: String) -> void:
	_kart_paneli.visible = false
	kart_secildi.emit(id)


## Barikat v3: bölüm canlarını şeride yazar; gedik varken ONAR düğmesi "GEDİĞİ KAPAT" olur.
func bolum_guncelle(bolumler: PackedFloat32Array, bolum_max: float, gedik: int) -> void:
	_bolum_serit.ayarla(bolumler, bolum_max)
	if gedik != _gedik:
		_gedik = gedik
		_onar_metni()


func _onar_metni() -> void:
	_onar_dugme.text = ("GEDİK! ONAR %d" if _gedik > 0 else "ONAR  %d altın") % onar_fiyat
	_onar_dugme.add_theme_color_override("font_color", Color(1, 0.55, 0.45) if _gedik > 0 else Color.WHITE)


## Kampanya v3: sonuç ekranının üstündeki OTO TEKRAR düğmesi (yalnız TEKRAR savaşlarında görünür).
func oto_tekrar_goster(gorunur: bool, metin: String) -> void:
	_oto_tekrar_dugme.visible = gorunur
	_oto_tekrar_dugme.text = metin


func oyun_basladi() -> void:
	_duraklat_paneli.visible = false
	_bitis.visible = false
	_kart_paneli.visible = false


func bitis_goster(dalga: int, oldurme: int, rekor: int, yeni_rekor: bool, ozet: Dictionary) -> void:
	_bitis_baslik.text = "BARİKAT DÜŞTÜ"
	_bitis_baslik.add_theme_color_override("font_color", Color(1, 0.3, 0.25))
	(_bitis as ColorRect).color = Color(0.12, 0.0, 0.0, 0.78)
	_tekrar_dugme.text = "TEKRAR"
	_yukselt_kutu.visible = false
	_oto_tekrar_dugme.visible = false
	var metin := "%d. dalgaya kadar dayandın\n%d zombi öldürdün · En iyi: %d" % [dalga, oldurme, rekor]
	_konusma_kutu.visible = ozet.has("uid")
	_konusma_satir.visible = true
	_konusma_metin.add_theme_color_override("font_color", Color(0.85, 0.85, 0.8))
	_konusma_metin.text = "%s ile konuş:" % String(ozet.get("ad", "Ekip"))
	if yeni_rekor:
		metin += "\nYENİ REKOR!"
	_bitis_metin.text = metin
	for c in _odul_kutusu.get_children():
		c.queue_free()
	if ozet.has("neden"):
		_odul_ekle(String(ozet["neden"]), Color(1, 0.65, 0.5), 24)
	if ozet.has("puanlar"):
		# FM maç puanı: lider ve surdakiler; en iyi olan "koşunun yıldızı"
		var parca: Array[String] = []
		for p in ozet["puanlar"]:
			parca.append("%s %.1f%s" % [p["ad"], float(p["puan"]), " ★" if p.has("yildiz") else ""])
		_odul_ekle("Puan: " + "  ·  ".join(parca), Color(0.95, 0.9, 0.6), 24)
	if ozet.has("yildiz"):
		var y := int(ozet["yildiz"])
		_odul_ekle("%s  %d/3%s" % ["★".repeat(y), y, "  YENİ!" if bool(ozet.get("yildiz_yeni", false)) else ""],
			Color(1, 0.85, 0.2), 34)
	for yo in ozet.get("yildiz_odulleri", []):
		_odul_ekle(String(yo), Color(1, 0.75, 1.0), 26)
	_odul_ekle("ÖDÜLLER", Color(1, 0.85, 0.4), 28)
	if ozet.has("kampanya"):
		_odul_ekle("+%d altın  ·  +%d hurda" % [int(ozet.get("altin", 0)), int(ozet.get("hurda", 0))], Color(1, 0.8, 0.35), 28)
	else:
		_odul_ekle("+%d hurda" % int(ozet.get("hurda", 0)), Color(1, 0.8, 0.35), 28)
	if ozet.has("tehdit"):
		_odul_ekle("Tehdit %d: hurda +%%%d" % [int(ozet["tehdit"]), int(round(Veri.TEHDIT_HURDA * int(ozet["tehdit"]) * 100))],
			Color(1, 0.55, 0.4), 24)
	if ozet.has("tehdit_odul"):
		_odul_ekle(String(ozet["tehdit_odul"]), Color(1, 0.6, 1.0), 26)
	if bool(ozet.get("x3", false)):
		_odul_ekle("x3 OYUN HIZI AÇILDI!", Color(0.6, 1, 0.9), 28)
	if ozet.has("hedef"):
		_odul_ekle(String(ozet["hedef"]), Color(0.75, 0.85, 1.0), 24)
	# en değerli 3 silah gösterilir, kalanı tek satırda (ekrana sığsın)
	var silahlar: Array = ozet.get("silahlar", []).duplicate()
	silahlar.sort_custom(func(a, b) -> bool: return int(a["nadirlik"]) > int(b["nadirlik"]))
	for i in mini(silahlar.size(), 3):
		var sl: Dictionary = silahlar[i]
		var n: Dictionary = Veri.NADIRLIK[int(sl["nadirlik"])]
		_odul_ekle("Silah: %s %s" % [n["ad"], Veri.SILAHLAR[sl["taban"]]["ad"]], n["renk"], 26)
	if silahlar.size() > 3:
		_odul_ekle("+%d silah daha" % (silahlar.size() - 3), Color(0.8, 0.8, 0.75), 24)
	var gelisen: Array = ozet.get("gelisim", [])
	if not gelisen.is_empty():
		var sayim := {}
		for g in gelisen:
			sayim[g] = int(sayim.get(g, 0)) + 1
		var parcalar: Array[String] = []
		for o in Veri.OZELLIKLER:
			if sayim.has(o["id"]):
				parcalar.append("%s +%d" % [o["ad"], sayim[o["id"]]])
		_odul_ekle("Gelişim: " + ", ".join(parcalar), Color(0.55, 0.85, 1.0), 24)
	var m := int(ozet.get("moral", 0))
	var moral_yazi := ("Moral %s%d" % ["+" if m > 0 else "", m]) if m != 0 else ""
	if bool(ozet.get("seviye_atladi", false)):
		moral_yazi = "Seviye atladı!" + ("  ·  " + moral_yazi if moral_yazi != "" else "")
	if moral_yazi != "":
		_odul_ekle(moral_yazi, Color(0.6, 1, 0.5) if m >= 0 else Color(1, 0.55, 0.45), 24)
	var sakat: Dictionary = ozet.get("sakat", {})
	if not sakat.is_empty():
		_odul_ekle("SAKATLIK: %s %d koşu oynayamaz" % [sakat["ad"], int(sakat["sure"])], Color(1, 0.45, 0.4), 26)
		if sakat.has("yedek"):
			_odul_ekle("Sahaya %s çıkıyor" % sakat["yedek"], Color(0.8, 0.85, 0.75), 24)
	elif String(ozet.get("yorgunluk", "")) in ["Yorgun", "Bitkin"]:
		_odul_ekle("Durum: %s. Rotasyon yap, gücü düşüyor." % ozet["yorgunluk"], Color(1, 0.75, 0.4), 24)
	_kart_paneli.visible = false
	_duraklat_paneli.visible = false
	_bitis.visible = true
	_bitis.modulate.a = 0.0
	create_tween().tween_property(_bitis, "modulate:a", 1.0, 0.6)


## Kampanya savaşı sonu: bitiş ekranı kullanılır, başlık/metin/düğme kampanyaya göre değişir.
func kampanya_sonu_goster(kazandi: bool, dalga: int, oldurme: int, sonraki: int, ozet: Dictionary) -> void:
	bitis_goster(dalga, oldurme, 0, false, ozet)
	if kazandi:
		_bitis_baslik.text = "ZAFER!"
		_bitis_baslik.add_theme_color_override("font_color", Color(0.55, 1, 0.45))
		(_bitis as ColorRect).color = Color(0.0, 0.1, 0.02, 0.8)
		_bitis_metin.text = "Kampanya %d. dalga geçildi\n%d zombi öldürdün\nSıradaki: %d. dalga%s" % [dalga, oldurme, sonraki,
			"  (BOSS)" if sonraki % Veri.KAMPANYA_BOSS == 0 else ""]
		_tekrar_dugme.text = "SONRAKİ"
	else:
		_bitis_metin.text = "Kampanya %d. dalga\nCeza yok: Sur'u ve Güç seviyelerini\nyükseltip yeniden dene." % dalga
		_tekrar_dugme.text = "YENİDEN"


func tekrar_metni(metin: String) -> void:
	_tekrar_dugme.text = metin


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


## Barikat v3: HUD'daki 6 bölümlü can şeridi. Yalnızca can değişince çizilir; gedik varken yanıp sönmek için
## kendi _process'i açılır (gedik kapanınca kapanır).
class BolumSeridi extends Control:
	var _bolum := PackedFloat32Array([1, 1, 1, 1, 1, 1])
	var _max := 1.0
	var _zaman := 0.0

	func _ready() -> void:
		set_process(false)

	func ayarla(b: PackedFloat32Array, m: float) -> void:
		_bolum = b
		_max = maxf(m, 0.001)
		var gedik := false
		for x in _bolum:
			if x <= 0.0:
				gedik = true
		set_process(gedik)
		queue_redraw()

	func _process(delta: float) -> void:
		_zaman += delta
		queue_redraw()

	func _draw() -> void:
		var n := _bolum.size()
		if n == 0:
			return
		var w := size.x / n
		for i in n:
			var o := clampf(_bolum[i] / _max, 0.0, 1.0)
			var r := Rect2(i * w + 2.0, 0.0, w - 4.0, size.y)
			draw_rect(r, Color(0.12, 0.03, 0.03, 0.85))
			if o > 0.0:
				draw_rect(Rect2(r.position, Vector2(r.size.x * o, r.size.y)), Color(0.9, 0.2, 0.15).lerp(Color(0.35, 0.85, 0.3), o))
			else:
				var a := 0.45 + 0.45 * sin(_zaman * 10.0)
				draw_rect(r, Color(1, 0.15, 0.1, a))
