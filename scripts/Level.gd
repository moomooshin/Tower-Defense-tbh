extends Node2D

@export var tile_map: TileMap
@export var wave_spawner: Node
@export var game_manager: Node

var tower_placement_manager: TowerPlacementManager = null
var tower_selection_manager: TowerSelectionManager = null

func _ready():
	# Setup tower placement manager
	tower_placement_manager = TowerPlacementManager.new()
	tower_placement_manager.tile_map = tile_map
	tower_placement_manager.ghost_tower_scene = preload("res://scenes/towers/CowTower.tscn")
	tower_placement_manager.tower_scene = preload("res://scenes/towers/CowTower.tscn")
	add_child(tower_placement_manager)
	
	# Setup tower selection manager
	tower_selection_manager = TowerSelectionManager.new()
	tower_selection_manager.tower_placement_manager = tower_placement_manager
	
	# Setup tower data
	var cow_tower_data = {
		name = "Cow Tower",
		cost = 100,
		scene_path = "res://scenes/towers/CowTower.tscn",
		description = "Basic tower that shoots milk",
		sprite = preload("res://icon.svg") # TODO: Replace with actual tower sprite
	}
	tower_selection_manager.tower_data = [cow_tower_data]
	
	# Add to scene
	add_child(tower_selection_manager)
	
	# Connect game manager signals
	if game_manager:
		game_manager.money_changed.connect(_on_money_changed)

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_T:
			# Toggle tower selection panel
			if tower_selection_manager:
				tower_selection_manager.show_panel()
		elif event.scancode == KEY_ESCAPE:
			# Cancel placement
			if tower_selection_manager:
				tower_selection_manager.hide_panel()

func _on_money_changed(new_amount: int):
	# Update tower selection panel money display
	if tower_selection_manager:
		tower_selection_manager._update_money_display()
