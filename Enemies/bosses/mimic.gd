extends CharacterBody2D

var direction
var randInt
var pos
var speed = 300.0
var too_close = false
var oppositeDir
var canMelee = false
var attacking = false

var health = 1

@onready var player = get_parent().get_node('Player/player')

var wave = preload("res://Enemies/bosses/shock_wave.tscn")

func _ready():
	$attack_intervals.start()

func _physics_process(delta):
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

	if not attacking:
		chase_player()
	
	move_and_slide()
	
func chase_player():
	$AnimationPlayer.play("run")
	if too_close:
		velocity.x = speed * oppositeDir
	else:
		velocity.x = speed * direction
	
	
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

func _on_attack_intervals_timeout():
	if not Boss.shadowDeath:
		var rng = RandomNumberGenerator.new()
		randInt = rng.randi_range(2, 2)
			
		if randInt == 2:
			melee_attack()

func hurt():
	queue_free()

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
		print("canMelee")
		canMelee = true

func _on_player_detect_body_exited(body):
	if body.name == "player":
		print("cannotMelee")
		canMelee = false
