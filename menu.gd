extends Node2D

var hover

func _process(delta):
	if hover and Input.is_action_just_pressed("attack"):
		get_tree().change_scene_to_file("res://level_1.tscn")

func _on_play_button_mouse_entered():
	hover = true


func _on_play_button_mouse_exited():
	hover = false
