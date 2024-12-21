extends Node2D

var hoverDash = false
var hoverDeflect = false
var hoverTime = false

func _process(delta):
	if hoverDash:
		if Input.is_action_just_pressed("attack"):
			Game.hasDash = false
			$AnimationPlayer.play("outro")
			$"../../gui/Ability-Dash".visible = false
			
	if hoverDeflect:
		if Input.is_action_just_pressed("attack"):
			Game.hasDeflect = false
			$AnimationPlayer.play("outro")
			$"../../gui/Ability-Deflect".visible = false
						
	if hoverTime:
		if Input.is_action_just_pressed("attack"):
			Game.hasTimeStop = false
			$AnimationPlayer.play("outro")
			$"../../gui/Ability-Time".visible = false
									
func transition_out():
	if Game.level == 1:
		self.visible = false
					
func transition_in():
	print("visible")
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
