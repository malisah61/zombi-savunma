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
var _doku: Texture2D  # Performans v3: zemin halkası, gövde ve namlu alevi tek dokuda

const HUCRE := 110.0
const OLCEK := 2.0
const BOLGE_ZEMIN := Rect2(0, 0, 220, 220)
const BOLGE_GOVDE := Rect2(220, 0, 220, 220)
const BOLGE_ALEV := Rect2(440, 0, 220, 220)


## Hücreleri bir kez çizer. Çokgenler birleşmediği için kahraman her kare ~15 ayrı çizim çağrısıydı.
class Cizer extends Node2D:
	func _draw() -> void:
		var o := 2.0
		var m := Vector2(110, 110)
		draw_set_transform(m + Vector2(0, 6) * o, 0.0, Vector2(1.35, 0.75) * o)
		draw_circle(Vector2.ZERO, 34, Color(1.0, 0.95, 0.6, 0.12))
		draw_arc(Vector2.ZERO, 34, 0.0, TAU, 32, Color(1.0, 0.95, 0.6, 0.35), 2.0)
		draw_set_transform(m + Vector2(4, 10) * o, 0.0, Vector2(1.3, 0.6) * o)
		draw_circle(Vector2.ZERO, 26, Color(0, 0, 0, 0.3))
		draw_set_transform(Vector2(330, 110), 0.0, Vector2(o, o))
		_govde_ciz(self)
		draw_set_transform(Vector2(550, 110), 0.0, Vector2(o, o))
		draw_circle(Vector2(4, 0), 12.0, Color(1.0, 0.85, 0.3, 0.8))
		draw_circle(Vector2.ZERO, 6.0, Color.WHITE)

	static func _govde_ciz(ci: CanvasItem) -> void:
		ci.draw_circle(Vector2.ZERO, 22, Color("4b5320"))
		ci.draw_rect(Rect2(-22, -6, 44, 12), Color("3d4419"))
		ci.draw_circle(Vector2(-16, 4), 7, Color("5d6628"))
		ci.draw_circle(Vector2(16, 4), 7, Color("5d6628"))
		ci.draw_circle(Vector2(0, -2), 14, Color("556b2f"))
		ci.draw_circle(Vector2(-3, -5), 6, Color("6b8237"))


func pisir() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(660, 220)
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.msaa_2d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	vp.add_child(Cizer.new())
	add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var dok := vp.get_texture()
	var img: Image = dok.get_image() if dok else null
	if img != null and not img.is_empty() and not img.is_invisible():
		_doku = ImageTexture.create_from_image(img)
	vp.queue_free()


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
	return oyun.hedef_bul(position, float(oyun.st["menzil"]))


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
	var kutu := Rect2(-HUCRE / 2.0, -HUCRE / 2.0, HUCRE, HUCRE)
	# oyuncunun askerini kolay görmesi için ayak altında hafif ışık halkası
	if _doku:
		draw_texture_rect_region(_doku, kutu, BOLGE_ZEMIN)
		_silah_ciz()
		if _parlama > 0.0:
			draw_set_transform(Vector2.from_angle(aci) * (24.0 + _silah_boy), aci, Vector2(_parlama, _parlama))
			draw_texture_rect_region(_doku, kutu, BOLGE_ALEV)
		draw_set_transform(Vector2.ZERO, aci + PI / 2, Vector2.ONE)
		draw_texture_rect_region(_doku, kutu, BOLGE_GOVDE)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		return
	# yedek yol: dokusuz (pişirme bitmeden veya başarısızsa) doğrudan çizim
	draw_set_transform(Vector2(0, 6), 0.0, Vector2(1.35, 0.75))
	draw_circle(Vector2.ZERO, 34, Color(1.0, 0.95, 0.6, 0.12))
	draw_arc(Vector2.ZERO, 34, 0.0, TAU, 32, Color(1.0, 0.95, 0.6, 0.35), 2.0)
	# gölge
	draw_set_transform(Vector2(4, 10), 0.0, Vector2(1.3, 0.6))
	draw_circle(Vector2.ZERO, 26, Color(0, 0, 0, 0.3))

	_silah_ciz()
	if _parlama > 0.0:
		var uc := 14.0 + _silah_boy
		draw_set_transform(Vector2.ZERO, aci, Vector2.ONE)
		draw_circle(Vector2(uc + 12, 0), 12.0 * _parlama, Color(1.0, 0.85, 0.3, _parlama * 0.8))
		draw_circle(Vector2(uc + 8, 0), 6.0 * _parlama, Color(1, 1, 1, _parlama))

	# gövde (yelek) ve kask
	draw_set_transform(Vector2.ZERO, aci + PI / 2, Vector2.ONE)
	Cizer._govde_ciz(self)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Silah ve kollar namlu yönüne döner; dikdörtgen ve yumuşatmasız çizgi tek partiye sığar.
func _silah_ciz() -> void:
	var geri := Vector2.from_angle(aci) * -_geri_tepme
	draw_set_transform(geri, aci, Vector2.ONE)
	draw_line(Vector2(6, -14), Vector2(30, -3), Color("c99b76"), 9.0)
	draw_line(Vector2(6, 14), Vector2(22, 4), Color("c99b76"), 9.0)
	var uc := 14.0 + _silah_boy
	draw_rect(Rect2(14, -_silah_kalin / 2, _silah_boy, _silah_kalin), _silah_renk)
	draw_rect(Rect2(10, -5, 12, 10), Color("5a3d24"))
	draw_rect(Rect2(uc - 2, -3, 8, 6), Color("444444"))
