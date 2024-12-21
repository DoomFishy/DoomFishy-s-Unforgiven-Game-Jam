extends Area2D

func _ready():
	$Timer.start()

func _process(delta):
	if Boss.beamDir == "top":
		if position.y <= -2689:
			position.y += 3

	if Boss.beamDir == "right":
		if position.x >= 2016:
			position.x += -3
		
	if Boss.beamDir == "left":
		if position.x <= 2894:
			position.x += 3

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.name == "player":
		if Game.health > 0:
			body.hurt()
