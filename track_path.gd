# scripts/TrackFromPath.gd — Godot 5
extends Path2D
@export var path_node: NodePath = ^"../TrackPath"
@export var bake_interval: float = 8.0  # plus petit = plus de points = plus lisse

func _ready() -> void:
	_sync_from_path()
	set_process(true)

func _process(_delta: float) -> void:
	# En éditeur comme en jeu, garde la Line2D sync avec le Path2D
	if Engine.is_editor_hint():
		_sync_from_path()

func _sync_from_path() -> void:
	var p := get_node_or_null(path_node) as Path2D
	if p == null or p.curve == null:
		return
	p.curve.bake_interval = bake_interval
points = p.curve.get_baked_points()  # PackedVector2Array
