# TrackFromPath.gd — à ATTACHER au Line2D
extends Line2D

@export var path_node: NodePath = ^"../TrackPath"
@export var bake_interval: float = 8.0

func _ready() -> void:
	_sync_from_path()
	if Engine.is_editor_hint():
		set_process(true)

func _process(_dt: float) -> void:
	if Engine.is_editor_hint():
		_sync_from_path()

func _sync_from_path() -> void:
	var p := get_node_or_null(path_node) as Path2D
	if p == null or p.curve == null:
		return
	p.curve.bake_interval = bake_interval

	# OPTION A (propriété "points" sur Line2D)
	self.points = p.curve.get_baked_points()

	# OPTION B (si tu préfères éviter "points", dé-commente et commente l’option A)
	# var baked: PackedVector2Array = p.curve.get_baked_points()
	# clear_points()
	# for v in baked:
	#     add_point(v)
