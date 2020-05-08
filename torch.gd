extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	play("burn") # Replace with function body.
	if $RayCast2D.is_colliding():
		var rayCollision = $RayCast2D.get_collision_point()
		rayCollision.y -= 10
		set_position(rayCollision)
		$RayCast2D.enabled = false
