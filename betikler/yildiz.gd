extends Control
## 5 yıldızlı değerlendirme çizer (FM'deki yetenek / potansiyel yıldızları). Yarım yıldız destekler.
## alt_deger > 0 ise yıldızlar bir aralık olarak (belirsiz bilgi) soluk çizilir.

var deger := 2.5
var aralik_ust := -1.0  # >= 0 ise deger..aralik_ust arası "belki" olarak soluk dolu
var renk := Color(1.0, 0.8, 0.2)


func _init() -> void:
	custom_minimum_size = Vector2(150, 30)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func ayarla(d: float, ust: float = -1.0, r: Color = Color(1.0, 0.8, 0.2)) -> void:
	deger = d
	aralik_ust = ust
	renk = r
	queue_redraw()


func _draw() -> void:
	var boy := size.y
	for i in 5:
		var merkez := Vector2(boy * 0.5 + i * boy * 1.0, boy * 0.5)
		var nokta := _yildiz(merkez, boy * 0.48, boy * 0.2)
		draw_colored_polygon(nokta, Color(0.25, 0.25, 0.25, 0.9))
		var dolu := clampf(deger - i, 0.0, 1.0)
		var belki := clampf(aralik_ust - i, 0.0, 1.0) if aralik_ust >= 0.0 else 0.0
		if belki > dolu:
			_kirpik_ciz(nokta, merkez, boy, belki, Color(renk, 0.35))
		if dolu > 0.0:
			_kirpik_ciz(nokta, merkez, boy, dolu, renk)


func _kirpik_ciz(nokta: PackedVector2Array, merkez: Vector2, boy: float, oran: float, r: Color) -> void:
	if oran >= 0.99:
		draw_colored_polygon(nokta, r)
		return
	# yarım yıldız: sol yarıyı çiz
	var dis := boy * 0.48
	var x_son := -dis + 2.0 * dis * oran
	var kirp := PackedVector2Array([
		merkez + Vector2(-boy, -boy), merkez + Vector2(x_son, -boy),
		merkez + Vector2(x_son, boy), merkez + Vector2(-boy, boy)])
	var kesisim := Geometry2D.intersect_polygons(nokta, kirp)
	for p in kesisim:
		draw_colored_polygon(p, r)


func _yildiz(m: Vector2, dis: float, ic: float) -> PackedVector2Array:
	var p := PackedVector2Array()
	for k in 10:
		var a := -PI / 2 + k * PI / 5
		var r := dis if k % 2 == 0 else ic
		p.append(m + Vector2(cos(a), sin(a)) * r)
	return p
