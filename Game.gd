extends Node

var time_slow_active = false
var health = 6
var maxHp = 6
var maxBullets = 6
var awake = true

var invulnerable = false

var hasTimeStop = true
var hasDash = true
var hasDeflect = true

var hasPressedSac = false
var ending = false

var inLevel = 1

var level1SpawnPoint = Vector2(550,326)
var level2SpawnPoint = Vector2(145, 514)
var level3SpawnPoint = Vector2(260, -28)
var endingSpawnPoint = Vector2(91, 160)

var Menu = false
var returnBack = false
var playerded = false

var spawn_point = Vector2(446,289)

func update_spawn(new_point):
	spawn_point = new_point
