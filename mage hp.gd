extends Control

var num

func _ready():
	$ProgressBar.value = 100

func _process(delta):
	if Boss.mageDeath:
		queue_free()
	
	num = Boss.magehp / 30
	
	$ProgressBar.value = num * 100
