extends CanvasLayer

@onready var speed_label: Label = $Speedometer/SpeedLabel

func update_speed(v: float) -> void:
	speed_label.text = "%d km/h" % v
