extends Node

signal money_changed(new_amount)
signal lives_changed(new_amount)
signal wave_changed(new_wave)
signal game_over
signal level_won

var current_money: int = 100
var current_lives: int = 20
var current_wave: int = 0
var max_waves: int = 10
var game_active: bool = false

func start_game():
	current_money = 100
	current_lives = 20
	current_wave = 0
	game_active = true
	emit_signal("money_changed", current_money)
	emit_signal("lives_changed", current_lives)
	emit_signal("wave_changed", current_wave)

func add_money(amount: int):
	current_money += amount
	emit_signal("money_changed", current_money)

func spend_money(amount: int) -> bool:
	if current_money >= amount:
		current_money -= amount
		emit_signal("money_changed", current_money)
		return true
	return false

func lose_life(amount: int = 1):
	current_lives -= amount
	emit_signal("lives_changed", current_lives)
	if current_lives <= 0:
		game_over_sequence()

func next_wave():
	current_wave += 1
	emit_signal("wave_changed", current_wave)
	if current_wave > max_waves:
		game_won_sequence()

func game_over_sequence():
	game_active = false
	emit_signal("game_over")
	print("Game Over!")

func game_won_sequence():
	game_active = false
	emit_signal("level_won")
	print("Level Won!")
