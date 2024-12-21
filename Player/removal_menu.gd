extends Node2D

var hoverDash = false
var hoverDeflect = false
var hoverTime = false

func _ready():
	$AnimationPlayer.play("intro")
	

func _process(delta):
	if hoverDash:
		if Input.is_action_just_pressed("attack"):
			Game.hasDash = false
			$AnimationPlayer.play("outro")
			
	if hoverDeflect:
		if Input.is_action_just_pressed("attack"):
			Game.hasDeflect = false
			$AnimationPlayer.play("outro")
			
	if hoverTime:
		if Input.is_action_just_pressed("attack"):
			Game.hasTimeStop = false
			$AnimationPlayer.play("outro")
						
func transition_out():
	if Game.level == 1:
		get_tree().change_scene_to_file("res://level_1.tscn")
					
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
