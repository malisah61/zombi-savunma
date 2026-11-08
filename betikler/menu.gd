extends CanvasLayer
## Ana menü: alt sekmeler (Oyna, Ekip, Envanter, Keşif, Ayarlar). Mobil oyun düzeni:
## üstte hurda, ortada kaydırılabilir içerik, altta sekme çubuğu. Her sekme koddan kurulur.

signal oyna_istendi
signal devam_istendi  # Hayatta Kalma: kaldığın dalgadan devam
signal ayarlar_degisti

const Veri := preload("res://betikler/veri.gd")
const YildizBetik := preload("res://betikler/yildiz.gd")

const SEKMELER := ["OYNA", "EKİP", "ENVANTER", "KEŞİF", "LAB", "KASABA", "AYARLAR"]
const BOSLUK := 18

var profil  # profil.gd
var _sekme := 0
var _icerik: VBoxContainer
var _kaydirma: ScrollContainer
var _hurda_etiket: Label
var _sekme_dugmeleri: Array[Button] = []
var _bildirim: Label
var _sayac := 0.0
var _kesif_etiket: Label
var _kesif_cubuk: ProgressBar
var _ust_bosluk := 24.0
var _acik_kart := ""  # ekipte detayı açık olan hayatta kalan
var _maden_etiket: Label
var _maden_dugme: Button
var _ciftlik_etiket: Label
var _ciftlik_dugme: Button


func _ready() -> void:
	layer = 5
	process_mode = Node.PROCESS_MODE_ALWAYS
	var guvenli := DisplayServer.get_display_safe_area()
	var pencere := DisplayServer.window_get_size()
	if pencere.y > 0:
		_ust_bosluk += guvenli.position.y * get_viewport().get_visible_rect().size.y / pencere.y

	var arka := ColorRect.new()
	arka.color = Color(0.05, 0.07, 0.05, 0.97)
	add_child(arka)
	arka.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# üst bilgi
	var baslik := _etiket("ZOMBİ SAVUNMA", 40, Color(0.75, 0.95, 0.4))
	add_child(baslik)
	baslik.position = Vector2(24, _ust_bosluk)
	_hurda_etiket = _etiket("", 34, Color(1, 0.8, 0.35))
	add_child(_hurda_etiket)
	_hurda_etiket.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	_hurda_etiket.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_hurda_etiket.offset_left = -320
	_hurda_etiket.offset_right = -24
	_hurda_etiket.offset_top = _ust_bosluk + 4

	# içerik
	_kaydirma = ScrollContainer.new()
	_kaydirma.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(_kaydirma)
	_kaydirma.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_kaydirma.offset_top = _ust_bosluk + 70
	_kaydirma.offset_bottom = -120
	_kaydirma.offset_left = 18
	_kaydirma.offset_right = -18
	_icerik = VBoxContainer.new()
	_icerik.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_icerik.add_theme_constant_override("separation", BOSLUK)
	_kaydirma.add_child(_icerik)

	# sekme çubuğu
	var cubuk := HBoxContainer.new()
	cubuk.add_theme_constant_override("separation", 4)
	add_child(cubuk)
	cubuk.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	cubuk.offset_top = -112
	cubuk.offset_left = 6
	cubuk.offset_right = -6
	cubuk.offset_bottom = -8
	for i in SEKMELER.size():
		var d := Button.new()
		d.text = SEKMELER[i]
		d.focus_mode = Control.FOCUS_NONE
		d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		d.add_theme_font_size_override("font_size", 18)  # 7 sekme dar ekrana sığsın
		var idx := i
		d.pressed.connect(func() -> void: sekme_ac(idx))
		cubuk.add_child(d)
		_sekme_dugmeleri.append(d)

	_bildirim = _etiket("", 30, Color.WHITE)
	add_child(_bildirim)
	_bildirim.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_bildirim.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bildirim.offset_top = -200
	_bildirim.offset_bottom = -130
	_bildirim.modulate.a = 0.0


func goster() -> void:
	visible = true
	profil.zaman_dinlenmesi()
	profil.kesif_kontrol()
	profil.gorevleri_hazirla()
	profil.maden_guncelle()
	profil.ciftlik_guncelle()
	sekme_ac(_sekme)


func gizle() -> void:
	visible = false


func _process(delta: float) -> void:
	if not visible:
		return
	_sayac -= delta
	if _sayac > 0.0:
		return
	_sayac = 1.0
	if profil.kesif_kontrol():
		bildir("Keşif raporu hazır!", Color(0.5, 1, 0.5))
		if _sekme == 0 or _sekme == 3:
			sekme_ac(_sekme)
	elif is_instance_valid(_kesif_etiket):
		_kesif_guncelle()
	if is_instance_valid(_maden_etiket):
		profil.maden_guncelle()
		_maden_guncelle()
	if is_instance_valid(_ciftlik_etiket):
		profil.ciftlik_guncelle()
		_ciftlik_guncelle()


# ================================================================ YARDIMCILAR

func _etiket(metin: String, boyut: int, renk: Color = Color.WHITE) -> Label:
	var l := Label.new()
	l.text = metin
	l.add_theme_font_size_override("font_size", boyut)
	l.add_theme_color_override("font_color", renk)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	l.add_theme_constant_override("outline_size", 6)
	l.autowrap_mode = TextServer.AUTOWRAP_OFF
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l


## Dikey kutulardaki yazılar satır kaydırır; yan yana dizilen (satır) yazılar kaydırmaz,
## yoksa dar alanda harf harf alt alta kırılırlar.
func _etiketleri_duzenle(n: Node) -> void:
	for c in n.get_children():
		if c is Label:
			var l := c as Label
			if n is VBoxContainer:
				l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			else:
				l.autowrap_mode = TextServer.AUTOWRAP_OFF
		_etiketleri_duzenle(c)


func _stil(renk: Color, kenar: Color, yaricap: int = 16, kenar_kalinlik: int = 3) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = renk
	s.border_color = kenar
	s.set_border_width_all(kenar_kalinlik)
	s.set_corner_radius_all(yaricap)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s


func _kart(kenar: Color = Color(0.35, 0.4, 0.3)) -> VBoxContainer:
	var p := PanelContainer.new()
	p.add_theme_stylebox_override("panel", _stil(Color(0.11, 0.13, 0.1, 0.95), kenar, 18))
	_icerik.add_child(p)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	p.add_child(v)
	return v


func _dugme(metin: String, renk: Color, eylem: Callable, boyut: int = 26, etkin: bool = true) -> Button:
	var d := Button.new()
	d.text = metin
	d.focus_mode = Control.FOCUS_NONE
	d.disabled = not etkin
	d.add_theme_font_size_override("font_size", boyut)
	d.add_theme_stylebox_override("normal", _stil(renk.darkened(0.35), renk, 14))
	d.add_theme_stylebox_override("hover", _stil(renk.darkened(0.35), renk, 14))
	d.add_theme_stylebox_override("pressed", _stil(renk.darkened(0.1), Color.WHITE, 14))
	d.add_theme_stylebox_override("disabled", _stil(Color(0.18, 0.18, 0.18), Color(0.35, 0.35, 0.35), 14))
	d.add_theme_color_override("font_disabled_color", Color(0.55, 0.55, 0.55))
	d.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	d.custom_minimum_size.y = 64
	d.pressed.connect(eylem)
	return d


func _satir(ana: Control) -> HBoxContainer:
	var h := HBoxContainer.new()
	h.add_theme_constant_override("separation", 10)
	ana.add_child(h)
	return h


func _yildizlar(ana: Control, deger: float, ust: float = -1.0, renk: Color = Color(1.0, 0.8, 0.2)) -> void:
	var y := Control.new()
	y.set_script(YildizBetik)
	ana.add_child(y)
	y.ayarla(deger, ust, renk)


func _ozellik_cubugu(ana: Control, ad: String, deger: int, ust: int = -1) -> void:
	var h := _satir(ana)
	var e := _etiket(ad, 24, Color(0.85, 0.85, 0.8))
	e.custom_minimum_size.x = 210
	e.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(e)
	var c := ProgressBar.new()
	c.show_percentage = false
	c.max_value = 20
	c.value = deger
	c.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	c.custom_minimum_size.y = 18
	var arka := StyleBoxFlat.new()
	arka.bg_color = Color(0.2, 0.2, 0.2)
	arka.set_corner_radius_all(6)
	var dolu := StyleBoxFlat.new()
	dolu.bg_color = _ozellik_rengi(deger)
	dolu.set_corner_radius_all(6)
	c.add_theme_stylebox_override("background", arka)
	c.add_theme_stylebox_override("fill", dolu)
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	h.add_child(c)
	var metin := str(deger) if ust < 0 or ust == deger else "%d-%d" % [deger, ust]
	var d := _etiket(metin, 26, _ozellik_rengi(deger))
	d.custom_minimum_size.x = 70
	d.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	d.autowrap_mode = TextServer.AUTOWRAP_OFF
	h.add_child(d)


func _ozellik_rengi(d: int) -> Color:
	if d >= 16:
		return Color(0.35, 0.75, 1.0)
	if d >= 12:
		return Color(0.4, 0.85, 0.4)
	if d >= 8:
		return Color(0.95, 0.8, 0.3)
	return Color(0.95, 0.4, 0.3)


func bildir(metin: String, renk: Color = Color.WHITE) -> void:
	_bildirim.text = metin
	_bildirim.add_theme_color_override("font_color", renk)
	var tw := create_tween()
	_bildirim.modulate.a = 1.0
	tw.tween_interval(1.6)
	tw.tween_property(_bildirim, "modulate:a", 0.0, 0.5)


func _sure_metni(sn: int) -> String:
	if sn >= 3600:
		return "%d sa %02d dk" % [sn / 3600, (sn % 3600) / 60]
	return "%02d:%02d" % [sn / 60, sn % 60]


# ================================================================ SEKMELER

func sekme_ac(i: int) -> void:
	_sekme = i
	for j in _sekme_dugmeleri.size():
		var secili := j == i
		var r := Color(0.45, 0.65, 0.25) if secili else Color(0.25, 0.27, 0.24)
		_sekme_dugmeleri[j].add_theme_stylebox_override("normal", _sekme_stili(r.darkened(0.3), r))
		_sekme_dugmeleri[j].add_theme_stylebox_override("hover", _sekme_stili(r.darkened(0.3), r))
		_sekme_dugmeleri[j].add_theme_stylebox_override("pressed", _sekme_stili(r, Color.WHITE))
	for c in _icerik.get_children():
		c.queue_free()
	_kesif_etiket = null
	_kesif_cubuk = null
	_maden_etiket = null
	_maden_dugme = null
	_ciftlik_etiket = null
	_ciftlik_dugme = null
	_hurda_etiket.text = "%d HURDA" % profil.hurda()
	match i:
		0: _oyna_sekmesi()
		1: _ekip_sekmesi()
		2: _envanter_sekmesi()
		3: _kesif_sekmesi()
		4: _lab_sekmesi()
		5: _kasaba_sekmesi()
		6: _ayarlar_sekmesi()
	_etiketleri_duzenle(_icerik)
	_kaydirma.scroll_vertical = 0


## Altı sekme dar ekrana sığsın diye iç boşluğu az.
func _sekme_stili(renk: Color, kenar: Color) -> StyleBoxFlat:
	var s := _stil(renk, kenar, 12)
	s.content_margin_left = 3
	s.content_margin_right = 3
	return s


func _yenile() -> void:
	var konum := _kaydirma.scroll_vertical
	sekme_ac(_sekme)
	await get_tree().process_frame
	_kaydirma.scroll_vertical = konum


# ---------------------------------------------------------------- OYNA

## Menü v2 (Gece 5): iki oyun modu en üstte (ilk ekranda görünür), lider ve ekip bilgisi altta,
## Kasaba kendi sekmesinde (burada tek satırlık özet + TOPLA). Hiçbir bilgi kaldırılmadı, yalnızca sırası değişti.
func _oyna_sekmesi() -> void:
	if not profil.cevrimdisi.is_empty():
		# B6: uygulama dışında Kasaba'nın ürettiği (bir kez gösterilir; birikim TOPLA'ya dek binada durur)
		var sk := _kart(Color(1.0, 0.8, 0.3))
		sk.add_child(_etiket("SEN YOKKEN", 22, Color(1, 0.85, 0.45)))
		var dk := int(float(profil.cevrimdisi["saat"]) * 60.0)
		var sure := ("%d saat %d dk" % [dk / 60, dk % 60]) if dk >= 60 else "%d dk" % dk
		var ek := " (8 saat sınırı doldu)" if float(profil.cevrimdisi["saat"]) > Veri.MADEN_SAAT else ""
		var parca: Array[String] = []
		if int(profil.cevrimdisi.get("miktar", 0)) > 0:
			parca.append("Hurda Madeni +%d hurda" % int(profil.cevrimdisi["miktar"]))
		if int(profil.cevrimdisi.get("altin", 0)) > 0:
			parca.append("Çiftlik +%d altın" % int(profil.cevrimdisi["altin"]))
		var e := _etiket("%s boyunca %s çıkardı%s." % [sure, " ve ".join(parca), ek], 28)
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		sk.add_child(e)
		sk.add_child(_dugme("TOPLA", Color(0.7, 0.55, 0.15), _kasaba_topla, 32))
		profil.cevrimdisi = {}

	_hayatta_kalma_karti()

	var h: Dictionary = profil.aktif_kahraman()
	var rol: Dictionary = Veri.ROLLER[h["rol"]]
	var k := _kart(rol["renk"])
	k.add_child(_etiket("SAHADAKİ HAYATTA KALAN", 22, Color(0.7, 0.7, 0.65)))
	k.add_child(_etiket(String(h["ad"]), 36))
	k.add_child(_etiket("%s · %d yaş · Seviye %d · Moral: %s" % [rol["ad"], int(h["yas"]), int(h["seviye"]),
		Veri.moral_metni(int(h["moral"]))], 24, Color(0.85, 0.85, 0.8)))
	var y := _satir(k)
	y.add_child(_etiket("Yetenek", 24))
	_yildizlar(y, Veri.yildiz(Veri.toplam_ozellik(h)))
	y.add_child(_etiket("Potansiyel", 24))
	_yildizlar(y, Veri.yildiz(int(h["potansiyel"])), -1.0, Color(0.5, 0.8, 1.0))
	k.add_child(_etiket("Pasif: " + String(rol["pasif"]), 22, Color(0.7, 0.9, 0.6)))
	var ak: Dictionary = Veri.AKTIFLER[h["rol"]]
	k.add_child(_etiket("Aktif: %s (%d sn) · %s" % [ak["ad"], int(ak["bekleme"]), ak["aciklama"]], 22, Color(1, 0.75, 0.45)))
	var yorgun := float(h.get("yorgunluk", 0.0))
	if yorgun >= 15.0:
		k.add_child(_etiket("%s: güç -%%%d. Ekip sekmesinden rotasyon yap." % [Veri.yorgunluk_metni(yorgun),
			int(round(yorgun * 0.15))], 22, Color(1, 0.75, 0.4)))
	var s: Dictionary = profil.kahraman_silahi(h)
	if not s.is_empty():
		var n: Dictionary = Veri.NADIRLIK[int(s["nadirlik"])]
		k.add_child(_etiket("Silah: %s %s (Sv %d) · Güç %d" % [n["ad"], Veri.SILAHLAR[s["taban"]]["ad"], int(s["seviye"]),
			Veri.silah_gucu(s)], 26, n["renk"]))

	var sur: Array = profil.nobetci_listesi()
	var nk := _kart(Color(0.85, 0.65, 0.3))
	nk.add_child(_etiket("SURDAKİ EKİP (%d/%d yuva)" % [sur.size(), profil.nobetci_yuva()], 22, Color(0.7, 0.7, 0.65)))
	if sur.is_empty():
		nk.add_child(_etiket("Sur boş. Ekip sekmesinden birini \"Sura koy\": o da kendi silahıyla ateş eder.", 22, Color(1, 0.8, 0.5)))
	for x in sur:
		var mdl: Dictionary = Veri.HEDEF_MODLARI[String(x.get("hedef_modu", "rol"))]
		nk.add_child(_etiket("%s · %s · hedef: %s" % [String(x["ad"]), Veri.ROLLER[x["rol"]]["ad"], mdl["ad"]], 24, Color(1, 0.88, 0.6)))

	_sur_karti()
	_kasaba_ozet_karti()
	_gorev_karti()

	var kk := _kart()
	kk.add_child(_etiket("KEŞİF", 22, Color(0.7, 0.7, 0.65)))
	_kesif_etiket = _etiket("", 26)
	kk.add_child(_kesif_etiket)
	_kesif_guncelle()


## Hayatta Kalma (roguelike koşu) + Tehdit Seviyesi şalterleri (Hades Heat).
func _hayatta_kalma_karti() -> void:
	var b := _kart(Color(0.45, 0.7, 0.3))
	var puan: int = profil.tehdit_puani()
	b.add_child(_etiket("HAYATTA KALMA (roguelike koşu)%s" % ("" if puan == 0 else " · TEHDİT %d" % puan), 22,
		Color(0.7, 0.7, 0.65) if puan == 0 else Color(1, 0.55, 0.4)))
	var devam_dalga := int(profil.veri["devam"].get("dalga", 0))
	if devam_dalga >= 2:
		b.add_child(_dugme("DALGA %s DEVAM ET" % Veri.den_eki(devam_dalga), Color(0.35, 0.65, 0.2), func() -> void: devam_istendi.emit(), 44))
		b.add_child(_etiket("Kartların, taretlerin ve altının kaldığı gibi gelir. Zombiler senin gücünle birlikte güçlenir.",
			20, Color(0.75, 0.85, 0.7)))
		b.add_child(_dugme("BAŞTAN BAŞLA (1. dalga)", Color(0.3, 0.4, 0.3), func() -> void: oyna_istendi.emit(), 30))
	else:
		b.add_child(_dugme("SAVAŞA BAŞLA", Color(0.35, 0.65, 0.2), func() -> void: oyna_istendi.emit(), 44))
	b.add_child(_etiket("En iyi: %d. dalga · Toplam %d zombi" % [int(profil.veri["rekor"]),
		int(profil.veri["istatistik"]["oldurme"])], 24, Color(1, 0.85, 0.4)))
	var hedef: Dictionary = profil.lab_sonraki()
	if not hedef.is_empty():
		var eksik: int = int(hedef["fiyat"]) - profil.hurda()
		b.add_child(_etiket("Laboratuvar: %s %s" % [hedef["ad"], "alınabilir!" if eksik <= 0 else "için %d hurda kaldı" % eksik],
			22, Color(0.7, 0.85, 1.0)))
	if not profil.tehdit_acik():
		b.add_child(_etiket("TEHDİT SEVİYESİ: Hayatta Kalma'da %d. dalgaya ulaşınca açılır (zor ama ödüllü)." % Veri.TEHDIT_ACILIS,
			22, Color(1, 0.6, 0.45)))
		return
	b.add_child(HSeparator.new())
	var rekor := int(profil.veri["tehdit_rekor"])
	var ust := 0
	for t in Veri.TEHDITLER:
		ust += int(t["max"])
	b.add_child(_etiket("TEHDİT %d/%d · hurda +%%%d · rekor %d. %d. dalgaya ulaşıp rekoru geçersen garanti %s silah." % [puan, ust,
		int(round(Veri.TEHDIT_HURDA * puan * 100)), rekor, Veri.TEHDIT_DALGA,
		Veri.NADIRLIK[Veri.tehdit_odul_nadirlik(maxi(puan, rekor + 1))]["ad"]], 22, Color(1, 0.6, 0.45)))
	var izgara := GridContainer.new()
	izgara.columns = 2
	izgara.add_theme_constant_override("h_separation", 10)
	izgara.add_theme_constant_override("v_separation", 8)
	b.add_child(izgara)
	for t in Veri.TEHDITLER:
		var id := String(t["id"])
		var sv: int = profil.tehdit_sv(id)
		var etki := String(t["etki"]) % int(round(float(t["deger"]) * sv * 100)) if sv > 0 else "kapalı"
		var d := _dugme("%s %d/%d\n%s" % [t["ad"], sv, int(t["max"]), etki], Color(0.75, 0.3, 0.2) if sv > 0 else Color(0.35, 0.3, 0.28),
			func() -> void:
				profil.tehdit_degistir(id)
				_yenile(), 22)
		d.custom_minimum_size.y = 76
		izgara.add_child(d)


## Kasaba özeti (OYNA): birikimler ve hazır başarım ödülleri; ayrıntı KASABA sekmesinde.
func _kasaba_ozet_karti() -> void:
	var k := _kart(Color(0.7, 0.55, 0.3))
	k.add_child(_etiket("KASABA", 22, Color(0.7, 0.7, 0.65)))
	var parca: Array[String] = []
	if profil.maden_sv() > 0:
		parca.append("Maden %d hurda" % profil.maden_birikim())
	if profil.ciftlik_sv() > 0:
		parca.append("Çiftlik %d altın" % profil.ciftlik_birikim())
	var hazir: int = profil.hazir_basarim_sayisi()
	if parca.is_empty():
		k.add_child(_etiket("Maden, Çiftlik, Antrenman Sahası, Revir ve Atölye kur: KASABA sekmesi.", 22))
	else:
		k.add_child(_etiket("Biriken: " + " · ".join(parca), 24, Color(1, 0.85, 0.5)))
	var yakin: Dictionary = profil.en_yakin_basarim()
	if hazir > 0:
		k.add_child(_etiket("%d başarım ödülü hazır! KASABA sekmesinde al." % hazir, 24, Color(1, 0.8, 0.3)))
	elif not yakin.is_empty():
		var bb: Dictionary = yakin["b"]
		k.add_child(_etiket("Sıradaki başarım: %s (%s) %d/%d" % [bb["ad"], Veri.BASARIM_KADEME[int(yakin["kademe"])],
			int(yakin["deger"]), int(yakin["esik"])], 22, Color(0.85, 0.8, 0.65)))
	var satir := _satir(k)
	var toplanacak: int = profil.maden_birikim() + profil.ciftlik_birikim()
	satir.add_child(_dugme("TOPLA" if toplanacak > 0 else "Birikim yok", Color(0.7, 0.55, 0.15), _kasaba_topla, 24, toplanacak > 0))
	satir.add_child(_dugme("KASABA'YA GİT", Color(0.5, 0.42, 0.28), func() -> void: sekme_ac(5), 24))


## Maden ve Çiftlik birikimini birlikte toplar.
func _kasaba_topla() -> void:
	var m: int = profil.maden_topla()
	var a: int = profil.ciftlik_topla()
	var parca: Array[String] = []
	if m > 0:
		parca.append("+%d hurda" % m)
	if a > 0:
		parca.append("+%d altın" % a)
	if not parca.is_empty():
		bildir("  ".join(parca), Color(1, 0.85, 0.4))
	_yenile()


## Sur (kale) kalıcı yükseltmesi: can ve nöbetçi yuvası. Çizim seviyeyle büyür.
func _sur_karti() -> void:
	var sv: int = profil.sur_sv()
	var k := _kart(Color(0.6, 0.55, 0.45))
	k.add_child(_etiket("SUR · Seviye %d/%d" % [sv, Veri.SUR_MAX], 22, Color(0.7, 0.7, 0.65)))
	var c := SurCizim.new()
	c.seviye = sv
	c.custom_minimum_size = Vector2(0, 120)
	k.add_child(c)
	var sonraki_yuva := sv + 1
	while Veri.sur_yuva(sonraki_yuva) == Veri.sur_yuva(sv) and sonraki_yuva < Veri.SUR_MAX:
		sonraki_yuva += 1
	var yuva_metin := "" if Veri.sur_yuva(sv) >= Veri.NOBETCI_YUVA_MAX else " · %d. yuva %d. seviyede" % [Veri.sur_yuva(sv) + 1, sonraki_yuva]
	k.add_child(_etiket("Barikat canı +%%%d · %d nöbetçi yuvası%s" % [int(round(Veri.SUR_CAN * (sv - 1) * 100)),
		Veri.sur_yuva(sv), yuva_metin], 22, Color(0.85, 0.85, 0.8)))
	var en_ust := sv >= Veri.SUR_MAX
	k.add_child(_dugme("En üst seviye" if en_ust else "Yükselt: %d hurda" % Veri.sur_fiyat(sv), Color(0.55, 0.45, 0.3), func() -> void:
		var neden: String = profil.sur_yukselt()
		if neden == "":
			bildir("Sur %d. seviye!" % profil.sur_sv(), Color(1, 0.85, 0.45))
		else:
			bildir(neden, Color(1, 0.55, 0.45))
		_yenile(), 28, not en_ust))


## B6 Kasaba ilk binası: Hurda Madeni. Saatte hurda üretir, en çok 8 saat birikir (çevrimdışı kazanç).
func _maden_karti() -> void:
	var sv: int = profil.maden_sv()
	var k := _kart(Color(0.7, 0.55, 0.3))
	k.add_child(_etiket("HURDA MADENİ%s" % ("" if sv == 0 else " · Seviye %d/%d" % [sv, Veri.MADEN_MAX]), 22, Color(0.7, 0.7, 0.65)))
	if sv == 0:
		k.add_child(_etiket("Sen oyunda yokken de hurda çıkarır (en çok 8 saat birikir).", 24))
	_maden_etiket = _etiket("", 24, Color(1, 0.85, 0.5))
	k.add_child(_maden_etiket)
	var satir := _satir(k)
	_maden_dugme = _dugme("TOPLA", Color(0.7, 0.55, 0.15), _maden_topla, 26)
	_maden_dugme.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_maden_dugme.visible = sv > 0
	satir.add_child(_maden_dugme)
	var en_ust := sv >= Veri.MADEN_MAX
	var y := _dugme("En üst seviye" if en_ust else ("Kur: %d hurda" if sv == 0 else "Yükselt: %d hurda") % Veri.maden_fiyat(sv),
		Color(0.5, 0.42, 0.28), func() -> void:
			var neden: String = profil.maden_yukselt()
			if neden == "":
				bildir("Maden %d. seviye!" % profil.maden_sv(), Color(1, 0.85, 0.45))
			else:
				bildir(neden, Color(1, 0.55, 0.45))
			_yenile(), 26, not en_ust)
	y.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	satir.add_child(y)
	_maden_guncelle()


func _maden_guncelle() -> void:
	var sv: int = profil.maden_sv()
	if sv == 0:
		_maden_etiket.text = "Üretim: kurunca saatte %d hurda" % int(Veri.maden_uretim(1, int(profil.veri["rekor"])))
		return
	var ur: float = profil.maden_uretim()
	var b: int = profil.maden_birikim()
	_maden_etiket.text = "Saatte %d hurda · Birikti: %d / %d%s" % [int(round(ur)), b, int(ur * Veri.MADEN_SAAT),
		"  DOLU!" if profil.maden_dolu() else ""]
	if is_instance_valid(_maden_dugme):
		_maden_dugme.disabled = b <= 0
		_maden_dugme.text = "TOPLA +%d" % b


func _maden_topla() -> void:
	var m: int = profil.maden_topla()
	if m > 0:
		bildir("+%d hurda" % m, Color(1, 0.85, 0.4))
		_yenile()


func _gorev_karti() -> void:
	var g: Dictionary = profil.veri["gorevler"]
	var k := _kart(Color(0.85, 0.7, 0.3))
	k.add_child(_etiket("GÜNLÜK GÖREVLER", 22, Color(1, 0.85, 0.45)))
	var liste: Array = g["liste"]
	for i in liste.size():
		var x: Dictionary = liste[i]
		var bitti := int(x["ilerleme"]) >= int(x["hedef"])
		var satir := _satir(k)
		var e := _etiket("%s  %d/%d" % [String(x["ad"]) % int(x["hedef"]), int(x["ilerleme"]), int(x["hedef"])], 24,
			Color(0.6, 0.6, 0.55) if bool(x["alindi"]) else Color.WHITE)
		e.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		satir.add_child(e)
		var idx := i
		var d := _dugme("Alındı" if bool(x["alindi"]) else "+%d" % int(x["odul"]), Color(0.75, 0.6, 0.2), func() -> void:
			var bonus: Dictionary = profil.gorev_odulu_al(idx)
			if bonus.is_empty():
				bildir("+%d hurda" % int(x["odul"]), Color(1, 0.85, 0.4))
			else:
				var n: Dictionary = Veri.NADIRLIK[int(bonus["nadirlik"])]
				bildir("Üç görev bitti! %s %s" % [n["ad"], Veri.SILAHLAR[bonus["taban"]]["ad"]], n["renk"])
			_yenile(), 22, bitti and not bool(x["alindi"]))
		d.size_flags_horizontal = Control.SIZE_SHRINK_END
		d.custom_minimum_size.x = 130
		satir.add_child(d)
	k.add_child(_etiket("Üçünü de al: bonus silah. Görevler gece yarısı yenilenir.", 22, Color(0.75, 0.75, 0.7)))


func _kesif_guncelle() -> void:
	var kalan: int = profil.kesif_kalan_sure()
	var rapor_sayisi: int = profil.veri["kesif"]["raporlar"].size()
	if kalan > 0:
		var b: Dictionary = Veri.BOLGELER[int(profil.kesif_aktif()["bolge"])]
		_kesif_etiket.text = "Gözlemci %s bölgesinde. Dönüşüne %s" % [b["ad"], _sure_metni(kalan)]
		if _kesif_cubuk:
			_kesif_cubuk.value = 1.0 - float(kalan) / float(b["sure"])
	elif rapor_sayisi > 0:
		_kesif_etiket.text = "%d keşif raporu seni bekliyor." % rapor_sayisi
	else:
		_kesif_etiket.text = "Gözlemci boşta. Yeni hayatta kalanlar bulmak için Keşif'e git."


# ---------------------------------------------------------------- KASABA (B6, Gece 5)

## Grow Castle kasabası + FM tesisleri: çevrimdışı üretim (Maden: hurda, Çiftlik: altın) ve ekip tesisleri.
## En altta başarımlar (Onur Panosu).
func _kasaba_sekmesi() -> void:
	_icerik.add_child(_etiket("Kasaba sen yokken de çalışır. Maden hurda, Çiftlik altın üretir (en çok 8 saat birikir, dönünce TOPLA). Tesisler ekibini kalıcı olarak güçlendirir.", 22, Color(0.75, 0.75, 0.7)))
	_maden_karti()
	_ciftlik_karti()
	for id in Veri.TESISLER:
		_tesis_karti(String(id))
	_basarim_listesi()


func _ciftlik_karti() -> void:
	var sv: int = profil.ciftlik_sv()
	var k := _kart(Color(0.85, 0.75, 0.3))
	k.add_child(_etiket("ÇİFTLİK%s" % ("" if sv == 0 else " · Seviye %d/%d" % [sv, Veri.CIFTLIK_MAX]), 22, Color(0.7, 0.7, 0.65)))
	if sv == 0:
		k.add_child(_etiket("Altın üretir: Güç seviyelerinin parası. Rekor dalgan yükseldikçe verim artar.", 24))
	_ciftlik_etiket = _etiket("", 24, Color(1, 0.85, 0.4))
	k.add_child(_ciftlik_etiket)
	var satir := _satir(k)
	_ciftlik_dugme = _dugme("TOPLA", Color(0.7, 0.6, 0.15), func() -> void:
		var a: int = profil.ciftlik_topla()
		if a > 0:
			bildir("+%d altın" % a, Color(1, 0.85, 0.4))
		_yenile(), 26)
	_ciftlik_dugme.visible = sv > 0
	satir.add_child(_ciftlik_dugme)
	var en_ust := sv >= Veri.CIFTLIK_MAX
	satir.add_child(_dugme("En üst seviye" if en_ust else ("Kur: %d hurda" if sv == 0 else "Yükselt: %d hurda") % Veri.ciftlik_fiyat(sv),
		Color(0.55, 0.48, 0.2), func() -> void:
			var neden: String = profil.ciftlik_yukselt()
			bildir("Çiftlik %d. seviye!" % profil.ciftlik_sv() if neden == "" else neden,
				Color(1, 0.85, 0.45) if neden == "" else Color(1, 0.55, 0.45))
			_yenile(), 26, not en_ust))
	_ciftlik_guncelle()


func _ciftlik_guncelle() -> void:
	var sv: int = profil.ciftlik_sv()
	if sv == 0:
		_ciftlik_etiket.text = "Üretim: kurunca saatte %d altın" % int(Veri.ciftlik_uretim(1, int(profil.veri["rekor"])))
		return
	var ur: float = profil.ciftlik_uretim()
	var b: int = profil.ciftlik_birikim()
	_ciftlik_etiket.text = "Saatte %d altın · Birikti: %d / %d · Kasa: %d altın" % [int(round(ur)), b, int(ur * Veri.MADEN_SAAT), profil.altin()]
	if is_instance_valid(_ciftlik_dugme):
		_ciftlik_dugme.disabled = b <= 0
		_ciftlik_dugme.text = "TOPLA +%d" % b


func _tesis_karti(id: String) -> void:
	var t: Dictionary = Veri.TESISLER[id]
	var sv: int = profil.tesis_sv(id)
	var k := _kart(t["renk"])
	k.add_child(_etiket("%s · Seviye %d/%d" % [t["ad"], sv, Veri.TESIS_MAX], 22, Color(0.7, 0.7, 0.65)))
	var yuzde := int(round(float(t["deger"]) * sv * 100))
	var sonraki := int(round(float(t["deger"]) * (sv + 1) * 100))
	var metin: String
	if id == "revir":
		metin = String(t["aciklama"]) % [yuzde, int(round(Veri.REVIR_SAKATLIK * sv * 100))]
	else:
		metin = String(t["aciklama"]) % yuzde
	k.add_child(_etiket(metin, 24, (t["renk"] as Color).lightened(0.35)))
	var en_ust := sv >= Veri.TESIS_MAX
	var fiyat := Veri.tesis_fiyat(id, sv)
	k.add_child(_dugme("En üst seviye" if en_ust else "%s: %d hurda (→ %%%d)" % ["Kur" if sv == 0 else "Yükselt", fiyat, sonraki],
		(t["renk"] as Color).darkened(0.2), func() -> void:
			var neden: String = profil.tesis_yukselt(id)
			bildir("%s %d. seviye!" % [t["ad"], profil.tesis_sv(id)] if neden == "" else neden,
				Color(0.6, 1, 0.5) if neden == "" else Color(1, 0.55, 0.45))
			_yenile(), 24, not en_ust and profil.hurda() >= fiyat))


## Başarımlar (Onur Panosu): 12 başarım × Bronz/Gümüş/Altın. Hazır olanlar üstte; ödül elle alınır.
func _basarim_listesi() -> void:
	var k := _kart(Color(1.0, 0.8, 0.3))
	var bitti := 0
	for b in Veri.BASARIMLAR:
		bitti += profil.basarim_kademe(String(b["id"]))
	k.add_child(_etiket("ONUR PANOSU · BAŞARIMLAR %d/%d" % [bitti, Veri.BASARIMLAR.size() * 3], 24, Color(1, 0.85, 0.45)))
	var sirali: Array = Veri.BASARIMLAR.duplicate()
	sirali.sort_custom(func(a, c) -> bool: return int(profil.basarim_hazir(a)) > int(profil.basarim_hazir(c)))
	for b in sirali:
		var id := String(b["id"])
		var kd: int = profil.basarim_kademe(id)
		var deger: int = profil.basarim_degeri(id)
		var satir := _satir(k)
		var v := VBoxContainer.new()
		v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v.add_theme_constant_override("separation", 2)
		satir.add_child(v)
		var rozet := ""
		for i in 3:
			rozet += "●" if i < kd else "○"
		var renk: Color = Veri.BASARIM_RENK[kd - 1] if kd > 0 else Color.WHITE
		v.add_child(_etiket("%s  %s" % [b["ad"], rozet], 25, renk))
		if kd >= 3:
			v.add_child(_etiket("Tamamlandı (%s)" % (String(b["metin"]) % int(b["esik"][2])), 21, Color(0.6, 0.6, 0.55)))
			continue
		var esik := int(b["esik"][kd])
		v.add_child(_etiket("%s: %s · %d/%d" % [Veri.BASARIM_KADEME[kd], String(b["metin"]) % esik, mini(deger, esik), esik], 21,
			Color(0.75, 0.85, 0.7)))
		var hazir: bool = profil.basarim_hazir(b)
		var d := _dugme("+%d" % Veri.BASARIM_ODUL[kd], Veri.BASARIM_RENK[kd], func() -> void:
			var o: int = profil.basarim_al(id)
			if o > 0:
				bildir("%s %s: +%d hurda" % [b["ad"], Veri.BASARIM_KADEME[kd], o], Veri.BASARIM_RENK[kd])
			_yenile(), 22, hazir)
		d.size_flags_horizontal = Control.SIZE_SHRINK_END
		d.custom_minimum_size.x = 120
		satir.add_child(d)


# ---------------------------------------------------------------- EKİP

func _ekip_sekmesi() -> void:
	var ekip: Array = profil.veri["ekip"]
	_icerik.add_child(_etiket("Ekip (%d/%d) — Football Manager gibi: her hayatta kalanın özellikleri, potansiyeli ve moral durumu var. Lider maç deneyimiyle hızlı, surdakiler yarı hızla, diğerleri antrenmanla yavaş gelişir. Surda %d yuva var: oraya koyduğun kişi kendi silahıyla ateş eder. Altın: %d (Güç seviyesine harcanır; koşulardan ve Çiftlikten gelir)." % [ekip.size(), Veri.EKIP_SINIRI, profil.nobetci_yuva(), profil.altin()], 22, Color(0.75, 0.75, 0.7)))
	for h in ekip:
		_hayatta_kalan_karti(h)


func _hayatta_kalan_karti(h: Dictionary) -> void:
	var rol: Dictionary = Veri.ROLLER[h["rol"]]
	var aktif := String(h["uid"]) == String(profil.veri["aktif"])
	var surda: bool = profil.nobetci_mi(String(h["uid"])) and not aktif
	var k := _kart(Color(0.5, 0.9, 0.4) if aktif else (Color(0.95, 0.75, 0.35) if surda else rol["renk"]))
	var ust := _satir(k)
	var ad := _etiket(String(h["ad"]) + ("  (LİDER)" if aktif else ("  (SURDA)" if surda else "")), 32,
		Color(0.6, 1, 0.5) if aktif else (Color(1, 0.85, 0.45) if surda else Color.WHITE))
	ad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ust.add_child(ad)
	k.add_child(_etiket("%s · %d yaş · Sv %d (%d/%d XP) · %d koşu · en iyi %d. dalga" % [rol["ad"], int(h["yas"]),
		int(h["seviye"]), int(h["xp"]), int(h["seviye"]) * 100, int(h.get("kosu", 0)), int(h.get("en_iyi_dalga", 0))], 22, Color(0.8, 0.8, 0.75)))
	var y := _satir(k)
	y.add_child(_etiket("Yetenek", 22))
	_yildizlar(y, Veri.yildiz(Veri.toplam_ozellik(h)))
	y.add_child(_etiket("Pot.", 22))
	_yildizlar(y, Veri.yildiz(int(h["potansiyel"])), -1.0, Color(0.5, 0.8, 1.0))
	k.add_child(_etiket("Moral: %s · Pasif: %s" % [Veri.moral_metni(int(h["moral"])), rol["pasif"]], 22, Color(0.7, 0.9, 0.6)))
	var ks := Veri.kisilik(h)
	k.add_child(_etiket("Kişilik: %s (%s)" % [ks["ad"], ks["etki"]], 22, Color(0.8, 0.75, 1.0)))
	var fo: float = profil.form(h)
	if fo > 0.0:
		var pl: Array = h.get("puanlar", [])
		var son := PackedStringArray()
		for x in pl:
			son.append("%.1f" % float(x))
		k.add_child(_etiket("Form: %.1f  (son puanlar: %s)" % [fo, " ".join(son)], 22,
			Color(0.6, 1, 0.5) if fo >= 7.0 else (Color(1, 0.6, 0.45) if fo < 5.8 else Color(0.9, 0.9, 0.8))))
	var guc := int(h.get("guc", 0))
	var gs := _satir(k)
	var ge := _etiket("Güç Sv %d (hasar +%%%d)" % [guc, int(round(guc * Veri.GUC_HASAR * 100))], 24, Color(1, 0.8, 0.4))
	ge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gs.add_child(ge)
	var guc_uid := String(h["uid"])
	var guc_ust := guc >= Veri.GUC_MAX
	var gd := _dugme("En üst" if guc_ust else "+1: %d altın" % Veri.guc_fiyat(guc), Color(0.7, 0.55, 0.15), func() -> void:
		var neden: String = profil.guc_yukselt(guc_uid)
		if neden == "":
			bildir("Güç seviyesi arttı!", Color(1, 0.85, 0.4))
		else:
			bildir(neden, Color(1, 0.55, 0.45))
		_yenile(), 22, not guc_ust and profil.altin() >= Veri.guc_fiyat(guc))
	gd.custom_minimum_size.x = 200
	gs.add_child(gd)
	if surda:
		var md: Dictionary = Veri.HEDEF_MODLARI[String(h.get("hedef_modu", "rol"))]
		k.add_child(_etiket("Surda nöbette · Hedef: %s (%s)" % [md["ad"], md["aciklama"]], 22, Color(1, 0.85, 0.5)))
	var yorgun := float(h.get("yorgunluk", 0.0))
	var sakat := int(h.get("sakat", 0))
	var mentor: Dictionary = profil.kahraman_bul(String(h.get("mentor", "")))
	if not mentor.is_empty():
		k.add_child(_etiket("Mentor: %s (gelişim +%%20)" % mentor["ad"], 22, Color(0.6, 0.9, 1.0)))
	var durum := "Durum: %s" % Veri.yorgunluk_metni(yorgun)
	if yorgun >= 1.0:
		durum += " (güç -%%%d)" % int(round(yorgun * 0.15))
	k.add_child(_etiket(durum, 22, Color(1, 0.75, 0.4) if yorgun >= 40.0 else Color(0.75, 0.85, 0.75)))
	if sakat > 0:
		k.add_child(_etiket("SAKAT: %d koşu daha oynayamaz" % sakat, 24, Color(1, 0.45, 0.4)))

	var acik := _acik_kart == String(h["uid"])
	if acik:
		for o in Veri.OZELLIKLER:
			_ozellik_cubugu(k, String(o["ad"]) + (" ●" if String(h.get("odak", "")) == String(o["id"]) else ""), int(h["oz"][o["id"]]))
		var odak_ad := ""
		for o in Veri.OZELLIKLER:
			if o["id"] == h.get("odak", ""):
				odak_ad = o["ad"]
		k.add_child(_etiket("● Antrenman odağı: %s. Odaktaki özellik gelişim puanının yarısını alır." % odak_ad, 22, Color(0.75, 0.75, 0.7)))
	var d := _satir(k)
	var uid := String(h["uid"])
	d.add_child(_dugme("Gizle" if acik else "Detay", Color(0.4, 0.45, 0.5), func() -> void:
		_acik_kart = "" if _acik_kart == uid else uid
		_yenile(), 24))
	if not aktif:
		d.add_child(_dugme("Lider yap", Color(0.35, 0.65, 0.25), func() -> void:
			profil.aktif_yap(uid)
			bildir("%s artık lider!" % h["ad"], Color(0.5, 1, 0.5))
			_yenile(), 24, sakat <= 0))
		d.add_child(_dugme("Surdan indir" if surda else "Sura koy", Color(0.75, 0.55, 0.2), func() -> void:
			var neden: String = profil.nobetci_degistir(uid)
			if neden != "":
				bildir(neden, Color(1, 0.6, 0.45))
			else:
				bildir("%s %s" % [String(h["ad"]).get_slice(" ", 0), "surdan indi." if surda else "sura çıktı!"], Color(1, 0.85, 0.45))
			_yenile(), 24, sakat <= 0 or surda))
		if surda:
			d = _satir(k)
			d.add_child(_dugme("Hedef modu: %s" % Veri.HEDEF_MODLARI[String(h.get("hedef_modu", "rol"))]["ad"], Color(0.55, 0.4, 0.2), func() -> void:
				profil.hedef_modu_degistir(uid)
				_yenile(), 24))
	if acik:
		d.add_child(_dugme("Odak değiştir", Color(0.3, 0.55, 0.8), func() -> void:
			var ids: Array = []
			for o in Veri.OZELLIKLER:
				ids.append(o["id"])
			var sira := (ids.find(h.get("odak", ids[0])) + 1) % ids.size()
			profil.odak_degistir(uid, ids[sira])
			_yenile(), 24))
		var adaylar: Array = profil.mentor_adaylari(h)
		if int(h["yas"]) < 25 and not adaylar.is_empty():
			d = _satir(k)
			d.add_child(_dugme("Mentor değiştir", Color(0.3, 0.6, 0.65), func() -> void:
				# sırayla: yok → aday1 → aday2 → yok
				var uidler: Array = [""]
				for x in adaylar:
					uidler.append(x["uid"])
				var sira := (uidler.find(String(h.get("mentor", ""))) + 1) % uidler.size()
				profil.mentor_ata(uid, uidler[sira])
				_yenile(), 24))
		if not aktif:
			d.add_child(_dugme("Gönder", Color(0.7, 0.25, 0.2), func() -> void:
				if profil.kov(uid):
					bildir("%s ekipten ayrıldı." % h["ad"])
				_yenile(), 24))


# ---------------------------------------------------------------- ENVANTER

func _envanter_sekmesi() -> void:
	var env: Array = profil.veri["envanter"]
	_icerik.add_child(_etiket("Envanter (%d/%d). Silahlar 5 nadirlikte: Sıradan, Nadir, Ender, Destansı, Efsanevi. Nadirlik arttıkça güç ve ek özellik sayısı artar. Aynı nadirlikte 3 kullanılmayan silah, 1 üst nadirlikte silaha dönüşür." % [env.size(), Veri.ENVANTER_SINIRI], 22, Color(0.75, 0.75, 0.7)))

	var bk := _kart(Color(0.6, 0.45, 0.8))
	bk.add_child(_etiket("BİRLEŞTİR", 24, Color(0.85, 0.75, 1.0)))
	for n in Veri.NADIRLIK.size() - 1:
		var adet: int = profil.birlestirilebilir(n).size()
		var nad: Dictionary = Veri.NADIRLIK[n]
		var ust: Dictionary = Veri.NADIRLIK[n + 1]
		var nn: int = n
		bk.add_child(_dugme("3 %s → 1 %s   (%d/3)" % [nad["ad"], ust["ad"], mini(adet, 3)], ust["renk"], func() -> void:
			var yeni: Dictionary = profil.birlestir(nn)
			if not yeni.is_empty():
				bildir("Yeni: %s %s!" % [Veri.NADIRLIK[int(yeni["nadirlik"])]["ad"], Veri.SILAHLAR[yeni["taban"]]["ad"]], Veri.NADIRLIK[int(yeni["nadirlik"])]["renk"])
			_yenile(), 24, adet >= 3))

	var sirali := env.duplicate()
	sirali.sort_custom(func(a, b) -> bool: return Veri.silah_gucu(a) > Veri.silah_gucu(b))
	for s in sirali:
		_silah_karti(s)


func _silah_karti(s: Dictionary) -> void:
	var n: Dictionary = Veri.NADIRLIK[int(s["nadirlik"])]
	var t: Dictionary = Veri.SILAHLAR[s["taban"]]
	var st := Veri.silah_istatistik(s)
	var aktif_h: Dictionary = profil.aktif_kahraman()
	var kullanan: Dictionary = profil.silahi_kullanan(String(s["uid"]))
	var kusanili := String(aktif_h.get("silah", "")) == String(s["uid"])
	var k := _kart(n["renk"])
	var ust := _satir(k)
	var ad := _etiket("%s %s" % [n["ad"], t["ad"]], 30, n["renk"])
	ad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ust.add_child(ad)
	ust.add_child(_etiket("Güç %d" % Veri.silah_gucu(s), 28, Color(1, 0.85, 0.4)))
	var max_sv := int(n["max_sv"])
	k.add_child(_etiket("Seviye %d/%d · %s" % [int(s["seviye"]), max_sv, t["aciklama"]], 22, Color(0.8, 0.8, 0.75)))
	var mermi := "%d×" % int(st["namlu"]) if int(st["namlu"]) > 1 else ""
	k.add_child(_etiket("Hasar %s%.1f · %.1f atış/sn · Menzil %d · Kritik %%%d%s" % [mermi, st["hasar"], st["ates"],
		int(st["menzil"]), int(round(float(st["kritik"]) * 100)), (" · Delme %d" % int(st["delme"])) if int(st["delme"]) > 0 else ""], 22))
	for e in s["ekler"]:
		k.add_child(_etiket(Veri.ek_metni(e), 22, Color(0.55, 0.85, 1.0)))
	if kusanili:
		k.add_child(_etiket("Kuşanıldı: %s" % aktif_h["ad"], 22, Color(0.5, 1, 0.5)))
	elif not kullanan.is_empty():
		k.add_child(_etiket("%s kullanıyor" % kullanan["ad"], 22, Color(0.9, 0.8, 0.5)))
	var d := _satir(k)
	var uid := String(s["uid"])
	if not kusanili:
		d.add_child(_dugme("Kuşan", Color(0.35, 0.65, 0.25), func() -> void:
			profil.kusan(uid)
			bildir("Kuşanıldı", Color(0.5, 1, 0.5))
			_yenile(), 24))
	var fiyat: int = profil.gelistirme_fiyati(s)
	var gelisebilir := int(s["seviye"]) < max_sv
	d.add_child(_dugme(("Geliştir %d" % fiyat) if gelisebilir else "En üst seviye", Color(0.8, 0.6, 0.2), func() -> void:
		if profil.silah_gelistir(uid):
			bildir("Seviye atladı!", Color(1, 0.85, 0.4))
		else:
			bildir("Yeterli hurda yok", Color(1, 0.5, 0.4))
		_yenile(), 24, gelisebilir))
	# Nöbetçiye ver: surdakilerin her biri için bir düğme (silah başkasındaysa takas olur)
	var sur: Array = profil.nobetci_listesi()
	if not sur.is_empty():
		var sd := _satir(k)
		for x in sur:
			if String(x.get("silah", "")) == uid:
				continue
			var xuid := String(x["uid"])
			var xad := String(x["ad"]).get_slice(" ", 0)
			sd.add_child(_dugme("Sura: %s" % xad, Color(0.6, 0.45, 0.2), func() -> void:
				profil.silah_ver(xuid, uid)
				bildir("%s yeni silahını aldı" % xad, Color(1, 0.85, 0.45))
				_yenile(), 22))
	if kullanan.is_empty():
		d.add_child(_dugme("Sat +%d" % profil.silah_satis_degeri(s), Color(0.6, 0.3, 0.25), func() -> void:
			profil.silah_sat(uid)
			_yenile(), 24))


# ---------------------------------------------------------------- KEŞİF

func _kesif_sekmesi() -> void:
	_icerik.add_child(_etiket("Gözlemcini bir bölgeye gönder. Döndüğünde bulduğu hayatta kalanları rapor eder. Football Manager'daki gibi gözlemci her şeyi bilemez: özellikler aralık olarak görünür. Emin olmak için 15 hurdaya ayrıntılı incele. Kısa listedeki adayların raporu silinmez.", 22, Color(0.75, 0.75, 0.7)))
	var aktif: Dictionary = profil.kesif_aktif()
	var k := _kart(Color(0.35, 0.6, 0.8))
	if not aktif.is_empty():
		k.add_child(_etiket("GÖZLEMCİ YOLDA", 24, Color(0.6, 0.85, 1.0)))
		_kesif_etiket = _etiket("", 26)
		k.add_child(_kesif_etiket)
		_kesif_cubuk = ProgressBar.new()
		_kesif_cubuk.max_value = 1.0
		_kesif_cubuk.show_percentage = false
		_kesif_cubuk.custom_minimum_size.y = 20
		k.add_child(_kesif_cubuk)
		_kesif_guncelle()
	else:
		k.add_child(_etiket("BÖLGE SEÇ", 24, Color(0.6, 0.85, 1.0)))
		for i in Veri.BOLGELER.size():
			var b: Dictionary = Veri.BOLGELER[i]
			k.add_child(_etiket("%s — %s" % [b["ad"], b["aciklama"]], 24))
			var idx := i
			k.add_child(_dugme("Gönder: %d hurda · %s" % [int(b["fiyat"]), _sure_metni(int(b["sure"]))], Color(0.3, 0.55, 0.8), func() -> void:
				if profil.kesif_baslat(idx):
					bildir("Gözlemci yola çıktı", Color(0.6, 0.85, 1.0))
				else:
					bildir("Yeterli hurda yok", Color(1, 0.5, 0.4))
				_yenile(), 24, profil.hurda() >= int(b["fiyat"])))

	for r in profil.veri["kesif"]["raporlar"]:
		_rapor_karti(r)


func _rapor_karti(r: Dictionary) -> void:
	var k := _kart(Color(0.8, 0.7, 0.35))
	var ust := _satir(k)
	var b := _etiket("RAPOR: %s" % r["bolge"], 26, Color(1, 0.85, 0.45))
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ust.add_child(b)
	var ruid := String(r["uid"])
	ust.add_child(_dugme("Sil", Color(0.5, 0.3, 0.25), func() -> void:
		profil.rapor_sil(ruid)
		_yenile(), 22))
	var adaylar: Array = r["adaylar"]
	for i in adaylar.size():
		var aday: Dictionary = adaylar[i]
		var h: Dictionary = aday["h"]
		var rol: Dictionary = Veri.ROLLER[h["rol"]]
		var kesin := float(aday["bilgi"]) >= 0.99
		k.add_child(HSeparator.new())
		k.add_child(_etiket("%s · %s · %d yaş" % [h["ad"], rol["ad"], int(h["yas"])], 28, rol["renk"].lightened(0.3)))
		# Kişiliği gözlemci ancak yakından tanıyınca bilir: İncele'nin ek değeri
		var ks := Veri.kisilik(h)
		k.add_child(_etiket("Kişilik: %s (%s)" % [ks["ad"], ks["etki"]] if float(aday["bilgi"]) >= 0.6 else "Kişilik: ? (incele)", 22, Color(0.8, 0.75, 1.0)))
		var toplam_alt := 0
		var toplam_ust := 0
		for o in Veri.OZELLIKLER:
			var gercek := int(h["oz"][o["id"]])
			var ar: Vector2i = profil.aday_aralik(aday, gercek, String(o["id"]))
			toplam_alt += ar.x
			toplam_ust += ar.y
			_ozellik_cubugu(k, String(o["ad"]), ar.x, ar.y)
		var on := _satir(k)
		on.add_child(_etiket("Gözlemci önerisi", 22, Color(0.85, 0.85, 0.75)))
		_yildizlar(on, Veri.oneri(h, profil.ekip_en_iyi(), float(aday["bilgi"])), -1.0, Color(0.6, 1.0, 0.5))
		var y := _satir(k)
		y.add_child(_etiket("Yetenek", 22))
		var pot := int(h["potansiyel"])
		if kesin:
			_yildizlar(y, Veri.yildiz(toplam_alt))
			y.add_child(_etiket("Pot.", 22))
			_yildizlar(y, Veri.yildiz(pot), -1.0, Color(0.5, 0.8, 1.0))
		else:
			_yildizlar(y, Veri.yildiz(toplam_alt), Veri.yildiz(toplam_ust))
			y.add_child(_etiket("Pot.", 22))
			var pot_ar: Vector2i = profil.aday_aralik(aday, clampi(int(round(pot / 6.0)), 1, 20), "pot")
			_yildizlar(y, Veri.yildiz(pot_ar.x * 6), Veri.yildiz(pot_ar.y * 6), Color(0.5, 0.8, 1.0))
		var d := _satir(k)
		var idx := i
		var kisa: bool = bool(aday.get("kisa", false))
		d.add_child(_dugme("Listede" if kisa else "Kısa liste", Color(0.8, 0.65, 0.25) if kisa else Color(0.4, 0.42, 0.38), func() -> void:
			profil.kisa_liste_degistir(ruid, idx)
			_yenile(), 22))
		if not kesin:
			d.add_child(_dugme("İncele 15", Color(0.3, 0.55, 0.8), func() -> void:
				if not profil.aday_incele(ruid, idx):
					bildir("Yeterli hurda yok", Color(1, 0.5, 0.4))
				_yenile(), 24, profil.hurda() >= 15))
		d.add_child(_dugme("İşe al %d" % int(aday["fiyat"]), Color(0.35, 0.65, 0.25), func() -> void:
			var hata: String = profil.aday_al(ruid, idx)
			if hata == "":
				bildir("Ekibe katıldı!", Color(0.5, 1, 0.5))
			else:
				bildir(hata, Color(1, 0.5, 0.4))
			_yenile(), 24, profil.hurda() >= int(aday["fiyat"])))
	if r["silah"] != null:
		var s: Dictionary = r["silah"]
		var n: Dictionary = Veri.NADIRLIK[int(s["nadirlik"])]
		k.add_child(HSeparator.new())
		k.add_child(_etiket("Bulunan silah: %s %s (Güç %d)" % [n["ad"], Veri.SILAHLAR[s["taban"]]["ad"], Veri.silah_gucu(s)], 26, n["renk"]))
		k.add_child(_dugme("Envantere al", Color(0.35, 0.65, 0.25), func() -> void:
			var hata: String = profil.rapor_silah_al(ruid)
			bildir("Envantere eklendi" if hata == "" else hata, Color(0.5, 1, 0.5) if hata == "" else Color(1, 0.5, 0.4))
			_yenile(), 24))


# ---------------------------------------------------------------- LABORATUVAR

func _lab_sekmesi() -> void:
	_icerik.add_child(_etiket("Hurdanı kalıcı gelişime çevir. Her seviye küçük ama hiç kaybolmaz. Dalın sonundaki büyük buluş, o dalda %d seviye toplayınca açılır ve oyunun kuralını değiştirir." % Veri.LAB_FINAL_ESIK, 22, Color(0.75, 0.75, 0.7)))
	for i in Veri.LAB.size():
		var dal: Dictionary = Veri.LAB[i]
		var k := _kart(dal["renk"])
		k.add_child(_etiket(String(dal["ad"]), 28, dal["renk"]))
		var dugumler: Array = dal["dugumler"]
		for j in dugumler.size():
			_lab_dugumu(k, dal, dugumler[j], i, j)


func _lab_dugumu(k: VBoxContainer, dal: Dictionary, d: Dictionary, dal_i: int, dug_i: int) -> void:
	var sv: int = profil.lab_sv(d["id"])
	var en: int = int(d["max"])
	var final: bool = bool(d.get("final", false))
	var acik: bool = profil.lab_acik(dal, d)
	var satir := _satir(k)
	var v := VBoxContainer.new()
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	satir.add_child(v)
	var noktalar := "" if final else "   " + "●".repeat(sv) + "○".repeat(en - sv)
	v.add_child(_etiket(String(d["ad"]) + noktalar, 25, Color(1, 0.85, 0.45) if final else Color.WHITE))
	var metin: String = Veri.lab_metni(d, sv)
	if not acik:
		metin += " (%d/%d seviye)" % [profil.lab_dal_toplam(dal), Veri.LAB_FINAL_ESIK]
	v.add_child(_etiket(metin, 21, Color(0.75, 0.85, 0.7)))
	var dolu := sv >= en
	var fiyat := Veri.lab_fiyat(d, sv)
	var dg := _dugme("Tamam" if dolu else str(fiyat), dal["renk"], func() -> void:
		var hata: String = profil.lab_al(dal_i, dug_i)
		if hata == "":
			bildir("%s geliştirildi" % d["ad"], Color(0.5, 1, 0.5))
		else:
			bildir(hata, Color(1, 0.5, 0.4))
		_yenile(), 24, not dolu and acik and profil.hurda() >= fiyat)
	dg.size_flags_horizontal = Control.SIZE_SHRINK_END
	dg.custom_minimum_size.x = 120
	satir.add_child(dg)


# ---------------------------------------------------------------- AYARLAR

func _ayarlar_sekmesi() -> void:
	var k := _kart()
	k.add_child(_etiket("GRAFİK KALİTESİ", 24, Color(0.6, 0.85, 1.0)))
	k.add_child(_etiket("Telefonun ısınıyor ya da kasıyorsa düşür. Düşük: kan izi ve parçacık yok, 30 FPS önerilir.", 22, Color(0.75, 0.75, 0.7)))
	var g := _satir(k)
	var adlar := ["Düşük", "Orta", "Yüksek"]
	for i in 3:
		var secili: bool = int(profil.ayar("grafik")) == i
		var idx := i
		g.add_child(_dugme(adlar[i], Color(0.45, 0.7, 0.3) if secili else Color(0.3, 0.32, 0.3), func() -> void:
			profil.ayar_degistir("grafik", idx)
			ayarlar_degisti.emit()
			_yenile(), 24))
	k.add_child(_etiket("KARE HIZI (FPS)", 24, Color(0.6, 0.85, 1.0)))
	var f := _satir(k)
	for fps in [30, 60]:
		var secili: bool = int(profil.ayar("fps")) == fps
		var deger: int = fps
		f.add_child(_dugme("%d FPS" % fps, Color(0.45, 0.7, 0.3) if secili else Color(0.3, 0.32, 0.3), func() -> void:
			profil.ayar_degistir("fps", deger)
			ayarlar_degisti.emit()
			_yenile(), 24))

	var a := _kart()
	for ayar in [["ses", "Ses"], ["titresim", "Titreşim"], ["fps_goster", "FPS göstergesi"]]:
		var anahtar: String = ayar[0]
		var acik: bool = bool(profil.ayar(anahtar))
		a.add_child(_dugme("%s: %s" % [ayar[1], "AÇIK" if acik else "KAPALI"], Color(0.45, 0.7, 0.3) if acik else Color(0.45, 0.3, 0.3), func() -> void:
			profil.ayar_degistir(anahtar, not bool(profil.ayar(anahtar)))
			ayarlar_degisti.emit()
			_yenile(), 26))

	var oto := _kart()
	var oto_acik: bool = bool(profil.ayar("oto_kalite"))
	oto.add_child(_dugme("Otomatik kalite: %s" % ("AÇIK" if oto_acik else "KAPALI"), Color(0.45, 0.7, 0.3) if oto_acik else Color(0.45, 0.3, 0.3), func() -> void:
		profil.ayar_degistir("oto_kalite", not bool(profil.ayar("oto_kalite")))
		ayarlar_degisti.emit()
		_yenile(), 26))
	oto.add_child(_etiket("Koşuda FPS düşerse grafiği kendiliğinden bir kademe azaltır.", 22, Color(0.75, 0.75, 0.7)))

	var bilgi := _kart()
	bilgi.add_child(_etiket("Zombi Savunma · Her gece otomatik olarak geliştirilir. İlerlemen telefonunda saklanır.", 22, Color(0.75, 0.75, 0.7)))


## Menüdeki büyüyen sur çizimi: seviyeyle kat ve kule sayısı artar, malzeme ahşap → taş → çelik olur.
## Bir kez çizilir (Control yalnızca menü yenilenince yeniden kurulur).
class SurCizim extends Control:
	var seviye := 1

	func _draw() -> void:
		var w := size.x
		var h := size.y
		var kat := 1 + mini(int(seviye / 6.0), 6)  # 1–7 kat
		var malzeme := Color("8a6a45") if seviye < 17 else (Color("8d8f8a") if seviye < 33 else Color("6f8296"))
		var kat_boy := (h - 30.0) / 7.0
		var taban := h - 6.0
		for i in kat:
			var y := taban - (i + 1) * kat_boy
			var r := malzeme.darkened(0.12 * float(i % 2))
			draw_rect(Rect2(20, y, w - 40, kat_boy - 2), r)
			for j in int((w - 40) / 46.0):  # tuğla/tahta çizgileri
				draw_rect(Rect2(20 + j * 46 + (23 if i % 2 == 1 else 0), y, 2, kat_boy - 2), r.darkened(0.3))
		# nöbetçi kuleleri: yuva sayısı kadar
		var yuva := Veri.sur_yuva(seviye)
		var ust := taban - kat * kat_boy
		for i in yuva:
			var x := 30.0 + (w - 100.0) * (float(i) / maxf(yuva - 1, 1))
			draw_rect(Rect2(x, ust - 22, 40, 22), malzeme.lightened(0.15))
			draw_rect(Rect2(x + 4, ust - 30, 10, 8), malzeme.lightened(0.15))
			draw_rect(Rect2(x + 26, ust - 30, 10, 8), malzeme.lightened(0.15))
		draw_rect(Rect2(10, taban, w - 20, 6), Color("3a3328"))
