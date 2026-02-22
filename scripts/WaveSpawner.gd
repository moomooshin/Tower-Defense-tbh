extends Node

class_name WaveSpawner

@export var enemy_scene: PackedScene
@export var path_to_follow: Path2D
@export var spawn_interval: float = 1.5
@export var wave_count: int = 5

var enemies_spawned = 0
var timer = 0.0
var spawning = false

func start_wave():
	enemies_spawned = 0
	timer = 0.0
	spawning = true
	print("Wave Started!")

func _process(delta):
	if spawning:
		timer += delta
		if timer >= spawn_interval:
			spawn_enemy()
			timer = 0.0

func spawn_enemy():
	if enemies_spawned >= wave_count:
		spawning = false
		return

	var new_path_follow = PathFollow2D.new()
	path_to_follow.add_child(new_path_follow)
	new_path_follow.loop = false # Ensure they don't loop back
	
	var enemy_instance = enemy_scene.instantiate()
	new_path_follow.add_child(enemy_instance)
	
	enemies_spawned += 1
