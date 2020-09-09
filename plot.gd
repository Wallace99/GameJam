extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var mouseInArea = false
var plant = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $RayCast2D.is_colliding():
		var rayCollision = $RayCast2D.get_collision_point()
		set_position(rayCollision)
		$RayCast2D.enabled = false

func setPlant(_plant):
	plant = _plant
	
func getPlant():
	return plant
