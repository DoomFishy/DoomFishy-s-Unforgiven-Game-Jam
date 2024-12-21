extends Node2D

var player_in_room = false
var move_camera = false
var spawn_boss = false
var boss1 = preload("res://Enemies/bosses/big_fat_boss.tscn")

func _ready():
	Game.inLevel = 1
	$transition.play("black-->clear")

func _process(delta):
	if player_in_room:
		$door/CollisionShape2D.position.y += 2
		
		if $door/CollisionShape2D.position.y >= -1744.5:
			player_in_room = false
	
	if Game.hasPressedSac:
		
		$exit/CollisionShape2D.position.y -= 2
		$Player/player/Camera2D.limit_left = 0
		$Player/player/Camera2D.limit_right = 8384
		$Player/player/Camera2D.limit_bottom = 10000000
		$Player/player/Camera2D.limit_top = -10000000
		
func _on_door_close_boss_body_entered(body):
	if body.name == "player":
		player_in_room = true
		move_camera = true
		$Player/player/Camera2D.limit_left = 6720
		$Player/player/Camera2D.limit_right = 7840
		$Player/player/Camera2D.limit_bottom = -1600
		$Player/player/Camera2D.limit_top = -2112
		Boss.spawn_boss1 = true	
		$"door close boss".queue_free()

func _on_transition_to_next_body_entered(body):
	if body.name == "player":
		$transition.play("fade-->black")

func transition():
	get_tree().change_scene_to_file("res://level_2.tscn")

func visibleBox(value):
	$CanvasLayer/black.visible = value

func _on_cp_body_entered(body):
	if body.name == "player":
		print("in cp")
		Game.update_spawn($cp/CollisionShape2D.position)
