extends Node2D
## Kusan zombinin asit damlası. Hedefe kavis çizerek gider, barikata çarpınca hasar verir.
## Havuzdan yeniden kullanılır.

var oyun  # oyun.gd
var _bas := Vector2.ZERO
var _son := Vector2.ZERO
var _sure := 1.0
var _gecen := 0.0
var _hasar := 0.0


func baslat(konum: Vector2, hedef: Vector2, hasar: float) -> void:
	_bas = konum
	_son = hedef
	_hasar = hasar
	_gecen = 0.0
	_sure = clampf(konum.distance_to(hedef) / 420.0, 0.4, 1.1)
	position = konum
	visible = true
	set_process(true)


func _process(delta: float) -> void:
	_gecen += delta
	var t := minf(_gecen / _sure, 1.0)
	position = _bas.lerp(_son, t) + Vector2(0, -sin(t * PI) * 70.0)
	if t >= 1.0:
		oyun.asit_dustu(self, _son, _hasar)


func _draw() -> void:
	draw_circle(Vector2(0, -5), 7.0, Color(0.55, 0.85, 0.2, 0.45))
	draw_circle(Vector2.ZERO, 10.0, Color(0.6, 0.9, 0.2))
	draw_circle(Vector2(-3, -3), 4.0, Color(0.9, 1.0, 0.55))
