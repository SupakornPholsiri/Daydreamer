extends TextureRect

@onready var texture_rect = $TextureRect
@onready var texture_progress_bar = $TextureProgressBar

func change_value(incoming_value : float, maximum : float):
	texture_progress_bar.value = incoming_value * texture_progress_bar.max_value / maximum
	
func change_texture(incoming_texture):
	texture_rect.texture = incoming_texture
