extends Control

var max = 1
var current
var start = true

@onready var time = $freeze_timer_clone

func _ready():
	$ProgressBar.value = 100

func _process(delta):
	if Game.time_slow_active:
		if start:
			time.start()
		
		current = time.time_left / max
		
		$ProgressBar.value = current * 100
		
		start = false
	
	if not Game.hasTimeStop:
		$ProgressBar.visible = false
func _on_freeze_timer_clone_timeout():
	start = true
	$ProgressBar.value = 0
