extends Node2D
## Kahramanın mermisi. Düz gider, zombilere çarpar, delme hakkı kadar içinden geçer.

var oyun  # oyun.gd
var yon := Vector2.UP
var hiz := 1100.0
var hasar := 10.0
var kritik := false
var delme_kalan := 0
var _vurulanlar: Array = []


func _process(delta: float) -> void:
	position += yon * hiz * delta
	if position.y < -60.0 or position.x < -60.0 or position.x > oyun.genislik + 60.0:
		queue_free()
		return
	for z in oyun.zombiler:
		if z.olu or _vurulanlar.has(z):
			continue
		if position.distance_squared_to(z.position) < z.yaricap * z.yaricap:
			_vurulanlar.append(z)
			oyun.isabet(z, hasar, kritik, position)
			delme_kalan -= 1
			if delme_kalan < 0:
				queue_free()
				return


func _draw() -> void:
	var renk := Color(1.0, 0.55, 0.2) if kritik else Color(1.0, 0.9, 0.45)
	var kuyruk := Vector2(0, 26)  # düğüm uçuş yönüne döndürülür; kuyruk arkada kalır
	draw_line(Vector2.ZERO, kuyruk, Color(renk, 0.25), 9.0, true)
	draw_line(Vector2.ZERO, kuyruk * 0.7, renk, 4.0, true)
	draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 1))
