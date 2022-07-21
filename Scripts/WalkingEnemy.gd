extends KinematicBody2D

var direction = Vector2.RIGHT
var velocity = Vector2.ZERO

onready var ledgeCheckRight: RayCast2D = $LedgeCheckRight
onready var ledgeCheckLeft: RayCast2D = $LedgeCheckLeft
onready var sprite: AnimatedSprite = $Sprite

func _physics_process(delta: float) -> void:
	var found_wall = is_on_wall()
	var found_ledge = not ledgeCheckRight.is_colliding() or not ledgeCheckLeft.is_colliding()
	
	if found_wall or found_ledge:
		direction *= -1
		
	sprite.flip_h = direction.x > 0
	
	velocity = direction * 25
	move_and_slide(velocity, Vector2.UP)
