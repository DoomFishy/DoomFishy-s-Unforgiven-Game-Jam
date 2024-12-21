extends CharacterBody2D

var speed = 1000
var player
var direction : Vector2 = Vector2(1,0)

func _physics_process(delta):
	var collision_info = move_and_collide(direction.normalized() * delta * speed)

func _on_detect_body_entered(body):
	if body.is_in_group("enemy"):
		if body.health > 0:
			body.hurt()
			queue_free()
	if body.name == "big_fat_boss":
		if Boss.fatboyhp > 0:
			body.hurt()
			queue_free()
	if body.name == "mage_boss":
		if Boss.magehp > 0:
			body.hurt()
			queue_free()
	if body.name == "shadow_boss":
		if Boss.shadowhp > 0:
			body.hurt()
			queue_free()			
	if body.name == "level":
		queue_free()
