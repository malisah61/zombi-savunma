extends Node
## Performans v2: zombi kareleri açılışta BİR KEZ tek dokuya pişirilir. Oyun sırasında her zombi yalnızca
## bu dokudan bir bölge çizer: yüzlerce zombi tek çizim partisine sığar, her kare yeniden şekil çizilmez.
## Pişirme başarısız olursa (eski sürücü vb.) `hazir` false kalır ve zombi.gd yedek yola, doğrudan çizime döner.

const ZombiCizim := preload("res://betikler/zombi_cizim.gd")
const ZombiBetik := preload("res://betikler/zombi.gd")
const LekeBetik := preload("res://betikler/leke.gd")

const KARE := 4               # yürüme karesi sayısı
const HUCRE := 110.0          # normal zombi hücresi (mantıksal piksel)
const HUCRE_DEV := 300.0      # boss hücresi
const OLCEK := 1.4            # doku çözünürlüğü (telefonda keskin dursun)
const OLCEK_DEV := 1.2
const GENISLIK := 1024

var hazir := false
var doku: Texture2D
var _bolgeler := {}  # "tur|varyant" -> Array[Rect2]
var _leke_bolgeleri: Array[Rect2] = []
var _isler: Array = []  # {tur, r, gomlek, ten, merkez, olcek}


class Cizer extends Node2D:
	var isler: Array = []

	func _draw() -> void:
		for i in isler:
			if i.has("leke"):
				draw_set_transform(i["merkez"], 0.0, Vector2(i["olcek"], i["olcek"]))
				for p in i["leke"]:
					draw_circle(Vector2(p.x, p.y), p.z, LekeBetik.RENK)
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				continue
			ZombiCizim.ciz(self, i["tur"], i["r"], i["gomlek"], i["ten"], i["yurume"], 0.0, i["merkez"], i["olcek"])


func pisir() -> void:
	var px := int(HUCRE * OLCEK)
	var px_dev := int(HUCRE_DEV * OLCEK_DEV)
	var sutun := int(GENISLIK / float(px))
	var i := 0
	for tur in ZombiBetik.TURLER:
		var t: Dictionary = ZombiBetik.TURLER[tur]
		if bool(t.get("boss", false)):
			continue
		for v in t["gomlek"].size():
			var kareler: Array[Rect2] = []
			for k in KARE:
				var konum := Vector2((i % sutun) * px, (i / sutun) * px)
				kareler.append(Rect2(konum, Vector2(px, px)))
				_is_ekle(tur, t, v, k, konum + Vector2(px, px) / 2.0, OLCEK)
				i += 1
			_bolgeler["%s|%d" % [tur, v]] = kareler
	for l in LekeBetik.VARYANT:
		var konum := Vector2((i % sutun) * px, (i / sutun) * px)
		_leke_bolgeleri.append(Rect2(konum, Vector2(px, px)))
		_isler.append({"leke": LekeBetik.sekil_uret(), "merkez": konum + Vector2(px, px) / 2.0, "olcek": OLCEK})
		i += 1
	var y := (ceili(float(i) / sutun)) * px
	for tur in ZombiBetik.TURLER:
		var t: Dictionary = ZombiBetik.TURLER[tur]
		if not bool(t.get("boss", false)):
			continue
		var kareler: Array[Rect2] = []
		for k in KARE:
			var konum := Vector2((k % 2) * px_dev, y + (k / 2) * px_dev)
			kareler.append(Rect2(konum, Vector2(px_dev, px_dev)))
			_is_ekle(tur, t, 0, k, konum + Vector2(px_dev, px_dev) / 2.0, OLCEK_DEV)
		_bolgeler["%s|0" % tur] = kareler
		y += px_dev * 2

	var vp := SubViewport.new()
	vp.size = Vector2i(GENISLIK, y)
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.msaa_2d = Viewport.MSAA_4X
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var c := Cizer.new()
	c.isler = _isler
	vp.add_child(c)
	add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var dok := vp.get_texture()
	var img: Image = dok.get_image() if dok else null
	if img != null and not img.is_empty() and img.is_invisible() == false:
		doku = ImageTexture.create_from_image(img)
		hazir = true
	else:
		push_warning("Zombi atlası pişirilemedi, doğrudan çizime dönülüyor")
	vp.queue_free()
	_isler = []


func _is_ekle(tur: String, t: Dictionary, v: int, k: int, merkez: Vector2, olcek: float) -> void:
	_isler.append({"tur": tur, "r": float(t["yaricap"]), "gomlek": t["gomlek"][v], "ten": t["ten"],
		"yurume": sin(TAU * k / float(KARE)), "merkez": merkez, "olcek": olcek})


func leke_bolgesi(varyant: int) -> Rect2:
	return _leke_bolgeleri[varyant]


func bolge(tur: String, varyant: int, kare: int) -> Rect2:
	return _bolgeler["%s|%d" % [tur, varyant]][kare]
