extends Node

enum MasterState {
	MENU,
	PLAYING
}

var curr_state


@onready var menu_state_machine = $Menu
@onready var gameplay_state_machine = $Game

# Called when the node enters the scene tree for the first time.
func _ready():
	menu_state_machine.set_state(Menu.MenuState.MAIN_MENU)
	set_state(MasterState.MENU)

# This function is responsible for setting new states
func set_state(new_state):
	curr_state = new_state
	match curr_state:
		MasterState.MENU:
			print("StateMachine: In MENU")
			menu_state_machine.show()
			gameplay_state_machine.hide()
		MasterState.PLAYING:
			print("StateMachine: In PLAYING")
			menu_state_machine.hide()
			gameplay_state_machine.show()


# Called when menu state is GAME_START
func _on_hud_game_start(p2_type, p2_difficulty, p1_sprite, p2_sprite):
	gameplay_state_machine.new_game(p2_type, p2_difficulty, p1_sprite, p2_sprite)
	$Menu/MainMenuMusic.stop()
	set_state(MasterState.PLAYING)


func _on_game_game_end():
	menu_state_machine.set_state(Menu.MenuState.MAIN_MENU)
	$Menu/MainMenuMusic.play()
	set_state(MasterState.MENU)
