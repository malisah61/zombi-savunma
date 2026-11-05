extends Node2D
## Ekranın altındaki barikat: kum torbaları + tahta çit. Can azaldıkça tahtalar kırılır.

var oyun  # oyun.gd
var can := 300.0
var max_can := 300.0
var _parlama := 0.0
var _sarsinti := 0.0
var _rng := RandomNumberGenerator.new()
var _son_oran := -1.0


func _process(delta: float) -> void:
	# yalnızca bir şey değiştiğinde yeniden çiz (performans)
	var oran := snappedf(can / max_can, 0.02)
	if _parlama <= 0.0 and _sarsinti <= 0.0 and oran == _son_oran:
		return
	_son_oran = oran
	_parlama = maxf(_parlama - delta * 5.0, 0.0)
	_sarsinti = maxf(_sarsinti - delta * 40.0, 0.0)
	position.x = randf_range(-_sarsinti, _sarsinti)
	queue_redraw()


func hasar_al(miktar: float) -> void:
	can = maxf(can - miktar, 0.0)
	_parlama = 1.0
	_sarsinti = minf(_sarsinti + 3.0, 6.0)


func onar(oran: float) -> void:
	can = minf(can + max_can * oran, max_can)


func _draw() -> void:
	var w: float = oyun.genislik
	var oran := can / max_can
	var kirmizi := Color(1, 0.3, 0.3)

	# kum torbaları (iki sıra)
	_rng.seed = 7
	for sira in 2:
		var y := 34.0 + sira * 22.0
		var x := -20.0 + sira * 22.0
		while x < w + 40.0:
			var renk := Color("b9a07a").darkened(_rng.randf_range(0.0, 0.18)).lerp(kirmizi, _parlama * 0.35)
			draw_set_transform(Vector2(x, y), 0.0, Vector2(1.0, 0.55))
			draw_circle(Vector2.ZERO, 24, renk.darkened(0.25))
			draw_circle(Vector2(-1, -2), 21, renk)
			x += 44.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# direkler
	var direk := Color("4a3220")
	for i in 7:
		var x := 20.0 + i * (w - 40.0) / 6.0
		draw_rect(Rect2(x - 9, -30, 18, 62), direk)

	# tahtalar: can azaldıkça bazı parçalar kırılır
	_rng.seed = 11
	for sira in 2:
		var y := -22.0 + sira * 24.0
		var parca := 12
		var pw := w / parca
		for i in parca:
			var esik := _rng.randf()
			if esik > oran + 0.08:
				# kırık tahta: kısa, eğri parça
				draw_set_transform(Vector2(i * pw + pw * 0.3, y + 8), _rng.randf_range(-0.4, 0.4), Vector2.ONE)
				draw_rect(Rect2(0, 0, pw * 0.35, 14), Color("6b4a2f").darkened(0.3))
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				continue
			var renk := Color("8b5e3c").darkened(_rng.randf_range(0.0, 0.2)).lerp(kirmizi, _parlama * 0.4)
			draw_rect(Rect2(i * pw, y, pw + 1, 18), renk)
			draw_line(Vector2(i * pw + 4, y + 9), Vector2(i * pw + pw - 6, y + 8), renk.darkened(0.3), 2.0)
			draw_circle(Vector2(i * pw + 6, y + 9), 2.5, Color("3b3b3b"))
			draw_circle(Vector2(i * pw + pw - 6, y + 9), 2.5, Color("3b3b3b"))

	# dikenli tel
	var tel := Color(0.65, 0.65, 0.68)
	var x := 0.0
	while x < w:
		draw_arc(Vector2(x + 12, -34), 12.0, PI, TAU, 8, tel, 2.0)
		draw_line(Vector2(x + 6, -40), Vector2(x + 18, -28), tel, 1.5)
		x += 24.0
