extends Node2D
## Performans v4: uçan hasar/altın yazıları TEK düğümde çizilir. Eskiden 32 ayrı Label vardı; her biri
## (dış çizgisiyle) en az iki ayrı çizim çağrısıydı ve her biri ayrı Tween taşıyordu. Burada sabit boyutlu
## bir dizi döner (havuz), yazı yoksa _draw hiç çağrılmaz. Harfler aynı yazı tipi dokusundan geldiği için
## renk ve boyut farklı olsa da çizimler birleşebilir.

const SINIR := 40
const OMUR := 0.7
const SOLMA_GECIKME := 0.25
const YUKSELME := 60.0

var _font: Font
# Paralel diziler: her kare sözlük oluşturmamak için (çöp toplayıcı yok ama ayırma maliyeti var)
var _metin: PackedStringArray = PackedStringArray()
var _konum: PackedVector2Array = PackedVector2Array()
var _renk: PackedColorArray = PackedColorArray()
var _boyut: PackedInt32Array = PackedInt32Array()
var _genislik: PackedFloat32Array = PackedFloat32Array()
var _yas: PackedFloat32Array = PackedFloat32Array()
var _sira := 0
var _aktif := 0


func _ready() -> void:
	_font = ThemeDB.fallback_font
	_metin.resize(SINIR)
	_konum.resize(SINIR)
	_renk.resize(SINIR)
	_boyut.resize(SINIR)
	_genislik.resize(SINIR)
	_yas.resize(SINIR)
	for i in SINIR:
		_yas[i] = OMUR  # boş
	set_process(false)


## Eski Label havuzuyla aynı davranış: en eskisinin üstüne yazar, yazı yukarı süzülüp söner.
func yaz(konum: Vector2, metin: String, renk: Color, boyut: int) -> void:
	var i := _sira
	_sira = (_sira + 1) % SINIR
	if _yas[i] >= OMUR:
		_aktif += 1
	_metin[i] = metin
	_konum[i] = konum
	_renk[i] = renk
	_boyut[i] = boyut
	_genislik[i] = _font.get_string_size(metin, HORIZONTAL_ALIGNMENT_LEFT, -1, boyut).x
	_yas[i] = 0.0
	set_process(true)


func temizle() -> void:
	for i in SINIR:
		_yas[i] = OMUR
	_aktif = 0
	set_process(false)
	queue_redraw()


func aktif_sayisi() -> int:
	return _aktif


func _process(delta: float) -> void:
	_aktif = 0
	for i in SINIR:
		if _yas[i] < OMUR:
			_yas[i] += delta
			if _yas[i] < OMUR:
				_aktif += 1
	queue_redraw()
	if _aktif == 0:
		set_process(false)  # son kare boş çizilir, sonra hiç işlem yok


func _draw() -> void:
	for i in SINIR:
		var t := _yas[i]
		if t >= OMUR:
			continue
		var oran := t / OMUR
		# Label'daki EASE_OUT ile aynı his: hızlı çıkar, yavaşlar
		var y := -YUKSELME * (1.0 - (1.0 - oran) * (1.0 - oran))
		var a := 1.0 if t < SOLMA_GECIKME else 1.0 - (t - SOLMA_GECIKME) / (OMUR - SOLMA_GECIKME)
		var boy := _boyut[i]
		var p := _konum[i] + Vector2(-_genislik[i] / 2.0, y + boy * 0.35)
		var r := _renk[i]
		r.a *= a
		draw_string_outline(_font, p, _metin[i], HORIZONTAL_ALIGNMENT_LEFT, -1, boy, 8, Color(0, 0, 0, 0.9 * a))
		draw_string(_font, p, _metin[i], HORIZONTAL_ALIGNMENT_LEFT, -1, boy, r)
