extends Node2D
## Barikattaki taret yuvası. Altınla kurulur, 3 seviyeye çıkar, sonra iki uzmanlıktan birine dönüşür:
## Havan (alan, zırhı aşar) veya Ağır Taret (tek hedef, zırh deler, 1 delme). Havuz gibi çalışır: üç düğüm
## baştan oluşturulur, koşu başında sıfırlanır. Şekil bir kez çizilir; dönüş yalnızca namlu düğümünün açısıdır.

const MENZIL := 520.0
const ATIS_ARA := 0.6
const HEDEF_ARA := 0.2
const FIYATLAR := [60, 96, 154]
const UZMAN_FIYAT := 240
const HAVAN_ARA := 2.6
const HAVAN_HASAR := 45.0  # Sv3 taretin 18 hasarının 2.5 katı, ama alana
const HAVAN_YARICAP := 105.0
const HAVAN_UCUS := 0.7
const AGIR_ARA := 1.2
const AGIR_HASAR := 43.0

var oyun  # oyun.gd
var seviye := 0
var uzman := ""  # "", "havan", "agir"
var _namlu: Node2D
var _gulle: Node2D
var _gulle_bas := Vector2.ZERO
var _gulle_son := Vector2.ZERO
var _gulle_t := -1.0
var _gulle_hasar := 0.0
var _atis := 0.0
var _hedef_sayac := 0.0
var _hedef


class Namlu extends Node2D:
	var seviye := 1
	var uzman := ""

	func _draw() -> void:
		if uzman == "havan":
			draw_rect(Rect2(-4, -15, 30, 30), Color("2f3338"))
			draw_rect(Rect2(22, -18, 10, 36), Color("55595e"))
			return
		if uzman == "agir":
			draw_rect(Rect2(0, -9, 54, 18), Color("2a3440"))
			draw_rect(Rect2(50, -5, 14, 10), Color("7fb2d9"))
			return
		draw_rect(Rect2(0, -5 - seviye, 30 + seviye * 4, 10 + seviye * 2), Color("2f3338"))
		draw_rect(Rect2(26 + seviye * 4, -3, 8, 6), Color("55595e"))


class Gulle extends Node2D:
	func _draw() -> void:
		draw_rect(Rect2(-7, -7, 14, 14), Color("1f2226"))
		draw_rect(Rect2(-4, -5, 6, 4), Color("7a8088"))


func _ready() -> void:
	_namlu = Namlu.new()
	add_child(_namlu)
	_gulle = Gulle.new()
	_gulle.top_level = true
	_gulle.visible = false
	add_child(_gulle)
	sifirla()


func sifirla() -> void:
	seviye = 0
	uzman = ""
	visible = false
	set_process(false)
	_hedef = null
	_gulle_t = -1.0
	_gulle.visible = false
	_namlu.uzman = ""


func fiyat() -> int:
	var f := 0
	if seviye < FIYATLAR.size():
		f = FIYATLAR[seviye]
	elif uzman == "":
		f = UZMAN_FIYAT
	return int(round(f * float(oyun.st.get("kule_fiyat", 1.0))))


func uzmanlik_sirasi() -> bool:
	return seviye >= FIYATLAR.size() and uzman == ""


func uzmanlas(tur: String) -> void:
	uzman = tur
	_namlu.uzman = tur
	_namlu.queue_redraw()
	queue_redraw()


func yukselt() -> void:
	seviye += 1
	visible = true
	set_process(true)
	_namlu.rotation = -PI / 2.0
	_namlu.seviye = seviye
	_namlu.queue_redraw()
	queue_redraw()


func _process(delta: float) -> void:
	if oyun.durum != 1:
		return
	_atis -= delta
	_hedef_sayac -= delta
	_gulle_isle(delta)
	if _hedef_sayac <= 0.0 or _hedef == null or _hedef.olu:
		_hedef_sayac = HEDEF_ARA
		_hedef = oyun.hedef_bul(position, MENZIL)
	if _hedef == null:
		return
	var yon: Vector2 = _hedef.position - position
	_namlu.rotation = lerp_angle(_namlu.rotation, yon.angle(), minf(delta * 12.0, 1.0))
	if _atis <= 0.0:
		_ates()


func _guc(taban: float) -> float:
	return taban * (1.0 + 0.05 * oyun.dalga) * float(oyun.st.get("kule_hasar", 1.0))


func _ates() -> void:
	var yon := Vector2.from_angle(_namlu.rotation)
	var uc: Vector2 = position + yon * 36.0
	match uzman:
		"havan":
			_atis = HAVAN_ARA
			if _gulle_t < 0.0:
				_gulle_bas = uc
				_gulle_son = _hedef.position
				_gulle_t = 0.0
				_gulle_hasar = _guc(HAVAN_HASAR)
				_gulle.position = uc
				_gulle.visible = true
		"agir":
			_atis = AGIR_ARA
			oyun.kule_atesi(uc, yon, _guc(AGIR_HASAR), 1, true, _hedef)
		_:
			_atis = ATIS_ARA
			oyun.kule_atesi(uc, yon, _guc(8.0 * pow(1.5, seviye - 1)), 0, false, _hedef)


## Gülle kavis çizerek uçar, düştüğü yerde patlar (düğüm yeniden kullanılır).
func _gulle_isle(delta: float) -> void:
	if _gulle_t < 0.0:
		return
	_gulle_t += delta / HAVAN_UCUS
	if _gulle_t >= 1.0:
		_gulle_t = -1.0
		_gulle.visible = false
		oyun.havan_dustu(_gulle_son, HAVAN_YARICAP, _gulle_hasar)
		return
	_gulle.position = _gulle_bas.lerp(_gulle_son, _gulle_t) + Vector2(0, -sin(_gulle_t * PI) * 90.0)


func _draw() -> void:
	draw_rect(Rect2(-24, -16, 48, 32), Color("4a4f45"))
	draw_rect(Rect2(-24, -16, 48, 5), Color("ffa040") if uzman == "havan" else (Color("7fb2d9") if uzman == "agir" else Color("6c7264")))
	for i in seviye:
		draw_rect(Rect2(-18 + i * 13, 8, 9, 5), Color("ffcf4a"))
