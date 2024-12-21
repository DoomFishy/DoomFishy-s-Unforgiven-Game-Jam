extends Control

var num

func _ready():
	$ProgressBar.value = 100

func _process(delta):
	if Boss.fatboydeath:
		queue_free()
	
	num = Boss.fatboyhp / 35
	
	$ProgressBar.value = num * 100
	
	print($ProgressBar.value)
