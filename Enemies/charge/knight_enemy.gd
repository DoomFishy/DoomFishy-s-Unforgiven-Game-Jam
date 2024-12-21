extends CharacterBody2D

var gravity = 100.0
const SPEED = 100.0

var chase = false
var patrol = true
var attack = false
var hit
var health = 4

var direction = 1

@onready var marker2D = $Marker2D
@onready var player = get_parent().get_node('Player/player')
var blood = preload("res://assets/hit_particles.tscn")

func _ready():
	get_node("AnimationPlayer").play("idle")
	
func _physics_process(delta):
	velocity.y += gravity

	if health <= 0:
		health = 0
		get_node("AnimationPlayer").play("death")
		$hit_detect/CollisionShape2D2.disabled = true
		velocity.x = 0

	if get_node("AnimationPlayer").current_animation != "death" and get_node("AnimationPlayer").current_animation != "hurt":
		if attack == false:
			get_node("AnimationPlayer").play("run")
		
		if patrol:
			if near_right_edge() or near_right_wall():
				direction = -1
				marker2D.scale.x = -1

			if near_left_edge() or near_left_wall():
				direction = 1
				marker2D.scale.x = 1

			velocity.x = direction * SPEED
			
		if chase:
			var pos = (player.position - self.position).normalized()
			
			if pos.x > 0:
				marker2D.scale.x = 1
				direction = 1

			elif pos.x < 0:
				marker2D.scale.x = -1
				direction = -1

			velocity.x = pos.x * SPEED
			
			if near_right_edge() or near_right_wall():
				velocity.x = 0

			if near_left_edge() or near_left_wall():
				velocity.x = 0
			
	move_and_slide()
			
func _on_player_detect_body_entered(body):
	if body.name == "player":
		chase = true
		patrol = false
		$wait_time.start()

func _on_player_detect_body_exited(body):
	if body.name == "player":
		chase = false
		patrol = true
		$wait_time.stop()

func _on_hit_detect_body_entered(body):
	if body.name == "player":
		body.hurt()

func _on_hit_detect_body_exited(body):
	if body.name == "player":
		attack = false

func _on_player_detect_up_body_entered(body):
	if body.name == "player":
		$jump_time.start()

func _on_player_detect_up_body_exited(body):
	if body.name == "player":
		$jump_time.stop()
	
func _on_jump_time_timeout():
	var rng = RandomNumberGenerator.new()
	var randInt = rng.randi_range(1,5)
		
	velocity.y = -1800.0

func _on_wait_time_timeout():
	chase = false 
	patrol = true

func hurt():
	var blood_instance = blood.instantiate()
	blood_instance.global_position = global_position
	var player_direction = global_position.angle_to_point(player.global_position)
	blood_instance.rotation = player_direction + PI
	blood_instance.emitting = true
	get_tree().current_scene.add_child(blood_instance)
		
	health -= 1
	velocity.x = direction * 500 * -1
	get_node("AnimationPlayer").play("hurt")

func near_right_edge():
	return not $EdgeDetect/RightEdge.is_colliding()

func near_left_edge():
	return not $EdgeDetect/LeftEdge.is_colliding()
	
func near_right_wall():
	return $WallDetect/RightWall.is_colliding()
	
func near_left_wall():
	return $WallDetect/LeftWall.is_colliding()

