extends Node2D
## Yerde kalan kan lekesi; zamanla solar ve kaybolur.

var omur := 18.0
var _noktalar: Array[Vector3] = []  # x, y, yarıçap
var _renk := Color(0.38, 0.04, 0.04, 0.85)


func _ready() -> void:
	var n := randi_range(5, 9)
	for i in n:
		var a := randf() * TAU
		var d := randf_range(0.0, 16.0)
		_noktalar.append(Vector3(cos(a) * d, sin(a) * d * 0.7, randf_range(5.0, 13.0)))
	for i in 4:
		var a := randf() * TAU
		var d := randf_range(18.0, 30.0)
		_noktalar.append(Vector3(cos(a) * d, sin(a) * d, randf_range(2.0, 4.0)))
	rotation = randf() * TAU


func _process(delta: float) -> void:
	omur -= delta
	if omur < 4.0:
		modulate.a = maxf(omur / 4.0, 0.0)
	if omur <= 0.0:
		queue_free()


func _draw() -> void:
	for p in _noktalar:
		draw_circle(Vector2(p.x, p.y), p.z, _renk)
