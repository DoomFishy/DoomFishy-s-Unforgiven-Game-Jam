extends Area2D

func _on_body_entered(body):
	if body.name == "player":
		Game.update_spawn(self.global_position)
