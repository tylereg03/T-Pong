extends CanvasLayer

signal start(diff, c)

@export var textures: Array[Texture2D]

var current_texture_index: int = 0
var sprite

func _ready():
	sprite = $SkinSelect/TextureRect
	update_texture()
	
func update_texture():
	sprite.texture = textures[current_texture_index]

func _on_left_button_down():
	if current_texture_index == 0:
		current_texture_index = textures.size() - 1
	else:
		current_texture_index -= 1
	update_texture()

func _on_right_button_down():
	if current_texture_index == textures.size() - 1:
		current_texture_index = 0
	else:
		current_texture_index += 1
	update_texture()

func _on_easy_button_down():
	start_game(Paddle.Behavior.EASY, sprite)
	
func _on_medium_button_down():
	start_game(Paddle.Behavior.MEDIUM, sprite)

func _on_hard_button_down():
	start_game(Paddle.Behavior.HARD, sprite)

func start_game(diff, c):
	hide()
	start.emit(diff, c)
