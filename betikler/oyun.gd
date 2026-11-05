extends Node2D
## Oyun yöneticisi: menü ↔ koşu geçişi, dalgalar, zombi doğurma, mermiler, ekonomi, kartlar,
## nesne havuzları (kasma olmasın diye mermi/zombi/yazı/parçacık yeniden kullanılır), kalite ayarları.

const ZombiBetik := preload("res://betikler/zombi.gd")
const MermiBetik := preload("res://betikler/mermi.gd")
const LekeBetik := preload("res://betikler/leke.gd")
const AsitBetik := preload("res://betikler/asit.gd")
const CanCubukBetik := preload("res://betikler/can_cubuklari.gd")
const AtlasBetik := preload("res://betikler/zombi_atlas.gd")
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

# Otomatik kalite (Performans v2): FPS, hedefin bu oranının altında bu kadar saniye kalırsa kalite bir düşer
const OTO_ESIK := 0.8
const OTO_SURE := 3.0

# Zombi türlerinin ilk çıktığı dalga ve tanıtım metni (Kingdom Rush: her yeni düşman tanıtılır)
const TANITIM := {
	"kosucu": "Hızlı ama çürük. Barikata çabuk varır.",
	"zirhli": "Zırh, her mermiden hasar keser. Ağır vuruşlu silah veya Zırh Delici kartı al.",
	"kusan": "Uzakta durup barikata asit atar. Asker onu öncelikli hedefler.",
	"dev": "BOSS. Vuruşunu kırmızı halkayla işaret eder, yarı canda koşucu çağırır. Öldür: garanti Ender+ silah!",
}

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
var _olu_var := false
var boss  # sahadaki Dev (yoksa null)
var _boss_olduruldu := 0
var _bekleyen_cagri := 0
var _cagri_konum := Vector2.ZERO
var _onarim_sayisi := 0
var _cekme_sayisi := 0
var _gosterilen_kartlar: Array[Dictionary] = []
var _kese_gelir := 0
var _perf_sayac := 0.0
var _perf_dusuk := 0.0
var _perf_kareler := 0
var atlas  # zombi_atlas.gd

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
var _asit_havuzu: Array = []
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
	var cubuklar = Node2D.new()
	cubuklar.set_script(CanCubukBetik)
	cubuklar.oyun = self
	add_child(cubuklar)
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
	arayuz.yeniden_cek_istendi.connect(_yeniden_cek)

	menu = CanvasLayer.new()
	menu.set_script(MenuBetik)
	menu.profil = profil
	add_child(menu)
	menu.oyna_istendi.connect(_yeni_oyun)
	menu.ayarlar_degisti.connect(_ayarlari_uygula)

	atlas = Node.new()
	atlas.set_script(AtlasBetik)
	add_child(atlas)
	atlas.pisir()  # arka planda: bitene dek zombiler yedek yoldan çizilir
	arka.pisir()
	barikat.pisir()

	_havuzlari_kur()
	_ayarlari_uygula()
	st = profil.kosu_istatistigi()
	barikat.max_can = float(st["barikat_max"])
	barikat.can = barikat.max_can
	_arayuz_guncelle()
	arayuz.visible = false
	menu.goster()

	for a in OS.get_cmdline_user_args():
		if a.begins_with("--onizleme="):
			_onizleme(a.trim_prefix("--onizleme="))
		elif a.begins_with("--bot="):
			_bot(int(a.trim_prefix("--bot=")))


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
	g.set_color(1, Color(0, 0, 0, 0.45))
	g.set_offset(0, 0.62)
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
	_lekeleri_sinirla()


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
	_oto_kalite(delta)

	# ölen zombileri listeden çıkar (döngü içinde silmek atlamaya yol açar); yerinde sıkıştırma, her kare yeni dizi yok
	if _olu_var:
		_olu_var = false
		var j := 0
		for i in zombiler.size():
			var z = zombiler[i]
			if not z.olu:
				zombiler[j] = z
				j += 1
		zombiler.resize(j)
	if _bekleyen_cagri > 0:
		_cagri_dogur()

	if float(st["yenilenme"]) > 0.0:
		barikat.onar(float(st["yenilenme"]) * delta)

	if not _dogacak.is_empty():
		_dogum_sayac -= delta
		if _dogum_sayac <= 0.0:
			_dogum_sayac = _dogum_aralik * randf_range(0.6, 1.3)
			_zombi_dogur(_dogacak.pop_front())
	elif zombiler.is_empty() and _bekleyen_cagri == 0:
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
	_boss_olduruldu = 0
	_onarim_sayisi = 0
	_cekme_sayisi = 0
	_kese_gelir = 0
	profil.zaman_dinlenmesi()
	_ayarlari_uygula()
	menu.gizle()
	arayuz.visible = true
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
	for dugum in _asit_havuzu:
		dugum.visible = false
		dugum.set_process(false)
	_dogacak.clear()
	_dalga_bitti_sayac = -1.0
	boss = null
	_bekleyen_cagri = 0
	arayuz.boss_gizle()
	Engine.time_scale = 1.0


func _sonraki_dalga() -> void:
	dalga += 1
	durum = Durum.OYUN
	_dogacak.clear()
	if _kese_gelir > 0:
		altin += _kese_gelir
	var boss_dalgasi := dalga % 5 == 0
	var nefes := dalga % 5 == 1 and dalga > 5  # boss sonrası nefes dalgası
	var adet := 6 + dalga * 2
	if boss_dalgasi:
		adet = int(adet * 0.5)  # boss sahneyi doldurur
	elif nefes:
		adet = int(adet * 0.6)
	for t in _dalga_bilesimi(adet):
		_dogacak.append(t)
	_dogacak.shuffle()
	# her 5 dalgada bir yoğun saldırı + boss
	if boss_dalgasi:
		for i in dalga:
			_dogacak.append("kosucu")
		_dogacak.insert(mini(3, _dogacak.size()), "dev")
	_dogum_aralik = maxf(1.25 - dalga * 0.06, 0.35)
	_dogum_sayac = 1.5
	var afis := "DALGA %d" % dalga
	if boss_dalgasi:
		afis += "\nBOSS: DEV!\nYOĞUN SALDIRI!"
	elif nefes:
		afis += "\nNefes al"
	arayuz.dalga_afisi(afis)
	ses("boss" if boss_dalgasi else "dalga")
	_yeni_turleri_tanit()
	_arayuz_guncelle()


## Dalganın zombi türleri. Türler sırayla açılır; oranlar dalgayla artar, sınırlıdır.
func _dalga_bilesimi(adet: int) -> Array[String]:
	var kosucu_orani := 0.0 if dalga < 3 else minf(0.15 + dalga * 0.03, 0.45)
	var zirhli_orani := 0.0 if dalga < 4 else minf(0.1 + (dalga - 4) * 0.015, 0.25)
	var kusan_orani := 0.0 if dalga < 6 else minf(0.08 + (dalga - 6) * 0.01, 0.16)
	var liste: Array[String] = []
	# yeni tür çıktığı dalgada kesin görünsün
	if dalga == 4:
		liste.append("zirhli")
		liste.append("zirhli")
	elif dalga == 6:
		liste.append("kusan")
		liste.append("kusan")
	for i in maxi(adet - liste.size(), 0):
		var r := randf()
		if r < kosucu_orani:
			liste.append("kosucu")
		elif r < kosucu_orani + zirhli_orani:
			liste.append("zirhli")
		elif r < kosucu_orani + zirhli_orani + kusan_orani:
			liste.append("kusan")
		else:
			liste.append("yuruyen")
	return liste


func _yeni_turleri_tanit() -> void:
	var gorulen: Array = profil.veri["gorulen"]
	for t in TANITIM:
		if gorulen.has(t):
			continue
		if _dogacak.has(t):
			gorulen.append(t)
			arayuz.tanitim_goster(_tur_adi(t), String(TANITIM[t]))
			return


func _tur_adi(t: String) -> String:
	return {"kosucu": "KOŞUCU", "zirhli": "ZIRHLI", "kusan": "KUSAN", "dev": "DEV"}.get(t, t)


## Zombi canı: 15. dalgaya dek doğrusal, sonra karesel, 25. dalgadan sonra üstel (tam evrimli yapı da bir yerde düşsün).
func can_carpani() -> float:
	var gec := maxf(float(dalga - 15), 0.0)
	return (1.0 + 0.12 * (dalga - 1) + 0.03 * gec * gec) * pow(1.08, maxf(float(dalga - 25), 0.0))


func _duraklat(acik: bool) -> void:
	if durum != Durum.OYUN and acik:
		return
	get_tree().paused = acik
	arayuz.duraklat_goster(acik)


func _menuye_don() -> void:
	get_tree().paused = false
	if (durum == Durum.OYUN or durum == Durum.KART) and not _kosu_odullendi:
		_kosu_odullendi = true
		profil.kosu_bitti(dalga, oldurme, _boss_olduruldu)
	_temizle()
	durum = Durum.MENU
	arayuz.bitis_gizle()
	_arayuz_guncelle()
	arayuz.visible = false
	menu.goster()


func _oyun_bitti() -> void:
	if durum == Durum.BITTI:
		return
	durum = Durum.BITTI
	var eski_rekor := int(profil.veri["rekor"])
	var ozet: Dictionary = {}
	if not _kosu_odullendi:
		_kosu_odullendi = true
		ozet = profil.kosu_bitti(dalga, oldurme, _boss_olduruldu, true)
	ses("bitis")
	_titret(250)
	_sarsinti = 14.0
	arayuz.boss_gizle()
	Engine.time_scale = 1.0
	arayuz.bitis_goster(dalga, oldurme, int(profil.veri["rekor"]), dalga > eski_rekor, ozet)
	_arayuz_guncelle()


# ================================================================ ZOMBİLER

func _zombi_dogur(tur: String):
	var z
	if _zombi_havuzu.is_empty():
		z = Node2D.new()
		z.set_script(ZombiBetik)
		_zombi_katmani.add_child(z)
	else:
		z = _zombi_havuzu.pop_back()
	if tur == "dev":
		# her Dev bir öncekinden güçlü; ilk Dev bilerek kolay
		var sira := int(dalga / 5.0)
		z.kur(self, tur, can_carpani() * (1.0 + 0.6 * (sira - 1)), 1.0 + 0.35 * (sira - 1))
		z.position = Vector2(genislik / 2.0, -80.0)
		boss = z
		arayuz.boss_goster("DEV", 1.0)
	else:
		z.kur(self, tur, can_carpani(), 1.0 + dalga * 0.02)
		z.position = Vector2(randf_range(70.0, genislik - 70.0), randf_range(-60.0, -20.0))
	zombiler.append(z)
	return z


func _zombi_havuza(z) -> void:
	z.olu = true
	z.visible = false
	z.set_process(false)
	if not _zombi_havuzu.has(z):
		_zombi_havuzu.append(z)


func zombi_oldu(z) -> void:
	oldurme += 1
	_olu_var = true
	var kazanc := int(round(z.altin_degeri * float(st["altin_carpan"])))
	altin += kazanc
	_leke_birak(z.position)
	_parcacik("kan_buyuk", z.position)
	if bool(st["yanma_yayilim"]) and z._yakilmis:
		_yanma_yay(z)
	if z.boss:
		_boss_oldu(z)
	_yazi(z.position + Vector2(0, -20), "+%d" % kazanc, Color(1, 0.85, 0.3), 26, true)
	ses("olum")
	var tw: Tween = z.create_tween()
	tw.tween_property(z, "scale", Vector2(1.3, 0.2), 0.18)
	tw.parallel().tween_property(z, "modulate:a", 0.0, 0.18)
	tw.tween_callback(_zombi_havuza.bind(z))
	z.set_meta("tw", tw)
	_arayuz_guncelle()


## saldiran: yakın dövüşte vuran zombi (Dikenli Tel için); asitte null.
func barikat_vuruldu(miktar: float, x: float, saldiran = null) -> void:
	if durum != Durum.OYUN:
		return
	barikat.hasar_al(miktar)
	if saldiran != null and float(st["diken"]) > 0.0:
		saldiran.vurul(float(st["diken"]))
	_sarsinti = minf(_sarsinti + (2.0 if kalite > 0 else 1.0), 8.0)
	_parcacik("kiymik", Vector2(x, barikat_y - 10))
	_titret(25)
	ses("barikat")
	_arayuz_guncelle()
	if barikat.can <= 0.0:
		_oyun_bitti()


# ================================================================ BOSS VE ASİT

func boss_vurdu(z) -> void:
	barikat_vuruldu(z.hasar, z.position.x)
	_sarsinti = minf(_sarsinti + 10.0, 16.0)
	_titret(120)
	ses("barikat")
	for i in 3:
		_parcacik("kiymik", Vector2(z.position.x + randf_range(-90, 90), barikat_y - 10))


func boss_cagirdi(z) -> void:
	_bekleyen_cagri = 2 + int(dalga / 5.0) * 2
	_cagri_konum = z.position
	ses("boss")
	_yazi(z.position + Vector2(0, -100), "YARDIM ÇAĞIRDI!", Color(1, 0.4, 0.3), 40, true)


## Çağrılan koşucular Dev'in yanında doğar (mermi döngüsü dışında, güvenli anda).
func _cagri_dogur() -> void:
	while _bekleyen_cagri > 0:
		_bekleyen_cagri -= 1
		var z = _zombi_dogur("kosucu")
		z.position = _cagri_konum + Vector2(randf_range(-110, 110), randf_range(-40, 40))
		z.position.x = clampf(z.position.x, 40.0, genislik - 40.0)


func _boss_oldu(z) -> void:
	boss = null
	_boss_olduruldu += 1
	arayuz.boss_gizle()
	arayuz.dalga_afisi("DEV DÜŞTÜ!\nGARANTİ GANİMET")
	ses("bitis")
	_titret(200)
	_sarsinti = 16.0
	for i in 5:
		_parcacik("kan_buyuk", z.position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	# kısa ağır çekim: büyük an hissedilsin
	Engine.time_scale = 0.35
	get_tree().create_timer(0.5, true, false, true).timeout.connect(func() -> void: Engine.time_scale = 1.0)


func asit_at(konum: Vector2, hasar: float) -> void:
	var a
	for aday in _asit_havuzu:
		if not aday.visible:
			a = aday
			break
	if a == null:
		a = Node2D.new()
		a.set_script(AsitBetik)
		a.oyun = self
		_efekt_katmani.add_child(a)  # mermi katmanına koyma: _temizle oradakileri mermi sanır
		_asit_havuzu.append(a)
	a.baslat(konum, Vector2(konum.x + randf_range(-30, 30), barikat_y - 4.0), hasar)
	ses("asit")


func asit_dustu(a, konum: Vector2, hasar: float) -> void:
	a.visible = false
	a.set_process(false)
	_parcacik("asit", konum)
	barikat_vuruldu(hasar, konum.x)


func yanma_tik(z, miktar: float) -> void:
	z.vurul(miktar)
	_parcacik("ates", z.position)
	if TUM_SAYILAR[kalite]:
		_yazi(z.position + Vector2(randf_range(-14, 14), -22), str(int(round(miktar))), Color(1, 0.6, 0.2), 20)


func _yanma_yay(olen) -> void:
	var kalan := 2
	for z in zombiler:
		if kalan == 0:
			break
		if z.olu or z == olen or z.position.distance_squared_to(olen.position) > 22500.0:
			continue
		z.tutustur(float(st["hasar"]) * float(st["yanma"]), 3.0)
		kalan -= 1


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
	# Zırh düz hasar keser: küçük mermi çok, büyük mermi az etkilenir. En az %20 hep geçer.
	var kalan_zirh := 0.0 if bool(st["zirh_yok"]) else maxf(float(z.zirh) - float(st["zirh_delme"]), 0.0)
	var son := maxf(hasar - kalan_zirh, hasar * 0.2)
	var zirhta_kaldi: bool = son < hasar * 0.6
	z.vurul(son)
	if float(st["yanma"]) > 0.0 and not z.olu:
		z.tutustur(float(st["hasar"]) * float(st["yanma"]), 3.0)
	_parcacik("kivilcim" if kalan_zirh > 0.0 else "kan_kucuk", konum)
	if kritik or TUM_SAYILAR[kalite]:
		var renk := Color(0.7, 0.75, 0.8) if zirhta_kaldi else (Color(1, 0.5, 0.2) if kritik else Color.WHITE)
		_yazi(konum + Vector2(randf_range(-12, 12), -10), str(int(round(son))) + ("!" if kritik else ""),
			renk, 34 if kritik else 24)
	if kritik:
		_titret(12)
	if not z.olu:
		ses("zirh" if kalan_zirh > 0.0 else "isabet")
	if z == boss and boss != null:
		arayuz.boss_goster("DEV", z.can / z.max_can)


# ================================================================ KARTLAR

func _kart_sec() -> void:
	durum = Durum.KART
	_gosterilen_kartlar = _kart_secenekleri()
	if _gosterilen_kartlar.is_empty():
		_sonraki_dalga()
		return
	ses("evrim" if _gosterilen_kartlar[0].has("evrim") else "kart")
	_kartlari_ac()


## Önce hazır evrim (altın kart), sonra rastgele kartlar; kart kalmazsa dolgu kartlar.
func _kart_secenekleri() -> Array[Dictionary]:
	var adaylar: Array[Dictionary] = []
	for k in Kartlar.LISTE:
		if int(kart_seviye.get(k["id"], 0)) < int(k["max"]):
			adaylar.append(k)
	adaylar.shuffle()
	var secenekler: Array[Dictionary] = []
	var evrimler := Kartlar.hazir_evrimler(kart_seviye)
	if not evrimler.is_empty():
		secenekler.append(evrimler.pick_random())
	var bos := 3 - secenekler.size()
	for i in mini(bos, adaylar.size()):
		secenekler.append(adaylar[i])
	var dolgu: Array = Kartlar.DOLGU.duplicate()
	dolgu.shuffle()
	var d := 0
	while secenekler.size() < 3 and d < dolgu.size():
		secenekler.append(dolgu[d])
		d += 1
	return secenekler


func _kartlari_ac() -> void:
	arayuz.kartlari_goster(_gosterilen_kartlar, kart_seviye, _cekme_fiyati(), altin)


## Yeniden çekme: altının ikinci harcama yeri (Archero/Brotato). Her kullanımda pahalanır.
func _cekme_fiyati() -> int:
	return 15 + _cekme_sayisi * 10


func _yeniden_cek() -> void:
	var fiyat := _cekme_fiyati()
	if durum != Durum.KART or altin < fiyat:
		return
	altin -= fiyat
	_cekme_sayisi += 1
	_gosterilen_kartlar = _kart_secenekleri()
	ses("altin")
	_kartlari_ac()
	_arayuz_guncelle()


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
		"yanma":
			st["yanma"] = float(st["yanma"]) + 0.15  # saniyede hasarın %15'i
		"zirh_delici":
			st["zirh_delme"] = float(st["zirh_delme"]) + 4.0
		"diken":
			st["diken"] = float(st["diken"]) + 10.0
		"tamirci":
			st["yenilenme"] = float(st["yenilenme"]) + 0.005
		"kese":
			_kese_gelir += 8
		"tam_onarim":
			barikat.can = barikat.max_can
		"minigun":
			st["ates_hizi"] = float(st["ates_hizi"]) * 1.5
			st["hasar"] = float(st["hasar"]) * 1.1
			_evrim_afisi("MİNİGUN")
		"napalm":
			st["yanma"] = float(st["yanma"]) * 2.5
			st["yanma_yayilim"] = true
			_evrim_afisi("NAPALM")
		"titanyum":
			st["zirh_yok"] = true
			st["delme"] = int(st["delme"]) + 2
			_evrim_afisi("TİTANYUM ÇEKİRDEK")
		"kale":
			st["diken"] = float(st["diken"]) * 3.0
			barikat.max_can *= 1.3
			barikat.can = barikat.max_can
			_evrim_afisi("DİKEN KALESİ")
	_arayuz_guncelle()


func _evrim_afisi(ad: String) -> void:
	_sarsinti = 8.0
	_titret(80)
	_yazi(Vector2(genislik / 2.0, yukseklik * 0.45), "EVRİM: " + ad, Color(1, 0.82, 0.3), 44, true)


## Onarım her kullanımda 5 altın pahalanır: altın bedava can değil, zamanlaması olan bir karardır.
func onar_fiyati() -> int:
	return int(st.get("onar_fiyat", 25)) + _onarim_sayisi * 5


func _onar() -> void:
	var fiyat := onar_fiyati()
	if altin < fiyat or durum != Durum.OYUN:
		return
	altin -= fiyat
	_onarim_sayisi += 1
	barikat.onar(float(st["onarim"]))
	ses("altin")
	_yazi(Vector2(genislik / 2, barikat_y - 40), "ONARILDI", Color(0.5, 1, 0.5), 36, true)
	_arayuz_guncelle()


func _arayuz_guncelle() -> void:
	arayuz.guncelle(dalga, altin, oldurme, barikat.can / barikat.max_can, durum == Durum.OYUN, onar_fiyati())


# ================================================================ GİRDİ

## FPS uzun süre hedefin altındaysa kaliteyi bir kademe düşürür. Ayarın kendisine dokunmaz (bu koşu için).
func _oto_kalite(delta: float) -> void:
	if not bool(profil.ayar("oto_kalite")) or kalite == 0:
		return
	_perf_sayac += delta
	_perf_kareler += 1
	if _perf_sayac < 1.0:
		return
	var fps := _perf_kareler / _perf_sayac
	_perf_sayac = 0.0
	_perf_kareler = 0
	if fps < float(profil.ayar("fps")) * OTO_ESIK:
		_perf_dusuk += 1.0
		if _perf_dusuk >= OTO_SURE:
			_perf_dusuk = 0.0
			kalite -= 1
			_lekeleri_sinirla()
			arayuz.uyari_goster("Akıcılık için grafik otomatik düşürüldü")
	else:
		_perf_dusuk = 0.0


func _lekeleri_sinirla() -> void:
	while _lekeler.size() > LEKE_SINIRI[kalite]:
		_lekeler.pop_front().queue_free()


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
		"kivilcim": {"adet": 5, "renk": Color("ffe9a0"), "hiz": 340.0, "boy": 4.0, "sayi": 8},
		"asit": {"adet": 10, "renk": Color("9be02f"), "hiz": 240.0, "boy": 7.0, "sayi": 4},
		"ates": {"adet": 4, "renk": Color("ff8a2a"), "hiz": 120.0, "boy": 6.0, "sayi": 8},
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
		l.atlas = atlas
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
	profil.veri["ekip"][1]["sakat"] = 2
	profil.veri["ekip"][0]["yorgunluk"] = 46.0
	menu.sekme_ac(1)
	await _bekle(0.3)
	await _kare(klasor + "/06_ekip_kisilik.png")
	_yeni_oyun()
	profil.ayar_degistir("oto_kalite", false)  # yazılım ekranında kalite düşmesin, gerçek görüntü çıksın
	print("ONIZLEME atlas hazir: ", atlas.hazir)
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
	# Yeni zombiler: zırhlı + kusan + tanıtım afişi
	barikat.can = barikat.max_can
	st["hasar"] = 9.0
	dalga = 9
	for i in 6:
		_zombi_dogur("zirhli" if i % 2 == 0 else "kusan")
		zombiler[-1].position = Vector2(110.0 + i * 95.0, 300.0 + (i % 3) * 170.0)
	arayuz.tanitim_goster("ZIRHLI", String(TANITIM["zirhli"]))
	await _bekle(2.2)
	await _kare(klasor + "/15_zirhli_kusan.png")
	_temizle()
	# Boss: işaretli vuruş ve can çubuğu
	dalga = 5
	var dev = _zombi_dogur("dev")
	dev.position = Vector2(genislik / 2.0, dev._durus_y)
	dev.can = dev.max_can * 0.7
	dev._cagirdi = true
	arayuz.boss_goster("DEV", 0.7)
	for i in 6:
		_zombi_dogur("yuruyen")
		zombiler[-1].position = Vector2(90.0 + i * 105.0, 500.0 + (i % 2) * 90.0)
	dev._saldiri_sayac = 0.05
	await _bekle(0.9)
	await _kare(klasor + "/16_boss.png")
	_temizle()
	barikat.can = barikat.max_can
	_kart_sec()
	await _bekle(0.5)
	await _kare(klasor + "/13_kartlar.png")
	# Evrim kartı
	durum = Durum.OYUN
	altin = 120
	kart_seviye = {"ates_hizi": 5, "namlu": 2, "hasar": 2}
	_kart_sec()
	await _bekle(0.5)
	await _kare(klasor + "/17_evrim_kart.png")
	_kart_secildi("minigun")
	arayuz.oyun_basladi()
	await _yuk_testi()
	_temizle()
	profil.veri["ekip"][1]["sakat"] = 0
	durum = Durum.OYUN
	dalga = 12
	oldurme = 140
	_boss_olduruldu = 2
	profil.veri["ekip"][0]["yorgunluk"] = 100.0
	_oyun_bitti()
	await _bekle(0.9)
	await _kare(klasor + "/14_bitis.png")
	get_tree().quit()


## Denge sınaması (geliştirici aracı): `godot --headless --fixed-fps 60 -- --bot=5`
## Rastgele kart seçip onarım yapan bir bot N koşu oynar, ulaştığı dalgayı yazar.
func _bot(kosu: int) -> void:
	await _bekle(0.5)
	for i in kosu:
		_yeni_oyun()
		while durum != Durum.BITTI:
			await _bekle(0.1)
			if durum == Durum.KART:
				_kart_secildi(_gosterilen_kartlar[0]["id"])
			elif durum == Durum.OYUN:
				if not zombiler.is_empty():
					kahraman.hedef_x = zombiler[0].position.x
				if barikat.can < barikat.max_can * 0.5:
					_onar()
			if dalga >= 60:
				barikat.can = 0.0
				_oyun_bitti()
		print("BOT kosu %d: dalga=%d oldurme=%d boss=%d evrim=%s kartlar=%d" % [i, dalga, oldurme, _boss_olduruldu,
			str(kart_seviye.keys().filter(func(k) -> bool: return Kartlar.bul(k).is_empty())), kart_seviye.size()])
	get_tree().quit()


## Performans sınaması: 120 zombi + sürekli ateş, FPS kayda yazılır.
func _yuk_testi() -> void:
	_temizle()
	dalga = 12
	barikat.max_can = 1000000.0
	barikat.can = barikat.max_can
	st["ates_hizi"] = 10.0
	st["hasar"] = 1.0
	var turler := ["yuruyen", "kosucu", "zirhli", "kusan"]
	for i in 120:
		_zombi_dogur(turler[i % 4])
		zombiler[-1].position = Vector2(randf_range(50, genislik - 50), randf_range(120, barikat_y - 60))
		zombiler[-1].max_can = 1000000.0
		zombiler[-1].can = 1000000.0
	await _bekle(1.0)
	var bas := Time.get_ticks_msec()
	var kare_bas := Engine.get_frames_drawn()
	await _bekle(4.0)
	var fps := (Engine.get_frames_drawn() - kare_bas) * 1000.0 / (Time.get_ticks_msec() - bas)
	var cagri := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	print("ONIZLEME yuk testi: 120 zombi FPS=%.1f cizim_cagrisi=%d" % [fps, cagri])
	await _kare("%s/18_yuk_testi.png" % OS.get_cmdline_user_args()[0].trim_prefix("--onizleme="))
	barikat.max_can = 300.0
	barikat.can = 300.0


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn, true).timeout


func _kare(yol: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(yol)
	print("ONIZLEME kaydedildi: ", yol)
