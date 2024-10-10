extends Area2D

class_name Paddle

signal hit

@export var speed = 400
@export var up_action = "move_up"  # Default to Player 1's up action
@export var down_action = "move_down"  # Default to Player 1's down action

enum Behavior {PLAYER, EASY, MEDIUM, HARD}
var behavior_weight = {Behavior.EASY: 0.05, Behavior.MEDIUM: 0.25, Behavior.HARD: 0.75}

var screen_size
var ball
var behavior

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if ball == null or behavior == null:
		return
		
	# This determines the AI pattern (HUGE OVERHAUL NEEDED)
	if ball.velocity.x > 0 and behavior != Behavior.PLAYER:
		var target_position = ball.position.y
		position.y = lerp(position.y, target_position, behavior_weight[behavior])
	
	# This determines the behavior of a player paddle
	elif behavior == Behavior.PLAYER:
		if Input.is_action_pressed(down_action):
			velocity = Vector2.DOWN
		if Input.is_action_pressed(up_action):
			velocity = Vector2.UP
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	var size = $CollisionShape2D.shape.size
	
	position += velocity * delta
	position.y = clamp(position.y, size.y / 2, screen_size.y - size.y / 2)

# Called when an area (the ball) hits the paddle
func _on_area_entered(_area):
	hit.emit()
