extends Node2D

var player_in_room = false
var move_camera = false
var spawn_boss = false


var boss2 = preload("res://Enemies/bosses/mage_boss.tscn")


func _ready():
	Game.inLevel = 2
	$transition.play("black-->clear")
	
func _process(delta):
	if Boss.spawn_boss2:
		var boss = boss2.instantiate()
		boss.position.x = 2432
		boss.position.y = -3008
		
		get_parent().add_child.call_deferred(boss)
		Boss.spawn_boss2 = false
	
	if player_in_room:
		$door/CollisionShape2D.position.x += 2
		
		if $door/CollisionShape2D.position.x >= 2864:
			player_in_room = false
			Boss.spawn_boss2 = true

	if Game.hasPressedSac:
		
		$exit/CollisionShape2D.position.y -= 2
		$Player/player/Camera2D.limit_left = 1280
		$Player/player/Camera2D.limit_right = 10000000
		$Player/player/Camera2D.limit_bottom = 10000000
		$Player/player/Camera2D.limit_top = -10000000

func _on_player_detect_in_room_body_entered(body):
	if body.name == "player":
		player_in_room = true
		$Player/player/Camera2D.limit_left = 1856
		$Player/player/Camera2D.limit_right = 3008
		$Player/player/Camera2D.limit_bottom = -2432	
		$Player/player/Camera2D.limit_top = -3008
		$player_detect_in_room.queue_free()

func _on_transition_to_next_body_entered(body):
	if body.name == "player":
		$transition.play("fade-->black")
		
func transition():
	get_tree().change_scene_to_file("res://level_3.tscn")
	
func _on_cp_body_entered(body):
	if body.name == "player":
		print("in cp")
		Game.update_spawn($cp/CollisionShape2D.position)
	
