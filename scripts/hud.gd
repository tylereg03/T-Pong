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

# 2 Player option pressed in Player select
func _on_p_2_button_down():
	$NumPlayers.hide()
	$Title.hide()
	$InGame.show()
	# textures hardcoded for now, WILL IMPLEMENT 2 PERSON SKIN SELECTOR
	start_game.emit(Paddle.Behavior.PLAYER, $SkinSelector.textures[1], $SkinSelector.textures[0])

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
