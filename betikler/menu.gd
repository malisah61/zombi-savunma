extends CanvasLayer
## Ana menü: alt sekmeler (Oyna, Ekip, Envanter, Keşif, Ayarlar). Mobil oyun düzeni:
## üstte hurda, ortada kaydırılabilir içerik, altta sekme çubuğu. Her sekme koddan kurulur.

signal oyna_istendi
signal ayarlar_degisti

const Veri := preload("res://betikler/veri.gd")
const YildizBetik := preload("res://betikler/yildiz.gd")

const SEKMELER := ["OYNA", "EKİP", "ENVANTER", "KEŞİF", "AYARLAR"]
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
		d.add_theme_font_size_override("font_size", 22)
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
	profil.kesif_kontrol()
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
		_sekme_dugmeleri[j].add_theme_stylebox_override("normal", _stil(r.darkened(0.3), r, 12))
		_sekme_dugmeleri[j].add_theme_stylebox_override("hover", _stil(r.darkened(0.3), r, 12))
		_sekme_dugmeleri[j].add_theme_stylebox_override("pressed", _stil(r, Color.WHITE, 12))
	for c in _icerik.get_children():
		c.queue_free()
	_kesif_etiket = null
	_kesif_cubuk = null
	_hurda_etiket.text = "%d HURDA" % profil.hurda()
	match i:
		0: _oyna_sekmesi()
		1: _ekip_sekmesi()
		2: _envanter_sekmesi()
		3: _kesif_sekmesi()
		4: _ayarlar_sekmesi()
	_etiketleri_duzenle(_icerik)
	_kaydirma.scroll_vertical = 0


func _yenile() -> void:
	var konum := _kaydirma.scroll_vertical
	sekme_ac(_sekme)
	await get_tree().process_frame
	_kaydirma.scroll_vertical = konum


# ---------------------------------------------------------------- OYNA

func _oyna_sekmesi() -> void:
	var h: Dictionary = profil.aktif_kahraman()
	var rol: Dictionary = Veri.ROLLER[h["rol"]]
	var k := _kart(rol["renk"])
	k.add_child(_etiket("SAHADAKİ HAYATTA KALAN", 22, Color(0.7, 0.7, 0.65)))
	k.add_child(_etiket(String(h["ad"]), 40))
	k.add_child(_etiket("%s · %d yaş · Seviye %d · Moral: %s" % [rol["ad"], int(h["yas"]), int(h["seviye"]),
		Veri.moral_metni(int(h["moral"]))], 24, Color(0.85, 0.85, 0.8)))
	var y := _satir(k)
	y.add_child(_etiket("Yetenek", 24))
	_yildizlar(y, Veri.yildiz(Veri.toplam_ozellik(h)))
	y.add_child(_etiket("Potansiyel", 24))
	_yildizlar(y, Veri.yildiz(int(h["potansiyel"])), -1.0, Color(0.5, 0.8, 1.0))
	k.add_child(_etiket("Pasif: " + String(rol["pasif"]), 24, Color(0.7, 0.9, 0.6)))

	var s: Dictionary = profil.kahraman_silahi(h)
	if not s.is_empty():
		var n: Dictionary = Veri.NADIRLIK[int(s["nadirlik"])]
		var sk := _kart(n["renk"])
		sk.add_child(_etiket("SİLAH", 22, Color(0.7, 0.7, 0.65)))
		sk.add_child(_etiket("%s %s  (Sv %d)" % [n["ad"], Veri.SILAHLAR[s["taban"]]["ad"], int(s["seviye"])], 32, n["renk"]))
		sk.add_child(_etiket("Güç: %d" % Veri.silah_gucu(s), 26))

	var b := _kart(Color(0.45, 0.7, 0.3))
	b.add_child(_dugme("SAVAŞA BAŞLA", Color(0.35, 0.65, 0.2), func() -> void: oyna_istendi.emit(), 44))
	b.add_child(_etiket("En iyi: %d. dalga · Toplam %d zombi" % [int(profil.veri["rekor"]),
		int(profil.veri["istatistik"]["oldurme"])], 24, Color(1, 0.85, 0.4)))

	var kk := _kart()
	kk.add_child(_etiket("KEŞİF", 22, Color(0.7, 0.7, 0.65)))
	_kesif_etiket = _etiket("", 26)
	kk.add_child(_kesif_etiket)
	_kesif_guncelle()


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


# ---------------------------------------------------------------- EKİP

func _ekip_sekmesi() -> void:
	var ekip: Array = profil.veri["ekip"]
	_icerik.add_child(_etiket("Ekip (%d/%d) — Football Manager gibi: her hayatta kalanın özellikleri, potansiyeli ve moral durumu var. Oynayan, maç deneyimiyle hızlı; diğerleri antrenmanla yavaş gelişir. Gençler daha hızlı gelişir." % [ekip.size(), Veri.EKIP_SINIRI], 22, Color(0.75, 0.75, 0.7)))
	for h in ekip:
		_hayatta_kalan_karti(h)


func _hayatta_kalan_karti(h: Dictionary) -> void:
	var rol: Dictionary = Veri.ROLLER[h["rol"]]
	var aktif := String(h["uid"]) == String(profil.veri["aktif"])
	var k := _kart(Color(0.5, 0.9, 0.4) if aktif else rol["renk"])
	var ust := _satir(k)
	var ad := _etiket(String(h["ad"]) + ("  (SAHADA)" if aktif else ""), 32, Color(0.6, 1, 0.5) if aktif else Color.WHITE)
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
		d.add_child(_dugme("Sahaya sür", Color(0.35, 0.65, 0.25), func() -> void:
			profil.aktif_yap(uid)
			bildir("%s sahada!" % h["ad"], Color(0.5, 1, 0.5))
			_yenile(), 24))
	if acik:
		d.add_child(_dugme("Odak değiştir", Color(0.3, 0.55, 0.8), func() -> void:
			var ids: Array = []
			for o in Veri.OZELLIKLER:
				ids.append(o["id"])
			var sira := (ids.find(h.get("odak", ids[0])) + 1) % ids.size()
			profil.odak_degistir(uid, ids[sira])
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
	var fiyat := Veri.gelistirme_fiyati(s)
	var gelisebilir := int(s["seviye"]) < max_sv
	d.add_child(_dugme(("Geliştir %d" % fiyat) if gelisebilir else "En üst seviye", Color(0.8, 0.6, 0.2), func() -> void:
		if profil.silah_gelistir(uid):
			bildir("Seviye atladı!", Color(1, 0.85, 0.4))
		else:
			bildir("Yeterli hurda yok", Color(1, 0.5, 0.4))
		_yenile(), 24, gelisebilir))
	if kullanan.is_empty():
		d.add_child(_dugme("Sat +%d" % profil.silah_satis_degeri(s), Color(0.6, 0.3, 0.25), func() -> void:
			profil.silah_sat(uid)
			_yenile(), 24))


# ---------------------------------------------------------------- KEŞİF

func _kesif_sekmesi() -> void:
	_icerik.add_child(_etiket("Gözlemcini bir bölgeye gönder. Döndüğünde bulduğu hayatta kalanları rapor eder. Football Manager'daki gibi gözlemci her şeyi bilemez: özellikler aralık olarak görünür. Emin olmak için 15 hurdaya ayrıntılı incele.", 22, Color(0.75, 0.75, 0.7)))
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
		var toplam_alt := 0
		var toplam_ust := 0
		for o in Veri.OZELLIKLER:
			var gercek := int(h["oz"][o["id"]])
			var ar: Vector2i = profil.aday_aralik(aday, gercek, String(o["id"]))
			toplam_alt += ar.x
			toplam_ust += ar.y
			_ozellik_cubugu(k, String(o["ad"]), ar.x, ar.y)
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

	var bilgi := _kart()
	bilgi.add_child(_etiket("Zombi Savunma · Her gece otomatik olarak geliştirilir. İlerlemen telefonunda saklanır.", 22, Color(0.75, 0.75, 0.7)))
