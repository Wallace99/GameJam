extends KinematicBody2D

var velocity = Vector2()
const SPEED = 60
const GRAVITY = 5
const JUMP_POWER = -150
const FLOOR_DETECT_DISTANCE = 20.0
var collision
var selectedItem = null
var purpleCount = 0
var greenCount = 1
var mushroomCount = 0
var torchCount = 0
var lightCount = 0
var food = 100
var enemies = []
var specialEnemies = []
var plants = []
var torches = []
var nightCounter = 1
var overlappedPlantArea = 0
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

onready var lightScore = $"../CanvasLayer/GUI/HBoxContainer/Counters/Counter/Background/Number"
onready var dayMessage = $"../CanvasLayer/DayAnnoucement"

onready var purpleImage = load("res://plants/purple.png")
onready var greenImage = load("res://plants/green.png")
onready var mushroomImage = load("res://plants/mushroom.png")
onready var purpleImageBig= load("res://plants/purple_big.png")
onready var greenImageBig = load("res://plants/green_big.png")
onready var mushroomImageBig = load("res://plants/mushroom_big.png")
onready var purpleImageSmall = load("res://plants/purple_small.png")
onready var greenImageSmall = load("res://plants/green_small.png")
onready var mushroomImageSmall = load("res://plants/mushroom_small.png")

onready var waterArea1 = $"../Water2D/Area2D"
onready var waterArea2 = $"../Water2D2/Area2D"

onready var torchImage = load("res://tile_0316.png")

onready var placer = $"placer"

onready var plant = load("res://plant.tscn")
onready var torch = load("res://torch.tscn")
onready var enemy = load("res://enemy1.tscn")
onready var specialEnemy = load("res://enemy2.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	purpleButtonCount.set_text(str(purpleCount))
	greenButtonCount.set_text(str(greenCount))
	mushroomButtonCount.set_text(str(mushroomCount))
	torchButtonCount.set_text(str(lightCount/2))
	lightScore.set_text(str(lightCount))
	
	if purpleCount == 0:
		purpleButton.disabled = true
		purpleButton.pressed = false
	if greenCount == 0:
		greenButton.disabled = true
		greenButton.pressed = false
	if mushroomCount == 0:
		mushroomButton.disabled = true
		mushroomButton.pressed = false
	if torchCount == 0:
		torchButton.disabled = true
		torchButton.pressed = false

	purpleButton.connect("pressed", self, "_select_purple")
	greenButton.connect("pressed", self, "_select_green")
	mushroomButton.connect("pressed", self, "_select_mushroom")
	torchButton.connect("pressed", self, "_select_torch")
	
	waterArea1.connect("mouse_entered", self, "incrementOverlappingPlacing")
	waterArea1.connect("mouse_exited", self, "decrementOverlappingPlacing")
	waterArea2.connect("mouse_entered", self, "incrementOverlappingPlacing")
	waterArea2.connect("mouse_exited", self, "decrementOverlappingPlacing")
	

	var plots = get_parent().get_node("plots")
	for i in plots.get_children():
		i.get_node("Area2D").connect("placed", self, "placePlant")
	

func _input(event):
	if event.is_action_pressed("jump") and $RayCast2D.is_colliding():
		$jumpAudio.play()
		velocity.y = JUMP_POWER
	if event.is_action_pressed("mouseRight"):
		selectedItem = null
	
	if event.is_action_pressed("mouseLeft") and selectedItem == "torch":
		var clickPosition = get_global_mouse_position()
		clickPosition.y = 0
		placeTorch(clickPosition)
		$placeAudio.play()
		lightCount -= 2
		lightScore.text = str(lightCount)
		if lightCount > 0:
			torchButtonCount.text = str(lightCount/2)
		else:
			torchButtonCount.text = str(0)
		if lightCount <= 1:
			torchButton.disabled = true
			torchButton.pressed = false
			selectedItem = null
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	food -= 0.01 * nightCounter
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
	
		
		
	collision = move_and_slide(velocity, Vector2.UP, true, 4, 1.7)

func _start_light_timer():
	get_node("Area2D/Timer").start()
	
func _stop_light_timer():
	get_node("Area2D/Timer").stop()
	
func _start_torches():
	emit_signal("startTorches")

func _stop_torches():
	emit_signal("stopTorches")
	
func _select_purple():
	if selectedItem == "purple":
		purpleButton.pressed = false
		selectedItem = null
	if purpleCount > 0:
		greenButton.pressed = false
		mushroomButton.pressed = false
		torchButton.pressed = false
		selectedItem = "purple"
	else:
		purpleButton.pressed = false

	
func _select_green():
	if selectedItem == "green":
		greenButton.pressed = false
		selectedItem = null
		return
	if greenCount > 0:
		purpleButton.pressed = false
		mushroomButton.pressed = false
		torchButton.pressed = false
		selectedItem = "green"
	else:
		greenButton.pressed = false

	
func _select_mushroom():
	if selectedItem == "mushroom":
		mushroomButton.pressed = false
		selectedItem = null
		return
	if mushroomCount > 0:
		purpleButton.pressed = false
		greenButton.pressed = false
		torchButton.pressed = false
		selectedItem = "mushroom"
	else:
		mushroomButton.pressed = false

	
func _select_torch():
	if selectedItem == "torch":
		torchButton.pressed = false
		selectedItem = null
		return
	if lightCount > 1:
		purpleButton.pressed = false
		greenButton.pressed = false
		mushroomButton.pressed = false
		selectedItem = "torch"
	else:
		torchButton.pressed = false



func placePlant(plot):
	if selectedItem == null or plot.getPlant() != null:
		return
	$placeAudio.play()
	var placementPosition = plot.global_position
	placementPosition.y -= 11
	var plantInstance = plant.instance()
	var sizes = []
	if selectedItem == 'green':
		sizes = [greenImageSmall, greenImage, greenImageBig]
	elif selectedItem == 'mushroom':
		sizes = [mushroomImageSmall, mushroomImage, mushroomImageBig]
	elif selectedItem == 'purple':
		sizes = [purpleImageSmall, purpleImage, purpleImageBig]
	plantInstance.set_sizes(sizes)
	plantInstance.setPlantImage(selectedItem)
	plantInstance.set_position(placementPosition)
	plot.setPlant(plantInstance)
	plantInstance.set_plot(plot)
	plantInstance.get_node("spacingArea").connect("mouse_entered", self, "incrementOverlappingPlacing")
	plantInstance.get_node("spacingArea").connect("mouse_exited", self, "decrementOverlappingPlacing")
	plantInstance.get_node("Area2D").connect("eaten", self, "_eatPlant")
	plantInstance.get_node("Area2D").connect("body_entered", self, "removeDestroyedPlant", [plantInstance])
	plants.append(plantInstance)
	get_tree().get_root().add_child(plantInstance)
	incrementPlantCount()
		
		
func incrementPlantCount():
	if selectedItem == "purple":
		purpleCount -= 1
		purpleButtonCount.text = str(purpleCount)
		if purpleCount <= 0:
			purpleButton.disabled = true
			purpleButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	elif selectedItem == "green":
		greenCount -= 1
		greenButtonCount.text = str(greenCount)
		if greenCount <= 0:
			greenButton.disabled = true
			greenButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	elif selectedItem == "mushroom":
		mushroomCount -= 1
		mushroomButtonCount.text = str(mushroomCount)
		if mushroomCount <= 0:
			mushroomButton.disabled = true
			mushroomButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
	
	
func placeTorch(clickPosition):
	var torchInstance = torch.instance()
	torchInstance.set_position(clickPosition)
	torchInstance.get_node("Area2D").connect("removed", self, "removeTorch")
	torchInstance.get_node("Area2D").connect("relight", self, "relightTorch")
	torches.append(torchInstance)
	for enemy in enemies:
		enemy.connectEnteredSignalFromPlayer("body_entered", torchInstance.get_node("enemyRange"), "bounceBack", [torchInstance])
	for body in torchInstance.get_node("Area2D").get_overlapping_bodies():
		if 'enemy' in body.name:
			body.bounceBack(body, torchInstance)
	get_tree().get_root().add_child(torchInstance)
	
func incrementOverlappingPlacing():
	overlappedPlantArea += 1
	
func decrementOverlappingPlacing():
	overlappedPlantArea -= 1	
	
func _eatPlant(plant):
	food = foodBar.get_value()
	if food >= 100 or selectedItem != null:

		return
	if plant in plants:
		$eatAudio.play()
		if plant.get_growth() > 10:
			give_seed_back(plant.get_plant_type())
		plant.get_plot().setPlant(null)
		plants.erase(plant)
		plant.queue_free()
		food += plant.get_growth()
		foodBar.set_value(food)
		overlappedPlantArea -= 1
	else:
		print("Error: plant not in plants list")

func give_seed_back(plant_type):
	if plant_type == 'green' and greenCount < 10:
		greenCount += 1
		greenButtonCount.text = str(greenCount)
	elif plant_type == 'purple' and purpleCount < 10:
		purpleCount += 1
		purpleButtonCount.text = str(purpleCount)
	elif plant_type == 'mushroom' and mushroomCount < 10:
		mushroomCount += 1
		mushroomButtonCount.text = str(mushroomCount)

func removeTorch(torch):
	if torch in torches:
		torches.erase(torch)
		torch.queue_free()
		lightCount += 1
		lightScore.text = str(lightCount)
		torchButtonCount.text = str(lightCount/2)
	else:
		print("Error: torch not in torch list")
	
	
func relightTorch(torch):
	if lightCount > 0 and selectedItem == null:
		torch.get_node("TextureProgress").value = 100
		torch.get_node("Timer").start()
		torch.play("burn")
		torch.get_node("Light2D").enabled = true
		lightCount -= 1
		lightScore.text = str(lightCount)
		if lightCount > 0:
			torchButtonCount.text = str(lightCount/2)

func removeDestroyedPlant(body, plant):
	if !(body in enemies):
		return
	if plant in plants:
		body.get_node("eatAudio").play()
		plant.get_plot().setPlant(null)
		plants.erase(plant)
		plant.queue_free()
	else:
		print("Error: plant not in plants list")
		print(plants)

func _spawnEnemies():
	for i in range(nightCounter * 2):
		placeEnemy("enemy1")
	for i in range(nightCounter):
		placeEnemy("enemy2")
	
func placeEnemy(enemyType):
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
	print("placed enemy at " + str(enemyPosition))
	if enemyType == "enemy2":
		var enemyInstance = specialEnemy.instance()
		enemyInstance.set_position(enemyPosition)
		specialEnemies.append(enemyInstance)
		print("special enemy")
		get_tree().get_root().add_child(enemyInstance)
	else:
		var enemyInstance = enemy.instance()
		enemyInstance.set_position(enemyPosition)
		for torch in torches:
			enemyInstance.connectEnteredSignalFromPlayer("body_entered", torch.get_node("enemyRange"), "bounceBack", [torch])
		enemyInstance.connectSignalFromPlayer("moved", self, "getDirection")
		enemies.append(enemyInstance)
		print("normal enemy") 
		get_tree().get_root().add_child(enemyInstance)
	
func _despawnEnemies():
	for enemy in enemies:
		enemy.queue_free()
	enemies = []
	#for enemy1 in specialEnemies:
	#	enemy1.queue_free()
	#specialEnemies = []
	
func incrementDay():
	nightCounter += 1
	dayMessage.text = "Day " + str(nightCounter)
	
	
func addSeed(seedType):
	$coinAudio.play()
	if seedType == 'purple' and purpleCount < 10:
		purpleCount += 1
		purpleButtonCount.text = str(purpleCount)
		purpleButton.disabled = false
	elif seedType == 'green' and greenCount < 10:
		greenCount += 1
		greenButtonCount.text = str(greenCount)
		greenButton.disabled = false
	elif seedType == 'mushroom' and mushroomCount < 10:
		mushroomCount += 1
		mushroomButtonCount.text = str(mushroomCount)
		mushroomButton.disabled = false
		
func addLight():
	$coinAudio.play()
	lightCount += 1
	lightScore.text = str(lightCount)
	torchButtonCount.text = str(lightCount / 2)
	if lightCount > 1:
		torchButton.disabled = false
	
func getLightCount():
	return lightCount
	

func _on_PositionUpdateTimer_timeout():
	emit_signal("moved", global_position, plants, torches)
