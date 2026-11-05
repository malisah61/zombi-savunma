extends Node2D
## Tek bir zombi. Yukarıdan aşağı yürür, barikata varınca vurur.
## Yeni tür eklemek için TURLER sözlüğüne bir kayıt ekle; çizim renkleri de oradan gelir.

const TURLER := {
	"yuruyen": {"can": 30.0, "hiz": 52.0, "hasar": 6.0, "yaricap": 30.0, "altin": 2,
		"gomlek": [Color("5d6b7a"), Color("7a5c4d"), Color("4f6b4a"), Color("6b4f6b")], "ten": Color("8fae6b")},
	"kosucu": {"can": 15.0, "hiz": 135.0, "hasar": 4.0, "yaricap": 24.0, "altin": 3,
		"gomlek": [Color("8c3b3b"), Color("a35a2a")], "ten": Color("a7b86d")},
}

var oyun  # oyun.gd
var tur := "yuruyen"
var can := 30.0
var max_can := 30.0
var hiz := 52.0
var hasar := 6.0
var yaricap := 24.0
var altin_degeri := 2
var olu := false

var _gomlek := Color.GRAY
var _ten := Color.GREEN
var _zaman := 0.0
var _faz := 0.0
var _parlama := 0.0
var _saldiri_sayac := 0.0
var _hamle := 0.0  # barikata vurma animasyonu


func kur(o, t: String, can_carpani: float) -> void:
	# havuzdan yeniden kullanılabilir: önceki ölüm animasyonunu durdur, her şeyi sıfırla
	if has_meta("tw"):
		var eski: Tween = get_meta("tw")
		if eski and eski.is_valid():
			eski.kill()
		remove_meta("tw")
	oyun = o
	tur = t
	olu = false
	scale = Vector2.ONE
	modulate = Color(1, 1, 1, 0)
	visible = true
	set_process(true)
	_zaman = 0.0
	_parlama = 0.0
	_hamle = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)
	var veri: Dictionary = TURLER[t]
	max_can = float(veri["can"]) * can_carpani
	can = max_can
	hiz = float(veri["hiz"]) * randf_range(0.9, 1.12)
	hasar = float(veri["hasar"])
	yaricap = float(veri["yaricap"])
	altin_degeri = int(veri["altin"])
	var gomlekler: Array = veri["gomlek"]
	_gomlek = gomlekler.pick_random()
	_ten = (veri["ten"] as Color).lerp(Color(randf(), randf(), randf()), 0.08)
	_faz = randf() * TAU
	_saldiri_sayac = randf_range(0.2, 0.8)


func _process(delta: float) -> void:
	if olu:
		return
	_zaman += delta
	_parlama = maxf(_parlama - delta * 7.0, 0.0)
	_hamle = maxf(_hamle - delta * 4.0, 0.0)
	var hedef_y: float = oyun.barikat_y - yaricap - 6.0
	if position.y < hedef_y:
		position.y = minf(position.y + hiz * delta, hedef_y)
		position.x += sin(_zaman * 2.3 + _faz) * 14.0 * delta
		position.x = clampf(position.x, 40.0, oyun.genislik - 40.0)
	else:
		_saldiri_sayac -= delta
		if _saldiri_sayac <= 0.0:
			_saldiri_sayac = 1.0
			_hamle = 1.0
			oyun.barikat_vuruldu(hasar, position.x)
	queue_redraw()


func vurul(miktar: float) -> void:
	if olu:
		return
	can -= miktar
	_parlama = 1.0
	position.y -= 5.0  # geri tepme
	if can <= 0.0:
		olu = true
		oyun.zombi_oldu(self)


func _draw() -> void:
	var r := yaricap
	var yurume := sin(_zaman * (hiz / 9.0) + _faz)
	var beyaz := Color(1, 1, 1)
	var ten := _ten.lerp(beyaz, _parlama * 0.7)
	var gomlek := _gomlek.lerp(beyaz, _parlama * 0.7)
	var ileri := _hamle * 10.0

	# gölge
	draw_set_transform(Vector2(3, 8), 0.0, Vector2(1.25, 0.55))
	draw_circle(Vector2.ZERO, r, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# kollar (öne uzanmış, sallanıyor)
	var omuz_sol := Vector2(-r * 0.72, 0)
	var omuz_sag := Vector2(r * 0.72, 0)
	var el_sol := omuz_sol + Vector2(-2 + yurume * 3.0, r * 1.15 + yurume * 5.0 + ileri)
	var el_sag := omuz_sag + Vector2(2 - yurume * 3.0, r * 1.15 - yurume * 5.0 + ileri)
	draw_line(omuz_sol, el_sol, gomlek.darkened(0.15), r * 0.42, true)
	draw_line(omuz_sag, el_sag, gomlek.darkened(0.15), r * 0.42, true)
	draw_circle(el_sol, r * 0.22, ten)
	draw_circle(el_sag, r * 0.22, ten)

	# gövde (yırtık gömlek)
	draw_circle(Vector2(0, -2), r * 0.78, gomlek)
	draw_circle(Vector2(-r * 0.3, r * 0.15), r * 0.22, gomlek.darkened(0.3))
	draw_circle(Vector2(r * 0.35, -r * 0.35), r * 0.15, Color(0.45, 0.05, 0.05, 0.8))

	# kafa (öne eğik)
	var kafa := Vector2(yurume * 1.5, r * 0.28 + ileri * 0.4)
	draw_circle(kafa, r * 0.5, ten)
	draw_circle(kafa + Vector2(-r * 0.12, -r * 0.18), r * 0.2, ten.darkened(0.25))
	draw_circle(kafa + Vector2(-r * 0.18, r * 0.2), r * 0.09, Color(0.9, 0.1, 0.05))
	draw_circle(kafa + Vector2(r * 0.18, r * 0.2), r * 0.09, Color(0.9, 0.1, 0.05))

	# can çubuğu
	if can < max_can:
		var w := r * 1.8
		draw_rect(Rect2(-w / 2, -r - 12, w, 6), Color(0, 0, 0, 0.6))
		draw_rect(Rect2(-w / 2, -r - 12, w * maxf(can / max_can, 0.0), 6), Color(0.85, 0.2, 0.2))
