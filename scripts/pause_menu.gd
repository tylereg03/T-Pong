extends CanvasLayer

signal unpause
signal end

# simply unpause the game
func _on_continue_button_down():
	unpause.emit()
	get_tree().paused = false
	hide()

# quit out of the current game
func _on_quit_button_down():
	end.emit()
	get_tree().paused = false
	hide()
	
