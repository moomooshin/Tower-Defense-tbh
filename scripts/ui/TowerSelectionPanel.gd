extends Control

@export var tower_data: Array[Dictionary] = []
@export var money_display: Label
@export var tower_button_template: Button
@export var tower_buttons_container: VBoxContainer

var selected_tower_index: int = -1
var tower_buttons: Array[Button] = []

func _ready():
	_setup_ui()
	_update_money_display()

func _setup_ui():
	# Hide the template button
	tower_button_template.visible = false
	
	# Create buttons for each tower
	for i in range(tower_data.size()):
		_create_tower_button(i)

func _create_tower_button(index: int):
	var tower_info = tower_data[index]
	
	# Instance the button from template
	var button = tower_button_template.duplicate()
	button.name = "TowerButton_%d" % index
	button.visible = true
	button.pressed.connect(_on_tower_button_pressed.bind(index))
	button.mouse_entered.connect(_on_tower_button_hovered.bind(index))
	button.mouse_exited.connect(_on_tower_button_exited.bind(index))
	
	# Setup tower sprite
	var sprite = button.get_node("TowerSprite") as TextureRect
	sprite.texture = tower_info.sprite
	
	# Setup tower name
	var name_label = button.get_node("TowerNameLabel") as Label
	name_label.text = tower_info.name
	
	# Setup tower cost
	var cost_label = button.get_node("TowerCostLabel") as Label
	cost_label.text = "$%d" % tower_info.cost
	
	# Add to container
	tower_buttons_container.add_child(button)
	tower_buttons.append(button)

func _on_tower_button_pressed(index: int):
	selected_tower_index = index
	_update_button_states()
	emit_signal("tower_selected", tower_data[index])

func _on_tower_button_hovered(index: int):
	var tower_info = tower_data[index]
	if tower_info.cost > money_display.text.replace("Money: $", "").to_int():
		# Show insufficient funds feedback
		get_node("Panel").modulate = Color.RED
	else:
		# Show valid selection feedback
		get_node("Panel").modulate = Color.GREEN

func _on_tower_button_exited(_index: int):
	get_node("Panel").modulate = Color.WHITE

func _update_button_states():
	for i in range(tower_buttons.size()):
		var button = tower_buttons[i]
		var tower_info = tower_data[i]
		
		if i == selected_tower_index:
			button.modulate = Color.YELLOW
		else:
			button.modulate = Color.WHITE
		
		# Update cost display based on available money
		var cost_label = button.get_node("TowerCostLabel") as Label
		var current_money = money_display.text.replace("Money: $", "").to_int()
		if tower_info.cost > current_money:
			cost_label.add_theme_color_override("font_color", Color.RED)
		else:
			cost_label.add_theme_color_override("font_color", Color.GREEN)

func _update_money_display():
	if money_display:
		money_display.text = "Money: $%d" % GameManager.current_money

func update_money():
	_update_money_display()
	_update_button_states()

func clear_selection():
	selected_tower_index = -1
	_update_button_states()

# Signals
@onready var tower_selected: Signal = Signal.new()