extends Area2D

class_name Paddle

signal hit

@export var up_action = "move_up"  # Default to Player 1's up action
@export var down_action = "move_down"  # Default to Player 1's down action

enum Behavior {PLAYER, EASY, MEDIUM, HARD}


# defines a paddle's reaction time (in seconds) before moving towards the ball
var behavior_reaction_time = {Behavior.PLAYER: 0.0, 
							Behavior.EASY: 0.85, 
							Behavior.MEDIUM: 0.65, 
							Behavior.HARD: 0.45}

# defines a paddle's movement speed (in pixels)
var behavior_paddle_speed = {Behavior.PLAYER: 500, 
							 Behavior.EASY: 200, 
							 Behavior.MEDIUM: 300, 
							 Behavior.HARD: 400}

var velocity = Vector2.ZERO
var timer_started = false

var screen_size
var ball
var behavior

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# determines the paddle speed based on the difficulty of the paddle
	var speed = behavior_paddle_speed[behavior]
	
	if ball == null or behavior == null:
		return
	
	if ball.velocity.x == 0:
		timer_started = false
	
	# This determines the AI pattern
	if ball.velocity.x > 0 and behavior != Behavior.PLAYER:
		if not timer_started:
			$ReactionTime.start(behavior_reaction_time[behavior])
			timer_started = true
		
		if $ReactionTime.get_time_left() > 0:
			return
		else:
			var target_pos = ball.position.y
			var distance = abs(target_pos - position.y)
			
			# if the distance is less than one "cycle" of movement
			if distance < speed * delta:
				velocity = Vector2.ZERO
			elif target_pos > position.y:
				velocity = Vector2.DOWN
			elif target_pos < position.y:
				velocity = Vector2.UP
	elif behavior != Behavior.PLAYER:
		velocity = Vector2.ZERO
		
	# This determines the behavior of a player paddle
	elif behavior == Behavior.PLAYER:
		if Input.is_action_pressed(down_action):
			velocity = Vector2.DOWN
		elif Input.is_action_pressed(up_action):
			velocity = Vector2.UP
		else:
			velocity = Vector2.ZERO
	
	var size = $CollisionShape2D.shape.size
	
	position += velocity.normalized() * speed * delta
	position.y = clamp(position.y, size.y / 2, screen_size.y - size.y / 2)

# Called when an area (the ball) hits the paddle
func _on_area_entered(_area):
	$Hit.play()
	timer_started = false
	hit.emit()
