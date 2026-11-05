extends Node2D
## Oyun alanının zemini: ortada çatlak asfalt yol, kenarlarda kuru çim ve toprak.
## Bir kez dokuya pişirilir: yüzlerce daire her kare ayrı çizim çağrısı olmasın diye (GL Compatibility'de
## çokgenler birleşmez). Pişirme olmazsa yedek olarak doğrudan çizilir.

const OLCEK := 1.25

var genislik := 720.0
var yukseklik := 1280.0
var _doku: Texture2D


func pisir() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(ceili(genislik * OLCEK), ceili(yukseklik * OLCEK))
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var kopya := Node2D.new()
	kopya.set_script(get_script())
	kopya.genislik = genislik
	kopya.yukseklik = yukseklik
	kopya.scale = Vector2(OLCEK, OLCEK)
	vp.add_child(kopya)
	add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	if img != null and not img.is_empty():
		img.convert(Image.FORMAT_RGB8)
		_doku = ImageTexture.create_from_image(img)
		queue_redraw()
	vp.queue_free()


func _draw() -> void:
	if _doku:
		draw_texture_rect(_doku, Rect2(0, 0, genislik, yukseklik), false)
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = 2026
	var w := genislik
	var h := yukseklik
	var yol_sol := w * 0.18
	var yol_sag := w * 0.82

	# kenarlar: kuru çim
	draw_rect(Rect2(0, 0, w, h), Color("4d5a32"))
	for i in 900:
		var p := Vector2(rng.randf() * w, rng.randf() * h)
		var c := Color("5f6d3b") if rng.randf() < 0.5 else Color("3f4a28")
		draw_circle(p, rng.randf_range(2, 7), Color(c, 0.6))
	for i in 140:
		var p := Vector2(rng.randf() * w, rng.randf() * h)
		draw_circle(p, rng.randf_range(10, 26), Color("6b5a3a", 0.35))

	# asfalt yol
	draw_rect(Rect2(yol_sol, 0, yol_sag - yol_sol, h), Color("3a3a3d"))
	for i in 1600:
		var p := Vector2(rng.randf_range(yol_sol, yol_sag), rng.randf() * h)
		var g := rng.randf_range(0.18, 0.3)
		draw_rect(Rect2(p, Vector2(2, 2)), Color(g, g, g + 0.01))
	for i in 18:
		var p := Vector2(rng.randf_range(yol_sol + 20, yol_sag - 20), rng.randf() * h)
		draw_circle(p, rng.randf_range(18, 40), Color(0.15, 0.15, 0.16, 0.35))
	# yol kenarı ve orta çizgi
	draw_rect(Rect2(yol_sol - 6, 0, 6, h), Color("8f8b80"))
	draw_rect(Rect2(yol_sag, 0, 6, h), Color("8f8b80"))
	var y := -20.0
	while y < h:
		if rng.randf() > 0.15:
			draw_rect(Rect2(w / 2 - 5, y, 10, 46), Color(0.85, 0.75, 0.3, 0.75))
		y += 92.0
	# çatlaklar
	for i in 26:
		var a := Vector2(rng.randf_range(yol_sol, yol_sag), rng.randf() * h)
		var noktalar := PackedVector2Array([a])
		for j in 5:
			a += Vector2(rng.randf_range(-22, 22), rng.randf_range(8, 26))
			noktalar.append(a)
		draw_polyline(noktalar, Color(0.1, 0.1, 0.1, 0.7), 2.0)
	# eski kan izleri ve döküntü
	for i in 10:
		var p := Vector2(rng.randf_range(yol_sol, yol_sag), rng.randf_range(0, h * 0.7))
		for j in 6:
			draw_circle(p + Vector2(rng.randf_range(-16, 16), rng.randf_range(-10, 10)), rng.randf_range(4, 12), Color(0.3, 0.03, 0.03, 0.45))
	for i in 14:
		var p := Vector2(rng.randf() * w, rng.randf() * h * 0.75)
		draw_set_transform(p, rng.randf() * TAU, Vector2.ONE)
		draw_rect(Rect2(-10, -4, 20, 8), Color(0.35, 0.3, 0.25))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# ufukta sis: zombilerin "karanlıktan" gelmesi
	for i in 12:
		draw_rect(Rect2(0, i * 14, w, 14), Color(0.05, 0.06, 0.05, 0.5 - i * 0.04))
