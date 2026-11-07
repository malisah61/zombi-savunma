extends Node2D
## Oyun yöneticisi: menü ↔ koşu geçişi, dalgalar, zombi doğurma, mermiler, ekonomi, kartlar,
## nesne havuzları (kasma olmasın diye mermi/zombi/yazı/parçacık yeniden kullanılır), kalite ayarları.

const ZombiBetik := preload("res://betikler/zombi.gd")
const MermiBetik := preload("res://betikler/mermi.gd")
const LekeBetik := preload("res://betikler/leke.gd")
const AsitBetik := preload("res://betikler/asit.gd")
const CanCubukBetik := preload("res://betikler/can_cubuklari.gd")
const AtlasBetik := preload("res://betikler/zombi_atlas.gd")
const KuleBetik := preload("res://betikler/kule.gd")
const PatlamaBetik := preload("res://betikler/patlama.gd")
const ParcacikBetik := preload("res://betikler/parcaciklar.gd")
const KahramanBetik := preload("res://betikler/kahraman.gd")
const BarikatBetik := preload("res://betikler/barikat.gd")
const ArkaPlanBetik := preload("res://betikler/arka_plan.gd")
const ArayuzBetik := preload("res://betikler/arayuz.gd")
const MenuBetik := preload("res://betikler/menu.gd")
const ProfilBetik := preload("res://betikler/profil.gd")
const SeslerBetik := preload("res://betikler/sesler.gd")
const Kartlar := preload("res://betikler/kartlar.gd")
const Veri := preload("res://betikler/veri.gd")
const YazilarBetik := preload("res://betikler/yazilar.gd")
const NobetciBetik := preload("res://betikler/nobetci.gd")

enum Durum { MENU, OYUN, KART, BITTI }

# Kalite ayarına göre (0 düşük, 1 orta, 2 yüksek)
const LEKE_SINIRI := [0, 25, 50]
const PARCACIK_ACIK := [false, true, true]
const PARCACIK_SINIRI := [0, 180, 320]
const TUM_SAYILAR := [false, true, true]

# Otomatik kalite (Performans v2): FPS, hedefin bu oranının altında bu kadar saniye kalırsa kalite bir düşer
const OTO_ESIK := 0.8
const OTO_SURE := 3.0

const BOMBA_YARICAP := 170.0
const NISAN_SURE := 5.0
const ASI_SURE := 6.0
const PATLAMA_YARICAP := 130.0
const PATLAMA_HASAR := 40.0  # can çarpanıyla büyür: yürüyeni her dalgada tek seferde indirir
const IKINCI_SANS_CAN := 0.25
const NOBETCI_X := [0.35, 0.65, 0.07, 0.93, 0.43, 0.57]  # sur yuvaları (taretlerin arası, sonra kenarlar)
# A3 Sürü: ızgara hücresi, güncelleme aralığı (kaliteye göre), itme gücü
const SURU_HUCRE := 80.0
const SURU_ARA := [0.2, 0.1, 0.1]
const SURU_GUC := 150.0
const SURU_ITME_MAX := 170.0
const SURU_KALKAN_MESAFE := Vector2(110.0, 170.0)  # koşucu bu kadar yakın (x, y) zırhlının arkasına geçer

# Yönetmen (Left 4 Dead'in yapay zekâ yönetmeni gibi): gerilimi ölçer, doğum zamanlamasını ve yönünü ayarlar.
# Adil kural: dalganın zombi sayısı ve türleri DEĞİŞMEZ; yalnızca ne zaman ve nereden geldikleri değişir.
enum Evre { YUKSELME, ZIRVE, SONME, NEFES }
const YON_ZIRVE := 70.0       # bu gerilimde zirve başlar
const YON_SONME_BITIS := 40.0 # sönme bu gerilimin altında nefese döner
const YON_DUSUK := 25.0       # altında doğum %30 hızlanır
const YON_KANAT := 15.0       # bu kadar sakin ve 4 sn sürerse kanattan sürpriz
const YON_HASAR_KATSAYI := 250.0  # barikat canının %10'u gitti → +25 gerilim
const YON_SONUM := 8.0        # hasar gerilimi saniyede bu kadar söner
const YON_MOLA_SINIRI := 15.0 # bir dalgada en fazla bu kadar saniye doğum durur

# Zombi türlerinin ilk çıktığı dalga ve tanıtım metni (Kingdom Rush: her yeni düşman tanıtılır)
const TANITIM := {
	"kosucu": "Hızlı ama çürük. Barikata çabuk varır.",
	"zirhli": "Zırh, her mermiden hasar keser. Ağır vuruşlu silah veya Zırh Delici kartı al.",
	"kusan": "Uzakta durup barikata asit atar. Asker onu öncelikli hedefler.",
	"patlayan": "Barikatta patlar, çok can götürür. Kalabalığın içinde vurursan etrafındakileri de havaya uçurur!",
	"dev": "BOSS. Vuruşunu kırmızı halkayla işaret eder, yarı canda koşucu çağırır. Öldür: garanti Ender+ silah!",
	"kralice": "BOSS. Geride durup sürekli koşucu doğurur. Yavrular bitmez: önce onu öldür! Havan ve el bombası iyi gelir.",
}

# Bitiş ekranı: barikatı en çok yiyen türe göre öneri (öğrenme döngüsü)
const OLUM_IPUCU := {
	"yuruyen": "Kalabalık yetişti. Hasar ve Delici Mermi kartı, Havan dene.",
	"kosucu": "Hızlılar geçti. Ateş hızı ve Dürbün kartı dene.",
	"zirhli": "Zırh mermini yedi. Zırh Delici, ağır silah veya Ağır Taret dene.",
	"kusan": "Asit uzaktan eritti. Menzil al veya Havan kur.",
	"patlayan": "Patlayanları kalabalığın içinde, erken vur.",
	"dev": "Dev'in vuruşunu bekle: bombanı ve onarımı ona sakla.",
	"kralice": "Kraliçe yavru doğurdukça kalabalık büyür. Surdakileri 'Boss önce' moduna al.",
}

var genislik := 720.0
var yukseklik := 1280.0
var barikat_y := 1010.0

var durum: Durum = Durum.MENU
var oyun_hizi := 1  # 1, 2 veya 3 (Engine.time_scale)
var kampanya := false  # Grow Castle tarzı kampanya savaşı (tek dalga) mı, Hayatta Kalma koşusu mu
var kampanya_tekrar := false  # Kampanya v2: geçilmiş dalgayı yeniden oynama (altın kasma, ilerletmez)
var oto := false  # B4: otomatik savaş açık mı (yalnız kampanyada geçilmiş dalgalarda izinli)
var _oto_izin := false
var _oto_sayac := 0.0
var _oto_el := 0.0  # oyuncu ekrana dokununca otomatik hareket kısa süre durur (parmak her zaman önce)
var _gorulen_tur: Dictionary = {}  # A6: bu koşuda doğan zombi türleri (akıllı kart için)
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
var zombi_hizi := 1.0  # Aşı yavaşlatır
var kuleler: Array = []
var _patlamalar: Array = []
var _patlama_sira := 0
var _parcaciklar: Node2D
var _uzman_yuva := -1  # uzmanlık seçimi açıkken yuva numarası
var _hasar_kaynak: Dictionary = {}  # zombi türü -> barikata verdiği toplam hasar
var _son_ozet: Dictionary = {}
var _ikinci_sans := false
var _bedava_cekim := 0
var _aktif_bekleme := 0.0
var _aktif_max := 22.0
var _nisan_kalan := 0.0
var _asi_kalan := 0.0
var nobetciler: Array = []  # surdaki ekip düğümleri (havuz, 6 yuva)
var _katki: Dictionary = {}  # kaynak (0 lider, 1+ nöbetçi, -2 taret) -> {hasar, oldurme}
var _yazilar  # yazilar.gd (Performans v4)
var _yon_evre: Evre = Evre.YUKSELME
var _yon_hasar := 0.0
var _yon_ekran := 0.0
var _yon_sayac := 0.0
var _yon_olcum := 0.0
var _yon_sakin := 0.0
var _yon_kanat := false
var _yon_mola := 0.0
var _yon_gunluk := false  # önizlemede evre geçişlerini kayda yazar
var _suru_sayac := 0.0
var _izgara_bas := PackedInt32Array()
var _izgara_sonraki := PackedInt32Array()
var _izgara_sutun := 1
var _izgara_satir := 1

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
	for i in 3:
		var ku = Node2D.new()
		ku.set_script(KuleBetik)
		ku.oyun = self
		ku.position = Vector2(genislik * (0.2 + 0.3 * i), barikat_y - 18.0)
		add_child(ku)
		kuleler.append(ku)
	for i in NOBETCI_X.size():
		var nb = Node2D.new()
		nb.set_script(NobetciBetik)
		nb.oyun = self
		nb.sira = i + 1
		nb.position = Vector2(genislik * NOBETCI_X[i], barikat_y - 20.0)
		nb.visible = false
		add_child(nb)
		nobetciler.append(nb)
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
	for i in 5:
		var pat := Node2D.new()
		pat.set_script(PatlamaBetik)
		pat.visible = false
		_efekt_katmani.add_child(pat)
		_patlamalar.append(pat)
	_parcaciklar = Node2D.new()
	_parcaciklar.set_script(ParcacikBetik)
	_efekt_katmani.add_child(_parcaciklar)
	_yazilar = Node2D.new()
	_yazilar.set_script(YazilarBetik)
	_efekt_katmani.add_child(_yazilar)

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
	arayuz.basla_istendi.connect(_tekrar)
	arayuz.menu_istendi.connect(_menuye_don)
	arayuz.duraklat_istendi.connect(_duraklat)
	arayuz.hiz_istendi.connect(_hiz_degistir)
	arayuz.yeniden_cek_istendi.connect(_yeniden_cek)
	arayuz.aktif_istendi.connect(aktif_kullan)
	arayuz.kule_istendi.connect(kule_al)
	arayuz.konusma_istendi.connect(_konusma)
	arayuz.oto_istendi.connect(_oto_degistir)
	arayuz.yukselt_istendi.connect(_hizli_yukselt)
	arayuz.kule_dugmeleri_kur([kuleler[0].position, kuleler[1].position, kuleler[2].position])

	menu = CanvasLayer.new()
	menu.set_script(MenuBetik)
	menu.profil = profil
	add_child(menu)
	menu.oyna_istendi.connect(_yeni_oyun)
	menu.kampanya_istendi.connect(_kampanya_baslat)
	menu.kampanya_tekrar_istendi.connect(_kampanya_tekrar_baslat)
	menu.ayarlar_degisti.connect(_ayarlari_uygula)

	atlas = Node.new()
	atlas.set_script(AtlasBetik)
	add_child(atlas)
	atlas.pisir()  # arka planda: bitene dek zombiler yedek yoldan çizilir
	arka.pisir()
	barikat.pisir()
	kahraman.pisir()

	_havuzlari_kur()
	_ayarlari_uygula()
	st = profil.kosu_istatistigi()
	barikat.max_can = float(st["barikat_max"])
	barikat.can = barikat.max_can
	_arayuz_guncelle()
	arayuz.visible = false
	menu.goster()

	for a in OS.get_cmdline_user_args():
		if a.begins_with("--bot_kampanya="):
			_bot_kampanya(int(a.trim_prefix("--bot_kampanya=")))
		elif a.begins_with("--onizleme="):
			_yon_gunluk = true
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
	_parcaciklar.sinir = PARCACIK_SINIRI[kalite]


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
	_aktif_isle(delta)

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
	_suru_isle(delta)
	if oto:
		_oto_isle(delta)

	if float(st["yenilenme"]) > 0.0:
		barikat.onar(float(st["yenilenme"]) * delta)

	_yonetmen(delta)
	if not _dogacak.is_empty():
		_dogum_sayac -= delta * _yon_dogum_carpani()
		if _dogum_sayac <= 0.0:
			_dogum_sayac = _dogum_aralik * randf_range(0.6, 1.3)
			_zombi_dogur(_dogacak.pop_front())
	elif zombiler.is_empty() and _bekleyen_cagri == 0:
		if _dalga_bitti_sayac < 0.0:
			_dalga_bitti_sayac = 1.0
		_dalga_bitti_sayac -= delta
		if _dalga_bitti_sayac <= 0.0:
			_dalga_bitti_sayac = -1.0
			if kampanya:
				_kampanya_zafer()
			else:
				_kart_sec()


# ================================================================ KOŞU AKIŞI

## TEKRAR düğmesi: aynı modu yeniden başlatır (kampanyada kazanınca sıradaki dalga, kaybedince aynısı).
func _tekrar() -> void:
	if kampanya:
		_yeni_oyun(true, kampanya_tekrar)
	else:
		_yeni_oyun()


func _kampanya_baslat() -> void:
	_yeni_oyun(true)


## Kampanya v2: en son geçilen dalgayı yeniden oyna (yarım ödül, yıldız yükseltilebilir, OTO açık).
func _kampanya_tekrar_baslat() -> void:
	_yeni_oyun(true, true)


func _yeni_oyun(kampanya_mi: bool = false, tekrar_mi: bool = false) -> void:
	get_tree().paused = false
	kampanya = kampanya_mi
	kampanya_tekrar = kampanya_mi and tekrar_mi and int(profil.veri["kampanya"]["en_yuksek"]) >= 1
	_gorulen_tur.clear()
	_temizle()
	oyun_hizi = clampi(int(profil.ayar("hiz")), 1, _hiz_ust())
	arayuz.hiz_goster(oyun_hizi)
	Engine.time_scale = float(oyun_hizi)
	st = profil.kosu_istatistigi()
	kart_seviye.clear()
	barikat.max_can = float(st["barikat_max"])
	barikat.can = barikat.max_can
	kahraman.silah_ayarla(String(st["silah_taban"]))
	kahraman.position.x = genislik / 2
	kahraman.hedef_x = genislik / 2
	dalga = 0
	altin = int(st["bas_altin"])
	oldurme = 0
	_kosu_odullendi = false
	_hasar_kaynak.clear()
	_ikinci_sans = bool(st["ikinci_sans"])
	_bedava_cekim = int(st["bedava_cekim"])
	_boss_olduruldu = 0
	_onarim_sayisi = 0
	_cekme_sayisi = 0
	_kese_gelir = 0
	for ku in kuleler:
		ku.sifirla()
	_nobetcileri_kur()
	_katki = {0: {"hasar": 0.0, "oldurme": 0}}
	var ak: Dictionary = Veri.AKTIFLER[String(st["rol"])]
	_aktif_max = float(ak["bekleme"])
	_aktif_bekleme = 0.0
	_nisan_kalan = 0.0
	_asi_kalan = 0.0
	zombi_hizi = 1.0
	arayuz.aktif_ayarla(String(ak["ad"]))
	profil.zaman_dinlenmesi()
	_ayarlari_uygula()
	menu.gizle()
	arayuz.visible = true
	arayuz.oyun_basladi()
	arayuz.bitis_gizle()
	if kampanya:
		# Kampanya: sıradaki dalganın bir önceki dalgasından başla; savaş başına 1 kart, taret için altın
		var n: int = int(profil.veri["kampanya"]["en_yuksek"]) if kampanya_tekrar else profil.kampanya_dalgasi()
		dalga = n - 1
		_oto_izin = n <= int(profil.veri["kampanya"]["en_yuksek"])
		oto = _oto_izin and bool(profil.ayar("oto"))
		arayuz.oto_goster(_oto_izin, oto)
		altin += 30 + 6 * n
		_arayuz_guncelle()
		_kart_sec()
		return
	_oto_izin = false
	oto = false
	arayuz.oto_goster(false, false)
	if bool(st["acilis_karti"]):
		_arayuz_guncelle()
		_kart_sec()  # Laboratuvar: Sert Açılış
		return
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
	_yazilar.temizle()
	boss = null
	_bekleyen_cagri = 0
	_uzman_yuva = -1
	arayuz.boss_gizle()
	Engine.time_scale = 1.0


func _sonraki_dalga() -> void:
	dalga += 1
	durum = Durum.OYUN
	profil.gorev_ulas("dalga", dalga)
	_dogacak.clear()
	if _kese_gelir > 0:
		altin += _kese_gelir
	var boss_dalgasi := boss_dalgasi_mi(dalga)
	var boss_turu := _boss_turu(dalga)  # Dev ve Kraliçe sırayla
	_yon_sifirla()
	var nefes := not kampanya and dalga % 5 == 1 and dalga > 5  # boss sonrası nefes dalgası
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
		_dogacak.insert(mini(3, _dogacak.size()), boss_turu)
	_dogum_aralik = maxf(1.25 - dalga * 0.06, 0.35)
	_dogum_sayac = 1.5
	var afis := ("KAMPANYA · DALGA %d" if kampanya else "DALGA %d") % dalga
	if kampanya_tekrar:
		afis += " (TEKRAR)"
	if boss_dalgasi:
		afis += "\nBOSS: %s!\nYOĞUN SALDIRI!" % _tur_adi(boss_turu)
	elif nefes:
		afis += "\nNefes al"
	arayuz.dalga_afisi(afis)
	ses("boss" if boss_dalgasi else "dalga")
	_yeni_turleri_tanit()
	_ogret()
	_arayuz_guncelle()


## Hayatta Kalma'da her 5. dalga boss; kampanyada her 10. (Grow Castle). Dev ve Kraliçe sırayla gelir.
func boss_dalgasi_mi(d: int) -> bool:
	return d % (Veri.KAMPANYA_BOSS if kampanya else 5) == 0


func _boss_turu(d: int) -> String:
	var aralik: int = Veri.KAMPANYA_BOSS if kampanya else 5
	return "kralice" if (d / aralik) % 2 == 0 else "dev"


## Dalganın zombi türleri. Türler sırayla açılır; oranlar dalgayla artar, sınırlıdır.
func _dalga_bilesimi(adet: int) -> Array[String]:
	var o := tur_oranlari(dalga)
	var kosucu_orani: float = o["kosucu"]
	var zirhli_orani: float = o["zirhli"]
	var kusan_orani: float = o["kusan"]
	var patlayan_orani: float = o["patlayan"]
	var liste: Array[String] = []
	# yeni tür çıktığı dalgada kesin görünsün
	if dalga == 4:
		liste.append("zirhli")
		liste.append("zirhli")
	elif dalga == 6:
		liste.append("kusan")
		liste.append("kusan")
	elif dalga == 8:
		liste.append("patlayan")
		liste.append("patlayan")
	for i in maxi(adet - liste.size(), 0):
		var r := randf()
		if r < kosucu_orani:
			liste.append("kosucu")
		elif r < kosucu_orani + zirhli_orani:
			liste.append("zirhli")
		elif r < kosucu_orani + zirhli_orani + kusan_orani:
			liste.append("kusan")
		elif r < kosucu_orani + zirhli_orani + kusan_orani + patlayan_orani:
			liste.append("patlayan")
		else:
			liste.append("yuruyen")
	return liste


## d. dalgada türlerin beklenen oranı (dalga bileşimi ve A6 akıllı kart aynı formülü kullanır).
func tur_oranlari(d: int) -> Dictionary:
	return {
		"kosucu": 0.0 if d < 3 else minf(0.15 + d * 0.03, 0.45),
		"zirhli": 0.0 if d < 4 else minf(0.1 + (d - 4) * 0.015, 0.25),
		"kusan": 0.0 if d < 6 else minf(0.08 + (d - 6) * 0.01, 0.16),
		"patlayan": 0.0 if d < 8 else minf(0.06 + (d - 8) * 0.01, 0.14),
	}


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
	return {"yuruyen": "YÜRÜYEN", "kosucu": "KOŞUCU", "zirhli": "ZIRHLI", "kusan": "KUSAN", "patlayan": "PATLAYAN",
		"dev": "DEV", "kralice": "KRALİÇE"}.get(t, t)


## İlk koşularda her şeyi bir anda değil, gerektiği dalgada anlatır.
func _ogret() -> void:
	if int(profil.veri["istatistik"]["kosu"]) >= 3:
		return
	match dalga:
		1: arayuz.ipucu_goster("Parmağını sağa sola kaydır.\nAsker en tehlikeli zombiye kendisi ateş eder.")
		2: arayuz.ipucu_goster("Sol alttaki yetenek düğmesini kalabalığa sakla.\nBarikat yaralanınca altınla ONAR.")
		3: arayuz.ipucu_goster("Altın 60 olunca barikatta TARET düğmesi çıkar.\nAltını onarım mı taret mi, sen seç.")


## Zombi canı: 15. dalgaya dek doğrusal, sonra karesel, 25. dalgadan sonra üstel (tam evrimli yapı da bir yerde düşsün).
func can_carpani() -> float:
	if kampanya:
		# Kampanya tek dalga + tek kartla oynanır; güç Sur, Güç seviyesi ve ekipten gelir: daha yumuşak eğri
		var k := float(dalga - 1)
		return 1.0 + 0.09 * k + 0.002 * k * k
	var gec := maxf(float(dalga - 15), 0.0)
	return (1.0 + 0.12 * (dalga - 1) + 0.03 * gec * gec) * pow(1.08, maxf(float(dalga - 25), 0.0))


## Oyun hızı x1 → x2 → x3 (Grow Castle tarzı). Seçim kaydedilir, sonraki koşularda da geçerli olur.
## x3 kilidi (B7): kampanyada 10. dalgayı geç ya da Hayatta Kalma'da 10. dalgaya ulaş.
func _hiz_ust() -> int:
	return 3 if bool(profil.veri["x3_acik"]) else 2


func _hiz_degistir() -> void:
	oyun_hizi = oyun_hizi % _hiz_ust() + 1
	if oyun_hizi == 1 and _hiz_ust() == 2 and int(profil.ayar("hiz")) == 2:
		arayuz.uyari_goster("x3 hız: Kampanyada %d. dalgayı geçince açılır" % Veri.HIZ3_DALGA)
	profil.ayar_degistir("hiz", oyun_hizi)
	arayuz.hiz_goster(oyun_hizi)
	if durum == Durum.OYUN or durum == Durum.KART:
		Engine.time_scale = float(oyun_hizi)


func _duraklat(acik: bool) -> void:
	if (durum != Durum.OYUN and acik) or _uzman_yuva >= 0:
		return
	get_tree().paused = acik
	arayuz.duraklat_goster(acik)


func _menuye_don() -> void:
	get_tree().paused = false
	if (durum == Durum.OYUN or durum == Durum.KART) and not _kosu_odullendi and not kampanya:
		_kosu_odullendi = true
		profil.kosu_bitti(dalga, oldurme, _boss_olduruldu, false, _katki)
	_temizle()
	arayuz.kart_kapat()
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
	if kampanya:
		_kampanya_sonu(false)
		return
	if not _kosu_odullendi:
		_kosu_odullendi = true
		ozet = profil.kosu_bitti(dalga, oldurme, _boss_olduruldu, true, _katki)
		_olum_ozeti(ozet)
	_son_ozet = ozet
	ses("bitis")
	_titret(250)
	_sarsinti = 14.0
	arayuz.boss_gizle()
	Engine.time_scale = 1.0
	arayuz.bitis_goster(dalga, oldurme, int(profil.veri["rekor"]), dalga > eski_rekor, ozet)
	_arayuz_guncelle()


## Kampanya dalgası temizlendi: zafer ekranı, ödül, sıradaki dalga açılır.
func _kampanya_zafer() -> void:
	durum = Durum.BITTI
	_kampanya_sonu(true)


func _kampanya_sonu(kazandi: bool) -> void:
	durum = Durum.BITTI
	var ozet: Dictionary = {}
	if not _kosu_odullendi:
		_kosu_odullendi = true
		ozet = profil.kampanya_bitti(kazandi, dalga, oldurme, _boss_olduruldu, _katki,
			barikat.can / barikat.max_can, kampanya_tekrar)
		if not kazandi:
			_olum_ozeti(ozet)
	_son_ozet = ozet
	ses("evrim" if kazandi else "bitis")
	_titret(120 if kazandi else 250)
	if not kazandi:
		_sarsinti = 14.0
	arayuz.boss_gizle()
	Engine.time_scale = 1.0
	arayuz.kampanya_sonu_goster(kazandi, dalga, oldurme, profil.kampanya_dalgasi(), ozet)
	if kampanya_tekrar:
		arayuz.tekrar_metni("TEKRAR")
	_yukselt_paneli()
	_arayuz_guncelle()


## Kampanya v2: sonuç ekranında Sur ve lider Güç seviyesini hemen yükseltme düğmeleri.
func _yukselt_paneli() -> void:
	var sv: int = profil.sur_sv()
	var h: Dictionary = profil.aktif_kahraman()
	var g := int(h.get("guc", 0))
	var sur_metin := "SUR en üstte" if sv >= Veri.SUR_MAX else "SUR %d→%d\n%d hurda" % [sv, sv + 1, Veri.sur_fiyat(sv)]
	var guc_metin := "GÜÇ en üstte" if g >= Veri.GUC_MAX else "%s GÜÇ %d→%d\n%d altın" % [String(h["ad"]), g, g + 1, Veri.guc_fiyat(g)]
	arayuz.yukselt_guncelle(sur_metin, sv < Veri.SUR_MAX and profil.hurda() >= Veri.sur_fiyat(sv),
		guc_metin, g < Veri.GUC_MAX and profil.altin() >= Veri.guc_fiyat(g),
		"Kasa: %d hurda · %d altın · Toplam ★ %d" % [profil.hurda(), profil.altin(), profil.toplam_yildiz()])


func _hizli_yukselt(tur: String) -> void:
	if durum != Durum.BITTI or not kampanya:
		return
	var neden: String = profil.sur_yukselt() if tur == "sur" else profil.guc_yukselt(String(profil.veri["aktif"]))
	if neden == "":
		ses("kule")
		_titret(40)
	_yukselt_paneli()


## Barikatı en çok yiyen tür ve öneri + sıradaki kalıcı hedef (koşu sonu v2).
func _olum_ozeti(ozet: Dictionary) -> void:
	var toplam := 0.0
	var en := ""
	for t in _hasar_kaynak:
		toplam += float(_hasar_kaynak[t])
		if en == "" or float(_hasar_kaynak[t]) > float(_hasar_kaynak[en]):
			en = t
	if en != "":
		ozet["neden"] = "Barikatın %%%d canını %s yedi. %s" % [int(round(float(_hasar_kaynak[en]) / toplam * 100.0)),
			_tur_adi(en), OLUM_IPUCU.get(en, "")]
	var lab: Dictionary = profil.lab_sonraki()
	if not lab.is_empty():
		var eksik: int = int(lab["fiyat"]) - profil.hurda()
		ozet["hedef"] = "Laboratuvar: %s hazır!" % lab["ad"] if eksik <= 0 else "Laboratuvar: %s için %d hurda kaldı" % [lab["ad"], eksik]


func _konusma(secim: String) -> void:
	if _son_ozet.is_empty() or _son_ozet.has("konusuldu"):
		return
	_son_ozet["konusuldu"] = true
	var s: Dictionary = profil.konusma_yap(String(_son_ozet["uid"]), secim, int(_son_ozet["performans"]))
	if s.is_empty():
		return
	var m := int(s["moral"])
	var metin := String(s["metin"])
	if m != 0:
		metin += "  (Moral %s%d)" % ["+" if m > 0 else "", m]
	arayuz.konusma_sonuc(metin, Color(0.6, 1, 0.5) if m > 0 else (Color(1, 0.55, 0.45) if m < 0 else Color(0.85, 0.85, 0.8)))


# ================================================================ ZOMBİLER

func _zombi_dogur(tur: String):
	var z
	if _zombi_havuzu.is_empty():
		z = Node2D.new()
		z.set_script(ZombiBetik)
		_zombi_katmani.add_child(z)
	else:
		z = _zombi_havuzu.pop_back()
	if tur == "dev" or tur == "kralice":
		# her boss bir öncekinden güçlü; ilk Dev bilerek kolay. Dev 5, 15, 25…; Kraliçe 10, 20, 30…
		var sira := maxi(int(dalga / float(Veri.KAMPANYA_BOSS if kampanya else 5)), 1)
		z.kur(self, tur, can_carpani() * (1.0 + 0.6 * (sira - 1)), 1.0 + 0.35 * (sira - 1))
		z.position = Vector2(genislik / 2.0, -80.0)
		boss = z
		arayuz.boss_goster(boss_adi(), 1.0)
	else:
		z.kur(self, tur, can_carpani(), 1.0 + dalga * 0.02)
		z.position = Vector2(randf_range(70.0, genislik - 70.0), randf_range(-60.0, -20.0))
	zombiler.append(z)
	_gorulen_tur[tur] = int(_gorulen_tur.get(tur, 0)) + 1
	return z


func boss_adi() -> String:
	return "KRALİÇE" if boss != null and boss.tur == "kralice" else "DEV"


func _zombi_havuza(z) -> void:
	z.olu = true
	z.visible = false
	z.set_process(false)
	if not _zombi_havuzu.has(z):
		_zombi_havuzu.append(z)


func zombi_oldu(z) -> void:
	oldurme += 1
	_olu_var = true
	profil.gorev_ilerlet("oldur")
	if z.tur == "zirhli" or z.tur == "kusan" or z.tur == "patlayan":
		profil.gorev_ilerlet(z.tur)
	var kazanc := int(round(z.altin_degeri * float(st["altin_carpan"])))
	altin += kazanc
	_leke_birak(z.position)
	_parcacik("kan_buyuk", z.position)
	if bool(st["yanma_yayilim"]) and z._yakilmis:
		_yanma_yay(z)
	if z.boss:
		_boss_oldu(z)
	if z.tur == "patlayan":
		_patlayan_infilak(z.position)
	_yazi(z.position + Vector2(0, -20), "+%d" % kazanc, Color(1, 0.85, 0.3), 26, true)
	ses("olum")
	var tw: Tween = z.create_tween()
	tw.tween_property(z, "scale", Vector2(1.3, 0.2), 0.18)
	tw.parallel().tween_property(z, "modulate:a", 0.0, 0.18)
	tw.tween_callback(_zombi_havuza.bind(z))
	z.set_meta("tw", tw)
	_arayuz_guncelle()


## saldiran: yakın dövüşte vuran zombi (Dikenli Tel için); asitte null.
func barikat_vuruldu(miktar: float, x: float, saldiran = null, kaynak: String = "") -> void:
	if durum != Durum.OYUN:
		return
	if saldiran != null:
		kaynak = saldiran.tur
	if kaynak == "kusan" or kaynak == "patlayan":
		miktar *= 1.0 - float(st["direnc"])
	_hasar_kaynak[kaynak] = float(_hasar_kaynak.get(kaynak, 0.0)) + miktar
	_yon_hasar = minf(_yon_hasar + miktar / barikat.max_can * YON_HASAR_KATSAYI, 100.0)
	if kaynak == "dev" or kaynak == "kralice":
		# boss geniş vurur: hasar üç bölüme bölünür (tek bölümü bir vuruşta yıkmasın)
		var bw := genislik / 6.0
		for k in [-1, 0, 1]:
			barikat.hasar_al(miktar / 3.0, clampf(x + k * bw, 1.0, genislik - 1.0))
	else:
		barikat.hasar_al(miktar, x)
	if saldiran != null and float(st["diken"]) > 0.0:
		saldiran.vurul(float(st["diken"]))
	_sarsinti = minf(_sarsinti + (2.0 if kalite > 0 else 1.0), 8.0)
	_parcacik("kiymik", Vector2(x, barikat_y - 10))
	_titret(25)
	ses("barikat")
	_arayuz_guncelle()
	if barikat.can <= 0.0:
		if _ikinci_sans:
			_ikinci_sans_kullan()
		else:
			_oyun_bitti()


## A2: bir bölüm kırıldı. Oyuncuya yeri gösterilir; gerilim artar (yönetmen nefes aldırabilir).
func gedik_acildi(i: int) -> void:
	if durum != Durum.OYUN:
		return
	_yazi(Vector2(barikat.bolum_merkez(i), barikat_y - 70.0), "GEDİK!", Color(1, 0.3, 0.2), 34, true)
	_yon_hasar = minf(_yon_hasar + 15.0, 100.0)
	_titret(60)
	if kalite > 0:
		for k in 3:
			_parcacik("kiymik", Vector2(barikat.bolum_merkez(i) + randf_range(-40, 40), barikat_y - 10))


## Laboratuvar: barikat koşu başına bir kez %25 canla ayağa kalkar.
func _ikinci_sans_kullan() -> void:
	_ikinci_sans = false
	barikat.onar(IKINCI_SANS_CAN)
	arayuz.dalga_afisi("İKİNCİ ŞANS!")
	ses("evrim")
	_titret(150)
	_sarsinti = 12.0
	_arayuz_guncelle()


# ================================================================ BOSS VE ASİT

func boss_vurdu(z) -> void:
	barikat_vuruldu(z.hasar, z.position.x, null, "dev")
	_sarsinti = minf(_sarsinti + 10.0, 16.0)
	_titret(120)
	ses("barikat")
	for i in 3:
		_parcacik("kiymik", Vector2(z.position.x + randf_range(-90, 90), barikat_y - 10))


func boss_cagirdi(z) -> void:
	_bekleyen_cagri += 2 + int(dalga / 5.0) * 2
	_cagri_konum = z.position
	ses("boss")
	_yazi(z.position + Vector2(0, -100), "YARDIM ÇAĞIRDI!", Color(1, 0.4, 0.3), 40, true)


## A4: boss aşama değişimi oyuncuya duyurulur.
func boss_asama(z, asama: int) -> void:
	var metin := ""
	if z.kralice:
		metin = "KRALİÇE HIZLANDI!" if asama == 1 else "KRALİÇE SALDIRIYA GEÇTİ!"
	else:
		metin = "DEV ÖFKELENDİ!" if asama == 1 else "DEV SIÇRIYOR!"
	arayuz.uyari_goster(metin)  # üst şerit: boss üstündeki "YARDIM ÇAĞIRDI" yazısıyla çakışmasın
	ses("boss")
	_titret(80)
	_sarsinti = minf(_sarsinti + 6.0, 14.0)


## Dev sıçrayıp indi: yer sarsılır, barikata yakın indiyse yarım vuruş hasarı.
func boss_sicradi(z) -> void:
	_sarsinti = minf(_sarsinti + 12.0, 16.0)
	_titret(120)
	ses("bomba")
	_parcacik("patlama", z.position + Vector2(0, 40))
	if z.position.y >= z._durus_y - 1.0:
		barikat_vuruldu(z.hasar * 0.6, z.position.x, null, "dev")


## Kraliçe yavruları: hep 2 koşucu, Kraliçe'nin dibinde (doğum _process'te, güvenli anda).
func kralice_dogurdu(z) -> void:
	_bekleyen_cagri += 2
	_cagri_konum = z.position
	if kalite > 0:
		_parcacik("asit", z.position + Vector2(0, 40))


## Çağrılan koşucular Dev'in yanında doğar (mermi döngüsü dışında, güvenli anda).
func _cagri_dogur() -> void:
	while _bekleyen_cagri > 0:
		_bekleyen_cagri -= 1
		var z = _zombi_dogur("kosucu")
		z.position = _cagri_konum + Vector2(randf_range(-110, 110), randf_range(-40, 40))
		z.position.x = clampf(z.position.x, 40.0, genislik - 40.0)


func _boss_oldu(z) -> void:
	boss = null
	if z.tur == "kralice":
		_bekleyen_cagri = 0  # ölen kraliçenin sıradaki yavruları doğmaz
	_boss_olduruldu += 1
	profil.gorev_ilerlet("boss")
	arayuz.boss_gizle()
	arayuz.dalga_afisi("%s DÜŞTÜ!\nGARANTİ GANİMET" % ("KRALİÇE" if z.tur == "kralice" else "DEV"))
	ses("bitis")
	_titret(200)
	_sarsinti = 16.0
	for i in 5:
		_parcacik("kan_buyuk", z.position + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	# kısa ağır çekim: büyük an hissedilsin
	Engine.time_scale = 0.35 * oyun_hizi
	get_tree().create_timer(0.5, true, false, true).timeout.connect(func() -> void:
		Engine.time_scale = float(oyun_hizi) if (durum == Durum.OYUN or durum == Durum.KART) else 1.0)


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
	barikat_vuruldu(hasar, konum.x, null, "kusan")


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

func _mermi_al():
	if _mermi_havuzu.is_empty():
		var m = Node2D.new()
		m.set_script(MermiBetik)
		m.oyun = self
		_mermi_katmani.add_child(m)
		return m
	return _mermi_havuzu.pop_back()


func mermi_at(konum: Vector2, yon: Vector2, hedef = null) -> void:
	var m = _mermi_al()
	var kritik := _nisan_kalan > 0.0 or randf() < float(st["kritik"])
	var h := float(st["hasar"]) * (float(st["kritik_carpan"]) if kritik else 1.0)
	m.baslat(konum, yon, float(st["mermi_hizi"]), h, kritik, int(st["delme"]))
	m.kaynak = 0
	_ayir(m, hedef, h)


## Ekip yapay zekâsı — aşırı öldürme önleme: atılan mermi hedefine "beklenen hasar" yazar. Beklenen hasar
## kalan canı karşılıyorsa diğer atıcılar o zombiyi bırakıp başkasını seçer (mermi boşa gitmez).
func _ayir(m, hedef, hasar: float) -> void:
	if hedef == null or hedef.olu:
		return
	var tahmin := maxf(hasar - float(hedef.zirh), hasar * 0.2)
	hedef.beklenen += tahmin
	m.hedef = hedef
	m.ayrilan = tahmin


func ayrimi_birak(m) -> void:
	if m.hedef != null:
		m.hedef.beklenen = maxf(m.hedef.beklenen - m.ayrilan, 0.0)
		m.hedef = null
		m.ayrilan = 0.0


## Barikata en tehlikeli, menzildeki hedef (kahraman ve taretler ortak kullanır).
func hedef_bul(konum: Vector2, menzil: float):
	var en_iyi = null
	var en_iyi_puan := -INF
	var menzil_kare := menzil * menzil
	for z in zombiler:
		if z.olu or z.position.y < -10.0:
			continue
		if konum.distance_squared_to(z.position) > menzil_kare:
			continue
		var puan: float = z.position.y + z.oncelik
		if z.beklenen >= z.can:
			puan -= 100000.0  # zaten ölecek: başka hedef varsa onu seç
		if puan > en_iyi_puan:
			en_iyi_puan = puan
			en_iyi = z
	return en_iyi


func kule_atesi(konum: Vector2, yon: Vector2, hasar: float, delme: int = 0, zirh_gec: bool = false, hedef = null) -> void:
	var m = _mermi_al()
	m.baslat(konum, yon, 1200.0, hasar, false, delme, zirh_gec)
	m.kaynak = -2
	_ayir(m, hedef, hasar)


# ================================================================ SURDAKİ EKİP + EKİP YAPAY ZEKÂSI

func _nobetcileri_kur() -> void:
	var liste: Array = profil.nobetci_listesi()
	for i in nobetciler.size():
		if i < liste.size():
			nobetciler[i].kur(profil.nobetci_istatistigi(liste[i]))
			_katki[i + 1] = {"hasar": 0.0, "oldurme": 0}
		else:
			nobetciler[i].sifirla()


## Nöbetçiler kart almaz ama taretler gibi dalgayla güçlenir; geç oyunda da işe yarasınlar.
func nobetci_carpani() -> float:
	return 1.0 + Veri.NOBETCI_DALGA * dalga


func nobetci_atesi(konum: Vector2, yon: Vector2, hasar: float, kritik: bool, delme: int, kaynak: int, hedef) -> void:
	var m = _mermi_al()
	m.baslat(konum, yon, 1150.0, hasar, kritik, delme)
	m.kaynak = kaynak
	_ayir(m, hedef, hasar)


func ekip_onarimi(oran: float) -> void:
	if barikat.can < barikat.max_can:
		barikat.onar(oran)


## Ekip yapay zekâsı hedef seçimi. mod: rol / yakin / guclu / boss. "rol" modunda Avcı en değerli hedefi
## (boss, zırhlı, kusan, patlayan) avlar, diğer roller barikata en yakını vurur. Beklenen hasarı kalan
## canını karşılayan zombi ancak başka aday yoksa seçilir.
func ekip_hedef_sec(konum: Vector2, menzil: float, mod: String, rol: String):
	if mod == "rol":
		mod = "avci" if rol == "avci" else "yakin"
	var en_iyi = null
	var en_iyi_puan := -INF
	var mk := menzil * menzil
	for z in zombiler:
		if z.olu or z.position.y < -10.0 or konum.distance_squared_to(z.position) > mk:
			continue
		var puan: float
		match mod:
			"guclu":
				puan = z.can + z.zirh * 25.0 + (5000.0 if z.boss else 0.0)
			"boss":
				puan = (100000.0 if z.boss else 0.0) + z.position.y + z.oncelik
			"avci":
				puan = z.position.y * 0.3 + z.oncelik + (3000.0 if z.boss else 0.0) + (800.0 if z.zirh > 0.0 else 0.0) \
					+ (900.0 if z.tur == "kusan" else 0.0) + (600.0 if z.tur == "patlayan" else 0.0)
			_:
				puan = z.position.y + z.oncelik
		if z.beklenen >= z.can:
			puan -= 1000000.0
		if puan > en_iyi_puan:
			en_iyi_puan = puan
			en_iyi = z
	return en_iyi


func _katki_ekle(kaynak: int, hasar: float, oldu: bool) -> void:
	if not _katki.has(kaynak):
		_katki[kaynak] = {"hasar": 0.0, "oldurme": 0}
	var k: Dictionary = _katki[kaynak]
	k["hasar"] = float(k["hasar"]) + hasar
	if oldu:
		k["oldurme"] = int(k["oldurme"]) + 1


# ================================================================ SÜRÜ (A3)

## Hafif boids: ızgara (bağlı liste, her güncellemede yeni dizi yok) ile yalnızca komşu hücrelere bakılır,
## O(n). Ayrılma: üst üste binen zombiler birbirini iter (kalabalık okunur). Kalkan: koşucu önündeki
## zırhlının arkasına geçer, onun hızında yürür (lider önce zırhlıyı vurur). Saniyede 10 kez (Düşük: 5).
func _suru_isle(delta: float) -> void:
	_suru_sayac -= delta
	if _suru_sayac > 0.0:
		return
	_suru_sayac = SURU_ARA[kalite]
	var n := zombiler.size()
	if n == 0:
		return
	_izgara_sutun = int(ceil(genislik / SURU_HUCRE)) + 1
	_izgara_satir = int(ceil((yukseklik + 240.0) / SURU_HUCRE)) + 1
	var hucre_sayisi := _izgara_sutun * _izgara_satir
	if _izgara_bas.size() != hucre_sayisi:
		_izgara_bas.resize(hucre_sayisi)
	_izgara_bas.fill(-1)
	if _izgara_sonraki.size() < n:
		_izgara_sonraki.resize(n)
	for i in n:
		var z = zombiler[i]
		if z.olu:
			continue
		var c := _hucre(z.position)
		_izgara_sonraki[i] = _izgara_bas[c]
		_izgara_bas[c] = i
	for i in n:
		var z = zombiler[i]
		if z.olu:
			continue
		var itme := Vector2.ZERO
		var kalkan_aday = null
		var kosucu: bool = z.tur == "kosucu" and z.kalkan == null and z.position.y > 0.0
		var cx := clampi(int(z.position.x / SURU_HUCRE), 0, _izgara_sutun - 1)
		var cy := clampi(int((z.position.y + 240.0) / SURU_HUCRE), 0, _izgara_satir - 1)
		for dy in range(-1, 3 if kosucu else 2):  # koşucu önündeki (aşağıdaki) zırhlıyı da arar
			var yy := cy + dy
			if yy < 0 or yy >= _izgara_satir:
				continue
			for dx in range(-1, 2):
				var xx := cx + dx
				if xx < 0 or xx >= _izgara_sutun:
					continue
				var j := _izgara_bas[yy * _izgara_sutun + xx]
				while j >= 0:
					if j != i:
						var o = zombiler[j]
						var fark: Vector2 = z.position - o.position
						var en_az: float = (z.yaricap + o.yaricap) * 0.8
						var d2 := fark.length_squared()
						if d2 < en_az * en_az and d2 > 0.01:
							var d := sqrt(d2)
							itme += fark / d * (en_az - d) / en_az
						if kosucu and kalkan_aday == null and o.tur == "zirhli" and not o.olu \
								and absf(fark.x) < SURU_KALKAN_MESAFE.x and -fark.y > 20.0 and -fark.y < SURU_KALKAN_MESAFE.y:
							kalkan_aday = o
					j = _izgara_sonraki[j]
		if z.boss:
			z.itme = Vector2.ZERO  # boss itilmez, ama başkalarını iter
		else:
			z.itme = (itme * SURU_GUC).limit_length(SURU_ITME_MAX)
		if kalkan_aday != null:
			z.kalkan = kalkan_aday


func _hucre(p: Vector2) -> int:
	var cx := clampi(int(p.x / SURU_HUCRE), 0, _izgara_sutun - 1)
	var cy := clampi(int((p.y + 240.0) / SURU_HUCRE), 0, _izgara_satir - 1)
	return cy * _izgara_sutun + cx


# ================================================================ YÖNETMEN (A1)

func _yon_sifirla() -> void:
	_yon_evre = Evre.YUKSELME
	_yon_sayac = 0.0
	_yon_sakin = 0.0
	_yon_kanat = false
	_yon_mola = 0.0


func gerilim() -> float:
	return minf(_yon_hasar + _yon_ekran, 100.0)


## Gerilim = son barikat hasarı (zamanla söner) + ekrandaki tehdit (zombilerin canı × barikata yakınlığı²).
func _yonetmen(delta: float) -> void:
	_yon_hasar = maxf(_yon_hasar - YON_SONUM * delta, 0.0)
	_yon_olcum -= delta
	if _yon_olcum <= 0.0:
		_yon_olcum = 0.25  # her kare değil, saniyede 4 kez ölç
		var agirlik := 0.0
		var cc := can_carpani() * 30.0
		for z in zombiler:
			if z.olu:
				continue
			var yakinlik := clampf(z.position.y / barikat_y, 0.0, 1.0)
			agirlik += minf(z.max_can / cc, 6.0) * yakinlik * yakinlik
		_yon_ekran = minf(agirlik * 4.0, 100.0)
	var g := gerilim()
	match _yon_evre:
		Evre.YUKSELME:
			if g >= YON_ZIRVE and _yon_mola < YON_MOLA_SINIRI:
				_yon_gec(Evre.ZIRVE, randf_range(3.0, 5.0))
			elif g < YON_KANAT and not _dogacak.is_empty():
				_yon_sakin += delta
				if _yon_sakin >= 4.0 and not _yon_kanat and dalga >= 4 and _dogacak.size() >= 3:
					_kanat_surprizi()
			else:
				_yon_sakin = 0.0
		Evre.ZIRVE:
			_yon_sayac -= delta
			if _yon_sayac <= 0.0:
				_yon_gec(Evre.SONME, 6.0)
		Evre.SONME:
			_yon_sayac -= delta
			_yon_mola += delta
			if g < YON_SONME_BITIS or _yon_sayac <= 0.0:
				_yon_gec(Evre.NEFES, randf_range(4.0, 8.0))
		Evre.NEFES:
			_yon_sayac -= delta
			_yon_mola += delta
			if _yon_sayac <= 0.0 or _yon_mola >= YON_MOLA_SINIRI:
				_yon_gec(Evre.YUKSELME, 0.0)


func _yon_gec(e: Evre, sure: float) -> void:
	_yon_evre = e
	_yon_sayac = sure
	_yon_sakin = 0.0
	if _yon_gunluk:
		print("YONETMEN dalga=%d evre=%s gerilim=%.0f" % [dalga, Evre.keys()[e], gerilim()])


## Zirvede doğum normal, sönme ve nefeste durur (sahadakiler devam eder), çok sakinse %30 hızlanır.
func _yon_dogum_carpani() -> float:
	match _yon_evre:
		Evre.SONME, Evre.NEFES:
			return 0.0
		Evre.YUKSELME:
			return 1.3 if gerilim() < YON_DUSUK else 1.0
	return 1.0


## Oyuncu çok rahatsa sıradaki 3–4 zombi (önce koşucular) askerin uzak tarafındaki kanattan birlikte gelir.
## Yeni zombi eklenmez: dalganın doğacaklar listesinden alınır.
func _kanat_surprizi() -> void:
	_yon_kanat = true
	var secilen: Array[String] = []
	for t in ["kosucu", "yuruyen", "zirhli", "patlayan"]:
		while secilen.size() < 4 and _dogacak.has(t):
			_dogacak.erase(t)
			secilen.append(t)
	if secilen.is_empty():
		return
	var sag: bool = kahraman.position.x < genislik / 2.0
	var x := genislik - 90.0 if sag else 90.0
	for i in secilen.size():
		var z = _zombi_dogur(secilen[i])
		z.position = Vector2(x + randf_range(-30.0, 30.0), -30.0 - i * 45.0)
	arayuz.uyari_goster("%s KANATTAN GELİYORLAR!" % ("SAĞ" if sag else "SOL"))
	ses("dalga")
	if _yon_gunluk:
		print("YONETMEN kanat surprizi: %s" % str(secilen))


func kule_al(i: int) -> void:
	var ku = kuleler[i]
	var fiyat: int = ku.fiyat()
	if durum != Durum.OYUN or fiyat <= 0 or altin < fiyat or _uzman_yuva >= 0:
		return
	if ku.uzmanlik_sirasi():
		_uzman_ac(i)
		return
	altin -= fiyat
	ku.yukselt()
	profil.gorev_ilerlet("kule")
	ses("kule")
	_yazi(ku.position + Vector2(0, -40), "TARET Sv %d" % ku.seviye, Color(1, 0.85, 0.4), 28, true)
	_arayuz_guncelle()


## Uzmanlık kararı: oyun duraklar (dalga ortasında acele karar olmasın), kart ekranı kullanılır.
func _uzman_ac(i: int) -> void:
	_uzman_yuva = i
	get_tree().paused = true
	var secenekler: Array[Dictionary] = [
		{"id": "havan", "ad": "HAVAN", "aciklama": "2.6 sn'de bir alan patlaması. Zırhı aşar, kalabalığı biçer.", "max": 9999, "renk": Color("ffa040")},
		{"id": "agir", "ad": "AĞIR TARET", "aciklama": "Tek hedefe 2.4 kat güç, zırhı yok sayar, 1 delme. Dev ve zırhlı avcısı.", "max": 9999, "renk": Color("7fb2d9")},
	]
	arayuz.uzman_goster(secenekler, kuleler[i].fiyat())
	_arayuz_guncelle()  # taret düğmeleri seçim ekranının üstünde kalmasın


func _uzman_kapat() -> void:
	_uzman_yuva = -1
	get_tree().paused = false
	arayuz.kart_kapat()
	_arayuz_guncelle()


func _uzman_sec(id: String) -> void:
	var ku = kuleler[_uzman_yuva]
	altin -= ku.fiyat()
	ku.uzmanlas(id)
	profil.gorev_ilerlet("kule")
	ses("evrim")
	_yazi(ku.position + Vector2(0, -40), "HAVAN" if id == "havan" else "AĞIR TARET", Color(1, 0.85, 0.4), 30, true)
	_uzman_kapat()


func havan_dustu(konum: Vector2, yaricap: float, hasar: float) -> void:
	_patla_efekt(konum, yaricap)
	_parcacik("patlama", konum)
	ses("bomba")
	_alan_hasari(konum, yaricap, hasar, -2)


# ================================================================ PATLAMALAR

func _patla_efekt(konum: Vector2, yaricap: float) -> void:
	_patlamalar[_patlama_sira].patla(konum, yaricap)
	_patlama_sira = (_patlama_sira + 1) % _patlamalar.size()


## Alan hasarı zırhı yok sayar. Zincirleme ölümler güvenli: dizi burada değişmez, ölenler kare sonunda çıkar.
func _alan_hasari(konum: Vector2, yaricap: float, hasar: float, kaynak: int = -1) -> void:
	var yk := yaricap * yaricap
	for z in zombiler:
		if z.olu or z.position.distance_squared_to(konum) > yk:
			continue
		_yazi(z.position + Vector2(0, -24), str(int(round(hasar))), Color(1, 0.7, 0.3), 30, false)
		var once: float = z.can
		z.vurul(hasar)
		if kaynak != -1:
			_katki_ekle(kaynak, minf(hasar, maxf(once, 0.0)), z.olu)
	if boss != null:
		arayuz.boss_goster(boss_adi(), boss.can / boss.max_can)


## Patlayan yolda vurulunca çevresini yakar: oyuncunun lehine "güzel an".
func _patlayan_infilak(konum: Vector2) -> void:
	_patla_efekt(konum, PATLAMA_YARICAP)
	_parcacik("patlama", konum)
	ses("bomba")
	_sarsinti = minf(_sarsinti + 5.0, 12.0)
	_titret(40)
	_alan_hasari(konum, PATLAMA_YARICAP, PATLAMA_HASAR * can_carpani())


## Patlayan barikata ulaştı: büyük hasar, altın yok.
func patlayan_barikatta(z) -> void:
	_olu_var = true
	_patla_efekt(z.position, PATLAMA_YARICAP)
	_parcacik("patlama", z.position)
	ses("bomba")
	_sarsinti = minf(_sarsinti + 8.0, 14.0)
	var hasar: float = z.hasar
	var x: float = z.position.x
	_zombi_havuza(z)
	barikat_vuruldu(hasar, x, null, "patlayan")


# ================================================================ AKTİF YETENEK

func _aktif_isle(delta: float) -> void:
	if _aktif_bekleme > 0.0:
		_aktif_bekleme = maxf(_aktif_bekleme - delta, 0.0)
		arayuz.aktif_guncelle(_aktif_bekleme)
	_nisan_kalan = maxf(_nisan_kalan - delta, 0.0)
	if _asi_kalan > 0.0:
		_asi_kalan -= delta
		if _asi_kalan <= 0.0:
			zombi_hizi = 1.0


func aktif_kullan() -> void:
	if durum != Durum.OYUN or _aktif_bekleme > 0.0:
		return
	match String(st["rol"]):
		"asker":
			var h = hedef_bul(kahraman.position, 2000.0)
			if h == null:
				return  # hedef yoksa bekleme harcanmasın
			_bomba(h.position)
		"avci":
			_nisan_kalan = NISAN_SURE
			_yazi(kahraman.position + Vector2(0, -230), "ÖLÜMCÜL NİŞAN", Color(1, 0.6, 0.2), 34, true)
		"muhendis":
			barikat.onar(0.3)
			_yazi(Vector2(genislik / 2, barikat_y - 40), "ACİL ONARIM", Color(0.5, 1, 0.5), 36, true)
		"doktor":
			_asi_kalan = ASI_SURE
			zombi_hizi = 0.6
			_yazi(Vector2(genislik / 2, yukseklik * 0.4), "AŞI: ZOMBİLER YAVAŞ", Color(0.5, 1, 0.8), 36, true)
	_aktif_bekleme = _aktif_max
	arayuz.aktif_guncelle(_aktif_bekleme)
	profil.gorev_ilerlet("aktif")
	ses("bomba" if String(st["rol"]) == "asker" else "yetenek")
	_titret(60)
	_arayuz_guncelle()


## Alan hasarı zırhı yok sayar: zırhlı yığınlara karşı kurtarıcı an.
func _bomba(konum: Vector2) -> void:
	var hasar := float(st["hasar"]) * 8.0 + 25.0
	_patla_efekt(konum, BOMBA_YARICAP)
	_sarsinti = minf(_sarsinti + 8.0, 14.0)
	_alan_hasari(konum, BOMBA_YARICAP, hasar, 0)


func mermi_birak(m) -> void:
	ayrimi_birak(m)
	m.visible = false
	m.set_process(false)
	if not _mermi_havuzu.has(m):
		_mermi_havuzu.append(m)


func isabet(z, hasar: float, kritik: bool, konum: Vector2, zirh_gec: bool = false, kaynak: int = -1) -> void:
	# Zırh düz hasar keser: küçük mermi çok, büyük mermi az etkilenir. En az %20 hep geçer.
	var kalan_zirh := 0.0 if bool(st["zirh_yok"]) or zirh_gec else maxf(float(z.zirh) - float(st["zirh_delme"]), 0.0)
	var son := maxf(hasar - kalan_zirh, hasar * 0.2)
	var zirhta_kaldi: bool = son < hasar * 0.6
	var once: float = z.can
	z.vurul(son)
	if kaynak != -1:
		_katki_ekle(kaynak, minf(son, maxf(once, 0.0)), z.olu)
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
		arayuz.boss_goster(boss_adi(), z.can / z.max_can)


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
	var oneri := _akilli_kart()
	arayuz.kartlari_goster(_gosterilen_kartlar, kart_seviye, _cekme_fiyati(), altin, String(oneri.get("id", "")),
		String(oneri.get("neden", "")))
	if oto and not oneri.is_empty():
		# OTO: kartı yapay zekâ seçer; oyuncu öneriyi bir an görsün
		var secilecek := String(oneri["id"])
		var kartlar := _gosterilen_kartlar
		get_tree().create_timer(0.8, true, false, true).timeout.connect(func() -> void:
			if oto and durum == Durum.KART and _gosterilen_kartlar == kartlar and _uzman_yuva < 0:
				arayuz.kart_kapat()
				_kart_secildi(secilecek))


# ---------------------------------------------------------------- A6 akıllı kart seçimi
# Taban değer: genel güç sırası (hasar ve ateş hızı en değerli). Sonra duruma göre artı puan:
# gelecek dalganın zombi karışımı (zırhlı → Zırh Delici, kalabalık → Delme/Namlu), barikat canı,
# evrim yolu (eşi alınmış kartın değeri artar), kampanyada altın kartları değersiz (tek dalga).
const KART_TABAN := {"ates_hizi": 10.0, "hasar": 10.0, "namlu": 8.0, "kritik": 7.0, "delme": 5.0, "menzil": 4.0,
	"barikat": 6.0, "altin": 4.0, "yanma": 6.0, "zirh_delici": 3.0, "diken": 4.0, "tamirci": 5.0, "kese": 2.0, "tam_onarim": 1.0}


## En yüksek puanlı kart ve kısa gerekçesi: {"id", "neden"}. Kart yoksa boş sözlük.
func _akilli_kart() -> Dictionary:
	if _gosterilen_kartlar.is_empty():
		return {}
	var o := tur_oranlari(dalga + 1)
	# koşuda görülen karışım da hesaba katılır (yönetmen/boss çağrıları oranı değiştirir)
	var top := 0
	for t in _gorulen_tur:
		top += int(_gorulen_tur[t])
	if top >= 20:
		for t in o:
			o[t] = (float(o[t]) + float(_gorulen_tur.get(t, 0)) / top) * 0.5
	var can_orani: float = barikat.can / barikat.max_can
	var en := {}
	var en_puan := -INF
	for k in _gosterilen_kartlar:
		var id := String(k["id"])
		var neden := ""
		var p: float = 1000.0 if k.has("evrim") else float(KART_TABAN.get(id, 3.0))
		match id:
			"zirh_delici":
				p += 40.0 * float(o["zirhli"])
				if float(o["zirhli"]) >= 0.18:
					neden = "zırhlı çok"
			"delme", "namlu":
				p += 10.0 * float(o["kosucu"])
				if float(o["kosucu"]) >= 0.35:
					neden = "kalabalık"
			"barikat", "tamirci", "diken":
				p += 10.0 * (1.0 - can_orani)
			"tam_onarim":
				p += 22.0 * (1.0 - can_orani)
				if can_orani < 0.5:
					neden = "barikat zayıf"
			"yanma":
				if boss_dalgasi_mi(dalga + 1):
					p += 4.0
					neden = "boss geliyor"
			"altin", "kese":
				if kampanya:
					p *= 0.3
		for e in Kartlar.EVRIMLER:
			if kart_seviye.has(e["id"]):
				continue
			if e["ana"] == id:
				p += 2.0 + 3.0 * int(kart_seviye.get(e["es"], 0))
			elif e["es"] == id and int(kart_seviye.get(id, 0)) < int(e["es_sv"]):
				p += 3.0 * int(kart_seviye.get(e["ana"], 0))
				if int(kart_seviye.get(e["ana"], 0)) >= 2:
					neden = "evrim yolu"
		if p > en_puan:
			en_puan = p
			en = {"id": id, "neden": neden}
	return en


# ---------------------------------------------------------------- B4 otomatik savaş

func _oto_degistir() -> void:
	if not _oto_izin:
		return
	oto = not oto
	profil.ayar_degistir("oto", oto)
	arayuz.oto_goster(_oto_izin, oto)
	if oto and durum == Durum.KART and _uzman_yuva < 0:
		_kartlari_ac()


## Saniyede 5 karar: lider en tehlikeli zombinin hizasına gider, yetenek gerilim yüksekken ya da boss
## varken basılır, en zayıf bölüm %45'in altına inince onarılır, onarım parası ayrıldıktan sonra taret alınır.
func _oto_isle(delta: float) -> void:
	_oto_el = maxf(_oto_el - delta, 0.0)
	_oto_sayac -= delta
	if _oto_sayac > 0.0 or durum != Durum.OYUN:
		return
	_oto_sayac = 0.2
	if _oto_el <= 0.0:
		var h = hedef_bul(kahraman.position, 2000.0)
		kahraman.hedef_x = h.position.x if h != null else genislik / 2.0
	if barikat.bolum_orani(barikat.en_zayif()) < 0.45 or barikat.can < barikat.max_can * 0.6:
		_onar()
	if gerilim() > 55.0 or boss != null:
		aktif_kullan()
	for k in 3:
		var f: int = kuleler[k].fiyat()
		if f > 0 and altin >= f + onar_fiyati():
			kule_al(k)
			if _uzman_yuva >= 0:  # uzmanlık ekranı oyunu durdurur: OTO beklemeden seçer (orta havan)
				_uzman_sec("havan" if k == 1 else "agir")


## Yeniden çekme: altının ikinci harcama yeri (Archero/Brotato). Her kullanımda pahalanır.
func _cekme_fiyati() -> int:
	if _bedava_cekim > 0:
		return 0
	return 15 + _cekme_sayisi * 10


func _yeniden_cek() -> void:
	if _uzman_yuva >= 0:
		_uzman_kapat()  # uzmanlık ekranında bu düğme "Vazgeç"
		return
	var fiyat := _cekme_fiyati()
	if durum != Durum.KART or altin < fiyat:
		return
	if _bedava_cekim > 0:
		_bedava_cekim -= 1
	else:
		altin -= fiyat
		_cekme_sayisi += 1
	_gosterilen_kartlar = _kart_secenekleri()
	ses("altin")
	_kartlari_ac()
	_arayuz_guncelle()


func _kart_secildi(id: String) -> void:
	if _uzman_yuva >= 0:
		_uzman_sec(id)
		return
	if durum != Durum.KART:
		return
	kart_seviye[id] = int(kart_seviye.get(id, 0)) + 1
	_karti_uygula(id)
	if Kartlar.bul(id).is_empty() and id != "kese" and id != "tam_onarim":
		profil.gorev_ilerlet("evrim")
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
	var zayif: int = barikat.en_zayif()
	barikat.onar(float(st["onarim"]))
	ses("altin")
	_yazi(Vector2(barikat.bolum_merkez(zayif), barikat_y - 40), "ONARILDI", Color(0.5, 1, 0.5), 36, true)
	_arayuz_guncelle()


func _arayuz_guncelle() -> void:
	arayuz.guncelle(dalga, altin, oldurme, barikat.can / barikat.max_can, durum == Durum.OYUN, onar_fiyati())
	arayuz.kule_guncelle([kuleler[0].fiyat(), kuleler[1].fiyat(), kuleler[2].fiyat()], altin, durum == Durum.OYUN and _uzman_yuva < 0,
		[kuleler[0].uzmanlik_sirasi(), kuleler[1].uzmanlik_sirasi(), kuleler[2].uzmanlik_sirasi()])


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
			_parcaciklar.sinir = PARCACIK_SINIRI[kalite]
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
		_oto_el = 1.5


## Sürükleme _input'ta: taret düğmesinin üstünden başlayan sürükleme de askeri oynatır.
## En alttaki ONAR ve yetenek düğmelerinin hizası hariç.
func _input(event: InputEvent) -> void:
	if durum == Durum.OYUN and event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.position.y < yukseklik - 100.0:
			kahraman.hedef_x = d.position.x
			_oto_el = 1.5


# ================================================================ EFEKTLER (havuzlu)

func ses(ad: String) -> void:
	_sesler.cal(ad)


func _titret(ms: int) -> void:
	if not bool(profil.ayar("titresim")) or _titresim_sayac > 0.0:
		return
	_titresim_sayac = 0.08
	Input.vibrate_handheld(ms)


func _havuzlari_kur() -> void:
	pass  # Performans v4: hasar yazıları artık tek düğümde (yazilar.gd); Label havuzu kalmadı


func _parcacik(tur: String, konum: Vector2) -> void:
	if PARCACIK_ACIK[kalite]:
		_parcaciklar.yay(tur, konum)


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
	_yazilar.yaz(konum, metin, renk, boyut)


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
	# Surdaki ekip: iki kişi sura, biri "Boss önce" modunda; liderin formu dolu görünsün
	profil.nobetci_degistir(String(profil.veri["ekip"][1]["uid"]))
	profil.nobetci_degistir(String(profil.veri["ekip"][2]["uid"]))
	profil.veri["ekip"][2]["hedef_modu"] = "boss"
	profil.veri["ekip"][0]["puanlar"] = [6.4, 7.1, 7.8]
	profil.veri["kesif"]["aktif"] = {"bolge": 1, "bitis": int(Time.get_unix_time_from_system()) - 1}
	profil.kesif_kontrol()
	await _bekle(0.6)
	profil.veri["lab"] = {"l_hasar": 3, "l_ates": 2, "l_barikat": 1, "l_bas_altin": 2}
	for s in 6:
		menu.sekme_ac(s)
		if s == 1:
			menu._acik_kart = String(profil.veri["ekip"][0]["uid"])
			menu.sekme_ac(1)
		await _bekle(0.4)
		await _kare(klasor + "/%s.png" % ["01_menu_oyna", "02_menu_ekip", "03_menu_envanter", "04_menu_kesif", "07_menu_lab", "05_menu_ayarlar"][s])
	profil.veri["ekip"][1]["sakat"] = 2
	profil.veri["ekip"][0]["yorgunluk"] = 46.0
	menu.sekme_ac(1)
	await _bekle(0.3)
	await _kare(klasor + "/06_ekip_kisilik.png")
	# Grow Castle: Sur 9. seviye (3 yuva), kampanya altını, menüde kampanya ve sur kartı
	profil.veri["sur"] = 9
	profil.veri["altin"] = 640
	profil.veri["ekip"][0]["guc"] = 3
	profil.veri["kampanya"]["dalga"] = 7
	menu.sekme_ac(0)
	await _bekle(0.3)
	menu._kaydirma.scroll_vertical = 760
	await _bekle(0.3)
	await _kare(klasor + "/29_menu_kampanya_sur.png")
	menu.sekme_ac(2)
	await _bekle(0.4)
	await _kare(klasor + "/32_envanter_sura_ver.png")
	profil.veri["ekip"][1]["sakat"] = 0
	_yeni_oyun()
	print("ONIZLEME surdaki ekip: %d nobetci" % profil.nobetci_listesi().size())
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
	# Taret ve aktif yetenek
	_dogacak.clear()
	altin = 400
	for i in 6:
		_zombi_dogur("zirhli")
		zombiler[-1].position = Vector2(180.0 + i * 70.0, 420.0 + (i % 2) * 70.0)
	kule_al(0)
	kule_al(1)
	kule_al(1)
	_arayuz_guncelle()
	await _bekle(1.0)
	await _kare(klasor + "/19_taret.png")
	aktif_kullan()
	await _bekle(0.1)
	await _kare(klasor + "/20_aktif_yetenek.png")
	# Taret uzmanlığı: 3. seviye → seçim ekranı → havan ve ağır taret
	altin = 2000
	kule_al(1)
	kule_al(0)
	kule_al(0)
	kule_al(1)
	await _bekle(0.4)
	await _kare(klasor + "/21_uzmanlik.png")
	_kart_secildi("havan")
	kule_al(0)
	_kart_secildi("agir")
	_temizle()
	dalga = 12
	for i in 8:
		_zombi_dogur("zirhli")
		zombiler[-1].position = Vector2(150.0 + (i % 4) * 110.0, 480.0 + int(i / 4.0) * 90.0)
	await _bekle(1.7)
	await _kare(klasor + "/22_havan.png")
	_temizle()
	# Patlayan: kalabalıkta zincirleme, barikata yaklaşınca yanıp söner
	barikat.can = barikat.max_can
	for i in 8:
		_zombi_dogur("yuruyen")
		zombiler[-1].position = Vector2(170.0 + (i % 4) * 110.0, 420.0 + int(i / 4.0) * 90.0)
	var pl = _zombi_dogur("patlayan")
	pl.position = Vector2(320.0, 470.0)
	var pl2 = _zombi_dogur("patlayan")
	pl2.position = Vector2(560.0, pl2._durus_y - 120.0)
	arayuz.tanitim_goster("PATLAYAN", String(TANITIM["patlayan"]))
	await _bekle(0.7)
	await _kare(klasor + "/23_patlayan.png")
	pl.vurul(100000.0)
	await _bekle(0.12)
	await _kare(klasor + "/24_patlama.png")
	_temizle()
	# Boss 2: Kraliçe geride durur, yavru doğurur; nöbetçiler "Boss önce" ile ona döner
	barikat.can = barikat.max_can
	dalga = 10
	var kr = _zombi_dogur("kralice")
	kr.position = Vector2(genislik / 2.0, kr._durus_y)
	kr._dogurma_sayac = 0.3
	arayuz.tanitim_goster("KRALİÇE", String(TANITIM["kralice"]))
	await _bekle(1.6)
	await _kare(klasor + "/27_kralice.png")
	print("ONIZLEME kralice: can=%.0f/%.0f zombi=%d durum=%d hak=%d bekleyen=%d" % [kr.can, kr.max_can, zombiler.size(),
		durum, kr._dogurma_hak, _bekleyen_cagri])
	_temizle()
	# Yönetmen: oyuncu rahatken sıradaki zombiler kanattan birlikte gelir
	dalga = 9
	for t in ["kosucu", "kosucu", "yuruyen", "zirhli", "yuruyen"]:
		_dogacak.append(t)
	kahraman.position.x = 560.0
	kahraman.hedef_x = 560.0
	_kanat_surprizi()
	await _bekle(1.3)
	await _kare(klasor + "/28_yonetmen_kanat.png")
	_dogacak.clear()
	_temizle()
	# A4 boss aşaması: Dev %33'ün altına inince iniş yerini işaretleyip sıçrar
	dalga = 15
	var dv = _zombi_dogur("dev")
	dv.position = Vector2(genislik / 2.0, 330.0)
	dv.can = dv.max_can * 0.35
	dv.vurul(dv.max_can * 0.03)
	print("ONIZLEME dev asama=%d sicrama=%.2f" % [dv.asama, dv._sicrama])
	await _bekle(0.45)
	await _kare(klasor + "/31_boss_sicrama.png")
	_temizle()
	# A2 zayıf nokta + A3 sürü: 2. bölüm gedik, 5. bölüm zayıf; zombiler oraya yönelir, koşucular zırhlının arkasında
	durum = Durum.OYUN
	barikat.can = barikat.max_can
	dalga = 9
	var bm: float = barikat.bolum_max()
	barikat.hasar_al(bm * 1.02, barikat.bolum_merkez(1))
	barikat.hasar_al(bm * 0.6, barikat.bolum_merkez(4))
	for i in 10:
		_zombi_dogur("yuruyen" if i % 2 == 0 else "kosucu")
		zombiler[-1].position = Vector2(80.0 + i * 60.0, 260.0 + (i % 3) * 90.0)
		zombiler[-1].zeka = 1.0
	var zr = _zombi_dogur("zirhli")
	zr.position = Vector2(520.0, 520.0)
	for i in 3:
		_zombi_dogur("kosucu")
		zombiler[-1].position = Vector2(500.0 + i * 25.0, 420.0 - i * 30.0)
	for i in 8:  # üst üste doğan yığın: sürü ayrılması dağıtmalı
		_zombi_dogur("yuruyen")
		zombiler[-1].position = Vector2(150.0 + randf_range(-6, 6), 180.0 + randf_range(-6, 6))
	await _bekle(0.5)
	var kalkanli := 0
	for z in zombiler:
		if z.kalkan != null:
			kalkanli += 1
	await _bekle(1.6)
	var gedige := 0
	for z in zombiler:
		if barikat.bolum_no(z._hedef_x) == 1:
			gedige += 1
	barikat.hasar_al(barikat.bolum_max() * 2.0, barikat.bolum_merkez(1))  # Mühendis onarmış olabilir: gedik görünsün
	await _bekle(0.1)
	print("ONIZLEME A2/A3: bolumler=%s gedik=%d kalkanli_kosucu=%d gedige_yonelen=%d/%d" % [
		str([barikat.bolum_orani(0), barikat.bolum_orani(1), barikat.bolum_orani(4)]), barikat.gedik_sayisi(), kalkanli, gedige, zombiler.size()])
	await _kare(klasor + "/33_gedik_suru.png")
	var once: float = barikat.bolum_orani(1)
	_onar()
	print("ONIZLEME akilli onarim: gedik %.2f -> %.2f" % [once, barikat.bolum_orani(1)])
	_temizle()
	await _yuk_testi()
	_temizle()
	profil.veri["ekip"][1]["sakat"] = 0
	durum = Durum.OYUN
	dalga = 12
	oldurme = 140
	_boss_olduruldu = 2
	profil.veri["ekip"][0]["yorgunluk"] = 100.0
	_hasar_kaynak = {"kusan": 180.0, "yuruyen": 90.0, "dev": 60.0}
	_oyun_bitti()
	await _bekle(0.9)
	await _kare(klasor + "/14_bitis.png")
	_konusma("sert")
	await _bekle(0.2)
	await _kare(klasor + "/25_konusma.png")
	# Kampanya: tek dalga, başta 1 kart, temizlenince ZAFER ekranı ve sıradaki dalga
	_kampanya_baslat()
	await _bekle(0.4)
	await _kare(klasor + "/30a_kampanya_kart.png")
	_kart_secildi(_gosterilen_kartlar[0]["id"])
	st["hasar"] = 400.0
	st["ates_hizi"] = 8.0
	var bekle := 0
	while durum != Durum.BITTI and bekle < 120:
		await _bekle(0.25)
		bekle += 1
		if not zombiler.is_empty():
			kahraman.hedef_x = zombiler[0].position.x
		_dogum_sayac = minf(_dogum_sayac, 0.05)
	await _bekle(0.8)
	await _kare(klasor + "/30_kampanya_zafer.png")
	print("ONIZLEME kampanya: durum=%d sonraki=%d altin=%d x3=%s" % [durum, profil.kampanya_dalgasi(), profil.altin(),
		str(profil.veri["x3_acik"])])
	# Kampanya v2: zafer ekranından Sur yükselt; sonra geçilmiş dalgayı TEKRAR + OTO savaş (A6 kart kendiliğinden)
	profil.veri["hurda"] = 900
	_hizli_yukselt("sur")
	await _bekle(0.3)
	await _kare(klasor + "/34_zafer_yukselt.png")
	print("ONIZLEME hizli yukselt: sur=%d yildiz=%d" % [profil.sur_sv(), profil.toplam_yildiz()])
	profil.ayar_degistir("oto", true)
	_kampanya_tekrar_baslat()
	await _bekle(0.3)
	await _kare(klasor + "/35_oto_kart.png")
	bekle = 0
	while durum == Durum.KART and bekle < 20:
		await _bekle(0.1)
		bekle += 1
	await _bekle(2.5)
	await _kare(klasor + "/36_oto_savas.png")
	print("ONIZLEME oto: oto=%s izin=%s durum=%d kartlar=%s tekrar=%s" % [str(oto), str(_oto_izin), durum, str(kart_seviye), str(kampanya_tekrar)])
	_menuye_don()
	# B6 Kasaba: Hurda Madeni + "Sen yokken" (5 saat önce kapatılmış gibi)
	profil.veri["maden"] = {"sv": 3, "son": int(Time.get_unix_time_from_system()) - 5 * 3600, "birikim": 0.0}
	var saat: float = profil.maden_guncelle()
	profil.cevrimdisi = {"saat": saat, "miktar": profil.maden_birikim()}
	menu.sekme_ac(0)
	await _bekle(0.4)
	await _kare(klasor + "/37_sen_yokken.png")
	menu._kaydirma.scroll_vertical = 1250
	await _bekle(0.3)
	await _kare(klasor + "/38_kasaba_maden.png")
	var topla: int = profil.maden_topla()
	profil.veri["maden"]["son"] = int(Time.get_unix_time_from_system()) + 3600  # saat geri alınmış gibi
	print("ONIZLEME maden: sv=%d uretim=%.1f/sa toplandi=%d saat_geri=%.2f birikim=%d" % [profil.maden_sv(), profil.maden_uretim(),
		topla, profil.maden_guncelle(), profil.maden_birikim()])
	get_tree().quit()


## Denge sınaması (geliştirici aracı): `godot --headless --fixed-fps 60 -- --bot=5`
## Rastgele kart seçip onarım yapan bir bot N koşu oynar, ulaştığı dalgayı yazar.
func _bot(kosu: int) -> void:
	await _bekle(0.5)
	_yon_gunluk = false
	if OS.get_cmdline_user_args().has("--bot_ekip"):
		# surdaki ekiple denge: iki sıradan hayatta kalan sura çıkar
		for i in 2:
			var h := Veri.hayatta_kalan_uret(9.0, 0.3)
			h["silah"] = ""
			profil.veri["ekip"].append(h)
			profil.nobetci_degistir(String(h["uid"]))
	for i in kosu:
		_yeni_oyun()
		while durum != Durum.BITTI:
			await _bekle(0.1)
			if _uzman_yuva >= 0:
				_kart_secildi("havan" if _uzman_yuva == 1 else "agir")
			elif durum == Durum.KART:
				_kart_secildi(_gosterilen_kartlar[0]["id"])
			elif durum == Durum.OYUN:
				if not zombiler.is_empty():
					kahraman.hedef_x = zombiler[0].position.x
				if barikat.can < barikat.max_can * 0.5:
					_onar()
				aktif_kullan()
				for k in 3:
					kule_al(k)
			if dalga >= 60:
				barikat.can = 0.0
				_oyun_bitti()
		print("BOT kosu %d: nobetci=%d dalga=%d oldurme=%d boss=%d evrim=%s kartlar=%d puan=%s" % [i, profil.nobetci_listesi().size(), dalga, oldurme, _boss_olduruldu,
			str(kart_seviye.keys().filter(func(k) -> bool: return Kartlar.bul(k).is_empty())), kart_seviye.size(),
			str(_son_ozet.get("puanlar", []))])
	get_tree().quit()


## Kampanya denge botu: N savaş oynar, her savaştan sonra parası yettikçe Sur'u ve liderin Güç seviyesini
## yükseltir. Her 10 savaşta bir nerede olduğunu yazar (Grow Castle "duvar"ı nerede?).
func _bot_kampanya(savas: int) -> void:
	await _bekle(0.5)
	for i in savas:
		_kampanya_baslat()
		while durum != Durum.BITTI:
			await _bekle(0.1)
			if durum == Durum.KART:
				_kart_secildi(_gosterilen_kartlar[0]["id"])
			elif durum == Durum.OYUN:
				if not zombiler.is_empty():
					kahraman.hedef_x = zombiler[0].position.x
				if barikat.can < barikat.max_can * 0.5:
					_onar()
				aktif_kullan()
				for k in 3:
					kule_al(k)
				if _uzman_yuva >= 0:
					_kart_secildi("havan" if _uzman_yuva == 1 else "agir")
		while profil.sur_yukselt() == "":
			pass
		while profil.guc_yukselt(String(profil.veri["aktif"])) == "":
			pass
		if i % 10 == 9:
			print("BOTK savas=%d kampanya_dalga=%d sur=%d guc=%d altin=%d hurda=%d zafer=%d yenilgi=%d" % [i + 1,
				profil.kampanya_dalgasi(), profil.sur_sv(), int(profil.aktif_kahraman().get("guc", 0)), profil.altin(),
				profil.hurda(), int(profil.veri["kampanya"]["zafer"]), int(profil.veri["kampanya"]["yenilgi"])])
	get_tree().quit()


## Performans sınaması: 120 zombi + sürekli ateş, FPS kayda yazılır.
func _yuk_testi() -> void:
	_temizle()
	dalga = 12
	barikat.max_can = 1000000.0
	barikat.can = barikat.max_can
	st["ates_hizi"] = 10.0
	st["hasar"] = 1.0
	# en kötü durum: 6 yuvanın hepsi dolu (Sur yükseltmesi sonrası)
	var ekip: Array = profil.veri["ekip"]
	for i in nobetciler.size():
		nobetciler[i].kur(profil.nobetci_istatistigi(ekip[i % ekip.size()]))
	var turler := ["yuruyen", "kosucu", "zirhli", "kusan"]
	for i in 120:  # patlayan yok: barikata varınca kaybolur, sayı sabit kalmaz
		_zombi_dogur(turler[i % 4])
		zombiler[-1].position = Vector2(randf_range(50, genislik - 50), randf_range(120, barikat_y - 60))
		zombiler[-1].max_can = 1000000.0
		zombiler[-1].can = 1000000.0
	await _bekle(1.0)
	for i in 8:
		_parcacik("patlama", Vector2(100.0 + i * 70.0, 500.0))
	var bas := Time.get_ticks_msec()
	var kare_bas := Engine.get_frames_drawn()
	await _bekle(4.0)
	var fps := (Engine.get_frames_drawn() - kare_bas) * 1000.0 / (Time.get_ticks_msec() - bas)
	var cagri := RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	print("ONIZLEME yuk testi: 120 zombi + 6 nobetci FPS=%.1f cizim_cagrisi=%d yazi=%d mermi=%d" % [fps, cagri,
		_yazilar.aktif_sayisi(), _mermi_katmani.get_child_count()])
	await _kare("%s/18_yuk_testi.png" % OS.get_cmdline_user_args()[0].trim_prefix("--onizleme="))
	barikat.max_can = 300.0
	barikat.can = 300.0
	_nobetcileri_kur()


func _bekle(sn: float) -> void:
	await get_tree().create_timer(sn, true).timeout


func _kare(yol: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(yol)
	print("ONIZLEME kaydedildi: ", yol)
