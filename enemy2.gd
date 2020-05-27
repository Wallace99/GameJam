extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state = 'walking'
var direction = 'left'
var velocity = Vector2()
var bouncingBack = false
const GRAVITY = 5
const SPEED = 20
const JUMP_POWER = -150


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if direction == 'left':
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = false
		velocity.x = -SPEED
		if $wallCheckLeft.is_colliding():
			$jumpAudio.play()
			velocity.y = JUMP_POWER
	elif direction == 'right':
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = true
		velocity.x = SPEED
		if $wallCheckRight.is_colliding():
			$jumpAudio.play()
			velocity.y = JUMP_POWER
	else:
		velocity.x = 0
	
	if bouncingBack:
		velocity.x *= 2
	
	if !$RayCast2D.is_colliding():
		velocity.y += GRAVITY
	
	move_and_slide(velocity)

func connectEnteredSignalFromPlayer(signalToConnect, targetArea, function, target):
	targetArea.connect(signalToConnect, self, function, target)

func connectSignalFromPlayer(signalToConnect, target, function):
	target.connect(signalToConnect, self, function)
	
	
func getDirection(player_position, plants, _torches, litTorches):
	if bouncingBack:
		if player_position.x > global_position.x:
			direction = 'left'
		else:
			direction = 'right'
		return
	if abs(player_position.x - global_position.x) < 100:
		bouncingBack = true
		$bounceBackTimer.start()
		if player_position.x > global_position.x:
			direction = 'left'
		else:
			direction = 'right'
		return
	if litTorches.size() > 0:
		var closestTorch = litTorches[0]
		if !is_instance_valid(closestTorch):
			direction = "stationary"
			return 
		var distanceToClosest = abs(closestTorch.global_position.x - global_position.x)
		for torch in litTorches:
			var distance = abs(torch.global_position.x - global_position.x)
			if distance < distanceToClosest:
				distanceToClosest = distance
				closestTorch = torch
		if closestTorch.global_position.x > global_position.x:
			direction = 'right'
		else:
			direction = 'left'
	else:
		direction = "stationary"

	

func _on_bounceBackTimer_timeout():
	bouncingBack = false
	
	
func getBouncingBack():
	return bouncingBack
