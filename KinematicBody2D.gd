extends KinematicBody2D

var velocity = Vector2()
const SPEED = 60
const GRAVITY = 5
const JUMP_POWER = -150
var collision
var selectedItem = null
var purpleCount = 3
var greenCount = 3
var mushroomCount = 3
var torchCount = 0
var food = 100
var enemies = []
var plants = []
var torches = []
var nightCounter = 1
signal isDay(day)
signal moved(globalPosition, plants, torches)

onready var purpleButton = $"../CanvasLayer/NinePatchRect/TextureRect/purple"
onready var greenButton = $"../CanvasLayer/NinePatchRect/TextureRect/green"
onready var mushroomButton = $"../CanvasLayer/NinePatchRect/TextureRect/mushroom"
onready var torchButton = $"../CanvasLayer/NinePatchRect/TextureRect/torch"

onready var foodBar = $"../CanvasLayer/GUI/HBoxContainer/Bars/Bar/Gauge"

onready var purpleButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/purple/count"
onready var greenButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/green/count"
onready var mushroomButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/mushroom/count"
onready var torchButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/torch/count"


onready var purpleImage = load("res://plants/tile_0016.png")
onready var greenImage = load("res://plants/tile_0017.png")
onready var mushroomImage = load("res://plants/tile_0107.png")
onready var torchImage = load("res://tile_0316.png")

onready var placer = $"placer"

onready var plant = load("res://plant.tscn")
onready var torch = load("res://torch.tscn")
onready var enemy = load("res://enemy1.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	purpleButtonCount.set_text(str(purpleCount))
	greenButtonCount.set_text(str(greenCount))
	mushroomButtonCount.set_text(str(mushroomCount))

	purpleButton.connect("pressed", self, "_select_purple")
	greenButton.connect("pressed", self, "_select_green")
	mushroomButton.connect("pressed", self, "_select_mushroom")
	torchButton.connect("pressed", self, "_select_torch")
	

func _input(event):
	if event.is_action_pressed("jump") and $RayCast2D.is_colliding():
		velocity.y = JUMP_POWER
	if event.is_action_pressed("mouseRight"):
		Input.set_custom_mouse_cursor(null)
		selectedItem = null
	
	if event.is_action_pressed("mouseLeft") and selectedItem != null:
		var clickPosition = get_global_mouse_position()
		place_item(selectedItem, get_global_mouse_position())
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	food -= 0.01
	foodBar.set_value(int(food))
	if Input.is_action_pressed("right"):
		velocity.x = SPEED
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("left"):
		velocity.x = -SPEED
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.play("idle")
		velocity.x = 0
		
	if $RayCast2D_up.is_colliding():
		velocity.y = 50
	
	if !$RayCast2D.is_colliding():
		$AnimatedSprite.play("suprise")
		velocity.y += GRAVITY
		
	collision = move_and_slide(velocity)

func _start_light_timer():
	emit_signal("isDay", true)
	
func _stop_light_timer():
	emit_signal("isDay", false)
	
func _start_torches():
	emit_signal("startTorches")

func _stop_torches():
	emit_signal("stopTorches")
	
func _select_purple():
	if purpleCount > 0:
		selectedItem = "purple"
		Input.set_custom_mouse_cursor(purpleImage)
	print("purple")
	
func _select_green():
	if greenCount > 0:
		selectedItem = "green"
		Input.set_custom_mouse_cursor(greenImage)
	print("green")
	
func _select_mushroom():
	if mushroomCount > 0:
		selectedItem = "mushroom"
		Input.set_custom_mouse_cursor(mushroomImage)
	print("mushroom")
	
func _select_torch():
	torchCount = int(torchButtonCount.get_text())
	if torchCount > 0:
		selectedItem = "torch"
		Input.set_custom_mouse_cursor(torchImage)
	print("torch")
		
func place_item(item, clickPosition):
	if item == "purple":
		placePlant(purpleImage, clickPosition)
		purpleCount -= 1
		purpleButtonCount.text = str(purpleCount)
		if purpleCount <= 0:
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	elif item == "green":
		placePlant(greenImage, clickPosition)
		greenCount -= 1
		greenButtonCount.text = str(greenCount)
		if greenCount <= 0:
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	elif item == "mushroom":
		placePlant(mushroomImage, clickPosition)
		mushroomCount -= 1
		mushroomButtonCount.text = str(mushroomCount)
		if mushroomCount <= 0:
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	elif item == "torch":
		torchCount = int(torchButtonCount.get_text())
		placeTorch(clickPosition)
		torchCount -= 1
		torchButtonCount.text = str(torchCount)
		if torchCount <= 0:
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
		
func placePlant(plantTexture, clickPosition):
	var plantInstance = plant.instance()
	plantInstance.set_texture(plantTexture)
	plantInstance.set_position(clickPosition)
	plantInstance.get_node("Area2D").connect("eaten", self, "_eatPlant")
	plantInstance.get_node("Area2D").connect("body_entered", self, "removeDestroyedPlant", [plantInstance])
	plants.append(plantInstance)
	get_tree().get_root().add_child(plantInstance)
	
	
func placeTorch(clickPosition):
	var torchInstance = torch.instance()
	torchInstance.set_position(clickPosition)
	torchInstance.get_node("torchArea").connect("removed", self, "removeTorch")
	torches.append(torchInstance)
	for enemy in enemies:
		enemy.connectTorchEnteredSignalFromPlayer("body_entered", torchInstance, "bounceBack", [torchInstance])
	get_tree().get_root().add_child(torchInstance)
	
func _eatPlant(plant):
	if plant in plants:
		print("ate " + str(plant))
		plants.erase(plant)
	else:
		print("Error: plant not in plants list")
	food = foodBar.get_value()
	if food < 100:
		plant.queue_free()
		food += 20
		foodBar.set_value(food)

func removeTorch(torch):
	if torch in torches:
		torches.erase(torch)
	else:
		print("Error: torch not in torch list")
	torch.queue_free()
	

func removeDestroyedPlant(body, plant):
	if !(body in enemies):
		return
	if plant in plants:
		plants.erase(plant)
	else:
		print("Error: plant not in plants list")

func _spawnEnemies():
	for i in range(nightCounter * 2):
		randomize()
		var enemyPosition = Vector2(0,0)
		var toCloseToLight = true
		while toCloseToLight:
			enemyPosition = Vector2(rand_range($Camera2D.limit_left, $Camera2D.limit_right), $Camera2D.limit_top)
			if torches.size() == 0:
				toCloseToLight = false
			for torch in torches:
				if abs(torch.get_global_position().x - enemyPosition.x) < 50:
					toCloseToLight = true
					break
				toCloseToLight = false
		var enemyInstance = enemy.instance() 
		print("placed enemy at " + str(enemyPosition))
		enemyInstance.set_position(enemyPosition)
		for torch in torches:
			enemyInstance.connectEnteredSignalFromPlayer("body_entered", torch.get_node("enemyRange"), "bounceBack", [torch])
		for plant in plants:
			enemyInstance.connectEnteredSignalFromPlayer("body_entered", plant.get_node("Area2D"), "destroyPlant", [plant])
		enemyInstance.connectSignalFromPlayer("moved", self, "getDirection")
		enemies.append(enemyInstance) 
		get_tree().get_root().add_child(enemyInstance)
	
func _despawnEnemies():
	for enemy in enemies:
		#enemy.queue_free()
		pass
	#enemies = []
	

func _on_PositionUpdateTimer_timeout():
	emit_signal("moved", global_position, plants, torches)
