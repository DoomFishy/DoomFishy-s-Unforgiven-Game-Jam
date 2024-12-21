extends Node2D

var hover

func _process(delta):
	if hover and Input.is_action_just_pressed("attack"):
		if Game.inLevel == 1:
			get_tree().reload_current_scene()
			get_tree().change_scene_to_file("res://level_1.tscn")
			Game.playerded = false
		if Game.inLevel == 2:
			get_tree().reload_current_scene()
			get_tree().change_scene_to_file("res://level_2.tscn")
			Game.playerded = false
		if Game.inLevel == 3:
			get_tree().reload_current_scene()
			get_tree().change_scene_to_file("res://level_3.tscn")
			Game.playerded = false

func _on_area_2d_mouse_entered():
	hover = true


func _on_area_2d_mouse_exited():
	hover = false
