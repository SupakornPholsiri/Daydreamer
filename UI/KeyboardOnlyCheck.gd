extends CheckButton

signal set_control_scheme(keyboard_ctrl_on: bool)

func _on_toggled(button_pressed):
	emit_signal("set_control_scheme", button_pressed)
