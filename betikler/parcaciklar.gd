extends Node2D
## Performans v3: tüm parçacıklar tek düğümde, tek çizim partisinde. Eskiden 52 ayrı CPUParticles2D düğümü
## vardı (her biri ayrı çizim çağrısı ve işlem). Burada sabit boyutlu diziler kullanılır: oyun sırasında
## bellek ayrılmaz, ölü parçacık sondakiyle yer değiştirir (dizi kaymaz). Parçacık yoksa işlem de çizim de durur.

const SINIR := 320
const OMUR := 0.45
const YERCEKIMI := 600.0

# adet: patlama başına parçacık, hiz: en yüksek hız, boy: piksel
const TURLER := {
	"kan_kucuk": {"adet": 6, "renk": Color(0.6, 0.05, 0.05), "hiz": 260.0, "boy": 6.0},
	"kan_buyuk": {"adet": 22, "renk": Color(0.55, 0.04, 0.04), "hiz": 300.0, "boy": 7.0},
	"kiymik": {"adet": 8, "renk": Color("8b5e3c"), "hiz": 220.0, "boy": 7.0},
	"kivilcim": {"adet": 5, "renk": Color("ffe9a0"), "hiz": 340.0, "boy": 4.0},
	"asit": {"adet": 10, "renk": Color("9be02f"), "hiz": 240.0, "boy": 7.0},
	"ates": {"adet": 4, "renk": Color("ff8a2a"), "hiz": 120.0, "boy": 6.0},
	"patlama": {"adet": 26, "renk": Color("ffb040"), "hiz": 420.0, "boy": 8.0},
}

var sinir := SINIR  # kaliteye göre oyun.gd ayarlar
var _adet := 0
var _konum := PackedVector2Array()
var _hiz := PackedVector2Array()
var _kalan := PackedFloat32Array()
var _boy := PackedFloat32Array()
var _renk := PackedColorArray()


func _ready() -> void:
	_konum.resize(SINIR)
	_hiz.resize(SINIR)
	_kalan.resize(SINIR)
	_boy.resize(SINIR)
	_renk.resize(SINIR)
	set_process(false)


func yay(tur: String, nokta: Vector2) -> void:
	var t: Dictionary = TURLER[tur]
	var en_hiz: float = t["hiz"]
	var en_boy: float = t["boy"]
	for i in int(t["adet"]):
		if _adet >= sinir:
			break
		_konum[_adet] = nokta
		_hiz[_adet] = Vector2.from_angle(randf() * TAU) * randf_range(en_hiz * 0.4, en_hiz)
		_kalan[_adet] = OMUR * randf_range(0.7, 1.0)
		_boy[_adet] = randf_range(en_boy * 0.5, en_boy)
		_renk[_adet] = t["renk"]
		_adet += 1
	set_process(true)


func _process(delta: float) -> void:
	var i := _adet - 1
	while i >= 0:
		_kalan[i] -= delta
		if _kalan[i] <= 0.0:
			_adet -= 1
			_konum[i] = _konum[_adet]
			_hiz[i] = _hiz[_adet]
			_kalan[i] = _kalan[_adet]
			_boy[i] = _boy[_adet]
			_renk[i] = _renk[_adet]
		else:
			_hiz[i] += Vector2(0.0, YERCEKIMI * delta)
			_konum[i] += _hiz[i] * delta
		i -= 1
	if _adet == 0:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	for i in _adet:
		var oran := minf(_kalan[i] / 0.2, 1.0)  # son anda küçülerek söner
		var b := _boy[i] * oran
		var r := _renk[i]
		r.a = oran
		draw_rect(Rect2(_konum[i].x - b * 0.5, _konum[i].y - b * 0.5, b, b), r)
