extends Node

@export var paddle_scene = preload("res://scenes/paddle.tscn")
@export var ball_scene = preload("res://scenes/ball.tscn")

@onready var p1_score_text = $HUD/InGame/Player1Score
@onready var p2_score_text = $HUD/InGame/Player2Score

const MAX_SCORE = 7
const MAX_SPEED = 600
const MIN_SPEED = 150
const P1_BEHAVIOR = Paddle.Behavior.PLAYER

var p1_score = 0
var p2_score = 0
var ball_direction = 1
var game_underway = false

var ball
var p1_paddle
var p2_paddle
var ball_spawn
var screen_size

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport().size

# Called to instantiate any scene passed into it
func inst(scene):
	var instance = scene.instantiate()
	add_child(instance)
	return instance

# Called whenever a new game has been started
func _new_game(behavior, p1_sprite, p2_sprite):
	game_underway = true
	
	var p1_paddle_spawn = Vector2(64, 64)
	var p2_paddle_spawn = Vector2(screen_size.x-64, screen_size.y-64)
	ball_spawn = Vector2(screen_size.x/2, screen_size.y/2)
	
	instantiate_game_objects()
	
	setup_ball(ball, ball_spawn)
	setup_paddle(p1_paddle, p1_paddle_spawn, P1_BEHAVIOR, p1_sprite, "move_up", "move_down")
	setup_paddle(p2_paddle, p2_paddle_spawn, behavior, p2_sprite, "move_up_2", "move_down_2")
	
	$HUD/InGame/Message.show()

# Instantiates all objects necessary for pong to work
func instantiate_game_objects():
	ball = inst(ball_scene)
	p1_paddle = inst(paddle_scene)
	p2_paddle = inst(paddle_scene)

# Sets up the ball to connect it's signals, and spawn in the correct place
func setup_ball(new_ball, pos):
	new_ball.score.connect(_on_score)
	new_ball.serve.connect(_server)
	new_ball.position = pos

# Sets up the paddles to connect their signals, spawn in the right place,
# take on the correct behavior, the correct sprite, and keep track of the ball
func setup_paddle(new_paddle, pos, behavior, sprite, up, down):
	new_paddle.hit.connect(_on_paddle_hit)
	new_paddle.position = pos
	new_paddle.behavior = behavior
	new_paddle.get_node("Sprite2D").texture = sprite
	
	if behavior == Paddle.Behavior.PLAYER:
		new_paddle.up_action = up
		new_paddle.down_action = down
		
	new_paddle.ball = ball

# Called whenever a paddle comes into contact with the ball
func _on_paddle_hit():
	ball.velocity.x *= -1
	ball.velocity.y += randf_range(-0.5, 0.5)
	ball.velocity.normalized()
	ball.speed += 5
	ball.speed = clamp(ball.speed, MIN_SPEED, MAX_SPEED)

# Called whenever the ball has exited the screen on the left or right
func _on_score():
	$HUD/InGame/Message.show()
	
	if ball.velocity.x > 0:
		p1_score = update_score(p1_score + 1, p1_score_text)
	else:
		p2_score = update_score(p2_score + 1, p2_score_text)
		
	is_winner()

# Called whenever a score update occurs
func update_score(score, score_label):
	ball_direction *= -1 # alternates the server
	score_label.text = str(score)
	
	return score

# Called to see if there is a winner, if not, respawn the ball
func is_winner():
	if p1_score == 7:
		print("p1 wins!")
		game_over()
	elif p2_score == 7:
		print("p2 wins!")
		game_over()
	else:
		ball.position = ball_spawn
		ball.velocity = Vector2.ZERO
		ball.speed = MIN_SPEED

# Called by ball whenever space is pressed to serve the ball
func _server():
	ball.velocity.x = ball_direction
	$HUD/InGame/Message.hide()

# Called whenever either player has won
func game_over():
	game_underway = false
	clear_game_objects()
	
	p1_score = update_score(0, p1_score_text)
	p2_score = update_score(0, p2_score_text)
	$HUD/InGame.hide()
	$HUD/Title.show()
	$HUD/MainMenu.show()

# Called to delete no longer used game objects
func clear_game_objects():
	p1_paddle.hit.disconnect( _on_paddle_hit)
	p2_paddle.hit.disconnect(_on_paddle_hit)
	ball.score.disconnect(_on_score)
	ball.serve.disconnect(_server)
	
	p1_paddle.queue_free()
	p2_paddle.queue_free()
	ball.queue_free()

# Checks for any inputs
func _input(event):
	if event.is_action_pressed("esc") and game_underway:
		get_tree().paused = true
		$PauseMenu.show()
