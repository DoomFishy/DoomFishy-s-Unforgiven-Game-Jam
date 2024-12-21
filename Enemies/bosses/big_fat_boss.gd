extends CharacterBody2D

var rollSpeed = 1000
var direction = 0
var gravity = 100.0
var jumpSpeed = -1800
var randInt
var pos
var shader_material
var fireball = preload("res://Enemies/bosses/fireball.tscn")

@onready var player = get_parent().get_node('Player/player')
@onready var rollbox = $Marker2D/roll/CollisionShape2D

func _ready():
	shader_material = $Marker2D/AnimatedSprite2D.material
	$attack_intervals.start()

func _physics_process(delta):
	if not Game.time_slow_active:
		gravity = 100
		
	if Boss.fatboyhp <= 0 and not Boss.fatboydeath:
		Boss.fatboydeath = true
		$AnimationPlayer.play("death")
		await get_tree().create_timer(1).timeout
		$AnimationPlayer.play("dead")
		$Marker2D/roll/CollisionShape2D.disabled = true
		$jump_sit_slam/CollisionShape2D.disabled = true
		Game.update_spawn(Vector2(145, 514))
		
	velocity.y += gravity
	
	if not $attack_intervals.is_stopped() and not Boss.fatboydeath:
		$AnimationPlayer.play("idle")
		pos = (player.position - self.position).normalized()
		
		if pos.x > 0:
			$Marker2D.scale.x = -1
			direction = 1
					
		elif pos.x < 0:
			$Marker2D.scale.x = 1
			direction = -1
			
	move_and_slide()
		
func jump_sit_slam():
	if Game.time_slow_active:
		gravity = 20
	velocity.y = -1800.0
	velocity.x = 1000 * pos.x
	
	
	
	move_and_slide()
	
func jumpCol(value):
	$jump_sit_slam/CollisionShape2D.disabled = value
	
func fire_ball():
	var ball = fireball.instantiate()
	
	var rng = RandomNumberGenerator.new()
	var randX = rng.randi_range(6784,7808)
	
	ball.position.x = randX
	ball.position.y = -2304
	
	get_parent().add_child(ball)

func roll():
	velocity.x = rollSpeed * direction
	move_and_slide()
	
func rollboxCol(value):
	rollbox.disabled = value

func _on_attack_intervals_timeout():
	if not Boss.fatboydeath:
		var rng = RandomNumberGenerator.new()
		randInt = rng.randi_range(1, 9)
		print(randInt)

		if randInt >= 1 and randInt <= 4:
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			fire_ball()
			$AnimationPlayer.play("jump")
			$attack_intervals.stop()
			$air_timer.start()
			await get_tree().create_timer(0.75).timeout
			jumpCol(false)
			
		if randInt == 5:
			velocity.x = 0
			$rain_spawn.start()
			$rain_timer.start()
			$attack_intervals.stop()
			var gui = $"Marker2D/AnimatedSprite2D"
			var tween = get_tree().create_tween()
			tween.tween_property(gui, "modulate:a", 0, 0.2)
			position.y = -2428.1
			
		if randInt >= 6 and randInt <= 7:
			print("roll")
			$AnimationPlayer.play("attack")
			$attack_intervals.stop()
			
func _on_roll_body_entered(body):
	if body.is_in_group("level"):
		print("hitwall and start dizzy")
		$roll_dizzy_time.start()
		$Marker2D/roll/CollisionShape2D.call_deferred("set_disabled", true)
		velocity.x = 0
				
	if body.name == "player":
		body.hurt()

func _on_roll_dizzy_time_timeout():
	print("dizzy over")
	$attack_intervals.start()
	rollboxCol(true)

func _on_jump_sit_slam_body_entered(body):
		
	if body.name == "player":
		body.hurt()
		velocity.x = 0
		$jump_sit_slam/CollisionShape2D.call_deferred("set_disabled", true)
		$attack_intervals.start()
		
func hurt():
	Boss.fatboyhp -= 1
	shader_material.set_shader_parameter("active", true) 
	await get_tree().create_timer(0.2).timeout
	shader_material.set_shader_parameter("active", false) 
	
func _on_rain_spawn_timeout():
	fire_ball()

func _on_rain_timer_timeout():
	$rain_spawn.stop()
	$attack_intervals.start()
	position.y = -1783
	var gui = $"Marker2D/AnimatedSprite2D"
	var tween = get_tree().create_tween()
	tween.tween_property(gui, "modulate:a", 1, 0.2)
	
func _on_air_timer_timeout():
	$jump_sit_slam/CollisionShape2D.call_deferred("set_disabled", true)
	$attack_intervals.start()
	velocity.x = 0

func deadsac():
	Boss.sacrifice = true
