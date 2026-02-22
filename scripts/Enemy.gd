extends Area2D

@export var speed: float = 200.0
@export var damage: int = 1
@export var max_health: int = 10
@export var money_reward: int = 10

var current_health: int

func _ready():
	current_health = max_health
	
	# Create a visual representation if one doesn't exist
	if not has_node("Sprite2D"):
		var sprite := Sprite2D.new()
		var texture := PlaceholderTexture2D.new()
		texture.size = Vector2(32, 32)
		sprite.texture = texture
		sprite.modulate = Color.RED
		add_child(sprite)
	
	# Create a collision shape if one doesn't exist
	if not has_node("CollisionShape2D"):
		var collision := CollisionShape2D.new()
		var shape := CircleShape2D.new()
		shape.radius = 16
		collision.shape = shape
		add_child(collision)

func _process(delta):
	var path_follow = get_parent()
	if path_follow is PathFollow2D:
		path_follow.progress += speed * delta
		
		# Check if reached end of path (loop is false on PathFollow usually, but we check ratio)
		if path_follow.progress_ratio >= 1.0:
			reached_end()

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	GameManager.add_money(money_reward)
	get_parent().queue_free()

func reached_end():
	GameManager.lose_life(damage)
	get_parent().queue_free()
