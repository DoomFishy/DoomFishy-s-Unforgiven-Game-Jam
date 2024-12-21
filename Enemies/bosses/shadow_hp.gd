extends Control

var num

func _ready():
	$ProgressBar.value = 100

func _process(delta):
	if Boss.shadowDeath:
		queue_free()
	
	num = Boss.shadowhp / 40
	
	$ProgressBar.value = num * 100
