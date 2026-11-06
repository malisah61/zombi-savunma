extends RefCounted
## Zombilerin görünüşü tek yerde: hem atlasa pişirirken hem de atlas yoksa (yedek yol) doğrudan
## çizerken kullanılır. Yeni tür için `_susleme` içine ayırt edici şeklini ekle.
## m: merkez, o: ölçek (atlas için). yurume: -1..1 adım evresi, ileri: öne hamle pikseli.

static func ciz(ci: CanvasItem, tur: String, r: float, gomlek: Color, ten: Color, yurume: float, ileri: float,
		m: Vector2 = Vector2.ZERO, o: float = 1.0) -> void:
	# gölge
	ci.draw_set_transform(m + Vector2(3, 8) * o, 0.0, Vector2(1.25, 0.55) * o)
	ci.draw_circle(Vector2.ZERO, r, Color(0, 0, 0, 0.28))
	ci.draw_set_transform(m, 0.0, Vector2(o, o))

	# kollar (öne uzanmış, sallanıyor)
	var omuz_sol := Vector2(-r * 0.72, 0)
	var omuz_sag := Vector2(r * 0.72, 0)
	var el_sol := omuz_sol + Vector2(-2 + yurume * 3.0, r * 1.15 + yurume * 5.0 + ileri)
	var el_sag := omuz_sag + Vector2(2 - yurume * 3.0, r * 1.15 - yurume * 5.0 + ileri)
	ci.draw_line(omuz_sol, el_sol, gomlek.darkened(0.15), r * 0.42, true)
	ci.draw_line(omuz_sag, el_sag, gomlek.darkened(0.15), r * 0.42, true)
	ci.draw_circle(el_sol, r * 0.22, ten)
	ci.draw_circle(el_sag, r * 0.22, ten)

	# gövde (yırtık gömlek)
	ci.draw_circle(Vector2(0, -2), r * 0.78, gomlek)
	ci.draw_circle(Vector2(-r * 0.3, r * 0.15), r * 0.22, gomlek.darkened(0.3))
	ci.draw_circle(Vector2(r * 0.35, -r * 0.35), r * 0.15, Color(0.45, 0.05, 0.05, 0.8))

	# kafa (öne eğik)
	var kafa := Vector2(yurume * 1.5, r * 0.28 + ileri * 0.4)
	_susleme_govde(ci, tur, r)
	ci.draw_circle(kafa, r * 0.5, ten)
	ci.draw_circle(kafa + Vector2(-r * 0.12, -r * 0.18), r * 0.2, ten.darkened(0.25))
	ci.draw_circle(kafa + Vector2(-r * 0.18, r * 0.2), r * 0.09, Color(0.9, 0.1, 0.05))
	ci.draw_circle(kafa + Vector2(r * 0.18, r * 0.2), r * 0.09, Color(0.9, 0.1, 0.05))
	_susleme_kafa(ci, tur, r, kafa)
	ci.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


static func _susleme_govde(ci: CanvasItem, tur: String, r: float) -> void:
	match tur:
		"zirhli":
			# polis yeleği: omuz plakaları ve göğüs levhası
			var metal := Color("6f7780")
			ci.draw_circle(Vector2(-r * 0.68, -r * 0.1), r * 0.3, metal)
			ci.draw_circle(Vector2(r * 0.68, -r * 0.1), r * 0.3, metal)
			ci.draw_rect(Rect2(-r * 0.55, -r * 0.7, r * 1.1, r * 0.75), Color("3d444c"))
			ci.draw_rect(Rect2(-r * 0.55, -r * 0.7, r * 1.1, r * 0.12), metal)
			ci.draw_circle(Vector2(-r * 0.35, -r * 0.3), r * 0.05, Color("aab2ba"))
			ci.draw_circle(Vector2(r * 0.35, -r * 0.3), r * 0.05, Color("aab2ba"))
		"kusan":
			# şişkin, parlayan zehir keseleri
			var kese := Color("8fd13f")
			ci.draw_circle(Vector2(-r * 0.42, -r * 0.42), r * 0.34, kese.darkened(0.25))
			ci.draw_circle(Vector2(r * 0.4, -r * 0.5), r * 0.28, kese.darkened(0.2))
			ci.draw_circle(Vector2(-r * 0.48, -r * 0.5), r * 0.14, kese)
			ci.draw_circle(Vector2(r * 0.36, -r * 0.56), r * 0.11, kese)
		"patlayan":
			# şişmiş, içi parlayan karın ve fitil
			ci.draw_circle(Vector2(0, -r * 0.2), r * 0.72, Color("a8431c"))
			ci.draw_circle(Vector2(-r * 0.1, -r * 0.28), r * 0.46, Color("e8791f"))
			ci.draw_circle(Vector2(-r * 0.16, -r * 0.34), r * 0.22, Color("ffd24a"))
			ci.draw_line(Vector2(r * 0.4, -r * 0.7), Vector2(r * 0.62, -r * 1.02), Color("2b2b2b"), 3.0, true)
			ci.draw_circle(Vector2(r * 0.64, -r * 1.05), r * 0.12, Color("ffe08a"))
		"kralice":
			# pelerin ve sırtındaki yumurta keseleri
			ci.draw_circle(Vector2(0, -r * 0.35), r * 0.85, Color("3d1f33"))
			for i in 4:
				var a := PI * (1.15 + i * 0.23)
				ci.draw_circle(Vector2.from_angle(a) * r * 0.62 + Vector2(0, -r * 0.1), r * 0.2, Color("c9d97a"))
				ci.draw_circle(Vector2.from_angle(a) * r * 0.62 + Vector2(-r * 0.04, -r * 0.14), r * 0.08, Color("eef5b0"))
			ci.draw_circle(Vector2(0, -r * 0.05), r * 0.5, Color("6e3a5c"))
		"dev":
			# kaslı omuzlar, bel zinciri ve dikişler
			var et := Color("6d7f4c")
			ci.draw_circle(Vector2(-r * 0.62, -r * 0.2), r * 0.42, et)
			ci.draw_circle(Vector2(r * 0.62, -r * 0.2), r * 0.42, et)
			for i in 5:
				var x := -r * 0.5 + i * r * 0.25
				ci.draw_circle(Vector2(x, -r * 0.62 + absf(x) * 0.15), r * 0.09, Color("555b60"))
			ci.draw_line(Vector2(-r * 0.2, -r * 0.3), Vector2(r * 0.22, -r * 0.05), Color("3a1a12"), 3.0, true)
			ci.draw_line(Vector2(-r * 0.1, -r * 0.27), Vector2(-r * 0.04, -r * 0.14), Color("3a1a12"), 2.0, true)


static func _susleme_kafa(ci: CanvasItem, tur: String, r: float, kafa: Vector2) -> void:
	match tur:
		"zirhli":
			# kask
			ci.draw_arc(kafa, r * 0.52, PI * 1.02, TAU * 0.99, 14, Color("2d3238"), r * 0.3, true)
			ci.draw_rect(Rect2(kafa.x - r * 0.52, kafa.y - r * 0.02, r * 1.04, r * 0.08), Color("6f7780"))
		"kusan":
			# damlayan ağız
			ci.draw_circle(kafa + Vector2(0, r * 0.38), r * 0.15, Color("b6f04a"))
			ci.draw_circle(kafa + Vector2(r * 0.06, r * 0.56), r * 0.07, Color("b6f04a"))
		"kralice":
			# taç (üstten bakış: başın çevresinde altın sivri uçlar ve ortada yakut)
			var altin := Color("e8c24a")
			for i in 6:
				var u := kafa + Vector2.from_angle(TAU * i / 6.0) * r * 0.36
				ci.draw_rect(Rect2(u.x - r * 0.08, u.y - r * 0.08, r * 0.16, r * 0.16), altin)
			ci.draw_circle(kafa, r * 0.09, Color("d13a5a"))
		"dev":
			# kırık diş ve yara izi
			ci.draw_rect(Rect2(kafa.x - r * 0.16, kafa.y + r * 0.34, r * 0.1, r * 0.13), Color("e8e0c0"))
			ci.draw_rect(Rect2(kafa.x + r * 0.08, kafa.y + r * 0.34, r * 0.1, r * 0.13), Color("e8e0c0"))
			ci.draw_line(kafa + Vector2(r * 0.05, -r * 0.3), kafa + Vector2(r * 0.3, r * 0.05), Color("5a1a12"), 2.5, true)
