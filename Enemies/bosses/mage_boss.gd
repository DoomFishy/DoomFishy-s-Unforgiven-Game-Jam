extends CharacterBody2D

var randInt
var minionMove = false
var direction = 1
var speed = 200.0
var shader_material
var attack_state = " "
var fireball = preload("res://Enemies/bosses/fireball.tscn")
var chargeUpBoi = preload("res://Enemies/rogue/rogue_enemy.tscn")
var shootyRoboi = preload("res://Enemies/shoot/bot_ranged.tscn")
var spikes = preload("res://Enemies/bosses/ground_spikes.tscn")
var beam = preload("res://Enemies/bosses/beam.tscn")

func _ready():
	$attack_intervals.start()
	$minion_spawn/minion_spawn.stop()
	$minion_spawn/minion_time.stop()
	$beam/beam_time.stop()
	$ground_spikes/ground_up_time.stop()
	$magic_missles/missle_spawn.stop()
	$magic_missles/missle_time.stop()
	randInt = 0

	shader_material = $Marker2D/AnimatedSprite2D.material
	$attack_intervals.start()
	
func _physics_process(delta):

	if Game.playerded:
		queue_free()
		
	if Boss.mageDeath:
		$attack_intervals.stop()
		$AnimationPlayer.play("death")
		Game.update_spawn(Vector2(169,386))
		
	if minionMove:
		velocity.x = 200.0 * direction
	
	move_and_slide()

func sac():
	Boss.sacrifice = true

func attack_finished():
	$AnimationPlayer.play("idle")

func beam_attack():
	$AnimationPlayer.play("attack")
	var wall = beam.instantiate()
	
	var rng = RandomNumberGenerator.new()
	var rand = rng.randi_range(1,3)
	
	if rand == 1:
		Boss.beamDir = "top"	
		wall.position.y = -3200
		wall.position.x = 2432
		wall.rotation_degrees = 90
		
	if rand == 2:
		Boss.beamDir = "left"
		wall.position.x = 1664
		wall.position.y = -2816
		wall.rotation_degrees = 0
		
	if rand == 3:
		Boss.beamDir = "right"
		wall.position.x = 3200
		wall.position.y = -2816
		wall.rotation_degrees = 0		

		
	var level_scene = get_tree().get_root().get_node("level_2")
	
	level_scene.add_child(wall)
	
func beam_attack_move():
	minionMove = false
	var gui = $"Marker2D/AnimatedSprite2D"
	var tween = get_tree().create_tween()
	tween.tween_property(gui, "modulate:a", 0, 0.2)
	position.x = 2432
	position.y = -2944
	tween.tween_property(gui, "modulate:a", 1, 0.7)	
	beam_attack()
	
func ground_spikes():
	$AnimationPlayer.play("attack")
	await get_tree().create_timer(0.75).timeout
	var ground = spikes.instantiate()
	ground.position.y = -2096
	ground.position.x = 2545
	
	var level_scene = get_tree().get_root().get_node("level_2")
	
	level_scene.add_child(ground)
	
func ground_spikes_move():
	minionMove = false
	var gui = $"Marker2D/AnimatedSprite2D"
	var tween = get_tree().create_tween()

	var rng = RandomNumberGenerator.new()
	var rand = rng.randi_range(1,2)

	if rand == 1:
		tween.tween_property(gui, "modulate:a", 0, 0.2)
		position.x = 2048
		position.y = -2688
		
	if rand == 2:
		tween.tween_property(gui, "modulate:a", 0, 0.2)
		position.x = 2880
		position.y = -2688
		
	tween.tween_property(gui, "modulate:a", 1, 0.7)	
	ground_spikes()
	
func summon_minions():
	$AnimationPlayer.play("attack")
	var chargeUp = chargeUpBoi.instantiate()
	var shooty = shootyRoboi.instantiate()

	var rng = RandomNumberGenerator.new()
	var randInt = rng.randi_range(1,2)
	
	chargeUp.position = self.position
	shooty.position = self.position
	
	chargeUp.scale.x = 4
	shooty.scale.x = 4
	chargeUp.scale.y = 4
	shooty.scale.y = 4
	
	chargeUp.add_to_group("enemy")
	shooty.add_to_group("enemy")
	
	var level_scene = get_tree().get_root().get_node("level_2")
	
	if randInt == 1:
		level_scene.add_child(chargeUp)
	
	if randInt == 2:
		level_scene.add_child(shooty)
		
func summon_minions_move():
	position.y = -2944
	minionMove = true
	
func is_right():
	return $right.is_colliding()
	
func is_left():
	return $left.is_colliding()
	
func magic_missles():
	$AnimationPlayer.play("attack")
	var ball = fireball.instantiate()
	
	var rng = RandomNumberGenerator.new()
	var randX = rng.randi_range(1920,3008)
	
	ball.position.x = randX
	ball.position.y = -3200
	
	get_parent().add_child(ball)

func magic_missles_move():
	minionMove = false
	var gui = $"Marker2D/AnimatedSprite2D"
	var tween = get_tree().create_tween()

	var rng = RandomNumberGenerator.new()
	var rand = rng.randi_range(1,2)

	if rand == 1:
		tween.tween_property(gui, "modulate:a", 0, 0.2)
		position.x = 2048
		position.y = -2944
		
	if rand == 2:
		tween.tween_property(gui, "modulate:a", 0, 0.2)
		position.x = 2880
		position.y = -2944
		
	tween.tween_property(gui, "modulate:a", 1, 0.7)
	
func _on_attack_intervals_timeout():
	if not Boss.mageDeath:
		var rng = RandomNumberGenerator.new()
		randInt = rng.randi_range(1, 14)

		if randInt >= 1 and randInt <= 2:
			attack_state = "magic_missles"
			magic_missles_move()
			$attack_intervals.stop()
			$magic_missles/missle_time.start()
			$magic_missles/missle_spawn.start()
			
		if randInt >= 3 and randInt <= 6:
			attack_state = "summon_minions"
			summon_minions_move()
			$attack_intervals.stop()
			$minion_spawn/minion_spawn.start()
			$minion_spawn/minion_time.start()
			
		if randInt >= 7 and randInt <= 10:
			attack_state = "ground_spikes"
			ground_spikes_move()
			$attack_intervals.stop()
			$ground_spikes/ground_up_time.start()
						
		if randInt >= 11 and randInt <= 14:
			attack_state = "beam"
			beam_attack_move()
			$attack_intervals.stop()
			$beam/beam_time.start()

func hurt():
	Boss.magehp -= 1
	shader_material.set_shader_parameter("active", true) 
	await get_tree().create_timer(0.2).timeout
	shader_material.set_shader_parameter("active", false) 
	
	if Boss.magehp <= 0:
		Boss.mageDeath = true
	
func _on_missle_spawn_timeout():
	magic_missles()

func _on_missle_time_timeout():
	$magic_missles/missle_spawn.stop()
	$attack_intervals.start()

func _on_minion_time_timeout():
	$minion_spawn/minion_spawn.stop()
	$attack_intervals.start()
	minionMove = false
	
func _on_minion_spawn_timeout():
	summon_minions()
	
func _on_left_body_entered(body):
	if body.is_in_group("level"):
		direction = 1

func _on_right_body_entered(body):
	if body.is_in_group("level"):
		direction = -1

func _on_ground_up_time_timeout():
	$attack_intervals.start()

func _on_beam_time_timeout():
	$attack_intervals.start()
