extends CharacterBody2D

var gravity = 100.0

const SPEED = 200.0

var chase = false
var attacking = false
var hit = false
var direction = 0

var health = 2

var retreat = false

var Bullet = preload("res://Enemies/shoot/bullet.tscn")
var blood = preload("res://assets/hit_particles.tscn")

@onready var player = get_parent().get_node('Player/player')
@onready var shootRangeRight = $shootRange/shootRangeRight
@onready var shootRangeLeft = $shootRange/shootRangeLeft
@onready var marker2D = $Marker2D

func _ready():
	get_node("AnimationPlayer").play("idle")

func _physics_process(delta):
	
	velocity.y += gravity
	
	if health <= 0:
		health = 0
		$player_detect/CollisionShape2D.disabled = true
		$hit_detect_left/CollisionShape2D.disabled = true
		$hit_detect_right/CollisionShape2D2.disabled = true
		$close_detect/CollisionShape2D.disabled = true
		get_node("AnimationPlayer").play("death")
		velocity.x = 0
	
	if get_node("AnimationPlayer").current_animation != "death" and not attacking and not hit and not retreat:
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
	
	if retreat:
		var pos = (player.position - self.position).normalized()
		if pos.x > 0:
			marker2D.scale.x = 1
			direction = 1
				
		elif pos.x < 0:
			marker2D.scale.x = -1
			direction = -1
			
		velocity.x = pos.x * SPEED * -1
		
	move_and_slide()

func _on_close_detect_body_entered(body):
	if body.name == "player":
		retreat = true
		attacking = false
		chase = false

func _on_close_detect_body_exited(body):
	if body.name == "player":
		attacking = true
		retreat = false
		velocity.x = 0

func _on_player_detect_body_entered(body):
	if body.name == "player":
		get_node("AnimationPlayer").play("wake")
		chase = true
		attacking = false

func _on_player_detect_body_exited(body):
	if body.name == "player":
		get_node("AnimationPlayer").play("idle")
		chase = false
		attacking = false
		velocity.x = 0
		
func _on_hit_detect_left_body_entered(body):
	if body.name == "player":
		get_node("AnimationPlayer").play("charge")
		shootRangeRight.enabled = false
		shootRangeLeft.enabled = true	
		$Attack_Timer.start()
		attacking = true
		velocity.x = 0
		
func _on_hit_detect_left_body_exited(body):
	if body.name == "player":
		$Attack_Timer.stop()
		shootRangeLeft.enabled = false	
			
func _on_hit_detect_right_body_entered(body):
	if body.name == "player":
		get_node("AnimationPlayer").play("charge")
		shootRangeRight.enabled = true
		shootRangeLeft.enabled = false
		$Attack_Timer.start()
		attacking = true
		velocity.x = 0

func _on_hit_detect_right_body_exited(body):
	if body.name == "player":
		$Attack_Timer.stop()

func run_anim():
	get_node("AnimationPlayer").play("run")	
	
func shoot_anim():
	get_node("AnimationPlayer").play("shoot")
	
func shoot_finished():
	attacking = false
	chase = true
	get_node("AnimationPlayer").play("run")

func _on_attack_timer_timeout():
	attacking = true
	chase = false
	get_node("AnimationPlayer").play("charge")
	
	if direction == 1:
		shootRangeRight.enabled = true
		shootRangeLeft.enabled = false
		shoot()
		
	if direction == -1:
		shootRangeRight.enabled = false
		shootRangeLeft.enabled = true
		shoot()
	
func shoot_move():
	var speed = 200.0
	shoot()
	shootRangeRight.enabled = false		
	shootRangeLeft.enabled = false		
	velocity.x = direction * speed * -1

func shoot():
	var bullet = Bullet.instantiate()
	
	var target_position = to_local(player.position)
	
	var direction = Vector2(target_position.x, 0).normalized()
	bullet.direction = direction

	if shootRangeRight.enabled == true:
		bullet.get_node("Sprite2D").flip_h = false
		bullet.position = position + Vector2(90, -22)
		shootRangeRight.target_position = target_position

	if shootRangeLeft.enabled == true:		
		bullet.get_node("Sprite2D").flip_h = true
		bullet.position = position + Vector2(-90, -22)
		shootRangeLeft.target_position = target_position

	get_tree().current_scene.add_child(bullet)

func hurt():
	var blood_instance = blood.instantiate()
	blood_instance.global_position = global_position
	var player_direction = global_position.angle_to_point(player.global_position)
	blood_instance.rotation = player_direction + PI
	blood_instance.emitting = true
	get_tree().current_scene.add_child(blood_instance)
	
	health -= 1
	hit = true
	velocity.x = direction * 100 * -1
	get_node("AnimationPlayer").play("hurt")

func hurt_finished():
	hit = false
	get_node("AnimationPlayer").play("run")	
	
func near_right_edge():
	return not $EdgeDetect/RightEdge.is_colliding()

func near_left_edge():
	return not $EdgeDetect/LeftEdge.is_colliding()
	
func near_right_wall():
	return $WallDetect/RightWall.is_colliding()
	
func near_left_wall():
	return $WallDetect/LeftWall.is_colliding()

