extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var light = load("res://sunlightv2.tscn")
onready var seedObject = load("res://seed.tscn")
onready var lightCount = $"../../CanvasLayer/NinePatchRect/TextureRect/torch/count"
onready var camera = $"../Camera2D"
var lightsInGame = 0
var seedsInGame = 0
const seedTypes = ['mushroom', 'green', 'purple']



# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


func _on_Area2D_body_entered(body):
	if 'light' in body.name and get_parent().getLightCount() < 10:
		get_parent().addLight()
		lightsInGame -= 1
		body.queue_free()
	elif 'seed' in body.name:
		get_parent().addSeed(body._getSeedType())
		seedsInGame -= 1
		body.queue_free()


func _on_Timer_timeout():
	var chanceOfLight = randi()%10+1
	if chanceOfLight == 2 and lightsInGame < 16:
		var lightInstance = light.instance()
		var lightPosition = Vector2(rand_range(camera.limit_left,camera.limit_right), camera.limit_top)
		lightInstance.set_position(lightPosition)
		get_tree().get_root().add_child(lightInstance)
		print("dropped light at: " + str(lightPosition))
		lightsInGame += 1
	var chanceOfSeed = randi()%10+1
	if chanceOfSeed == 10 and seedsInGame < 5:
		var seedInstance = seedObject.instance()
		var seedPosition = Vector2(rand_range(camera.limit_left,camera.limit_right), camera.limit_top)
		seedInstance.set_position(seedPosition)
		seedInstance._setSeedType(seedTypes[randi() % seedTypes.size()])
		seedInstance._setTexture()
		get_tree().get_root().add_child(seedInstance)
		print("dropped seed at: " + str(seedPosition))
		seedsInGame += 1
