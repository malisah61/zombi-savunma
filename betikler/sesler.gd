extends Node
## Oyunun sesleri kodla üretilir (dosya gerekmez). Gerçek ses dosyaları bulununca
## assets/sesler/ altına konup burada yüklenebilir: aynı adlı .ogg/.wav varsa o kullanılır.

const ORAN := 22050
var _oynaticilar := {}


func _ready() -> void:
	_ekle("atis", 0.16, -14.0, 8)
	_ekle("isabet", 0.12, -12.0, 6)
	_ekle("olum", 0.45, -10.0, 4)
	_ekle("barikat", 0.25, -9.0, 3)
	_ekle("dalga", 1.1, -8.0, 1)
	_ekle("kart", 0.35, -8.0, 1)
	_ekle("bitis", 1.6, -6.0, 1)
	_ekle("altin", 0.18, -14.0, 3)
	_ekle("zirh", 0.1, -13.0, 4)
	_ekle("asit", 0.3, -12.0, 3)
	_ekle("boss", 0.9, -5.0, 2)
	_ekle("evrim", 0.7, -7.0, 1)


func cal(ad: String) -> void:
	var o: AudioStreamPlayer = _oynaticilar.get(ad)
	if o:
		o.pitch_scale = randf_range(0.92, 1.08)
		o.play()


func _ekle(ad: String, sure: float, db: float, cokses: int) -> void:
	var o := AudioStreamPlayer.new()
	var dosya := "res://assets/sesler/%s.ogg" % ad
	if ResourceLoader.exists(dosya):
		o.stream = load(dosya)
	else:
		o.stream = _uret(ad, sure)
	o.volume_db = db
	o.max_polyphony = cokses
	add_child(o)
	_oynaticilar[ad] = o


func _uret(tur: String, sure: float) -> AudioStreamWAV:
	var n := int(sure * ORAN)
	var veri := PackedByteArray()
	veri.resize(n * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(tur)
	var suz := 0.0
	var faz := 0.0
	for i in n:
		var t := float(i) / ORAN
		var g := rng.randf_range(-1.0, 1.0)
		var s := 0.0
		match tur:
			"atis":
				suz += (g - suz) * 0.5
				s = suz * exp(-t * 38.0) * 1.4 + sin(TAU * 70.0 * t) * exp(-t * 30.0) * 0.8
			"isabet":
				suz += (g - suz) * 0.15
				s = suz * exp(-t * 30.0) * 2.0
			"olum":
				faz += TAU * (95.0 - t * 90.0 + sin(t * 40.0) * 12.0) / ORAN
				suz += (g - suz) * 0.08
				s = (signf(sin(faz)) * 0.35 + suz * 1.5) * minf(t / 0.03, 1.0) * exp(-t * 6.0)
			"barikat":
				suz += (g - suz) * 0.1
				s = (sin(TAU * 55.0 * t) * 0.9 + suz * 1.6) * exp(-t * 18.0)
			"dalga":
				faz += TAU * (180.0 + 40.0 * minf(t * 3.0, 1.0)) / ORAN
				var zarf := minf(t / 0.08, 1.0) * clampf((sure - t) / 0.4, 0.0, 1.0)
				s = (sin(faz) * 0.6 + sin(faz * 2.0) * 0.25 + sin(faz * 3.0) * 0.1) * zarf
			"kart":
				var nota := 523.0 if t < 0.11 else (659.0 if t < 0.22 else 784.0)
				faz += TAU * nota / ORAN
				s = sin(faz) * 0.5 * exp(-fmod(t, 0.11) * 12.0)
			"bitis":
				faz += TAU * (220.0 - t * 70.0) / ORAN
				s = (sin(faz) * 0.5 + sin(faz * 0.5) * 0.3) * minf(t / 0.05, 1.0) * clampf((sure - t) / 0.6, 0.0, 1.0)
			"zirh":
				faz += TAU * 2100.0 / ORAN
				s = (sin(faz) * 0.5 + sin(faz * 1.47) * 0.3) * exp(-t * 45.0)
			"asit":
				suz += (g - suz) * 0.3
				s = suz * 1.6 * sin(t * 60.0) * sin(t * 60.0) * exp(-t * 7.0)
			"boss":
				faz += TAU * (62.0 + sin(t * 26.0) * 16.0) / ORAN
				suz += (g - suz) * 0.06
				s = (signf(sin(faz)) * 0.45 + suz * 2.0) * minf(t / 0.1, 1.0) * clampf((sure - t) / 0.3, 0.0, 1.0)
			"evrim":
				var nota := 523.0 if t < 0.12 else (784.0 if t < 0.24 else 1047.0)
				faz += TAU * nota / ORAN
				s = (sin(faz) * 0.4 + sin(faz * 2.0) * 0.15) * exp(-fmod(t, 0.24) * 5.0)
			"altin":
				faz += TAU * (1320.0 if t < 0.06 else 1760.0) / ORAN
				s = sin(faz) * 0.4 * exp(-t * 18.0)
		veri.encode_s16(i * 2, int(clampf(s, -1.0, 1.0) * 30000.0))
	var akis := AudioStreamWAV.new()
	akis.format = AudioStreamWAV.FORMAT_16_BITS
	akis.mix_rate = ORAN
	akis.data = veri
	return akis
