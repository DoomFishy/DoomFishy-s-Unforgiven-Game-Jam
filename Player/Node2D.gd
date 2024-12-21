extends Node2D

func _ready():
	if Game.maxHp == 1:
		var gui = $gui/ColorRect
		gui.scale.x += -55
		
	if Game.maxHp == 2:
		var gui = $gui/ColorRect
		gui.scale.x += -44
		
	if Game.maxHp == 3:
		var gui = $gui/ColorRect
		gui.scale.x += -33
		
	if Game.maxHp == 4:
		var gui = $gui/ColorRect
		gui.scale.x += -22
		
	if Game.maxHp == 1:
		var gui = $gui/ColorRect
		gui.scale.x += -11
