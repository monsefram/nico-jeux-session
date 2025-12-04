extends CanvasLayer

@onready var speed_label: Label = $Speedometer/SpeedLabel

var coins: int = 0
@onready var counter: Label = $CoinCounter


func update_speed(v: float) -> void:
	speed_label.text = "%d km/h" % v

func add_coins(amount: int) -> void:
	coins += amount
	counter.text = str(coins)
