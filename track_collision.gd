extends Node2D

@export var line_path: NodePath = ^"../Track"  # pointer vers ton Line2D

func _ready() -> void:
	build_collision()

func build_collision() -> void:
	# 1) Nettoyer d'anciennes collisions
	for c in get_children():
		c.queue_free()

	# 2) Récupérer le Line2D via NodePath (un seul argument)
	var line_node := get_node_or_null(line_path)
	if line_node == null:
		push_warning("TrackCollision: line_path ne pointe vers aucun node.")
		return

	var line := line_node as Line2D
	if line == null:
		push_warning("TrackCollision: le node ciblé n'est pas un Line2D.")
		return

	var pts: PackedVector2Array = line.points
	if pts.size() < 2:
		push_warning("TrackCollision: pas assez de points dans le Line2D (>=2).")
		return

	# 3) Créer le StaticBody2D + segments
	var body := StaticBody2D.new()
	add_child(body)

	for i in range(pts.size() - 1):
		var seg := SegmentShape2D.new()
		seg.a = pts[i]
		seg.b = pts[i + 1]

		var shape := CollisionShape2D.new()
		shape.shape = seg
		body.add_child(shape)

	# 4) Fermer la boucle si la ligne est "closed"
	if line.closed:
		var seg_last := SegmentShape2D.new()
		seg_last.a = pts[pts.size() - 1]  # pas de back()
		seg_last.b = pts[0]               # pas de front()
		var shape_last := CollisionShape2D.new()
		shape_last.shape = seg_last
		body.add_child(shape_last)
