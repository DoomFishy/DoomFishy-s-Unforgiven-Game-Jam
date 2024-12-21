extends CharacterBody2D

var gravity = 25.0

func _ready():
	$Timer.start()

func _physics_process(delta):
	velocity.y += gravity
	
	move_and_slide()

func _on_area_2d_body_entered(body):
	if body.name == "player":
		if Game.health > 0:
			body.hurt()
		queue_free()
	if body.is_in_group("delete_balls"):
		queue_free()


func _on_timer_timeout():
	queue_free()
