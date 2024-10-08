extends CanvasLayer

signal end

func _on_continue_button_down():
	get_tree().paused = false
	hide()

func _on_quit_button_down():
	end.emit()
	get_tree().paused = false
	hide()
	
