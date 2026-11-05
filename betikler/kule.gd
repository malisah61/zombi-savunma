extends Node2D
## Barikattaki taret yuvası. Altınla kurulur, 3 seviyeye çıkar. Havuz gibi çalışır: üç düğüm baştan
## oluşturulur, koşu başında sıfırlanır. Şekil bir kez çizilir; dönüş yalnızca namlu düğümünün açısıdır.

const MENZIL := 520.0
const ATIS_ARA := 0.6
const HEDEF_ARA := 0.2
const FIYATLAR := [60, 96, 154]

var oyun  # oyun.gd
var seviye := 0
var _namlu: Node2D
var _atis := 0.0
var _hedef_sayac := 0.0
var _hedef


class Namlu extends Node2D:
	var seviye := 1

	func _draw() -> void:
		draw_rect(Rect2(0, -5 - seviye, 30 + seviye * 4, 10 + seviye * 2), Color("2f3338"))
		draw_rect(Rect2(26 + seviye * 4, -3, 8, 6), Color("55595e"))


func _ready() -> void:
	_namlu = Namlu.new()
	add_child(_namlu)
	sifirla()


func sifirla() -> void:
	seviye = 0
	visible = false
	set_process(false)
	_hedef = null


func fiyat() -> int:
	if seviye >= FIYATLAR.size():
		return 0
	return int(round(FIYATLAR[seviye] * float(oyun.st.get("kule_fiyat", 1.0))))


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
	if _hedef_sayac <= 0.0 or _hedef == null or _hedef.olu:
		_hedef_sayac = HEDEF_ARA
		_hedef = oyun.hedef_bul(position, MENZIL)
	if _hedef == null:
		return
	var yon: Vector2 = _hedef.position - position
	_namlu.rotation = lerp_angle(_namlu.rotation, yon.angle(), minf(delta * 12.0, 1.0))
	if _atis <= 0.0:
		_atis = ATIS_ARA
		var hasar: float = 8.0 * pow(1.5, seviye - 1) * (1.0 + 0.05 * oyun.dalga) * float(oyun.st.get("kule_hasar", 1.0))
		oyun.kule_atesi(position + Vector2.from_angle(_namlu.rotation) * 36.0, Vector2.from_angle(_namlu.rotation), hasar)


func _draw() -> void:
	draw_rect(Rect2(-24, -16, 48, 32), Color("4a4f45"))
	draw_rect(Rect2(-24, -16, 48, 5), Color("6c7264"))
	for i in seviye:
		draw_rect(Rect2(-18 + i * 13, 8, 9, 5), Color("ffcf4a"))
