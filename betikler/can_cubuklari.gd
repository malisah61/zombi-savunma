extends Node2D
## Tüm yaralı zombilerin can çubuğunu tek düğümde çizer: zombilerin atlas çizim partisi bölünmez.

var oyun  # oyun.gd


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if oyun.durum == 0:
		return
	for z in oyun.zombiler:
		if z.olu or z.boss or z.can >= z.max_can:
			continue
		var w: float = z.yaricap * 1.8
		var ust: Vector2 = z.position + Vector2(-w / 2.0, -z.yaricap - 12.0)
		draw_rect(Rect2(ust, Vector2(w, 6)), Color(0, 0, 0, 0.6))
		var renk := Color(0.75, 0.78, 0.85) if z.zirh > 0.0 else Color(0.85, 0.2, 0.2)
		draw_rect(Rect2(ust, Vector2(w * maxf(z.can / z.max_can, 0.0), 6)), renk)
