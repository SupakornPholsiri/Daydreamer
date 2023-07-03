extends Node2D

signal game_over

enum TEACHER_STATE {
	WRITING,
	LOOKING,
	TALKING
}

@export var LOOKING_TIME : float = 3

@onready var teacher = $Teacher
@onready var timer = $Timer
@onready var animation_player = $AnimationPlayer


var current_teacher_state = TEACHER_STATE.WRITING
var player_daydreaming : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	begin_writing()
	
func start():
	begin_writing()
	
func reset():
	timer.stop()
	animation_player.stop()
	$TripleDotBubble.visible = false
	current_teacher_state = TEACHER_STATE.WRITING
	player_daydreaming = false

func _physics_process(delta):
	if player_daydreaming and current_teacher_state == TEACHER_STATE.TALKING:
		emit_signal("game_over")
		
func begin_writing():
	SoundPlayer.stop_teacher_talking_sound()
	current_teacher_state = TEACHER_STATE.WRITING
	teacher.frame = 0
	timer.start(randi_range(3, 10))
	SoundPlayer.play_chalk_sound()
	
func begin_looking():
	SoundPlayer.stop_chalk_sound()
	current_teacher_state = TEACHER_STATE.LOOKING
	teacher.frame = 1
	animation_player.play("triple_dot")
	SoundPlayer.play_cough_sound()
	
func begin_talking():
	current_teacher_state = TEACHER_STATE.TALKING
	teacher.frame = 1
	timer.start(randi_range(1, 5))
	SoundPlayer.play_teacher_talking_sound()
	
func _on_timer_timeout():
	#Not including LOOKING state because we let animation_player handle it
	match current_teacher_state:
		TEACHER_STATE.WRITING : begin_looking()
		TEACHER_STATE.TALKING : begin_writing()
