extends Node2D

var boss1 = preload("res://Enemies/bosses/big_fat_boss.tscn")

func _process(delta):
	if Boss.spawn_boss1:
		var boss = boss1.instantiate()
		boss.position.x = 7296
		boss.position.y = -2048
		
		get_parent().add_child.call_deferred(boss)
		Boss.spawn_boss1 = false
