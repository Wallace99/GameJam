extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal snuffed(torch)
signal relight(torch)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == BUTTON_LEFT:
			emit_signal("relight", get_parent())
	


func _on_Area2D_body_entered(body):
	if "enemy2" in body.name:
		emit_signal("snuffed", get_parent())
		body.get_node("eatAudio").play()
