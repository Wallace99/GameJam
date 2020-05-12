extends RigidBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var seedType = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _getSeedType():
	return seedType

func _setSeedType(type):
	seedType = type

func _setTexture():
	if seedType == null:
		print("Error: seed type not set")
		return
	var colour = Color.brown
	if seedType == 'purple':
		colour = Color.purple
	elif seedType == 'green':
		colour = Color.green
	get_node("Sprite").modulate = colour 
