extends Area2D

signal score
signal serve

@export var speed = 150
var screen_size
var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	velocity = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# After a point, we can press "serve" (space) to start a new point
	if Input.is_action_just_pressed("serve") and velocity.length() == 0:
		serve.emit()
	
	position += velocity * speed * delta
	var size = $CollisionShape2D.shape.size
	
	# bounces off the top or bottom wall
	if position.y >= screen_size.y - size.y / 2 or position.y <= size.y / 2:
		velocity.y *= -1
	
	# passes the paddle and leaves through the left or right
	if position.x <= -size.x / 2 or position.x >= screen_size.x - size.x / 2:
		score.emit()
