extends Node2D
## Surdaki ekip (Grow Castle'daki kale kahramanları gibi): Ekip sekmesinde sura konan hayatta kalan
## barikatın üstünde durur ve kendi silahı, rolü ve özellikleriyle kendiliğinden ateş eder.
## Ekip yapay zekâsı: hedefi rolüne veya oyuncunun seçtiği moda göre seçer, başka mermilerin zaten
## öldüreceği zombiye boşuna ateş etmez (oyun.ekip_hedef_sec). Boşken Mühendis ve Doktor barikata bakar.
## Havuz gibi çalışır: düğümler açılışta bir kez kurulur, koşu başında kur()/sifirla() çağrılır.

const HEDEF_ARA := 0.2
const MUHENDIS_ONARIM := 0.003  # boşken saniyede barikat canının %0.3'ü
const DOKTOR_ONARIM := 0.002
const OLCEK := 0.62
const BOLGE_GOVDE := Rect2(220, 0, 220, 220)  # kahraman dokusundaki gövde hücresi

var oyun  # oyun.gd
var sira := 1  # katkı istatistiğindeki kaynak numarası (0 lider)
var veri: Dictionary = {}  # profil.nobetci_istatistigi()
var aci := -PI / 2
var _atis := 0.0
var _hedef_sayac := 0.0
var _hedef
var _parlama := 0.0
var _rol_renk := Color.WHITE


func kur(v: Dictionary) -> void:
	veri = v
	_rol_renk = v["renk"]
	aci = -PI / 2
	_atis = randf_range(0.2, 0.6)
	_hedef = null
	_parlama = 0.0
	visible = true
	set_process(true)
	queue_redraw()


func sifirla() -> void:
	visible = false
	set_process(false)
	_hedef = null
	veri = {}


func _process(delta: float) -> void:
	if oyun.durum != 1:
		return
	_atis -= delta
	_hedef_sayac -= delta
	var cizim := _parlama > 0.0
	_parlama = maxf(_parlama - delta * 12.0, 0.0)
	if _hedef_sayac <= 0.0 or _hedef == null or _hedef.olu:
		_hedef_sayac = HEDEF_ARA
		_hedef = oyun.ekip_hedef_sec(position, float(veri["menzil"]), String(veri["mod"]), String(veri["rol"]))
	if _hedef == null:
		_bosta_isle(delta)
		if cizim:
			queue_redraw()
		return
	var istenen: float = (_hedef.position - position).angle()
	aci = lerp_angle(aci, istenen, minf(delta * 14.0, 1.0))
	if _atis <= 0.0 and absf(angle_difference(aci, istenen)) < 0.3:
		_atis = 1.0 / float(veri["ates_hizi"])
		_ates()
	queue_redraw()


## Boşken rolün işi: Mühendis ve Doktor barikatı yavaşça onarır (A5).
func _bosta_isle(delta: float) -> void:
	match String(veri["rol"]):
		"muhendis":
			oyun.ekip_onarimi(MUHENDIS_ONARIM * delta)
		"doktor":
			oyun.ekip_onarimi(DOKTOR_ONARIM * delta)


func _ates() -> void:
	var namlu := int(veri["namlu"])
	var yayilim := float(veri["yayilim"])
	var uc := position + Vector2.from_angle(aci) * 34.0
	var guc: float = float(veri["hasar"]) * oyun.nobetci_carpani()
	for i in namlu:
		var sapma := (float(i) - float(namlu - 1) / 2.0) * yayilim
		var kritik := randf() < float(veri["kritik"])
		var h := guc * (float(veri["kritik_carpan"]) if kritik else 1.0)
		oyun.nobetci_atesi(uc, Vector2.from_angle(aci + sapma), h, kritik, int(veri["delme"]), sira,
			_hedef if i == 0 else null)
	_parlama = 1.0


func _draw() -> void:
	# taban: kum torbası parçası ve rol rengi şerit (oyuncu kimin nerede olduğunu görsün)
	draw_rect(Rect2(-22, -4, 44, 18), Color("6b5d45"))
	draw_rect(Rect2(-22, 10, 44, 4), _rol_renk)
	var doku: Texture2D = oyun.kahraman._doku if oyun and oyun.kahraman else null
	draw_set_transform(Vector2.ZERO, aci, Vector2.ONE)
	draw_rect(Rect2(8, -4, float(veri.get("boy", 30.0)) * 0.7, 8), Color("2b2b2b"))
	if _parlama > 0.0:
		var u := 10.0 + float(veri.get("boy", 30.0)) * 0.7
		draw_rect(Rect2(u, -6 * _parlama, 10 * _parlama, 12 * _parlama), Color(1, 0.85, 0.3, _parlama))
	draw_set_transform(Vector2.ZERO, aci + PI / 2, Vector2.ONE)
	if doku:
		var k := 110.0 * OLCEK
		draw_texture_rect_region(doku, Rect2(-k / 2, -k / 2, k, k), BOLGE_GOVDE, _rol_renk.lightened(0.35))
	else:
		draw_rect(Rect2(-13, -13, 26, 26), _rol_renk)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
