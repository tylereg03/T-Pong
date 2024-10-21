extends Node2D

class_name Game

enum GameplayState {
	IDLE,
	PLAYING,
	PAUSED,
	WIN
}

enum AIPaddleDifficulty {
	EASY,
	MEDIUM,
	HARD,
}

enum PaddleType {
	PLAYER,
	AI,
	FIRE
}

var paddle_type_scenes = {
	PaddleType.PLAYER: preload("res://scenes/paddle_scenes/player_paddle.tscn"),
	PaddleType.AI: preload("res://scenes/paddle_scenes/ai_paddle.tscn")
}

# First element is the paddle speed, second element is the reaction time
var paddle_difficulty_attributes = {
	AIPaddleDifficulty.EASY: [200, 0.85],
	AIPaddleDifficulty.MEDIUM: [300, 0.65],
	AIPaddleDifficulty.HARD: [400, 0.45]
}


signal game_end

var paddle_scene = preload("res://scenes/paddle_scenes/paddle.tscn")
var ball_scene = preload("res://scenes/ball.tscn")

@onready var p1_score_text = $HUD/Player1Score
@onready var p2_score_text = $HUD/Player2Score

const MAX_SCORE = 7
const MAX_SPEED = 600
const MIN_SPEED = 150
var p1_score = 0
var p2_score = 0
var ball_direction = 1


var ball
var p1_paddle: PlayerPaddle
var p2_paddle
var ball_spawn
var curr_state
var screen_size

func _ready():
	update_screen_size()
	
func update_screen_size():
	screen_size = get_viewport().get_visible_rect().size

func set_state(new_state):
	curr_state = new_state
	match curr_state:
		GameplayState.IDLE:
			print("GameplayState: In IDLE")
		GameplayState.PLAYING:
			print("GameplayState: In PLAYING")
			serve()
		GameplayState.PAUSED:
			print("GameplayState: In PAUSED")
			get_tree().paused = true
			$PauseMenu.show()
		GameplayState.WIN:
			print("GameplayState: In WIN")
			win_screen()


# Called to instantiate any scene passed into it
func inst(scene):
	var instance = scene.instantiate()
	add_child(instance)
	return instance


# Called whenever a new game has been started
func new_game(p2_type, p2_difficulty, p1_sprite, p2_sprite):	
	var p1_paddle_spawn = Vector2(64, 64)
	var p2_paddle_spawn = Vector2(screen_size.x-64, screen_size.y-64)
	ball_spawn = Vector2(screen_size.x/2, screen_size.y/2)
	
	instantiate_game_objects(p2_type)
	
	setup_ball(ball, ball_spawn)
	
	setup_paddle(p1_paddle, p1_paddle_spawn, p1_sprite)
	p1_paddle.setup_player_paddle("move_up", "move_down")
	
	setup_paddle(p2_paddle, p2_paddle_spawn, p2_sprite)
	var ai_speed = paddle_difficulty_attributes[p2_difficulty][0]
	var ai_reaction_time = paddle_difficulty_attributes[p2_difficulty][1]
	match p2_type:
		PaddleType.PLAYER:
			p2_paddle.setup_player_paddle("move_up_2", "move_down_2")
		PaddleType.AI:
			p2_paddle.setup_ai_paddle(ai_speed, ai_reaction_time, ball)
			
	$HUD.show()
	$HUD/ServeMessage.show()
	$HUD/WinMessage.hide()
	set_state(GameplayState.IDLE)


# Instantiates all objects necessary for pong to work
func instantiate_game_objects(p2_type):
	ball = inst(ball_scene)
	p1_paddle = inst(paddle_type_scenes[PaddleType.PLAYER])
	p2_paddle = inst(paddle_type_scenes[p2_type])


# Sets up the ball to connect it's signal, and spawn in the correct place
func setup_ball(new_ball, pos):
	new_ball.score.connect(_on_score)
	new_ball.position = pos


# Sets up the paddles to connect their signals, spawn in the right place,
# take on the correct behavior, the correct sprite, and keep track of the ball
func setup_paddle(new_paddle, pos, sprite):
	new_paddle.hit.connect(_on_paddle_hit)
	new_paddle.position = pos
	new_paddle.get_node("Sprite2D").texture = sprite

# Called by ball whenever space is pressed to serve the ball
func serve():
	ball.velocity.x = ball_direction
	$HUD/ServeMessage.hide()

# Called whenever a paddle comes into contact with the ball
func _on_paddle_hit():
	ball.velocity.x *= -1
	ball.velocity.y += randf_range(-0.5, 0.5)
	ball.velocity.normalized()
	ball.speed += 10
	ball.speed = clamp(ball.speed, MIN_SPEED, MAX_SPEED)


# Called whenever the ball has exited the screen on the left or right
func _on_score():
	$HUD/ServeMessage.show()
	
	if ball.velocity.x > 0:
		p1_score = update_score(p1_score + 1, p1_score_text)
		ball_direction = 1
	else:
		p2_score = update_score(p2_score + 1, p2_score_text)
		ball_direction = -1
		
	is_winner()


# Called whenever a score update occurs
func update_score(score, score_label):
	score_label.text = str(score)
	return score


# Called to see if there is a winner, if not, respawn the ball
func is_winner():
	ball.position = ball_spawn
	ball.velocity = Vector2.ZERO
	ball.speed = MIN_SPEED
	
	if p1_score == 7 or p2_score == 7:
		set_state(GameplayState.WIN)
	else:
		set_state(GameplayState.IDLE)


func win_screen():
	hide_game_objects()
	
	$Win.play()
	
	if p1_score == 7:
		$HUD/WinMessage.text = "Player 1 wins! \n Press Space"
	else:
		$HUD/WinMessage.text = "Player 2 wins! \n Press Space"
	
	$HUD/ServeMessage.hide()
	$HUD/WinMessage.show()

# Called when the game has ended either by a quit or a win
func game_over():
	clear_game_objects()
	
	p1_score = update_score(0, p1_score_text)
	p2_score = update_score(0, p2_score_text)
	$HUD.hide()
	$HUD/WinMessage.hide()
	
	game_end.emit()

func hide_game_objects():
	p1_paddle.hide()
	p2_paddle.hide()
	ball.hide()

# Called to delete no longer used game objects
func clear_game_objects():
	p1_paddle.hit.disconnect( _on_paddle_hit)
	p2_paddle.hit.disconnect(_on_paddle_hit)
	ball.score.disconnect(_on_score)
	
	p1_paddle.queue_free()
	p2_paddle.queue_free()
	ball.queue_free()


# create function to set state back to playing
func _on_pause_menu_unpause():
	set_state(GameplayState.PLAYING)
	
# Checks for any inputs
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.is_action_pressed("space") and curr_state == GameplayState.IDLE:
			set_state(GameplayState.PLAYING)
		elif event.is_action_pressed("space") and curr_state == GameplayState.WIN:
			game_over()
		elif event.is_action_pressed("esc") and (curr_state == GameplayState.PLAYING or curr_state == GameplayState.IDLE):
			set_state(GameplayState.PAUSED)
