extends Area2D

class_name Paddle

signal hit

enum Behavior {PLAYER, EASY, MEDIUM, HARD}
var behavior_weight = {Behavior.EASY: 0.05, Behavior.MEDIUM: 0.25, Behavior.HARD: 0.75}

@export var speed = 400
var follow_speed = 200
var rf = 0.1 # randomness factor
var damp = 0.1

var screen_size
var ball
var behavior

@export var up_action = "move_up"  # Default to Player 1's up action
@export var down_action = "move_down"  # Default to Player 1's down action

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity = Vector2.ZERO
	
	if ball == null or behavior == null:
		return
	
	if ball.velocity.x > 0 and behavior != Behavior.PLAYER:
		var target_position = ball.position.y
		var weight
			
		position.y = lerp(position.y, target_position, behavior_weight[behavior])
		
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

func _on_area_entered(area):
	print(area)
	hit.emit()
