extends CanvasLayer

signal done

@export var textures: Array[Texture2D]

# stores the index assigned to each sprite used for each difficulty
@onready var easy_sprite = 1
@onready var med_sprite = 2
@onready var hard_sprite = 3

# stores what texture the users are currently hovering
var p1_current_texture_index: int = 0
var p2_current_texture_index: int = 0

# this will display what sprite the users are hovering
var sprite1_display
var sprite2_display

# these will be accessed by HUD in order to retrieve the proper sprites/behavior
var behavior
var p1_sprite
var p2_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite1_display = $SkinSelect/TextureRect
	sprite2_display = $SkinSelect2/TextureRect2
		
	update_texture()
	
# Called whenever a sprite in the selector needs to be updated
func update_texture():
	sprite1_display.texture = textures[p1_current_texture_index]
	sprite2_display.texture = textures[p2_current_texture_index]
	
	p1_sprite = sprite1_display.texture
	p2_sprite = sprite2_display.texture
	
# Called when the left cycle button for P1 is pressed
func _on_left_button_down():
	if p1_current_texture_index == 0:
		p1_current_texture_index = textures.size() - 1
	else:
		p1_current_texture_index -= 1
	update_texture()

# Called when the right cycle button for P1 is pressed
func _on_right_button_down():
	if p1_current_texture_index == textures.size() - 1:
		p1_current_texture_index = 0
	else:
		p1_current_texture_index += 1
	update_texture()

# Called when the left cycle button for P1 is pressed
func _on_left_2_button_down():
	if p2_current_texture_index == 0:
		p2_current_texture_index = textures.size() - 1
	else:
		p2_current_texture_index -= 1
	update_texture()

# Called when the right cycle button for P2 is pressed
func _on_right_2_button_down():
	if p2_current_texture_index == textures.size() - 1:
		p2_current_texture_index = 0
	else:
		p2_current_texture_index += 1
	update_texture()

# ONLY ACCESSIBLE FOR 1 PLAYER, Easy button toggled
func _on_easy_toggled(toggled_on):
	if toggled_on:
		behavior = Paddle.Behavior.EASY
		p2_current_texture_index = easy_sprite
		update_texture()

# ONLY ACCESSIBLE FOR 1 PLAYER, Medium button toggled
func _on_medium_toggled(toggled_on):
	if toggled_on:
		behavior = Paddle.Behavior.MEDIUM
		p2_current_texture_index = med_sprite
		update_texture()
		
# ONLY ACCESSIBLE FOR 1 PLAYER, Hard button toggled
func _on_hard_toggled(toggled_on):
	if toggled_on:
		behavior = Paddle.Behavior.HARD
		p2_current_texture_index = hard_sprite
		update_texture()
	
# Hides the skin selector, and alerts the hud that it has finished
func finish():
	hide()
	done.emit()
