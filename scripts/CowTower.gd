extends Node2D

class_name CowTower

@export var range_radius: float = 150.0
@export var fire_rate: float = 1.0 # Shots per second
@export var damage: int = 2

@onready var range_area: Area2D = $RangeArea
@onready var collision_shape: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle

var projectile_scene := preload("res://scenes/projectiles/MilkProjectile.tscn")
var current_target: Area2D = null

func _ready():
	# Setup range
	var circle := CircleShape2D.new()
	circle.radius = range_radius
	collision_shape.shape = circle
	
	# Setup timer
	timer.wait_time = 1.0 / fire_rate
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _physics_process(_delta):
	# Periodically update target, not every frame for performance
	update_target()
	
	if current_target and is_instance_valid(current_target):
		look_at(current_target.global_position)
	else:
		current_target = null

func update_target():
	var overlapping_areas = range_area.get_overlapping_areas()
	
	if overlapping_areas.is_empty():
		current_target = null
		return

	# Find enemy furthest along path
	var best_target = null
	var max_progress: float = -1.0
	
	for area in overlapping_areas:
		if is_instance_valid(area) and area.has_method("take_damage"):
			var parent = area.get_parent()
			# Check if parent exists and is PathFollow2D
			if parent and parent is PathFollow2D:
				if parent.progress > max_progress:
					max_progress = parent.progress
					best_target = area
	
	current_target = best_target

func _on_timer_timeout():
	if current_target and is_instance_valid(current_target):
		shoot()

func shoot():
	if not current_target or not is_instance_valid(current_target):
		current_target = null
		return
	
	var projectile := projectile_scene.instantiate()
	# Set properties before adding to scene
	projectile.global_position = muzzle.global_position
	projectile.target_position = current_target.global_position
	
	# Calculate direction immediately
	projectile.direction = (current_target.global_position - muzzle.global_position).normalized()
	projectile.rotation = projectile.direction.angle()
	
	projectile.damage = damage
	
	# Add projectile to the main scene, not as child of tower
	get_tree().root.add_child(projectile)
