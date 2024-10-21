extends Paddle

class_name AIPaddle

var timer_started = false

var reaction_time
var ball

func setup_ai_paddle(p_speed, p_reaction_time, p_ball):
	setup_paddle(p_speed)
	reaction_time = p_reaction_time
	ball = p_ball
	
func _physics_process(delta):
	ai_move(delta)
		
func ai_move(delta):
	if ball == null:
		return
	
	# checks if the ball is in the serve state
	if ball.velocity.x == 0:
		timer_started = false
	
	# Don't move the paddle if ball not heading towards AI paddle
	if ball.velocity.x <= 0:
		return
	
	# Timer will start once we know the ball is moving toward the AI
	if not timer_started:
		$ReactionTime.start(reaction_time)
		timer_started = true
	
	if $ReactionTime.get_time_left() > 0:
		return
	
	var target_pos = ball.position.y
	var distance = abs(target_pos - position.y)
	var direction: Direction
	
	# if the distance is less than one "cycle" of movement
	if distance < speed * delta:
		direction = Direction.IDLE
	elif target_pos > position.y:
		direction = Direction.DOWN
	elif target_pos < position.y:
		direction = Direction.UP
	
	update_position(direction, delta)

func _on_area_entered(_area):
	$Hit.play()
	timer_started = false
	hit.emit()
