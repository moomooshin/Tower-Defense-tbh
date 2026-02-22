extends Node

@export var tower_scene: PackedScene
@export var ghost_tower_scene: PackedScene
@export var tile_map: TileMap
@export var valid_placement_color: Color = Color.GREEN
@export var invalid_placement_color: Color = Color.RED

var current_ghost_tower: Node2D = null
var is_placing: bool = false
var placement_valid: bool = false

func _ready():
	# Connect to tower selection manager
	var tower_selection_manager = get_node_or_null("/root/TowerSelectionManager")
	if tower_selection_manager:
		tower_selection_manager.tower_selected.connect(_on_tower_selected)
		tower_selection_manager.placement_cancelled.connect(_on_placement_cancelled)

func _unhandled_input(event):
	if not is_placing:
		return
	
	if event is InputEventMouseMotion:
		_update_ghost_tower_position(event.position)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_attempt_placement()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_placement()

func _on_tower_selected(tower_info: Dictionary):
	# Create ghost tower for preview
	current_ghost_tower = ghost_tower_scene.instantiate()
	current_ghost_tower.visible = true
	current_ghost_tower.modulate.a = 0.5
	
	# Set up ghost tower
	current_ghost_tower.position = get_global_mouse_position()
	
	# Add to scene
	get_tree().current_scene.add_child(current_ghost_tower)
	
	is_placing = true
	_update_placement_validity()

func _on_placement_cancelled():
	_cancel_placement()

func _update_ghost_tower_position(mouse_position: Vector2):
	if not current_ghost_tower:
		return
	
	# Snap to tile grid
	var snapped_position = tile_map.world_to_map(mouse_position)
	var world_position = tile_map.map_to_world(snapped_position)
	
	# Center on tile
	world_position += tile_map.cell_size / 2
	
	current_ghost_tower.position = world_position
	
	# Update placement validity
	_update_placement_validity()

func _update_placement_validity():
	if not current_ghost_tower:
		return
	
	# Check if tile is buildable
	var tile_position = tile_map.world_to_map(current_ghost_tower.position)
	var tile_id = tile_map.get_cellv(tile_position)
	
	# Check if tile is occupied by another tower
	var towers = get_tree().get_nodes_in_group("towers")
	var tile_occupied = false
	for tower in towers:
		if tower is Node2D:
			var tower_tile = tile_map.world_to_map(tower.position)
			if tower_tile == tile_position:
				tile_occupied = true
				break
	
	# Check if player has enough money
	var tower_cost = 100 # TODO: Get from tower data
	var has_enough_money = GameManager.current_money >= tower_cost
	
	placement_valid = (tile_id != TileMap.INVALID_CELL and 
					not tile_occupied and 
					has_enough_money)
	
	# Update ghost tower appearance
	if placement_valid:
		current_ghost_tower.modulate = valid_placement_color
		current_ghost_tower.modulate.a = 0.5
	else:
		current_ghost_tower.modulate = invalid_placement_color
		current_ghost_tower.modulate.a = 0.5

func _attempt_placement():
	if not placement_valid or not current_ghost_tower:
		return
	
	# Create actual tower
	var tower = tower_scene.instantiate()
	tower.position = current_ghost_tower.position
	
	# Add to scene and tower group
	get_tree().current_scene.add_child(tower)
	tower.add_to_group("towers")
	
	# Deduct money
	var tower_cost = 100 # TODO: Get from tower data
	GameManager.spend_money(tower_cost)
	
	# Clean up ghost tower
	_cancel_placement()
	
	# Notify tower selection manager
	var tower_selection_manager = get_node_or_null("/root/TowerSelectionManager")
	if tower_selection_manager:
		tower_selection_manager.placement_completed()

func _cancel_placement():
	if current_ghost_tower:
		current_ghost_tower.queue_free()
		current_ghost_tower = null
	
	is_placing = false
	placement_valid = false
	
	# Notify tower selection manager
	var tower_selection_manager = get_node_or_null("/root/TowerSelectionManager")
	if tower_selection_manager:
		tower_selection_manager.placement_cancelled()