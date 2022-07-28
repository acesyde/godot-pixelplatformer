extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB
}

export(Resource) var movementData

var velocity = Vector2.ZERO
var state = MOVE
var double_jump: int = 1
var buffered_jump: bool = false
var coyote_jump: bool = false

onready var animatedSprite: AnimatedSprite = $Sprite
onready var ladderCheck: RayCast2D = $LadderCheck
onready var jumpBufferTimer: Timer = $JumpBufferTimer
onready var coyoteTimer: Timer = $CoyoteJumpTimer

func _physics_process(delta: float) -> void:
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input)
		CLIMB: climb_state(input)

func move_state(input: Vector2):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
		state = CLIMB
		
	apply_gravity()
	
	if not horizontal_move(input):
		apply_friction()
		animatedSprite.animation = "Idle"
	
	if horizontal_move(input):
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input.x > 0
		
	if is_on_floor():
		reset_double_jump()
	else:
		animatedSprite.animation = "Jump"
			
	if can_jump():
		input_jump()
	else:
		input_jump_release()
		input_double_jump()
		buffered_jump()
		fast_fall()
	
	var was_in_air = not is_on_floor()
	var was_on_floor = is_on_floor()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if is_on_floor() and was_in_air:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		
	var just_left_ground = not is_on_floor() and was_on_floor
	if just_left_ground and velocity.y >= 0:
		coyote_jump = true
		coyoteTimer.start()
	
func climb_state(input: Vector2):
	if not is_on_ladder():
		state = MOVE

	if input.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
		
	velocity = input * movementData.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func input_jump_release():
	if Input.is_action_just_released("ui_up") and velocity.y < movementData.JUMP_RELEASE_FORCE:
		velocity.y = movementData.JUMP_RELEASE_FORCE
	
func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump > 0:
		velocity.y = movementData.JUMP_FORCE
		double_jump -= 1

func buffered_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()

func fast_fall():
	if velocity.y > 0:
		velocity.y += movementData.ADDITIONAL_FALL_GRAVITY

func horizontal_move(input: Vector2) -> bool:
	return input.x != 0

func can_jump() -> bool:
	return is_on_floor() or coyote_jump

func reset_double_jump():
	double_jump = movementData.DOUBLE_JUMP_COUNT

func input_jump() -> void:
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		velocity.y = movementData.JUMP_FORCE
		buffered_jump = false

func is_on_ladder() -> bool:
	if not ladderCheck.is_colliding():
		return false
	
	var collider = ladderCheck.get_collider()
	if not collider is Ladder:
		return false
		
	return true

func apply_gravity() -> void:
	velocity.y += movementData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, movementData.FRICTION)
	
func apply_acceleration(amount: float) -> void:
	velocity.x = move_toward(velocity.x, movementData.MAX_SPEED * amount, movementData.ACCELERATION)

func _on_JumpBufferTimer_timeout() -> void:
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout() -> void:
	coyote_jump = false
