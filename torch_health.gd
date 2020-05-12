extends TextureProgress


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal outOfLight

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	var torchRemaining = get_value()
	set_value(torchRemaining - 1)
	if torchRemaining < 1:
		emit_signal("outOfLight")
		
