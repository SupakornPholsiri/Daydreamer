extends CanvasLayer

@onready var main_menu = $MainMenu
@onready var health_ui = $HealthUI
@onready var score_label = $Score
@onready var score_multiplier_label = $ScoreMultiplier
@onready var game_over = $GameOver
@onready var setting = $Setting
@onready var powerup_ui = $PowerupUI
@onready var mouse = $Mouse
@onready var ijkl = $Ijkl

var tutorial_on : bool = false

func show_main_menu():
	main_menu.show()
	
func hide_main_menu():
	main_menu.hide()
	
func show_game_over(score : int):
	game_over.get_node("FinalScore").text = "Your Score : " + str(score)
	game_over.show()
	
func hide_game_over():
	game_over.hide()
	
func show_setting():
	setting.show()
	
func hide_setting():
	setting.hide()
	
func show_tutorial(keyboard_only : bool):
	get_tree().call_group("tutorial_ui", "show")
	if keyboard_only :
		mouse.hide()
	else :
		ijkl.hide()
	tutorial_on = true
		
func hide_tutorial():
	if tutorial_on:
		get_tree().call_group("tutorial_ui", "hide")
		tutorial_on = false
	
func change_health_ui(health : int):
	if health == 0 :
		health_ui.visible = false
	else :
		health_ui.size.x = 16 * health
		health_ui.visible = true
		
func update_score_ui(score : int):
	score_label.text = "SCORE : " + str(score)
	
func update_score_multiplier_ui(score_multi : int):
	score_multiplier_label.text = "X" + str(score_multi)
	
func update_powerup(incoming_texture, time):
	powerup_ui.change_texture(incoming_texture)
	if incoming_texture == null :
		powerup_ui.change_value(0, 100)
	else :
		powerup_ui.change_value(time, time)
	
func update_powerup_time(remaining_time, max_time):
	powerup_ui.change_value(remaining_time, max_time)
