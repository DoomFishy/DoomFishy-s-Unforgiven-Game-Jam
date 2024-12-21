extends CharacterBody2D

var hit = false
var KNOCK_BACK = 1000
var DASH_SPEED = 1800
var can_hit = true
var bulletsAmount = 6
var heals = 3
var canfreeze = true

#-------------=[ Movement Variables ]=-------------
var SPEED = 550.0
var acc = 50
var friction = 70
var gravity = 100.0
var JUMP_VELOCITY = -2400.0
var hasFlippedLeft = false
var direction = 0
var is_dash = false
var can_dash = true
var wallJumpPushBack = 100
var wallSlideGravity = 100
var is_wall_slide = false

#-------------=[ Attack Ground Variables ]=-----------------
var ATTACK_SPEED = 1000.0
var attacking = false
var input_count = 3
var attack1 = false
var attack2 = false
var attack3 = false
var attack_dir = 0

#-------------=[ Attack Air Variables ]=-----------------
const AIR_VELOCITY = -200.0
var input_count_air = 2
var attackAir1 = false
var attackAir2 = false
var justStop = false

var ded = false
var numHp

@onready var animtree : AnimationTree = $AnimationTree
@onready var freeze_time : Timer = $Timer/freeze_time
var ball = preload("res://ball.tscn")
var hookPath = preload("res://Mechanics/hookshot/hookshot.tscn")
@onready var removal = ("res://Mechanics/Sacrifice_menu/ability_removal_menu.tscn")
var inMenu = false
var hookshot_instance = null

func _ready():
	$song.play()
	self.position = Game.spawn_point
	
	Game.invulnerable = false
		
	Game.health = Game.maxHp
	changeHp()
		
	if Game.hasDash:
		$"gui/Ability-Dash".visible = true
		$gui/Label.visible = true

	if Game.hasDeflect:
		$"gui/Ability-Deflect".visible = true
		
	if Game.hasTimeStop:
		$"gui/Ability-Time".visible = true
		$gui/Label2.visible = true
func _physics_process(delta):
	ending()
	
	var input_dir : Vector2 = input()
	
	if input_dir != Vector2.ZERO and not attacking and Game.awake:
		accelerate(input_dir)
	else:
		add_friction()	
		
	if Game.health == 0:
		$hit.play()
		Game.health -= 1
		print("ded")
		transition_anim("isDead", "dead")
		transition_anim("get_up", "dead")
		await get_tree().create_timer(2).timeout
		$gui/transition_rect.visible = true
		$gui/transition.play("transition_fade_to_black")
		get_tree().change_scene_to_file("res://death_screen.tscn")
		Game.playerded = true
		
	time_input()
	
	if Input.is_action_just_pressed("stop") and Game.hasTimeStop:
		if canfreeze:
			time_freeze(0.2)
			justStop = true
			
	dash()

	sacrifice()
	
	if is_on_floor() and $Timer/dash_cooldown.is_stopped() and Game.awake and Game.hasDash:
		can_dash = true
		var guiDash = $"gui/Ability-Dash"
		var tween = get_tree().create_tween()
		tween.tween_property(guiDash, "modulate:a", 1, 0.7)
		$Camera2D.position_smoothing_speed = 5
		
	if not attacking and not hit and not is_dash and Game.awake:
		transition_anim("groundstate", "Moving")
		flip()
		jump() 
		move()
		get_hook()
		wall_slide(delta)
		
	if not hit and not is_dash and Game.awake:
		attack_combo_ground()
		attack_combo_air()
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	var just_left_floor = was_on_floor and not is_on_floor() and velocity.y >= 0
	
	if just_left_floor:
		print("just left")
		$Timer/coyote_timer.start()
	
func _on_chain_hooked(hooked_position):
	pass
	
func input() -> Vector2:
	var input_dir : Vector2 = Vector2.ZERO
	
	input_dir.x = Input.get_axis("ui_left", "ui_right")
	
	if input_dir.x == -1:
		direction = -1
		attack_dir = -1
	elif input_dir.x == 1:
		direction = 1
		attack_dir = 1
	else:
		direction = 0
	
	input_dir = input_dir.normalized()
	return input_dir
	
func accelerate(direction):
	velocity = velocity.move_toward(SPEED * direction, acc)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)	
	
func move():
	if Input.is_action_just_pressed("heal") and heals > 0 and Game.health < Game.maxHp:
		$heal.play()
		Game.health = Game.maxHp
		heals -= 1
		var gui = $gui/ColorRect3
		gui.scale.x += -5.63
		var gui2 = $gui/ColorRect
		gui2.scale.x = numHp
			
	if direction and is_on_floor() and not Input.is_action_just_pressed("ui_accept") :
		transition_anim("movement", "walk")
		
func jump():
	velocity.y += gravity
	
	if is_on_floor() or is_on_wall() or not $Timer/coyote_timer.is_stopped():
		input_count_air = 2
		transition_anim("inAirState", "ground")
		transition_anim("movement", "idle")
		if Input.is_action_just_pressed("ui_accept") and not attacking:
			$jump.play()
			transition_anim("inAir", "jump")
			print("space")
			if is_on_floor() or not $Timer/coyote_timer.is_stopped():
				print("q")
				velocity.y = JUMP_VELOCITY
			if is_on_wall() and Input.is_action_pressed("ui_right"):
				velocity.y = JUMP_VELOCITY
				velocity.x = -wallJumpPushBack
			if is_on_wall() and Input.is_action_pressed("ui_left"):
				velocity.y = JUMP_VELOCITY
				velocity.x = wallJumpPushBack			
					
	if not is_on_floor():
		transition_anim("inAirState", "air")
		if Input.is_action_just_released("ui_accept") and not attacking and velocity.y < -1200.0:
			velocity.y = -1200.0
		if velocity.y > 0:
			transition_anim("inAir", "fall")

func wall_slide(delta):
	if is_on_wall_only():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_slide = true
		else:
			is_wall_slide = false			
	else:
		is_wall_slide = false
		
	if is_wall_slide:
		velocity.y += wallSlideGravity * delta
		velocity.y = min(velocity.y, wallSlideGravity)
		
func dash():
	if Input.is_action_just_pressed("dash") and not hit and not attacking and can_dash and Game.awake and Game.hasDash:
		var guiDash = $"gui/Ability-Dash"
		var tween = get_tree().create_tween()
		tween.tween_property(guiDash, "modulate:a", 0.1, 0.7)
		transition_anim("inAirState", "dash")
		$Timer/dash_cooldown.start()
		$Camera2D.position_smoothing_speed = 1
		is_dash = true
		can_dash = false
		
func dash_move():
	velocity.x = (attack_dir) * DASH_SPEED
	velocity.y = 0
	
func dash_finished():
	is_dash = false

func get_hook():	
	if bulletsAmount > 6:
		$Timer/bullet_regen.stop()
	
	if Input.is_action_just_pressed("fire") and bulletsAmount >= 1:
		$gunshots.play()
		$Timer/bullet_regen.start()
		velocity.x = (attack_dir) * 200 * -1
		var gui = $gui/ColorRect2
		gui.scale.x += -11
		bulletsAmount -= 1
		shoothook()

	$Node2D.look_at(get_global_mouse_position())

func shoothook():
	var hook = hookPath.instantiate()

	get_parent().add_child(hook)
	hook.position = $Node2D/Marker2D.global_position

	hook.direction = get_global_mouse_position() - hook.position
	
func attack_combo_ground():
	if Input.is_action_just_pressed("attack") and is_on_floor() and input_count > 0:
		attacking = true
		transition_anim("groundstate", "Attacking")
		input_count-=1
		if input_count <= 0:
			input_count = 0
	
	if attacking:
		if input_count == 2:
			attack1 = true
		if input_count == 1:
			attack2 = true
			attack1 = false
			attack3 = false
		if input_count == 0:
			attack3 = true
			attack2 = false
			attack1 = false

func stop_attack1():
	if attack1 == true:
		attacking = false
		input_count = 3
		transition_anim("groundstate", "Moving")
		
func stop_attack2():
	if attack2 == true:
		attacking = false
		input_count = 3		
		transition_anim("groundstate", "Moving")
		
func stop_attack3():
	if attack3 == true:
		input_count = 3
		attacking = false
		transition_anim("groundstate", "Moving")
		
func move_attack():
	velocity.x = attack_dir * ATTACK_SPEED
	
func attack_combo_air():
	if Input.is_action_just_pressed("attack") and not is_on_floor() and input_count_air > 0:
		attacking = true
		transition_anim("inAir", "attack")
		input_count_air -= 1
		if input_count_air <= 0:
			input_count_air = 0
			
	if attacking:
		velocity.y += gravity
		if input_count_air == 1:
			attackAir1 = true
		if input_count_air == 0:
			attackAir2 = true
			attackAir1 = false
		
func stop_attack_air_1():
	if attackAir1 == true:
		attacking = false
		transition_anim("inAir", "fall")
		input_count_air = 0
		
func stop_attack_air_2():
	if attackAir2 == true:
		attacking = false
		transition_anim("inAir", "fall")
			
func move_air_attack():
	velocity.y += gravity
		
func attack_hitbox_collision(col):
	$hitbox/box.disabled = col
		
func flip():
	if direction == 1:
		if hasFlippedLeft:
			transform.x *= -1
			hasFlippedLeft = false
		elif not hasFlippedLeft:
			transform.x *= 1
			
	elif direction == -1 and not hasFlippedLeft:
		transform.x *= -1
		hasFlippedLeft = true
	
func transition_anim(transition, state):
	animtree.set("parameters/" + transition + "/transition_request", state)

func _on_hitbox_body_entered(body):
	if body.name == "big_fat_boss":
		if Boss.fatboyhp > 0:
			velocity.x = 0
			$hurt_others.play()
			body.hurt()
	if body.name == "mage_boss":
		if Boss.magehp > 0:
			velocity.x = 0
			$hurt_others.play()
			body.hurt()		
	if body.name == "shadow_boss":
		if Boss.shadowhp > 0:
			velocity.x = 0
			$hurt_others.play()
			body.hurt()		
	if body.is_in_group("enemy"):
		if body.health > 0:
			velocity.x = 0
			$hurt_others.play()
			body.hurt()
	if body.is_in_group("bullet") and Game.hasDeflect:
		print("deflect!")
		body.deflect()
		$hurt_others.play()
		
func changeHp():
	if Game.maxHp == 1:
		var gui = $gui/ColorRect
		gui.scale.x += -55
		numHp = -55
		
	if Game.maxHp == 2:
		var gui = $gui/ColorRect
		gui.scale.x += -44
		numHp = -44
		
	if Game.maxHp == 3:
		var gui = $gui/ColorRect
		gui.scale.x += -33
		numHp = -33
		
	if Game.maxHp == 4:
		var gui = $gui/ColorRect
		gui.scale.x += -22
		numHp = -22
		
	if Game.maxHp == 5:
		var gui = $gui/ColorRect
		gui.scale.x += -11
		numHp = -11
		
	if Game.maxHp == 6:
		var gui = $gui/ColorRect
		gui.scale.x += 0
		numHp = 0
		
func hurt_slow():
	$hit.play()
	Engine.time_scale = 0.1
	await get_tree().create_timer(0.03).timeout
	Engine.time_scale = 1
		
func hurt():
	if not is_dash and not Game.invulnerable:
		$Timer/invulnerable_time.start()
		Game.invulnerable = true
		var gui = $gui/ColorRect
		gui.scale.x += -11
		
		Game.health -= 1
		hit = true
		transition_anim("ishit", "hit")
	
func knock_back():
	velocity.x = (attack_dir * -1) * KNOCK_BACK
	velocity.y = -500
	move_and_slide()
	
func finish_hit():
	hit = false
	$hitbox/box.disabled = true
	attacking = false
	input_count = 3
	transition_anim("ishit", "no")
	transition_anim("groundstate", "Moving")
	
func _on_freeze_time_cooldown_timeout():
	var gui = $"gui/Ability-Time"
	var tween = get_tree().create_tween()
	tween.tween_property(gui, "modulate:a", 1, 0.7)
	canfreeze = true
	
func time_input():
	if Input.is_action_just_pressed("stop") and Game.time_slow_active and justStop and Game.awake and Game.hasTimeStop:
		$Timer/freeze_time_cooldown.start()
		$Timer/freeze_time.stop()
		justStop = false
		Engine.time_scale = 1.0
		Game.time_slow_active = false
		$AnimationTree.set("parameters/TimeScale/scale", 1.8)
		$AnimationTree.set("parameters/TimeScale 2/scale", 2)
		$AnimationTree.set("parameters/TimeScale 3/scale", 1.5)
		$AnimationTree.set("parameters/TimeScale 4/scale", 1)
		$AnimationTree.set("parameters/TimeScale 5/scale", 1)	
		$AnimationTree.set("parameters/TimeScale 6/scale", 1)
		$AnimationTree.set("parameters/TimeScale 7/scale", 1)		
		$AnimationTree.set("parameters/TimeScale 8/scale", 1)	
		SPEED = 800.0
		JUMP_VELOCITY = -2400
		ATTACK_SPEED = 1000
		friction = 70
		acc = 50
		gravity = 100.0
		KNOCK_BACK = 1000
		DASH_SPEED = 1800
		velocity.x = 0
		velocity.y = 0
	
func time_freeze(time_scale):
	$timeslow.play()
	canfreeze = false
	var gui =$"gui/Ability-Time"
	var tween = get_tree().create_tween()
	tween.tween_property(gui, "modulate:a", 0.1, 0.2)
	Game.time_slow_active = true
	Engine.time_scale = time_scale
	freeze_time.start()
	$AnimationTree.set("parameters/TimeScale/scale", 10)
	$AnimationTree.set("parameters/TimeScale 2/scale", 10)
	$AnimationTree.set("parameters/TimeScale 3/scale", 10)
	$AnimationTree.set("parameters/TimeScale 4/scale", 5)
	$AnimationTree.set("parameters/TimeScale 5/scale", 5)
	$AnimationTree.set("parameters/TimeScale 6/scale", 5)
	$AnimationTree.set("parameters/TimeScale 7/scale", 5)		
	$AnimationTree.set("parameters/TimeScale 8/scale", 5)
	SPEED = 3000
	JUMP_VELOCITY = -15400
	ATTACK_SPEED = 4000
	friction = 500
	acc = 450
	gravity = 600.0
	KNOCK_BACK = 5000
	DASH_SPEED = 10000
	
func _on_freeze_time_timeout():
	$Timer/freeze_time_cooldown.start()
	Engine.time_scale = 1.0
	Game.time_slow_active = false
	$AnimationTree.set("parameters/TimeScale/scale", 1.8)
	$AnimationTree.set("parameters/TimeScale 2/scale", 2)
	$AnimationTree.set("parameters/TimeScale 3/scale", 1.5)
	$AnimationTree.set("parameters/TimeScale 4/scale", 1)
	$AnimationTree.set("parameters/TimeScale 5/scale", 1)	
	$AnimationTree.set("parameters/TimeScale 6/scale", 1)
	$AnimationTree.set("parameters/TimeScale 7/scale", 1)		
	$AnimationTree.set("parameters/TimeScale 8/scale", 1)	
	SPEED = 800.0
	JUMP_VELOCITY = -2400
	ATTACK_SPEED = 1000
	friction = 70
	acc = 50
	gravity = 100.0
	KNOCK_BACK = 1000
	DASH_SPEED = 1800
	velocity.x = 0
	velocity.y = 0

func _on_bullet_regen_timeout():
	if bulletsAmount < 6:
		bulletsAmount += 1
		var gui = $gui/ColorRect2
		gui.scale.x += 11

func sacrafice():
	if Boss.sacrifice:
		print("sac")
		$"gui/boss1 sacrafice text".visible = true
		$"gui/press f to surrender".visible = true
		if Input.is_action_just_pressed("sacrafice"):
			
			Boss.sacrifice = false
			print("e")
			Game.awake = false
			transition_anim("isDead", "dead")
			transition_anim("get_up", "dead")
			$gui/transition_rect.visible = true
			$"gui/transition".play("transition_fade_to_black")
			Game.update_spawn(self.position)
			removal_menu()
			$"gui/boss1 sacrafice text".visible = false
			$"gui/press f to surrender".visible = false
			
			await get_tree().create_timer(3).timeout
			$"gui/transition".play("transition_fade_to_light")
			transition_anim("get_up", "get_up")
			await get_tree().create_timer(2).timeout
			transition_anim("isDead", "no")
			Game.awake = true
			$"gui/Your Ability has been sacrificed".visible = true
			await get_tree().create_timer(2).timeout
			$"gui/Your Ability has been sacrificed".visible = false
		
func sacrifice():
	if Boss.sacrifice:
		$"gui/boss1 sacrafice text".visible = true
		$"gui/press f to surrender".visible = true
		if Input.is_action_just_pressed("sacrafice"):
			var orb = ball.instantiate()
			
			orb.position = self.position
			
			get_parent().add_child(orb)
			
			Game.hasPressedSac = true
			print("_______________________________________________________________")
			Game.awake = false
			transition_anim("isDead", "dead")
			transition_anim("get_up", "dead")
			
			await get_tree().create_timer(1).timeout
			
			removal_menu()
			remove_symbol()
	
	if not Boss.sacrifice and Game.hasPressedSac:
		$"gui/boss1 sacrafice text".visible = false
		$"gui/press f to surrender".visible = false
		remove_symbol()
		$"gui/transition".play("transition_fade_to_light")
		await get_tree().create_timer(1).timeout
		transition_anim("get_up", "get_up")
		await get_tree().create_timer(2).timeout
		transition_anim("isDead", "no")
		Game.awake = true
		Game.hasPressedSac = false
		
func remove_symbol():
	if Game.hasTimeStop == false:
		$"gui/Ability-Time".visible = false
	if Game.hasDash == false:
		$"gui/Ability-Dash".visible = false
	if Game.hasDeflect == false:
		$"gui/Ability-Deflect".visible = false
		
func removal_menu():
	$removal_menu.visible = true
	Game.Menu = true

func _on_invulnerable_time_timeout():
	Game.invulnerable = false

func ending():
	if Game.ending:
		$song.stop()
		Game.awake = false
		transition_anim("isDead", "dead")
		transition_anim("get_up", "dead")
		await get_tree().create_timer(0.5).timeout
		$gui/transition_rect.visible = true
		$"gui/transition".play("transition_fade_to_black")
		await get_tree().create_timer(2).timeout
		$"gui/ending text".visible = true
		await get_tree().create_timer(8).timeout		
		get_tree().change_scene_to_file("res://menu.tscn")
		
func black():
	$gui/ColorRect5.visible = true

func _on_song_finished():
	$song.play()
