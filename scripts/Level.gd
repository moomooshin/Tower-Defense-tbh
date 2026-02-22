extends Node2D

@onready var path_2d := $Path2D as Path2D
@onready var wave_spawner := $WaveSpawner as WaveSpawner
@onready var tile_map = $TileMap

# Preload the enemy scene to assign to the spawner
var enemy_scene := preload("res://scenes/enemies/Enemy.tscn")

func _ready():
	# Setup a simple path for the prototype
	# A rectangular loop: (100, 100) -> (900, 100) -> (900, 500) -> (100, 500) -> (100, 100)
	var curve := Curve2D.new()
	curve.add_point(Vector2(100, 100))
	curve.add_point(Vector2(900, 100))
	curve.add_point(Vector2(900, 500))
	curve.add_point(Vector2(100, 500))
	curve.add_point(Vector2(100, 100)) # Loop back
	
	path_2d.curve = curve
	
	# Configure Spawner
	wave_spawner.path_to_follow = path_2d
	wave_spawner.enemy_scene = enemy_scene
	
	# Start the first wave after a short delay
	await get_tree().create_timer(1.0).timeout
	wave_spawner.start_wave()


func _draw():
	# Debug draw the path
	if path_2d and path_2d.curve:
		draw_polyline(path_2d.curve.get_baked_points(), Color.WHITE, 2.0)
