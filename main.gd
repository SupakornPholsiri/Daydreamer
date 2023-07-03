extends Node

@onready var daydream = $Control/SubViewportContainer/DaydreamViewport/Daydream
@onready var classroom = $Control/SubViewportContainer2/ClassroomViewport/Classroom

@onready var daybream_blackveil = $Control/SubViewportContainer/DaydreamViewport/Blackveil
@onready var classroom_blackveil = $Control/SubViewportContainer2/ClassroomViewport/Blackveil2

@onready var UI = $UI

var score_multi : int = 1 : set = set_score_multi
var score : int = 0 : set = set_score
var kill_streak : int = 0

var powerup_time : float = 0
var monitoring_powerup_countdown : bool = false

var daydream_paused : bool = true

var in_game_over : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_pause(true)
	daydream.get_node("Player").connect("player_health_changed", UI.change_health_ui)

func _physics_process(delta):
	if monitoring_powerup_countdown:
		UI.update_powerup_time(daydream.get_node("Player/PowerupTimer").time_left, powerup_time)
	if Input.is_action_just_pressed("toggle_daydream") and not in_game_over:
		toggle_daydream()
		
func set_score(value : int):
	score = value
	UI.update_score_ui(value)
	
func set_score_multi(value : int):
	score_multi = value
	UI.update_score_multiplier_ui(value)

func _on_player_died():
	game_over()
	
func _on_enemy_died(point : int):
	set_score(score + point * score_multi)
	kill_streak += 1
	var kill_multi = kill_streak / 2
	set_score_multi(1 + clamp(kill_multi, 0, 4))
	
func pause_daydream():
	daydream.process_mode = Node.PROCESS_MODE_DISABLED
	
func toggle_daydream():
	if daydream_paused:
		SoundPlayer.play_bgm()
		classroom.player_daydreaming = true
		daydream_paused = false
		daydream.process_mode = Node.PROCESS_MODE_INHERIT
		daybream_blackveil.hide()
		classroom_blackveil.show()
	else:
		SoundPlayer.stop_bgm()
		kill_streak = 0
		set_score_multi(1)
		classroom.player_daydreaming = false
		daydream_paused = true
		daydream.process_mode = Node.PROCESS_MODE_DISABLED
		daybream_blackveil.show()
		classroom_blackveil.hide()

func _on_daydream_child_entered_tree(node):
	if node in get_tree().get_nodes_in_group("Enemies"):
		node.connect("enemy_died", _on_enemy_died)

func game_over():
	get_tree().set_pause(true)
	in_game_over = true
	reset_game()
	UI.show_game_over(score)
	score = 0
	
func reset_game():
	UI.update_powerup(null, 100)
	monitoring_powerup_countdown = false
	SoundPlayer.stop_bgm()
	SoundPlayer.reset_bgm()
	SoundPlayer.stop_all_sound_effects()
	daydream.get_node("Player").disconnect("player_died", _on_player_died)
	classroom.disconnect("game_over", game_over)
	score_multi = 1
	kill_streak = 0
	daydream_paused = true
	daydream.reset()
	classroom.reset()
	daybream_blackveil.show()
	classroom_blackveil.hide()

func _on_play_pressed():
	UI.hide_main_menu()
	UI.hide_game_over()
	play()
	
func play():
	in_game_over = false
	daydream.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().set_pause(false)
	daydream.get_node("Player").connect("player_died", _on_player_died)
	classroom.connect("game_over", game_over)
	daydream.start()
	classroom.start()

func _on_quit_pressed():
	get_tree().quit()

func _on_main_menu_pressed():
	UI.show_main_menu()
	UI.hide_game_over()
	UI.hide_setting()

func _on_settings_pressed():
	UI.show_setting()
	UI.hide_main_menu()

func _on_daydream_powerup_activated(powerup_texture, time):
	UI.update_powerup(powerup_texture, time)
	powerup_time = time
	monitoring_powerup_countdown = true

func _on_daydream_powerup_deactivated():
	UI.update_powerup(null, 100)
	monitoring_powerup_countdown = false
	powerup_time = 0
	
