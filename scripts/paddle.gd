extends Area2D

class_name Paddle

signal hit

enum Direction {UP, DOWN, IDLE}

@onready var screen_size = get_viewport_rect().size
@onready var size = $CollisionShape2D.shape.size

var speed: int

func setup_paddle(p_speed: int):
	speed = p_speed

func update_position(direction: Direction, delta):
	var direction_velocity
	
	match direction:
		Direction.UP:
			direction_velocity = Vector2.UP
		Direction.DOWN:
			direction_velocity = Vector2.DOWN
		Direction.IDLE:
			direction_velocity = Vector2.ZERO
		
	position += direction_velocity * speed * delta
	position.y = clamp(position.y, size.y / 2, screen_size.y - size.y / 2)

# Called when an area (the ball) hits the paddle
func _on_area_entered(_area):
	$Hit.play()
	hit.emit()
