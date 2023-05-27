extends Node

@onready var sound_effects = $SoundEffects
@onready var gun_sound = $SoundEffects/GunSound
@onready var cough_sound = $SoundEffects/CoughSound
@onready var teacher_talking = $SoundEffects/TeacherTalking

@onready var bgm = $BGM

var bgm_playback_position = 0

func play_gun_sound(amount : int):
	for i in amount:
		gun_sound.play()
		
func play_cough_sound():
	cough_sound.play()
	
func play_teacher_talking_sound():
	teacher_talking.play()
	
func stop_teacher_talking_sound():
	teacher_talking.stop()
	
func stop_all_sound_effects():
	for audio_player in sound_effects.get_children():
		audio_player.stop()
		audio_player.seek(0)

func play_bgm():
	bgm.play(bgm_playback_position)
	
func stop_bgm():
	bgm_playback_position = bgm.get_playback_position()
	bgm.stop()
	
func reset_bgm():
	bgm_playback_position = 0
