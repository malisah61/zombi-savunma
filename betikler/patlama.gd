extends Node2D
## El bombası patlaması. Tek düğüm yeniden kullanılır.


func patla(konum: Vector2, yaricap: float) -> void:
	position = konum
	scale = Vector2.ONE * (yaricap / 100.0) * 0.3
	modulate.a = 1.0
	visible = true
	var tw := create_tween()
	tw.tween_property(self, "scale", Vector2.ONE * (yaricap / 100.0), 0.22).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(self, "modulate:a", 0.0, 0.3)
	tw.tween_callback(func() -> void: visible = false)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 100.0, Color(1.0, 0.55, 0.15, 0.55))
	draw_circle(Vector2.ZERO, 60.0, Color(1.0, 0.9, 0.55, 0.8))
	draw_arc(Vector2.ZERO, 100.0, 0.0, TAU, 32, Color(1, 1, 0.8), 5.0)
