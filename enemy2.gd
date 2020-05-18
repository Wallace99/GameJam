extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var state = 'walking'
var direction = 'left'
var velocity = Vector2()
var bouncingBack = false
const GRAVITY = 5
const SPEED = 40
const JUMP_POWER = -150


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite.play("walk")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _physics_process(delta):
	if direction == 'left' and $RayCast2D.is_colliding() and !bouncingBack:
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = true
		velocity.x = -SPEED
		if $wallCheckLeft.is_colliding():
			$jumpAudio.play()
			velocity.y = JUMP_POWER
	elif direction == 'right' and $RayCast2D.is_colliding() and !bouncingBack:
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = false
		velocity.x = SPEED
		if $wallCheckRight.is_colliding():
			$jumpAudio.play()
			velocity.y = JUMP_POWER
	
	if !$RayCast2D.is_colliding():
		velocity.y += GRAVITY
	
	move_and_slide(velocity)

func connectEnteredSignalFromPlayer(signalToConnect, targetArea, function, target):
	targetArea.connect(signalToConnect, self, function, target)

func connectSignalFromPlayer(signalToConnect, target, function):
	target.connect(signalToConnect, self, function)
	
	
func bounceBack(body, torch):
	if body != self or !torch.get_node("Light2D").enabled:
		return
	bouncingBack = true
	$jumpAudio.play()
	$bounceBackTimer.start()
	if torch.global_position.x > global_position.x:
		velocity.x = -SPEED
	else:
		velocity.x = SPEED
	velocity.y = JUMP_POWER/2
	if abs(torch.global_position.x - global_position.x) < 20:
		velocity.x *= 3
		velocity.y *= 3
	
func getDirection(player_position, plants, torches):
	if plants.size() > 0:
		var closestPlant = plants[0]
		if !is_instance_valid(closestPlant):
			getDirectionNoPlants(player_position)
			return
		var distanceToClosest = abs(closestPlant.global_position.x - global_position.x)
		for plant in plants:
			var distance = abs(plant.global_position.x - global_position.x)
			if distance < distanceToClosest:
				distanceToClosest = distance
				closestPlant = plant
		if distanceToClosest < abs(global_position.x - player_position.x):
			if closestPlant.global_position.x > global_position.x:
				direction = 'right'
			else:
				direction = 'left'
		else:
			getDirectionNoPlants(player_position)
	else:
		getDirectionNoPlants(player_position)
	for area in get_node("Area2D").get_overlapping_areas():
		if 'enemyRange' in area.name:
			bounceBack(self, area.get_parent())
				


func getDirectionNoPlants(player_position):
	if player_position.x > global_position.x:
		direction = 'right'
	else:
		direction = 'left'

func _on_bounceBackTimer_timeout():
	bouncingBack = false
