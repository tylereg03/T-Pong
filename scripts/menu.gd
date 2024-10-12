extends CanvasLayer

class_name Menu

# MENU STATE MACHINE
enum MenuState {
	MAIN_MENU,
	PLAYER_SELECT,
	SKIN_SELECT,
	GAME_START
}


# signaled when the player enters game_start
signal game_start(behavior, p1_sprite, p2_sprite)


# used to store the current state we are in, defaulting to main menu
var curr_state


# used to store information extracted from skin_selector
var behavior
var p1_sprite
var p2_sprite

# This function is responsible for setting new states
func set_state(new_state):
	curr_state = new_state
	match curr_state:
		MenuState.MAIN_MENU:
			print("MenuState: In MAIN_MENU")
			$NumPlayers.hide()
			$MainMenu.show()
		MenuState.PLAYER_SELECT:
			print("MenuState: In PLAYER_SELECT")
			$MainMenu.hide()
			$SkinSelector.hide()
			$NumPlayers.show()
		MenuState.SKIN_SELECT:
			print("MenuState: In SKIN_SELECT")
			$NumPlayers.hide()
			$SkinSelector.show()
		MenuState.GAME_START:
			print("MenuState: In GAME_START")
			$SkinSelector.hide()
			game_start.emit(behavior, p1_sprite, p2_sprite)

# Play Button in Main Menu pressed
func _on_play_pressed():
	set_state(MenuState.PLAYER_SELECT)

# Quit Button in Main Menu pressed
func _on_quit_button_down():
	get_tree().quit()


# 1 Player option pressed in Player select
func _on_p_1_button_down():
	# hide 2P specifics and show 1P specifics
	$SkinSelector/Difficulties.show()
	$SkinSelector/DifficultiesTexts.show()
	$SkinSelector/SkinSelect2.hide()
	
	# have easy automatically toggled to true
	$SkinSelector._on_easy_toggled(true)
	
	set_state(MenuState.SKIN_SELECT)


# 2 Player option pressed in Player select
func _on_p_2_button_down():
	# hide 1P specifics and show 2P specifics
	$SkinSelector/Difficulties.hide()
	$SkinSelector/DifficultiesTexts.hide()
	$SkinSelector/SkinSelect2.show()
	
	# toggle easy to false if 2 players are selected
	$SkinSelector._on_easy_toggled(false)
	$SkinSelector.behavior = Paddle.Behavior.PLAYER
	
	set_state(MenuState.SKIN_SELECT)


# Skins chosen inside of skin selector, this will call for a new game to start
func _on_skin_selector_start():
	behavior = $SkinSelector.behavior
	p1_sprite = $SkinSelector.p1_sprite
	p2_sprite = $SkinSelector.p2_sprite
	
	set_state(MenuState.GAME_START)

# This keeps track of which hud element is currently visible, in order to
# have "esc" either backtrack, or quit the game
func _input(event):
	if event.is_action_pressed("esc"):
		match curr_state:
			MenuState.MAIN_MENU:
				get_tree().quit()
			MenuState.PLAYER_SELECT:
				set_state(MenuState.MAIN_MENU)
			MenuState.SKIN_SELECT:
				set_state(MenuState.PLAYER_SELECT)
			MenuState.GAME_START:
				pass
