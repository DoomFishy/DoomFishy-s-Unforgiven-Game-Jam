extends CharacterBody2D

var gravity = 100.0
const SPEED = 200.0
const KNOCKBACK = 500.0

var health = 3

#----------=[ Chase ]=-----------
var chase = false
var patrol = true
var attacking = false
var hit = false
var direction = 1

var still = false

@onready var player = get_parent().get_node('Player/player')
@onready var marker2D = $Marker2D 
var blood = preload("res://assets/hit_particles.tscn")

func _ready():
	var rng = RandomNumberGenerator.new()
	var randInt = rng.randi_range(1, 2)
	
	if randInt == 1:
		still = true
	$Marker2D/AnimatedSprite2D.play("idle")
	
func _physics_process(delta):
	velocity.y += gravity
	
	if health <= 0:
		health = 0
		velocity.x = 0
		get_node("AnimationPlayer").play("death")
		$Marker2D/Hit_Detect_Range/CollisionShape2D.disabled = true
		$Player_Detect/CollisionShape2D.disabled = true
		
	if get_node("AnimationPlayer").current_animation != "death" and not attacking and not hit:
		if patrol and not still:
			get_node("AnimationPlayer").play("run")
			
			if near_right_edge() or near_right_wall():
				direction = -1
				marker2D.scale.x = -1
				
			if near_left_edge() or near_left_wall() :
				direction = 1
				marker2D.scale.x = 1

			velocity.x = direction * SPEED

		if chase:
			get_node("AnimationPlayer").play("run")
			
			var pos = (player.position - self.position).normalized()
			
			if pos.x > 0:
				marker2D.scale.x = 1
				direction = 1
				
			elif pos.x < 0:
				marker2D.scale.x = -1
				direction = -1
				
			velocity.x = pos.x * SPEED
			
			
	if attacking and not hit:
		get_node("AnimationPlayer").play("attack")
		if near_right_edge() or near_right_wall():
			velocity.x = 0
		if near_left_edge() or near_left_wall():
			velocity.x = 0
			
	move_and_slide()
	
func finish_attack():
	attacking = false
	chase = true
	
func _on_attack_timer_timeout():
	attacking = true
	
func _on_hit_detect_range_body_entered(body):
	if body.name == "player":
		$Timer/Attack_Timer.start()
		attacking = true
		chase = false
		
func _on_hit_detect_range_body_exited(body):
	if body.name == "player":
		$Timer/Attack_Timer.stop()

func _on_hitbox_body_entered(body):
	if body.name == "player":
		if health > 0:
			body.hurt()

func _on_player_detect_body_entered(body):
	if body.name == "player":
		patrol = false
		chase = true

func _on_player_detect_body_exited(body):
	if body.name == "player":
		patrol = true
		chase = false
		velocity.x = 0
		
func move_attack_forward():
	var speed = 20.0
	
	velocity.x = direction * speed * -1
		
func move_attack_recoil():
	var speed = 700.0
	
	velocity.x = direction * speed

func attack_hitbox_collision_left(col):
	$Marker2D/Hitbox/CollisionShape2D.disabled = col

func hurt():
	var blood_instance = blood.instantiate()
	blood_instance.global_position = global_position
	var player_direction = global_position.angle_to_point(player.global_position)
	blood_instance.rotation = player_direction + PI
	blood_instance.emitting = true
	get_tree().current_scene.add_child(blood_instance)
	
	hit = true
	health -= 1
	velocity.x = direction * 200 * -1
	get_node("AnimationPlayer").play("hurt")
	
func hurt_finished():
	hit = false
	
func near_right_edge():
	return not $EdgeDetect/RightEdge.is_colliding()

func near_left_edge():
	return not $EdgeDetect/LeftEdge.is_colliding()
	
func near_right_wall():
	return $WallDetect/RightWall.is_colliding()
	
func near_left_wall():
	return $WallDetect/LeftWall.is_colliding()

