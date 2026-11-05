extends Node2D
## Yerde kalan kan lekesi; zamanla solar ve kaybolur. Atlas hazırsa önceden pişirilmiş şekillerden birini çizer.

const VARYANT := 6
const RENK := Color(0.38, 0.04, 0.04, 0.85)

var atlas  # zombi_atlas.gd
var _varyant := 0
var omur := 18.0
var _noktalar: Array[Vector3] = []  # x, y, yarıçap


func _ready() -> void:
	yenile()


## Havuzdan yeniden kullanırken yeni bir şekil üretir.
func yenile() -> void:
	omur = 18.0
	modulate.a = 1.0
	visible = true
	set_process(true)
	_varyant = randi() % VARYANT
	if atlas == null or not atlas.hazir:
		_noktalar = sekil_uret()
	rotation = randf() * TAU
	queue_redraw()


static func sekil_uret() -> Array[Vector3]:
	var liste: Array[Vector3] = []
	var n := randi_range(5, 9)
	for i in n:
		var a := randf() * TAU
		var d := randf_range(0.0, 16.0)
		liste.append(Vector3(cos(a) * d, sin(a) * d * 0.7, randf_range(5.0, 13.0)))
	for i in 4:
		var a := randf() * TAU
		var d := randf_range(18.0, 30.0)
		liste.append(Vector3(cos(a) * d, sin(a) * d, randf_range(2.0, 4.0)))
	return liste


func _process(delta: float) -> void:
	omur -= delta
	if omur < 4.0:
		modulate.a = maxf(omur / 4.0, 0.0)
	if omur <= 0.0:
		# silinmez, gizlenir: oyun.gd bu lekeyi havuzdan tekrar kullanır
		visible = false
		set_process(false)


func _draw() -> void:
	if atlas != null and atlas.hazir:
		var boy: float = atlas.HUCRE
		draw_texture_rect_region(atlas.doku, Rect2(-boy / 2.0, -boy / 2.0, boy, boy), atlas.leke_bolgesi(_varyant))
		return
	for p in _noktalar:
		draw_circle(Vector2(p.x, p.y), p.z, RENK)
