extends CanvasLayer

signal start_game(diff)

func _on_play_button_down():
	$NumPlayers.show()
	$MainMenu.hide()
	
func _on_quit_button_down():
	get_tree().quit()

func _on_p_1_button_down():
	$SkinSelector.show()
	$NumPlayers.hide()
	
func _on_p_2_button_down():
	$NumPlayers.hide()
	$Title.hide()
	$InGame.show()
	start_game.emit(Paddle.Behavior.PLAYER, null)

func _on_skin_selector_start(diff, c):
	$NumPlayers.hide()
	$Title.hide()
	$InGame.show()
	start_game.emit(diff, c)
	
func _input(event):
	if event.is_action_pressed("esc") and $MainMenu.is_visible():
		get_tree().quit()
	elif event.is_action_pressed("esc") and $NumPlayers.is_visible():
		$NumPlayers.hide()
		$MainMenu.show()
	elif event.is_action_pressed("esc") and $SkinSelector.is_visible():
		$SkinSelector.hide()
		$NumPlayers.show()
