extends Node2D
const Veri := preload("res://betikler/veri.gd")
## Barikatın arkasındaki kahraman. Parmakla sağa sola gider, menzildeki en tehlikeli
## zombiye (barikata en yakın olana) otomatik ateş eder.

var oyun  # oyun.gd
var hedef_x := 360.0
var aci := -PI / 2  # namlunun baktığı yön
var _atis_sayac := 0.0
var _parlama := 0.0
var _geri_tepme := 0.0
var _zaman := 0.0
var _silah_boy := 34.0
var _silah_kalin := 12.0
var _silah_renk := Color("2b2b2b")


## Kuşanılan silaha göre namlunun görünüşü değişir.
func silah_ayarla(taban: String) -> void:
	_silah_boy = float(Veri.SILAHLAR.get(taban, Veri.SILAHLAR["tabanca"])["boy"])
	_silah_kalin = 16.0 if taban == "pompali" or taban == "makineli" else 12.0
	_silah_renk = Color("3a3226") if taban == "keskin" else Color("2b2b2b")


func _process(delta: float) -> void:
	_zaman += delta
	_parlama = maxf(_parlama - delta * 14.0, 0.0)
	_geri_tepme = maxf(_geri_tepme - delta * 30.0, 0.0)
	position.x = move_toward(position.x, clampf(hedef_x, 50.0, oyun.genislik - 50.0), 950.0 * delta)

	var hedef = _hedef_bul()
	if hedef:
		var istenen: float = (hedef.position - position).angle()
		aci = lerp_angle(aci, istenen, minf(delta * 18.0, 1.0))
		_atis_sayac -= delta
		if _atis_sayac <= 0.0 and absf(angle_difference(aci, istenen)) < 0.25:
			_atis_sayac = 1.0 / float(oyun.st["ates_hizi"])
			_ates()
	else:
		aci = lerp_angle(aci, -PI / 2, minf(delta * 6.0, 1.0))
	queue_redraw()


func _hedef_bul():
	var en_iyi = null
	var menzil: float = oyun.st["menzil"]
	for z in oyun.zombiler:
		if z.olu or z.position.y < -10.0:
			continue
		if position.distance_to(z.position) > menzil:
			continue
		if en_iyi == null or z.position.y > en_iyi.position.y:
			en_iyi = z
	return en_iyi


func _ates() -> void:
	var namlu := int(oyun.st["namlu"])
	var yayilim := float(oyun.st.get("yayilim", 0.09))
	if namlu > 1 and yayilim <= 0.0:
		yayilim = 0.06
	var ucu := position + Vector2.from_angle(aci) * (_silah_boy + 18.0) * scale.x
	for i in namlu:
		var sapma := (float(i) - float(namlu - 1) / 2.0) * yayilim
		oyun.mermi_at(ucu, Vector2.from_angle(aci + sapma))
	_parlama = 1.0
	_geri_tepme = 5.0
	oyun.ses("atis")


func _draw() -> void:
	# gölge
	draw_set_transform(Vector2(4, 10), 0.0, Vector2(1.3, 0.6))
	draw_circle(Vector2.ZERO, 26, Color(0, 0, 0, 0.3))

	# silah ve kollar namlu yönüne döner
	var geri := Vector2.from_angle(aci) * -_geri_tepme
	draw_set_transform(geri, aci, Vector2.ONE)
	draw_line(Vector2(6, -14), Vector2(30, -3), Color("c99b76"), 9.0, true)
	draw_line(Vector2(6, 14), Vector2(22, 4), Color("c99b76"), 9.0, true)
	var uc := 14.0 + _silah_boy
	draw_rect(Rect2(14, -_silah_kalin / 2, _silah_boy, _silah_kalin), _silah_renk)
	draw_rect(Rect2(10, -5, 12, 10), Color("5a3d24"))
	draw_rect(Rect2(uc - 2, -3, 8, 6), Color("444444"))
	if _parlama > 0.0:
		draw_circle(Vector2(uc + 12, 0), 12.0 * _parlama, Color(1.0, 0.85, 0.3, _parlama * 0.8))
		draw_circle(Vector2(uc + 8, 0), 6.0 * _parlama, Color(1, 1, 1, _parlama))

	# gövde (yelek) ve kask
	draw_set_transform(Vector2.ZERO, aci + PI / 2, Vector2.ONE)
	draw_circle(Vector2.ZERO, 22, Color("4b5320"))
	draw_rect(Rect2(-22, -6, 44, 12), Color("3d4419"))
	draw_circle(Vector2(-16, 4), 7, Color("5d6628"))
	draw_circle(Vector2(16, 4), 7, Color("5d6628"))
	draw_circle(Vector2(0, -2), 14, Color("556b2f"))
	draw_circle(Vector2(-3, -5), 6, Color("6b8237"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
