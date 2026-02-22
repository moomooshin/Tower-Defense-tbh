extends Area2D

class_name MilkProjectile

@export var speed: float = 400.0
@export var damage: int = 1

var target_position: Vector2
var direction: Vector2

func _ready():
	# If direction is not set but target_position is, calculate it
	# (This handles cases where direction wasn't set by spawner)
	if direction == Vector2.ZERO and target_position != Vector2.ZERO:
		direction = (target_position - global_position).normalized()
		rotation = direction.angle()
		
	# Delete after 5 seconds to prevent memory leaks if it misses everything
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _process(delta: float):
	position += direction * speed * delta

func _on_area_entered(area: Area2D):
	if area.has_method("take_damage"):
		area.take_damage(damage)
		queue_free()
