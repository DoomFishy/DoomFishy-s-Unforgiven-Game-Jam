extends Area2D

func _ready():
	$Timer.start()

func _process(delta):
	if position.y >= -2560:
		position.y += -5

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.name == "player":
		if Game.health > 0:
			body.hurt()
