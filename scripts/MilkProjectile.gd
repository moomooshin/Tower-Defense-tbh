extends Area2D

class_name MilkProjectile

@export var speed: float = 400.0
@export var damage: int = 1

var target_position: Vector2
var direction: Vector2

func _ready():
	# If target_position is set, calculate direction
	if target_position:
		direction = (target_position - global_position).normalized()
		rotation = direction.angle()
		
	# Delete after 5 seconds to prevent memory leaks if it misses everything
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _process(delta):
	position += direction * speed * delta

func _on_area_entered(area):
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
