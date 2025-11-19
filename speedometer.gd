extends Control

@onready var dial: TextureRect = $Dial as TextureRect
@onready var needle: TextureRect = $Needle as TextureRect

var max_speed_kmh: float = 140.0
var max_angle: float = 340.0

func update_speed(kmh: float) -> void:
	var ratio: float = clamp(kmh / max_speed_kmh, 0.0, 1.0)
	needle.rotation_degrees = -max_angle + (ratio * max_angle)
