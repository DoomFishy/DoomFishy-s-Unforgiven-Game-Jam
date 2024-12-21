extends CharacterBody2D

var direction
var randInt
var pos
var speed = 200.0
var too_close = false
var oppositeDir
var canMelee = false
var attacking = false
var shader_material

@onready var player = get_parent().get_node('Player/player')

var wave = preload("res://Enemies/bosses/shock_wave.tscn")
var clone = preload("res://Enemies/bosses/mimic.tscn")

var shader_material_outline = preload("res://Player/player.gdshader")

func _ready():
	$attack_intervals.start()
	shader_material = $Marker2D/AnimatedSprite2D.material
		
func _physics_process(delta):
	if Boss.shadowDeath:
		velocity.x = 0
		$attack_intervals.stop()
		$AnimationPlayer.play("death")
		Game.update_spawn(Game.endingSpawnPoint)

	
	velocity.y += 100.0
	
	pos = (player.position - self.position).normalized()
		
	if pos.x > 0:
		$Marker2D.scale.x = 1
		direction = 1
		oppositeDir	= -1
	elif pos.x < 0:
		$Marker2D.scale.x = -1
		direction = -1
		oppositeDir	= 1

	if not attacking and not Boss.shadowDeath:
		chase_player()
	
	move_and_slide()
	
func sac():
	Boss.sacrifice = true
	
func chase_player():
	$AnimationPlayer.play("run")
	if too_close:
		velocity.x = speed * oppositeDir
	else:
		velocity.x = speed * direction
	
func shock_wave():
	$AnimationPlayer.play("attack3")
	attacking = true
	velocity.x = 0
	
func spawn_wave():
	var shockLeft = wave.instantiate()
	var shockRight = wave.instantiate()	
	
	shockLeft.position.x = self.position.x
	shockRight.position.x = self.position.x
	
	shockLeft.position.y = 3758
	shockRight.position.y = 3758
	
	shockLeft.scale.x = 1
	shockRight.scale.x = -1
	
	
	get_parent().add_child(shockLeft)
	get_parent().add_child(shockRight)
	
func shock_wave_hitbox_value(value):
	$shock_wave/CollisionShape2D.disabled = value
	
func shock_wave_finished():
	$attack_intervals.start()
	attacking = false
	
func melee_attack():
	var rng = RandomNumberGenerator.new()
	randInt = rng.randi_range(1, 2)
	
	if canMelee and randInt == 1:
		$AnimationPlayer.play("attack1")
		velocity.x = 0
		attacking = true
		
	if canMelee and randInt == 2:
		$AnimationPlayer.play("attack2")		
		velocity.x = 0
		attacking = true
	
func melee_hitbox_value(value):
	$Marker2D/melee_attack_hitbox/CollisionShape2D.disabled = value
	
func melee_finished():
	attacking = false
	
func clone_spawn():
	var mimic1 = clone.instantiate()
	var mimic2 = clone.instantiate()
	var mimic3 = clone.instantiate()
	
	mimic1.position.x = self.position.x
	mimic2.position.x = self.position.x
	mimic3.position.x = self.position.x
	
	mimic1.position.y = self.position.y
	mimic2.position.y = self.position.y
	mimic3.position.y = self.position.y
	
	get_parent().add_child(mimic1)
	get_parent().add_child(mimic2)
	get_parent().add_child(mimic3)
	
func _on_attack_intervals_timeout():
	if not Boss.shadowDeath:
		var rng = RandomNumberGenerator.new()
		randInt = rng.randi_range(1, 9)
		print(randInt)

		if randInt >= 1 and randInt <= 2:
			shock_wave()
			$attack_intervals.stop()
			
		if randInt >= 3 and randInt <= 7:
			melee_attack()
			
		if randInt >= 8 and randInt <= 9:
			clone_spawn()

func _on_player_too_close_body_entered(body):
	if body.name == "player":
		#if not $attack_intervals.is_stopped():
		too_close = true

func _on_player_too_close_body_exited(body):
	if body.name == "player":
		#if not $attack_intervals.is_stopped():
		too_close = false

func _on_melee_attack_hitbox_body_entered(body):
	if body.name == "player":
		if Game.health >= 0:
			body.hurt()

func _on_player_detect_body_entered(body):
	if body.name == "player":
		canMelee = true

func _on_player_detect_body_exited(body):
	if body.name == "player":
		canMelee = false

func _on_shock_wave_body_entered(body):
	if body.name == "player":
		if Game.health >= 0:
			body.hurt()

func hurt():
	Boss.shadowhp -= 1
	shader_material.set_shader_parameter("line_thickness", 0) 
	await get_tree().create_timer(0.2).timeout
	shader_material.set_shader_parameter("line_thickness", 1.0) 
	if Boss.shadowhp <= 0:
		Boss.shadowDeath = true
