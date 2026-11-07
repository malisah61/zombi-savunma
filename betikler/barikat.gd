extends Node2D
## Ekranın altındaki barikat: kum torbaları + tahta çit. Can azaldıkça tahtalar kırılır.
## Kum torbası, direk ve tel bir kez dokuya pişirilir (çok sayıda çokgen = çok çizim çağrısı);
## yalnızca tahtalar can değiştikçe yeniden çizilir.
## A2 Zayıf nokta (Gece 4): barikat 6 bölümdür; her bölümün canı ayrı, üstünde küçük çubuğu görünür.
## Zombi vurduğu x'teki bölüme hasar verir. Bölüm kırılınca GEDİK olur: oraya gelen hasar ×1.5 olarak
## en yakın sağlam bölümlere taşar. Toplam can (`can`) eskisi gibi tek sayı olarak okunur ve yazılır;
## dışarıdan `can = x` yazmak bütün bölümleri aynı orana getirir (eski kod bozulmaz).

const DOKU_UST := -60.0
const DOKU_BOY := 150.0
const OLCEK := 1.5

var oyun  # oyun.gd
var sadece_sabit := false  # pişirme kopyası
var _doku: Texture2D
const BOLUM := 6
const GEDIK_CARPAN := 1.5
const ONARIM_PAYI := 0.05  # akıllı onarım: en zayıf bölüme bölüm canının %5'i kadar dilimlerle

var can: float:
	get:
		return _can
	set(deger):
		_hepsini_ayarla(deger)
var max_can: float:
	get:
		return _max_can
	set(deger):
		_max_ayarla(deger)
var _can := 300.0
var _max_can := 300.0
var _bolum := PackedFloat32Array([50.0, 50.0, 50.0, 50.0, 50.0, 50.0])
var _kirli := true
var _parlama := 0.0
var _sarsinti := 0.0
var _rng := RandomNumberGenerator.new()
var _cizim_rng := RandomNumberGenerator.new()
var _son_oran := -1.0


func pisir() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(ceili(oyun.genislik * OLCEK), ceili(DOKU_BOY * OLCEK))
	vp.transparent_bg = true
	vp.disable_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ONCE
	var kopya := Node2D.new()
	kopya.set_script(get_script())
	kopya.oyun = oyun
	kopya.sadece_sabit = true
	kopya.set_process(false)
	kopya.scale = Vector2(OLCEK, OLCEK)
	kopya.position = Vector2(0, -DOKU_UST * OLCEK)
	vp.add_child(kopya)
	add_child(vp)
	await RenderingServer.frame_post_draw
	await RenderingServer.frame_post_draw
	var img: Image = vp.get_texture().get_image()
	if img != null and not img.is_empty():
		_doku = ImageTexture.create_from_image(img)
		queue_redraw()
	vp.queue_free()


func _process(delta: float) -> void:
	if sadece_sabit:
		return
	# yalnızca bir şey değiştiğinde yeniden çiz (performans)
	var oran := snappedf(can / max_can, 0.02)
	if _parlama <= 0.0 and _sarsinti <= 0.0 and oran == _son_oran and not _kirli:
		return
	_son_oran = oran
	_kirli = false
	_parlama = maxf(_parlama - delta * 5.0, 0.0)
	_sarsinti = maxf(_sarsinti - delta * 40.0, 0.0)
	position.x = randf_range(-_sarsinti, _sarsinti)
	queue_redraw()


# ---------------------------------------------------------------- bölümler (A2)

func bolum_max() -> float:
	return _max_can / BOLUM


func bolum_no(x: float) -> int:
	return clampi(int(x / oyun.genislik * BOLUM), 0, BOLUM - 1)


func bolum_orani(i: int) -> float:
	return _bolum[i] / bolum_max()


func bolum_merkez(i: int) -> float:
	return (i + 0.5) * oyun.genislik / BOLUM


## En zayıf bölüm (en düşük oran) ve oranı.
func en_zayif() -> int:
	var en := 0
	for i in BOLUM:
		if _bolum[i] < _bolum[en]:
			en = i
	return en


func gedik_sayisi() -> int:
	var n := 0
	for i in BOLUM:
		if _bolum[i] <= 0.0:
			n += 1
	return n


## Zombi yapay zekâsı: x'teki zombi için hedef bölüm. Zayıf bölüm çeker, uzak bölüm cezalanır
## (bölüm başına 0.12 oran): zombi ekranın öbür ucuna koşmaz, yakındaki zayıf noktayı seçer.
func hedef_bolum(x: float) -> int:
	var simdi := bolum_no(x)
	var en := simdi
	var en_puan := INF
	var bm := bolum_max()
	for i in BOLUM:
		var puan := _bolum[i] / bm + absi(i - simdi) * 0.12
		if puan < en_puan:
			en_puan = puan
			en = i
	return en


## x < 0: hasar sağlam bölümlere eşit dağılır (bölgesi olmayan hasar).
func hasar_al(miktar: float, x: float = -1.0) -> void:
	if x < 0.0:
		var saglam := BOLUM - gedik_sayisi()
		if saglam <= 0:
			_can = 0.0
		else:
			for i in BOLUM:
				if _bolum[i] > 0.0:
					_bolum_vur(i, miktar / saglam)
	else:
		_bolum_vur(bolum_no(x), miktar)
	_toplami_guncelle()
	_parlama = 1.0
	_sarsinti = minf(_sarsinti + 3.0, 6.0)
	_kirli = true


func _bolum_vur(i: int, miktar: float) -> void:
	if _bolum[i] <= 0.0:
		_tas(i, miktar * GEDIK_CARPAN)  # gedikten giren hasar yanlara büyüyerek taşar
		return
	var kalan := miktar - _bolum[i]
	_bolum[i] = maxf(_bolum[i] - miktar, 0.0)
	if _bolum[i] <= 0.0:
		if oyun and oyun.has_method("gedik_acildi"):
			oyun.gedik_acildi(i)
		if kalan > 0.0:
			_tas(i, kalan)


## Hasarı i'ye en yakın sağlam bölüme verir (eşitlikte rastgele taraf). Sağlam bölüm yoksa barikat düşer.
func _tas(i: int, miktar: float) -> void:
	for uzak in range(1, BOLUM):
		var sol := i - uzak
		var sag := i + uzak
		var sol_iyi := sol >= 0 and _bolum[sol] > 0.0
		var sag_iyi := sag < BOLUM and _bolum[sag] > 0.0
		if sol_iyi and sag_iyi:
			_bolum_vur(sol if _rng.randf() < 0.5 else sag, miktar)
			return
		if sol_iyi:
			_bolum_vur(sol, miktar)
			return
		if sag_iyi:
			_bolum_vur(sag, miktar)
			return


## ONAR v2 (akıllı onarım): onarım önce en zayıf bölüme gider; gedikler önce kapanır.
func onar(oran: float) -> void:
	var miktar := _max_can * oran
	var bm := bolum_max()
	var dilim := bm * ONARIM_PAYI
	var tur := 0
	while miktar > 0.0001 and tur < 200:
		tur += 1
		var i := en_zayif()
		if _bolum[i] >= bm:
			break
		var ekle := minf(minf(miktar, dilim), bm - _bolum[i])
		_bolum[i] += ekle
		miktar -= ekle
	_toplami_guncelle()
	_kirli = true


func _hepsini_ayarla(deger: float) -> void:
	var oran := clampf(deger / _max_can, 0.0, 1.0) if _max_can > 0.0 else 0.0
	for i in BOLUM:
		_bolum[i] = bolum_max() * oran
	_toplami_guncelle()
	_kirli = true


func _max_ayarla(deger: float) -> void:
	var eski := _max_can
	_max_can = maxf(deger, 1.0)
	if eski > 0.0:
		var k := _max_can / eski
		for i in BOLUM:
			_bolum[i] *= k
	_toplami_guncelle()
	_kirli = true


func _toplami_guncelle() -> void:
	var t := 0.0
	for i in BOLUM:
		t += _bolum[i]
	_can = t


func _draw() -> void:
	var w: float = oyun.genislik
	var kirmizi := Color(1, 0.3, 0.3)
	if _doku:
		draw_texture_rect(_doku, Rect2(0, DOKU_UST, w, DOKU_BOY), false, Color.WHITE.lerp(kirmizi, _parlama * 0.35))
	else:
		_sabit_ciz(w, kirmizi)
	if sadece_sabit:
		return

	# tahtalar: bölümün canı azaldıkça o bölümdeki parçalar kırılır (A2)
	var cizim_rng := _cizim_rng
	cizim_rng.seed = 11
	var parca := 12
	var pw := w / parca
	var bm := bolum_max()
	for sira in 2:
		var y := -22.0 + sira * 24.0
		for i in parca:
			var esik := cizim_rng.randf()
			var b_oran := _bolum[int(i * BOLUM / float(parca))] / bm
			if esik > b_oran + 0.08 or b_oran <= 0.0:
				# kırık tahta: kısa, eğri parça
				draw_set_transform(Vector2(i * pw + pw * 0.3, y + 8), cizim_rng.randf_range(-0.4, 0.4), Vector2.ONE)
				draw_rect(Rect2(0, 0, pw * 0.35, 14), Color("6b4a2f").darkened(0.3))
				draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
				continue
			var renk := Color("8b5e3c").darkened(cizim_rng.randf_range(0.0, 0.2)).lerp(kirmizi, _parlama * 0.4)
			draw_rect(Rect2(i * pw, y, pw + 1, 18), renk)
			draw_line(Vector2(i * pw + 4, y + 9), Vector2(i * pw + pw - 6, y + 8), renk.darkened(0.3), 2.0)
			# çiviler dikdörtgen: çokgen çizim çağrısı üretmez
			draw_rect(Rect2(i * pw + 4, y + 7, 4, 4), Color("3b3b3b"))
			draw_rect(Rect2(i * pw + pw - 8, y + 7, 4, 4), Color("3b3b3b"))
	# bölüm can çubukları (dikdörtgen: tek partide birleşir) ve gedik işareti
	var bw := w / BOLUM
	for i in BOLUM:
		var bo := _bolum[i] / bm
		var x0 := i * bw + 10.0
		draw_rect(Rect2(x0, -52, bw - 20.0, 8), Color(0, 0, 0, 0.55))
		if bo > 0.0:
			draw_rect(Rect2(x0, -52, (bw - 20.0) * bo, 8), Color(0.9, 0.2, 0.15).lerp(Color(0.35, 0.85, 0.3), bo))
		else:
			# GEDİK: kırmızı çerçeve + yere düşmüş çapraz tahta
			draw_rect(Rect2(x0, -52, bw - 20.0, 8), Color(1, 0.15, 0.1, 0.9), false, 2.0)
			draw_rect(Rect2(i * bw + 6.0, -30, bw - 12.0, 56), Color(0.6, 0.05, 0.02, 0.22))


func _sabit_ciz(w: float, _kirmizi: Color) -> void:
	# kum torbaları (iki sıra)
	_rng.seed = 7
	for sira in 2:
		var y := 34.0 + sira * 22.0
		var x := -20.0 + sira * 22.0
		while x < w + 40.0:
			var renk := Color("b9a07a").darkened(_rng.randf_range(0.0, 0.18))
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

	# dikenli tel
	var tel := Color(0.65, 0.65, 0.68)
	var x := 0.0
	while x < w:
		draw_arc(Vector2(x + 12, -34), 12.0, PI, TAU, 8, tel, 2.0)
		draw_line(Vector2(x + 6, -40), Vector2(x + 18, -28), tel, 1.5)
		x += 24.0
