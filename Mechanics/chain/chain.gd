extends Sprite2D
@onready var ray_cast = $RayCast2D
var distance: float = 500.0
 
signal hooked(hooked_position)
 
func interpolate(length, duration = 0.2):
	var tween_offset = get_tree().create_tween()
	var tween_rect_h = get_tree().create_tween()
 
	tween_offset.tween_property(self, "offset",Vector2(0,length/2.0), duration)
	tween_rect_h.tween_property(self, "region_rect", Rect2(0,0,16,length), duration)
 
func _input(event):
	pass
#	if event.is_action_pressed("fire"):
#		var player = get_node("/root/world/Player/player")
#
#		player.hook = true
#		interpolate(await check_collision(), 0.2)
#		await get_tree().create_timer(0.2).timeout
#		reverse_interpolate()
 
func reverse_interpolate():
	interpolate(0,0.75)
 
func check_collision():
	var player = get_node("/root/world/Player/player")
	await get_tree().create_timer(0.1).timeout
	var collision_point
	if ray_cast.is_colliding():
		if player.hook:
			collision_point = ray_cast.get_collision_point()
			distance = (global_position - collision_point).length()
			hooked.emit(collision_point)
	else:
		distance = 500.0
	return distance
