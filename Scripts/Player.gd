extends KinematicBody2D
class_name Player

export(Resource) var movementData

var velocity = Vector2.ZERO

onready var animatedSprite: AnimatedSprite = $Sprite

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_gravity()
	var input = Vector2.ZERO
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	if input.x == 0:
		apply_friction()
		animatedSprite.animation = "Idle"
	else:
		apply_acceleration(input.x)
		animatedSprite.animation = "Run"
		
		animatedSprite.flip_h = input.x > 0
			
	if is_on_floor():
		if Input.is_action_pressed("ui_up"):
			velocity.y = movementData.JUMP_FORCE
	else:
		animatedSprite.animation = "Jump"
		if Input.is_action_just_released("ui_up") and velocity.y < movementData.JUMP_RELEASE_FORCE:
			velocity.y = movementData.JUMP_RELEASE_FORCE
		
		if velocity.y > 0:
			velocity.y += movementData.ADDITIONAL_FALL_GRAVITY
	
	var was_in_air = not is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	if is_on_floor() and was_in_air:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
		

func apply_gravity() -> void:
	velocity.y += movementData.GRAVITY
	velocity.y = min(velocity.y, 300)

func apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, movementData.FRICTION)
	
func apply_acceleration(amount: float) -> void:
	velocity.x = move_toward(velocity.x, movementData.MAX_SPEED * amount, movementData.ACCELERATION)
