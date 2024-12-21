extends Node2D

var hoverDash = false
var hoverDeflect = false
var hoverTime = false

func _process(delta):
	if Game.Menu:
		$AnimationPlayer.play("intro")
		Game.Menu = false
	
	if hoverDash:
		if Input.is_action_just_pressed("attack"):
			Game.hasDash = false
			$AnimationPlayer.play("outro")
			print("e")
			Game.returnBack = true
			Boss.sacrifice = false

	if hoverDeflect:
		if Input.is_action_just_pressed("attack"):
			Game.hasDeflect = false
			$AnimationPlayer.play("outro")
			Game.returnBack = true
			Boss.sacrifice = false
			
	if hoverTime:
		if Input.is_action_just_pressed("attack"):
			Game.hasTimeStop = false
			$AnimationPlayer.play("outro")
			Game.returnBack = true
			Boss.sacrifice = false
			
	if not Game.hasDash:
		$"Ability-Dash".visible = false
		$"Ability-Dash/Dash/CollisionShape2D".disabled = true
		$dash.visible = false
			
	if not Game.hasDeflect:
		$"Ability-Deflect".visible = false
		$"Ability-Deflect/Deflect/CollisionShape2D".disabled = true
		$deflect.visible = false	
		
	if not Game.hasTimeStop:
		$"Ability-Time".visible = false
		$"Ability-Time/Time/CollisionShape2D".disabled = true
		$timeslow.visible = false	
				
func game_out():
	Game.Menu = false
												
func transition_out():
	self.visible = false
	
func transition_in():
	self.visible = true
					
func _on_dash_mouse_entered():
	$"Ability-Dash".material.set_shader_parameter("line_thickness", 1)
	hoverDash = true

func _on_dash_mouse_exited():
	$"Ability-Dash".material.set_shader_parameter("line_thickness", 0)
	hoverDash = false

func _on_deflect_mouse_entered():
	$"Ability-Deflect".material.set_shader_parameter("line_thickness", 1)
	hoverDeflect = true

func _on_deflect_mouse_exited():
	$"Ability-Deflect".material.set_shader_parameter("line_thickness", 0)
	hoverDeflect = false

func _on_time_mouse_entered():
	$"Ability-Time".material.set_shader_parameter("line_thickness", 1)
	hoverTime = true

func _on_time_mouse_exited():
	$"Ability-Time".material.set_shader_parameter("line_thickness", 0)
	hoverTime = false
