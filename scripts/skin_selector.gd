extends CanvasLayer

signal done

@export var textures: Array[Texture2D]

# stores the sprites used for each difficulty
@onready var easy_sprite = textures[0]
@onready var med_sprite = textures[1]
@onready var hard_sprite = textures[2]

# stores what texture the user is currently hovering
var current_texture_index: int = 0

# this will display what sprite the user is hovering
var sprite

# these will be accessed by HUD in order to retrieve the proper sprites/behavior
var behavior
var p1_sprite
var p2_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite = $SkinSelect/TextureRect
	update_texture()

# Called whenever a sprite in the selector needs to be updated
func update_texture():
	sprite.texture = textures[current_texture_index]

# Called when the left cycle button for P1 is pressed
func _on_left_button_down():
	if current_texture_index == 0:
		current_texture_index = textures.size() - 1
	else:
		current_texture_index -= 1
	update_texture()

# Called when the left cycle button for P2 is pressed
func _on_right_button_down():
	if current_texture_index == textures.size() - 1:
		current_texture_index = 0
	else:
		current_texture_index += 1
	update_texture()

# ONLY ACCESSIBLE FOR 1 PLAYER, Easy button pressed
func _on_easy_button_down():
	behavior = Paddle.Behavior.EASY
	p1_sprite = sprite.texture
	p2_sprite = easy_sprite
	finish()

# ONLY ACCESSIBLE FOR 1 PLAYER, Medium button pressed
func _on_medium_button_down():
	behavior = Paddle.Behavior.MEDIUM
	p1_sprite = sprite.texture
	p2_sprite = med_sprite
	finish()

# ONLY ACCESSIBLE FOR 1 PLAYER, Hard button pressed
func _on_hard_button_down():
	behavior = Paddle.Behavior.HARD
	p1_sprite = sprite.texture
	p2_sprite = hard_sprite
	finish()

# Hides the skin selector, and alerts the hud that it has finished
func finish():
	hide()
	done.emit()
