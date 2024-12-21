extends Node2D

var player_in_room

var boss3 = preload("res://Enemies/bosses/shadow_boss.tscn")

func _ready():
	Game.inLevel = 3
	$transition.play("black-->clear")
	
func _process(delta):
	if Boss.spawn_boss3:
		var boss = boss3.instantiate()
		boss.position.x = 2016
		boss.position.y = 3644
		var level_scene = get_tree().get_root().get_node("level_3")
	
		level_scene.add_child.call_deferred(boss)
		Boss.spawn_boss3 = false
		
	if player_in_room:
		$door/CollisionShape2D.position.x += 2
		
		if $door/CollisionShape2D.position.x >= 2016:
			player_in_room = false
			Boss.spawn_boss3 = true
			
	if Game.hasPressedSac:

		$exit/CollisionShape2D.position.y -= 2
		$Player/player/Camera2D.limit_left = 1280
		$Player/player/Camera2D.limit_right = 10000000
		$Player/player/Camera2D.limit_bottom = 10000000
		$Player/player/Camera2D.limit_top = -10000000

func _on_player_in_room_body_entered(body):
	if body.name == "player":
		player_in_room = true
		$Player/player/Camera2D.limit_left = 1408
		$Player/player/Camera2D.limit_right = 2624
		$Player/player/Camera2D.limit_bottom = 3904	
		$Player/player/Camera2D.limit_top = 3328
		$player_in_room.queue_free()

func _on_cp_body_entered(body):
	if body.name == "player":
		print("in cp")
		Game.update_spawn($cp/CollisionShape2D.position)

func transition():
	get_tree().change_scene_to_file("res://ending.tscn")

func _on_transition_to_last_body_entered(body):
	if body.name == "player":
		$transition.play("fade-->black")
