extends KinematicBody2D

var velocity = Vector2()
const SPEED = 60
const GRAVITY = 5
const JUMP_POWER = -150
var collision



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event.is_action_pressed("ui_accept") and $RayCast2D.is_colliding():
		velocity.y = JUMP_POWER

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.play("idle")
		velocity.x = 0
		
	if $RayCast2D_up.is_colliding():
		velocity.y = 50
	
	if !$RayCast2D.is_colliding():
		$AnimatedSprite.play("suprise")
		velocity.y += GRAVITY
		
	collision = move_and_slide(velocity)
