extends Node2D
## Tek bir zombi. Yukarıdan aşağı yürür, barikata varınca vurur. Kusan uzakta durup asit atar,
## boss (Dev) vuruşunu önceden işaret eder ve yarı canda yardım çağırır.
## Yeni tür eklemek için TURLER sözlüğüne bir kayıt ekle; görünüşü zombi_cizim.gd içinde.
## Çizim: açılışta pişirilen atlastan tek bölge (Performans v2); yalnızca kare değişince yeniden çizilir.

const ZombiCizim := preload("res://betikler/zombi_cizim.gd")

# zirh: mermi başına düşülen düz hasar (dalgayla artar, en az %20 hasar geçer).
# oncelik: kahramanın hedef seçiminde "barikata bu kadar piksel daha yakınmış" gibi sayılır.
const TURLER := {
	"yuruyen": {"can": 30.0, "hiz": 52.0, "hasar": 6.0, "yaricap": 30.0, "altin": 2,
		"gomlek": [Color("5d6b7a"), Color("7a5c4d"), Color("4f6b4a"), Color("6b4f6b")], "ten": Color("8fae6b")},
	"kosucu": {"can": 15.0, "hiz": 135.0, "hasar": 4.0, "yaricap": 24.0, "altin": 3,
		"gomlek": [Color("8c3b3b"), Color("a35a2a")], "ten": Color("a7b86d")},
	"zirhli": {"can": 46.0, "hiz": 40.0, "hasar": 9.0, "yaricap": 32.0, "altin": 5, "zirh": 4.0, "zirh_artis": 0.35,
		"gomlek": [Color("2f3a4a"), Color("3a3f35")], "ten": Color("86a06a")},
	"kusan": {"can": 26.0, "hiz": 44.0, "hasar": 9.0, "yaricap": 30.0, "altin": 5, "oncelik": 260.0, "durus": 330.0,
		"gomlek": [Color("5c6b2c"), Color("6b5a2c")], "ten": Color("9cc25a")},
	"patlayan": {"can": 20.0, "hiz": 78.0, "hasar": 34.0, "yaricap": 28.0, "altin": 6, "oncelik": 200.0, "patlar": true,
		"gomlek": [Color("7a3b1f"), Color("6b2f2f")], "ten": Color("b5a55a")},
	"dev": {"can": 480.0, "hiz": 27.0, "hasar": 32.0, "yaricap": 76.0, "altin": 40, "oncelik": 140.0, "boss": true,
		"zirh": 2.0, "zirh_artis": 0.1, "gomlek": [Color("4d4436")], "ten": Color("7d9a58")},
	# Boss 2: geride durur, 4 sn'de bir 2 koşucu doğurur; doğurma hakkı bitince barikata yürür.
	"kralice": {"can": 520.0, "hiz": 22.0, "hasar": 26.0, "yaricap": 66.0, "altin": 50, "oncelik": 140.0, "boss": true,
		"kralice": true, "gomlek": [Color("5a2f4a")], "ten": Color("8fa070")},
}
const DEV_HAZIRLIK := 1.3  # Dev'in vuruşunu işaret ettiği süre: oyuncu görür, onarıma koşar
const DEV_ARA := 1.5
const KUSMA_ARA := 2.8
const PATLAMA_UYARI := 260.0
const KRALICE_ARA := 4.0
const KRALICE_HAK := 6      # 6 × 2 = 12 koşucu, sonra kendisi saldırır
const KRALICE_DURUS := 420.0
# Boss aşamaları (A4): can %66 ve %33'te davranış değişir
const ASAMA_1 := 0.66
const ASAMA_2 := 0.33
const DEV_OFKE_HIZ := 1.5
const DEV_SICRAMA_SURE := 0.9   # uyarı halkasının dolma süresi
const DEV_SICRAMA_MESAFE := 240.0
const KRALICE_HIZLI_ARA := 2.5

var oyun  # oyun.gd
var tur := "yuruyen"
var can := 30.0
var max_can := 30.0
var hiz := 52.0
var hasar := 6.0
var yaricap := 24.0
var altin_degeri := 2
var zirh := 0.0
var oncelik := 0.0
var boss := false
var olu := false
var beklenen := 0.0  # Ekip yapay zekâsı: yoldaki mermilerin bu zombiye getireceği hasar
var kralice := false
var _dogurma_sayac := 0.0
var _dogurma_hak := 0
var _dogurma_ara := KRALICE_ARA
var asama := 0  # 0 normal, 1 (%66 altı), 2 (%33 altı)
var _sicrama := 0.0  # Dev: >0 iken iniş yeri işaretli, dolunca oraya sıçrar
var _sicrama_y := 0.0

var _gomlek := Color.GRAY
var _ten := Color.GREEN
var _varyant := 0
var _kare := 0
var _taban_renk := Color.WHITE
var _yakilmis := false
var _zaman := 0.0
var _faz := 0.0
var _parlama := 0.0
var _saldiri_sayac := 0.0
var _hamle := 0.0  # barikata vurma animasyonu
var _durus_y := 0.0
var _hazirlik := 0.0  # Dev: vuruş işareti
var _cagirdi := false
var _yanma_kalan := 0.0
var _yanma_dps := 0.0
var _yanma_sayac := 0.0


func kur(o, t: String, can_carpani: float, hasar_carpani: float = 1.0) -> void:
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
	_hazirlik = 0.0
	_cagirdi = false
	_yanma_kalan = 0.0
	_yakilmis = false
	beklenen = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 0.6)
	var veri: Dictionary = TURLER[t]
	max_can = float(veri["can"]) * can_carpani
	can = max_can
	hiz = float(veri["hiz"]) * randf_range(0.9, 1.12)
	hasar = float(veri["hasar"]) * hasar_carpani
	yaricap = float(veri["yaricap"])
	altin_degeri = int(veri["altin"])
	zirh = float(veri.get("zirh", 0.0)) + float(veri.get("zirh_artis", 0.0)) * oyun.dalga
	oncelik = float(veri.get("oncelik", 0.0))
	boss = bool(veri.get("boss", false))
	kralice = bool(veri.get("kralice", false))
	_dogurma_sayac = 2.5
	_dogurma_hak = KRALICE_HAK
	_dogurma_ara = KRALICE_ARA
	asama = 0
	_sicrama = 0.0
	var gomlekler: Array = veri["gomlek"]
	_varyant = randi() % gomlekler.size()
	_gomlek = gomlekler[_varyant]
	_ten = (veri["ten"] as Color).lerp(Color(randf(), randf(), randf()), 0.08)
	var parlaklik := randf_range(0.88, 1.06)
	_taban_renk = Color(parlaklik, parlaklik, parlaklik)
	self_modulate = _taban_renk
	_faz = randf() * TAU
	_saldiri_sayac = randf_range(0.2, 0.8) if not veri.has("durus") else randf_range(0.5, 1.5)
	_durus_y = oyun.barikat_y - float(veri["durus"]) + randf_range(-50.0, 50.0) if veri.has("durus") else oyun.barikat_y - yaricap - 6.0
	if boss:
		_durus_y = oyun.barikat_y - yaricap - 24.0
	if kralice:
		_durus_y = oyun.barikat_y - KRALICE_DURUS
	queue_redraw()


func _process(delta: float) -> void:
	if olu:
		return
	_zaman += delta
	var cizim_gerek := _parlama > 0.0 or _hamle > 0.0 or _hazirlik > 0.0 or _sicrama > 0.0
	_parlama = maxf(_parlama - delta * 7.0, 0.0)
	_hamle = maxf(_hamle - delta * 4.0, 0.0)
	_yanma_isle(delta)
	if cizim_gerek or _yakilmis:
		_renk_guncelle()
	if kralice and _dogurma_hak > 0 and position.y > 40.0:
		_kralice_isle(delta)
	if _sicrama > 0.0:
		_sicrama_isle(delta)
		queue_redraw()
		return
	if tur == "patlayan" and position.y > _durus_y - PATLAMA_UYARI:
		# barikata yaklaşınca kırmızı yanıp söner: "şimdi vur" işareti
		self_modulate = _taban_renk.lerp(Color(2.2, 0.5, 0.25), 0.5 + 0.5 * sin(_zaman * 14.0))
	if position.y < _durus_y:
		position.y = minf(position.y + hiz * oyun.zombi_hizi * delta, _durus_y)
		position.x += sin(_zaman * 2.3 + _faz) * 14.0 * delta
		position.x = clampf(position.x, 40.0, oyun.genislik - 40.0)
		# yürüme karesi: yalnızca değişince yeniden çiz
		var evre := fposmod(_zaman * (hiz / 9.0) + _faz, TAU)
		var yeni_kare := int(evre / TAU * 4.0) % 4
		if yeni_kare != _kare:
			_kare = yeni_kare
			cizim_gerek = true
	elif tur == "patlayan":
		olu = true
		oyun.patlayan_barikatta(self)
		return
	elif kralice and _dogurma_hak > 0:
		pass  # Kraliçe geride bekler: yavruları bitene dek barikata vurmaz
	elif boss:
		_boss_saldir(delta)
	elif tur == "kusan":
		_saldiri_sayac -= delta
		if _saldiri_sayac <= 0.0:
			_saldiri_sayac = KUSMA_ARA * randf_range(0.85, 1.15)
			_hamle = 1.0
			oyun.asit_at(position + Vector2(0, yaricap), hasar)
	else:
		_saldiri_sayac -= delta
		if _saldiri_sayac <= 0.0:
			_saldiri_sayac = 1.0
			_hamle = 1.0
			oyun.barikat_vuruldu(hasar, position.x, self)
	if cizim_gerek or oyun.atlas == null or not oyun.atlas.hazir:
		queue_redraw()


func _boss_saldir(delta: float) -> void:
	if _hazirlik > 0.0:
		_hazirlik -= delta
		if _hazirlik <= 0.0:
			_hazirlik = 0.0
			_hamle = 1.6
			_saldiri_sayac = DEV_ARA
			oyun.boss_vurdu(self)
		return
	_saldiri_sayac -= delta
	if _saldiri_sayac <= 0.0:
		_hazirlik = DEV_HAZIRLIK
		oyun.ses("boss")


## Kraliçe: belli aralıkla yavru doğurur (doğum oyun.gd'de, güvenli anda). Hakkı bitince barikata yürür.
func _kralice_isle(delta: float) -> void:
	_dogurma_sayac -= delta
	if _dogurma_sayac > 0.0:
		return
	_dogurma_sayac = _dogurma_ara
	_dogurma_hak -= 1
	_hamle = 1.2
	oyun.kralice_dogurdu(self)
	if _dogurma_hak <= 0:
		_durus_y = oyun.barikat_y - yaricap - 24.0


func _yanma_isle(delta: float) -> void:
	if _yanma_kalan <= 0.0:
		return
	_yanma_kalan -= delta
	_yanma_sayac -= delta
	if _yanma_sayac <= 0.0:
		_yanma_sayac = 0.5
		oyun.yanma_tik(self, _yanma_dps * 0.5)
	if _yanma_kalan <= 0.0:
		_yakilmis = false
		_renk_guncelle()


func tutustur(saniye_hasar: float, sure: float) -> void:
	if olu:
		return
	_yanma_dps = maxf(_yanma_dps if _yanma_kalan > 0.0 else 0.0, saniye_hasar)
	_yanma_kalan = sure
	if not _yakilmis:
		_yakilmis = true
		_yanma_sayac = 0.5
		_renk_guncelle()


func _renk_guncelle() -> void:
	var r := _taban_renk
	if _yakilmis:
		r = r * Color(1.25, 0.72, 0.45)
	if _hazirlik > 0.0:
		r = r.lerp(Color(1.6, 0.5, 0.4), 0.6)
	self_modulate = r.lerp(Color(2.4, 2.4, 2.4), _parlama * 0.7)


## Atış hasarı: zırh oyun.gd içinde hesaplanır.
func vurul(miktar: float) -> void:
	if olu:
		return
	can -= miktar
	_parlama = 1.0
	if not boss:
		position.y -= 5.0  # geri tepme
	_renk_guncelle()
	if boss and can > 0.0:
		_asama_kontrol()
	if boss and not _cagirdi and can < max_can * 0.5 and can > 0.0:
		_cagirdi = true
		oyun.boss_cagirdi(self)
	if can <= 0.0:
		olu = true
		oyun.zombi_oldu(self)


## A4 Boss aşamaları. Dev: %66'da öfkelenir (hız ×1.5), %33'te iniş yerini işaretleyip ileri sıçrar
## (barikattaysa vuruşu hızlanır). Kraliçe: %66'da daha sık doğurur, %33'te doğurmayı bırakıp saldırır.
func _asama_kontrol() -> void:
	var oran := can / max_can
	var yeni := 2 if oran < ASAMA_2 else (1 if oran < ASAMA_1 else 0)
	if yeni <= asama:
		return
	asama = yeni
	if kralice:
		if asama == 1:
			_dogurma_ara = KRALICE_HIZLI_ARA
			_dogurma_sayac = minf(_dogurma_sayac, 1.0)
		else:
			_dogurma_hak = 0
			_durus_y = oyun.barikat_y - yaricap - 24.0
			hiz *= 1.6
	else:
		if asama == 1:
			hiz *= DEV_OFKE_HIZ
		elif position.y < _durus_y - 60.0:
			_sicrama = DEV_SICRAMA_SURE
			_sicrama_y = minf(position.y + DEV_SICRAMA_MESAFE, _durus_y)
			_hazirlik = 0.0
		else:
			_saldiri_sayac = minf(_saldiri_sayac, 0.3)
	oyun.boss_asama(self, asama)


func _sicrama_isle(delta: float) -> void:
	_sicrama -= delta
	if _sicrama <= 0.0:
		_sicrama = 0.0
		position.y = _sicrama_y
		_hamle = 1.6
		oyun.boss_sicradi(self)


func _draw() -> void:
	var at = oyun.atlas if oyun else null
	if _sicrama > 0.0:
		# iniş yeri: dolan kırmızı halka (oyuncu görür, bombayı oraya saklar)
		var hedef := Vector2(0, _sicrama_y - position.y)
		var oran := 1.0 - _sicrama / DEV_SICRAMA_SURE
		draw_arc(hedef, yaricap * 1.3, 0.0, TAU, 32, Color(1, 0.25, 0.1, 0.8), 5.0)
		draw_circle(hedef, yaricap * 1.3 * oran, Color(1, 0.2, 0.05, 0.28))
	var ileri := _hamle * (10.0 if not boss else 16.0)
	if _hazirlik > 0.0:
		_isaret_ciz()
	if at != null and at.hazir:
		var boy: float = at.HUCRE_DEV if boss else at.HUCRE
		var bolge: Rect2 = at.bolge(tur, _varyant, _kare)
		draw_texture_rect_region(at.doku, Rect2(-boy / 2.0, -boy / 2.0 + ileri * 0.7, boy, boy), bolge)
	else:
		# yedek yol: atlas hazır değilken doğrudan çizim
		ZombiCizim.ciz(self, tur, yaricap, _gomlek, _ten, sin(_zaman * (hiz / 9.0) + _faz), ileri)


func _isaret_ciz() -> void:
	# Dev'in vuruşu: büyüyen kırmızı halka, dolduğunda vurur
	var oran := 1.0 - _hazirlik / DEV_HAZIRLIK
	draw_arc(Vector2.ZERO, 125.0, 0.0, TAU, 36, Color(1, 0.2, 0.1, 0.75), 6.0)
	draw_circle(Vector2.ZERO, 125.0 * oran, Color(1, 0.15, 0.05, 0.3))
