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
signal isDay(day)

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
	if event.is_action_pressed("ui_accept") and $RayCast2D.is_colliding():
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
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
		$AnimatedSprite.play("walk")
		$AnimatedSprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
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
	
func _select_purple():
	selectedItem = "purple"
	if purpleCount > 0:
		Input.set_custom_mouse_cursor(purpleImage)
	
func _select_green():
	selectedItem = "green"
	if greenCount > 0:
		Input.set_custom_mouse_cursor(greenImage)
	
func _select_mushroom():
	selectedItem = "mushroom"
	if mushroomCount > 0:
		Input.set_custom_mouse_cursor(mushroomImage)
	
func _select_torch():
	selectedItem = "torch"
	torchCount = int(torchButtonCount.get_text())
	if torchCount > 0:
		Input.set_custom_mouse_cursor(torchImage)
		
func place_item(item, clickPosition):
	if item == "purple":
		placePlant(purpleImage, clickPosition)
		updateCount(purpleCount, purpleButtonCount)
	elif item == "green":
		placePlant(greenImage, clickPosition)
		updateCount(greenCount, greenButtonCount)
	elif item == "mushroom":
		placePlant(mushroomImage, clickPosition)
		updateCount(mushroomCount, mushroomButtonCount)
	elif item == "torch":
		placeTorch(clickPosition)
		updateCount(torchCount, torchButtonCount)
		
func placePlant(plantTexture, clickPosition):
	var plantInstance = plant.instance()
	plantInstance.set_texture(plantTexture)
	plantInstance.set_position(clickPosition)
	plantInstance.get_node("Area2D").connect("eaten", self, "_eatPlant")
	get_tree().get_root().add_child(plantInstance)
	
func updateCount(count, buttonCount):
	count -= 1
	buttonCount.text = str(count)
	if count == 0:
		Input.set_custom_mouse_cursor(null)
	
func placeTorch(clickPosition):
	var torchInstance = torch.instance()
	torchInstance.set_position(clickPosition)
	get_tree().get_root().add_child(torchInstance)
	
func _eatPlant(plant):
	food = foodBar.get_value()
	if food < 100:
		plant.queue_free()
		food += 20
		foodBar.set_value(food)
