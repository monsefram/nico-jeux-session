extends CanvasLayer

@onready var label: Label = $DebugLabel
var debug_enabled := false

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("toggle_debug"): # F12
		debug_enabled = !debug_enabled
		visible = debug_enabled

func _process(delta):
	if not debug_enabled:
		return

	var fps = Engine.get_frames_per_second()
	var ram = Performance.get_monitor(Performance.MEMORY_STATIC) / (1024.0 * 1024.0)

	label.text = "FPS: %d\nRAM: %.2f MB" % [fps, ram]
