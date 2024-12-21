extends CharacterBody2D

var direction : Vector2 = Vector2.RIGHT	
var archer
var speed = 600
var hit_others = false

func _ready():
	$"bullet time despawn".start()

func _physics_process(delta):
	position += direction * speed * delta
	
func deflect():
	hit_others = true
	speed = 950
	if direction == Vector2.RIGHT:
		direction = Vector2.LEFT
		get_node("Sprite2D").flip_h = true
	elif direction == Vector2.LEFT:
		direction = Vector2.RIGHT
		get_node("Sprite2D").flip_h = false
		
func _on_area_2d_body_entered(body):
	if body.name == "player":
		body.hurt()
		queue_free()
		
	if hit_others:
		if body.is_in_group("enemy"):
			if body.health > 0:
				body.hurt()
				queue_free()

func _on_deflect_time_timeout():
	queue_free()
