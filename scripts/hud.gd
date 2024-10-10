extends CanvasLayer

signal start_game(behavior, p1_sprite, p2_sprite)

# used to store information extracted from skin_selector
var behavior
var p1_sprite
var p2_sprite

# Play Button in Main Menu pressed
func _on_play_button_down():
	$NumPlayers.show()
	$MainMenu.hide()

# Quit Button in Main Menu pressed
func _on_quit_button_down():
	get_tree().quit()

# 1 Player option pressed in Player select
func _on_p_1_button_down():
	$SkinSelector.show()
	$NumPlayers.hide()
	
	# hide 2P specifics and show 1P specifics
	$SkinSelector/Difficulties.show()
	$SkinSelector/DifficultiesTexts.show()
	$SkinSelector/SkinSelect2.hide()
	
	# have easy automatically toggled to true
	$SkinSelector._on_easy_toggled(true)
	
# 2 Player option pressed in Player select
func _on_p_2_button_down():
	$SkinSelector.show()
	$NumPlayers.hide()
	
	# hide 1P specifics and show 2P specifics
	$SkinSelector/Difficulties.hide()
	$SkinSelector/DifficultiesTexts.hide()
	$SkinSelector/SkinSelect2.show()
	
	# toggle easy to false if 2 players are selected
	$SkinSelector._on_easy_toggled(false)
	$SkinSelector.behavior = Paddle.Behavior.PLAYER

# Skins chosen inside of skin selector, this will call for a new game to start
func _on_skin_selector_start():
	behavior = $SkinSelector.behavior
	p1_sprite = $SkinSelector.p1_sprite
	p2_sprite = $SkinSelector.p2_sprite
	
	$NumPlayers.hide()
	$Title.hide()
	$InGame.show()
	start_game.emit(behavior, p1_sprite, p2_sprite)

# This keeps track of which hud element is currently visible, in order to
# have "esc" either backtrack, or quit the game
func _input(event):
	if event.is_action_pressed("esc") and $MainMenu.is_visible():
		get_tree().quit()
	elif event.is_action_pressed("esc") and $NumPlayers.is_visible():
		$NumPlayers.hide()
		$MainMenu.show()
	elif event.is_action_pressed("esc") and $SkinSelector.is_visible():
		$SkinSelector.hide()
		$NumPlayers.show()
