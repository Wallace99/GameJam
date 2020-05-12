extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var light = load("res://sunlightv2.tscn")
onready var score = $"../../CanvasLayer/GUI/HBoxContainer/Counters/Counter/Background/Number"
onready var lightCount = $"../../CanvasLayer/NinePatchRect/TextureRect/torch/count"
onready var camera = $"../Camera2D"
var lights = 0
var lightsInGame = 0
var seedsInGame = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	score.set_text(str(lights))
	randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	var lights = int(lightCount.text)
	if 'light' in body.name and lights < 10:
		lights += 1
		lightCount.set_text(str(lights))
		score.set_text(str(lights))
		lightsInGame -= 1
		body.queue_free()


func _on_Timer_timeout():
	var chanceOfLight = randi()%3+1
	if chanceOfLight == 2 and lightsInGame < 20:
		var lightInstance = light.instance()
		var lightPosition = Vector2(rand_range(camera.limit_left,camera.limit_right), camera.limit_top)
		lightInstance.set_position(lightPosition)
		get_tree().get_root().add_child(lightInstance)
		print("dropped light at: " + str(lightPosition))
		lightsInGame += 1
	var chanceOfSeed = randi()%10+1
	if chanceOfSeed == 10 and seedsInGame < 20:
		var seedPosition = Vector2(rand_range(camera.limit_left,camera.limit_right), camera.limit_top)
		print("dropped seed at: " + str(seedPosition))
		lightsInGame += 1
