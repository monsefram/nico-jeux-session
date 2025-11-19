extends CanvasLayer

@onready var label: Label = $SpeedLabel
var last_speed := 0.0

func update_speed(v: float) -> void:
	# Mise à jour du texte
	label.text = "%.0f km/h" % v
