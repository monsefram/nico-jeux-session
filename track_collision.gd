# TrackCollision.gd — enfant direct du Line2D
extends Node2D

func _ready() -> void:
	build_collision()

func build_collision() -> void:
	for c in get_children():
		c.queue_free()

	var line := get_parent() as Line2D
	if line == null:
		push_warning("TrackCollision doit être enfant d'un Line2D.")
		return

	var pts: PackedVector2Array = line.points
	if pts.size() < 2:
		push_warning("Line2D: au moins 2 points requis.")
		return

	# IMPORTANT: on ne convertit plus les points -> les coords locales correspondent
	var body := StaticBody2D.new()
	add_child(body)

	for i in range(pts.size() - 1):
		var seg := SegmentShape2D.new()
		seg.a = pts[i]
		seg.b = pts[i + 1]

		var shape := CollisionShape2D.new()
		shape.shape = seg
		body.add_child(shape)

	if line.closed:
		var seg_last := SegmentShape2D.new()
		seg_last.a = pts[pts.size() - 1]
		seg_last.b = pts[0]
		var shape_last := CollisionShape2D.new()
		shape_last.shape = seg_last
		body.add_child(shape_last)
