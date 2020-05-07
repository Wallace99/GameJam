extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var score = $"../../CanvasLayer/GUI/HBoxContainer/Counters/Counter/Background/Number"
var lights = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	score.set_text(str(lights))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	if body.name == 'light':
		lights += 1
		score.set_text(str(lights))
		
		body.queue_free()
