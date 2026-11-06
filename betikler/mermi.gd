extends Node2D
## Kahramanın mermisi. Düz gider, zombilere çarpar, delme hakkı kadar içinden geçer.
## Havuzdan yeniden kullanılır: oluşturmak yerine baslat() çağrılır, bitince oyuna geri verilir.

var oyun  # oyun.gd
var yon := Vector2.UP
var hiz := 1100.0
var hasar := 10.0
var kritik := false
var delme_kalan := 0
var zirh_gec := false  # Ağır Taret mermisi zırhı yok sayar
var kaynak := -1  # katkı istatistiği: 0 lider, 1+ nöbetçi, -2 taret, -1 diğer
var hedef  # Ekip yapay zekâsı: bu merminin "ayırdığı" zombi (aşırı öldürme önleme)
var ayrilan := 0.0  # hedefe yazılan beklenen hasar
var _vurulanlar: Array = []


func baslat(konum: Vector2, y: Vector2, h: float, hs: float, k: bool, delme: int, zg: bool = false) -> void:
	position = konum
	yon = y
	rotation = y.angle() + PI / 2
	hiz = h
	hasar = hs
	kritik = k
	delme_kalan = delme
	zirh_gec = zg
	kaynak = -1
	hedef = null
	ayrilan = 0.0
	_vurulanlar.clear()
	visible = true
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	var once := position
	position += yon * hiz * delta
	if position.y < -60.0 or position.y > oyun.yukseklik + 60.0 or position.x < -60.0 or position.x > oyun.genislik + 60.0:
		oyun.mermi_birak(self)
		return
	# Çarpışma: bu karede gidilen yol (doğru parçası) zombiye değiyor mu? Oyun x2/x3 hızdayken
	# mermi bir karede zombiden uzun yol alabilir; tek noktaya bakmak "içinden geçme" yaratır.
	for z in oyun.zombiler:
		if z.olu or _vurulanlar.has(z):
			continue
		var en_yakin: Vector2 = Geometry2D.get_closest_point_to_segment(z.position, once, position)
		if en_yakin.distance_squared_to(z.position) < z.yaricap * z.yaricap:
			_vurulanlar.append(z)
			oyun.ayrimi_birak(self)
			oyun.isabet(z, hasar, kritik, position, zirh_gec, kaynak)
			delme_kalan -= 1
			if delme_kalan < 0:
				oyun.mermi_birak(self)
				return


func _draw() -> void:
	var renk := Color(0.6, 0.85, 1.0) if zirh_gec else (Color(1.0, 0.55, 0.2) if kritik else Color(1.0, 0.9, 0.45))
	var kuyruk := Vector2(0, 26)  # düğüm uçuş yönüne döndürülür; kuyruk arkada kalır
	# yumuşatmasız çizgiler tek partiye sığar; çok mermide çizim çağrısı patlamaz
	draw_line(Vector2.ZERO, kuyruk, Color(renk, 0.25), 9.0)
	draw_line(Vector2.ZERO, kuyruk * 0.7, renk, 4.0)
	draw_rect(Rect2(-2.5, -3, 5, 6), Color(1, 1, 1))
