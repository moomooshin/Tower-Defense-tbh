extends Node

@export var tower_data: Array[Dictionary] = []
@export var tower_selection_panel_scene: PackedScene
@export var tower_placement_manager: TowerPlacementManager

var tower_selection_panel: Control = null
var current_selected_tower: Dictionary = {}

func _ready():
	# Create tower selection panel
	tower_selection_panel = tower_selection_panel_scene.instantiate()
	get_tree().current_scene.add_child(tower_selection_panel)
	
	# Configure panel
	tower_selection_panel.tower_data = tower_data
	tower_selection_panel.money_display = tower_selection_panel.get_node("Panel/MoneyDisplay") as Label
	tower_selection_panel.tower_button_template = tower_selection_panel.get_node("TowerButtonTemplate") as Button
	tower_selection_panel.tower_buttons_container = tower_selection_panel.get_node("Panel/VBoxContainer/TowerButtons") as VBoxContainer
	
	# Connect signals
	tower_selection_panel.tower_selected.connect(_on_tower_selected)
	
	# Hide panel initially
	tower_selection_panel.visible = false

func _on_tower_selected(tower_info: Dictionary):
	current_selected_tower = tower_info
	
	# Start placement through placement manager
	if tower_placement_manager:
		tower_placement_manager._on_tower_selected(tower_info)

func show_panel():
	if tower_selection_panel:
		tower_selection_panel.visible = true
		_update_money_display()

func hide_panel():
	if tower_selection_panel:
		tower_selection_panel.visible = false
		clear_selection()

func _update_money_display():
	if tower_selection_panel and tower_selection_panel.money_display:
		tower_selection_panel.money_display.text = "Money: $%d" % GameManager.current_money

func clear_selection():
	current_selected_tower = {}
	if tower_placement_manager:
		tower_placement_manager._on_placement_cancelled()

func placement_completed():
	# Update money display after successful placement
	_update_money_display()
	
	# Clear selection
	clear_selection()

func placement_cancelled():
	# Clear selection
	clear_selection()

# Signals
@onready var tower_selected: Signal = Signal.new()
@onready var placement_completed: Signal = Signal.new()
@onready var placement_cancelled: Signal = Signal.new()