extends Node

@export var paddle_scene = preload("res://scenes/paddle.tscn")
@export var ball_scene = preload("res://scenes/ball.tscn")
var p1_score = 0
var p2_score = 0
var max_speed = 600
var min_speed = 150
var ball_direction = 1
var game_underway = false

var screen_size
var p1_paddle
var p2_paddle
var ball
var skin_selector

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size
	$HUD/InGame.hide()
	
func inst(scene, pos):
	var instance = scene.instantiate()
	instance.position = pos
	add_child(instance)
	return instance
	
func _on_paddle_hit():
	ball.velocity.x *= -1
	ball.velocity.y += randf_range(-0.5, 0.5)
	ball.velocity.normalized()
	ball.speed += 5
	ball.speed = clamp(ball.speed, min_speed, max_speed)
	
func _on_score():
	$HUD/InGame/Message.show()
	if ball.velocity.x > 0:
		p1_score += 1
		ball_direction = -1
		$HUD/InGame/Player1Score.text = str(p1_score)
	else:
		p2_score += 1
		ball_direction = 1
		$HUD/InGame/Player2Score.text = str(p2_score)
		
	if p1_score == 7:
		game_over()
	elif p2_score == 7:
		game_over()
	else:
		ball.position = Vector2(screen_size.x/2, screen_size.y/2)
		ball.velocity = Vector2.ZERO
		ball.speed = min_speed

func _server():
	ball.velocity.x = ball_direction
	$HUD/InGame/Message.hide()

func _new_game(diff, c):
	game_underway = true
	ball = inst(ball_scene, Vector2(screen_size.x/2, screen_size.y/2))
	p1_paddle = inst(paddle_scene, Vector2(64, 64))
	p2_paddle = inst(paddle_scene, Vector2(screen_size.x-64, screen_size.y-64))
	
	paddle_settings(diff, c)
	
	p1_paddle.hit.connect(_on_paddle_hit)
	p2_paddle.hit.connect(_on_paddle_hit)
	ball.score.connect(_on_score)
	ball.serve.connect(_server)
	$HUD/InGame/Message.show()

func paddle_settings(diff, c):
	p1_paddle.behavior = Paddle.Behavior.PLAYER
	p1_paddle.ball = ball
	p2_paddle.ball = ball
	match diff:
		Paddle.Behavior.PLAYER:
			print("Two-player mode selected")
			p2_paddle.up_action = "move_up_2"
			p2_paddle.down_action = "move_down_2"
			p2_paddle.behavior = Paddle.Behavior.PLAYER
		Paddle.Behavior.EASY:
			p1_paddle.get_node("Sprite2D").texture = c.texture
			skin_selector = $HUD.get_node("SkinSelector")
			
			p2_paddle.get_node("Sprite2D").texture = skin_selector.textures[0]
			p2_paddle.behavior = Paddle.Behavior.EASY
		Paddle.Behavior.MEDIUM:
			p1_paddle.get_node("Sprite2D").texture = c.texture
			skin_selector = $HUD.get_node("SkinSelector")
			
			p2_paddle.get_node("Sprite2D").texture = skin_selector.textures[1]
			p2_paddle.behavior = Paddle.Behavior.MEDIUM
		Paddle.Behavior.HARD:
			p1_paddle.get_node("Sprite2D").texture = c.texture
			skin_selector = $HUD.get_node("SkinSelector")
			
			p2_paddle.get_node("Sprite2D").texture = skin_selector.textures[2]
			p2_paddle.behavior = Paddle.Behavior.HARD

func game_over():
	game_underway = false
	p1_paddle.hit.disconnect( _on_paddle_hit)
	p2_paddle.hit.disconnect(_on_paddle_hit)
	ball.score.disconnect(_on_score)
	ball.serve.disconnect(_server)
	
	p1_paddle.queue_free()
	p2_paddle.queue_free()
	ball.queue_free()
	p1_score = 0
	p2_score = 0
	$HUD/InGame/Player1Score.text = str(p1_score)
	$HUD/InGame/Player2Score.text = str(p2_score)
	$HUD/InGame.hide()
	$HUD/Title.show()
	$HUD/MainMenu.show()

func _input(event):
	if event.is_action_pressed("esc") and game_underway:
		get_tree().paused = true
		$PauseMenu.show()

func _on_pause_menu_end():
	game_over()
