extends Paddle

class_name PlayerPaddle

const SPEED = 500

var up_action: StringName
var down_action: StringName

func setup_player_paddle(p_up_action: StringName, p_down_action: StringName):
	setup_paddle(SPEED)
	up_action = p_up_action
	down_action = p_down_action

func _physics_process(delta):
	var direction: Direction
	
	if Input.is_action_pressed(down_action):
		direction = Direction.DOWN
	elif Input.is_action_pressed(up_action):
		direction = Direction.UP
	else:
		direction = Direction.IDLE
	
	update_position(direction, delta)
