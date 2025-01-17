extends KinematicBody2D

var velocity = Vector2()
const SPEED = 60
const GRAVITY = 5
const JUMP_POWER = -150
const FLOOR_DETECT_DISTANCE = 20.0
const LEADERBOARD_ID = "CgkIm-rjr6cEEAIQAA"
var collision
var selectedItem = null
var purpleCount = 0
var greenCount = 1
var mushroomCount = 0
var torchCount = 1
var lightCount = 2
var food = 100
var enemies = []
var specialEnemies = []
var plants = []
var torches = []
var lights = []
var seeds = []
var litTorches = []
var nightCounter = 1
var overlappedWaterArea = 0
var overlappedControls = false
var lives = 3
var eatFoodMessageShown = false
var ad_loaded = false
var placedInRange = false
var play_games_services
var submittedScore = false
var firstTutorial = true
var itemPlaceTutorial = true
var eatPlantTutorial = true
var collectLightTutorial = true
var avoidMonsterTutorial = true
var avoidOtherMonsterTutorial = true
var toast

signal isDay(day)
signal moved(globalPosition, plants, torches)

onready var plots = get_parent().get_node("plots")

onready var admob = $"../Admob"

onready var purpleButton = $"../CanvasLayer/NinePatchRect/TextureRect/purple"
onready var greenButton = $"../CanvasLayer/NinePatchRect/TextureRect/green"
onready var mushroomButton = $"../CanvasLayer/NinePatchRect/TextureRect/mushroom"
onready var torchButton = $"../CanvasLayer/NinePatchRect/TextureRect/torch"

onready var foodBar = $"../CanvasLayer/GUI/VBoxContainer/HBoxContainer/Bars/Bar/Gauge"
onready var eatFoodLabel = $"../CanvasLayer/GUI/VBoxContainer/EatFoodLabel"
onready var eatFoodAnimationPlayer = $"../CanvasLayer/GUI/AnimationPlayer"

onready var purpleButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/purple/count"
onready var greenButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/green/count"
onready var mushroomButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/mushroom/count"
onready var torchButtonCount = $"../CanvasLayer/NinePatchRect/TextureRect/torch/count"

onready var lightScore = $"../CanvasLayer/GUI/VBoxContainer/HBoxContainer/Counters/Counter/Background/Number"
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

onready var deathPopUp = $"../CanvasLayer/DeathPopUp"
onready var helpPopUp = $"../CanvasLayer/HelpPopup"

# Called when the node enters the scene tree for the first time.
func _ready():
	admob.load_rewarded_video()
	loadSettings()
	if(Engine.has_singleton("GodotToast")):
		toast = Engine.get_singleton("GodotToast")
	
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		var show_popups := true 
		play_games_services.init(show_popups)
		play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success") # account_id: String
		play_games_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed") # error_code: int
		play_games_services.connect("_on_leaderboard_score_submitted", self, "_on_leaderboard_score_submitted") # leaderboard_id: String
		play_games_services.connect("_on_leaderboard_score_submitting_failed", self, "_on_leaderboard_score_submitting_failed") # leaderboard_id: String
	else:
		print("play services not connected")
		if toast:
			toast.sendToast("Could not connect to Google Play Services")
	
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
	
	admob.connect("rewarded", self, "_on_rewarded")
	admob.connect("rewarded_video_failed_to_load", self, "_on_rewarded_video_ad_failed_to_load")
	admob.connect("rewarded_video_loaded", self, "_on_rewarded_video_ad_loaded")
	
	waterArea1.connect("mouse_entered", self, "incrementOverlappingPlacing")
	waterArea1.connect("mouse_exited", self, "decrementOverlappingPlacing")
	waterArea2.connect("mouse_entered", self, "incrementOverlappingPlacing")
	waterArea2.connect("mouse_exited", self, "decrementOverlappingPlacing")
	
	deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton").connect("pressed", self, "showVideo")
	deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton2").connect("pressed", self, "goToMainMenu")
	deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton3").connect("pressed", self, "signIntoLeaderboard")
	

	
	for i in plots.get_children():
		i.get_node("Area2D").connect("placed", self, "placePlant")
		i.get_node("Area2D").connect("mouse_entered", self, "setMouseInPlot", [i])
		i.get_node("Area2D").connect("mouse_exited", self, "setMouseInPlot", [i])
		
	_start_light_timer()

	

func _input(event):
	if event.is_action_pressed("jump") and $RayCast2D.is_colliding():
		$jumpAudio.play()
		velocity.y = JUMP_POWER
	if event.is_action_pressed("mouseRight"):
		selectedItem = null
		$PlacingArea.visible = false
	
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	food -= 0.01 * (nightCounter * 0.4)
	if food <= 0:
		showDeathPopup()
	elif food <= 25 and !eatFoodMessageShown:
		showEatFood()
	elif food > 25 and eatFoodMessageShown:
		hideEatFood()
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
		velocity.y = min(velocity.y, 120)
	else:
		if firstTutorial:
			firstTutorial = false
			updateSetting("first-tutorial", "0")
			var helpText = """Welcome!
	Start off your first day by collecting any seeds or light that fall from the sky"""
			showHelpPopup(helpText)
	
		
		
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
		$PlacingArea.visible = false
		return
	if purpleCount > 0:
		greenButton.pressed = false
		mushroomButton.pressed = false
		torchButton.pressed = false
		selectedItem = "purple"
		$PlacingArea.visible = true
		showClickItemTutorial()
	else:
		purpleButton.pressed = false

	
func _select_green():
	if selectedItem == "green":
		greenButton.pressed = false
		selectedItem = null
		$PlacingArea.visible = false
		return
	if greenCount > 0:
		purpleButton.pressed = false
		mushroomButton.pressed = false
		torchButton.pressed = false
		selectedItem = "green"
		$PlacingArea.visible = true
		showClickItemTutorial()
	else:
		greenButton.pressed = false

	
func _select_mushroom():
	if selectedItem == "mushroom":
		mushroomButton.pressed = false
		selectedItem = null
		$PlacingArea.visible = false
		return
	if mushroomCount > 0:
		purpleButton.pressed = false
		greenButton.pressed = false
		torchButton.pressed = false
		selectedItem = "mushroom"
		$PlacingArea.visible = true
		showClickItemTutorial()
	else:
		mushroomButton.pressed = false

	
func _select_torch():
	if selectedItem == "torch":
		torchButton.pressed = false
		selectedItem = null
		$PlacingArea.visible = false
		return
	if lightCount > 1:
		purpleButton.pressed = false
		greenButton.pressed = false
		mushroomButton.pressed = false
		selectedItem = "torch"
		$PlacingArea.visible = true
		showClickItemTutorial()
	else:
		torchButton.pressed = false



func placePlant(plot):
	var clickPosition = get_global_mouse_position()
	if abs(clickPosition.x - global_position.x) > 30 or abs(clickPosition.y - global_position.y) > 12:
		return 
	if selectedItem == null or plot.getPlant() != null or selectedItem == 'torch':
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
	plantInstance.get_node("Area2D").connect("eaten", self, "_eatPlant")
	plantInstance.get_node("Area2D").connect("destroyed", self, "removeDestroyedPlant")
	plants.append(plantInstance)
	get_tree().get_root().add_child(plantInstance)
	incrementPlantCount()
	showEatPlantTutorial()
		
		
func incrementPlantCount():
	if selectedItem == "purple":
		purpleCount -= 1
		purpleButtonCount.text = str(purpleCount)
		if purpleCount <= 0:
			purpleButton.disabled = true
			purpleButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
			$PlacingArea.visible = false
	elif selectedItem == "green":
		greenCount -= 1
		greenButtonCount.text = str(greenCount)
		if greenCount <= 0:
			greenButton.disabled = true
			greenButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
			$PlacingArea.visible = false
	elif selectedItem == "mushroom":
		mushroomCount -= 1
		mushroomButtonCount.text = str(mushroomCount)
		if mushroomCount <= 0:
			mushroomButton.disabled = true
			mushroomButton.pressed = false
			Input.set_custom_mouse_cursor(null)
			selectedItem = null
			$PlacingArea.visible = false
	
func attemptToPlaceTorch():
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
		$PlacingArea.visible = false
	
	
func placeTorch(clickPosition):
	var torchInstance = torch.instance()
	torchInstance.set_position(clickPosition)
	torchInstance.get_node("Area2D").connect("relight", self, "relightTorch")
	torchInstance.get_node("Area2D").connect("snuffed", self, "snuffTorch")
	torchInstance.connect("torchOut", self, "torchWentOut")
	torchInstance.connect("removed", self, "removeTorch")
	torches.append(torchInstance)
	litTorches.append(torchInstance)
	for enemy in enemies:
		enemy.connectEnteredSignalFromPlayer("body_entered", torchInstance.get_node("enemyRange"), "bounceBack", [torchInstance])
	for body in torchInstance.get_node("Area2D").get_overlapping_bodies():
		if 'enemy' in body.name:
			body.bounceBack(body, torchInstance)
	get_tree().get_root().add_child(torchInstance)
	
func incrementOverlappingPlacing():
	overlappedWaterArea += 1
	
func decrementOverlappingPlacing():
	overlappedWaterArea -= 1	

func torchWentOut(torch):
	if torch in litTorches:
		litTorches.erase(torch)
	else:
		print("error removing torch from lit torches")

func snuffTorch(torch):
	if !(torch in litTorches):
		return
	torch.emit_signal("stopTimer")
	torch.play("normal")
	torch.get_node("Light2D").enabled = false
	torchWentOut(torch)
	
	
func _eatPlant(plant):
	var clickPosition = get_global_mouse_position()
	if abs(clickPosition.x - global_position.x) > 30 or clickPosition.y > global_position.y + 15:
		return
	food = foodBar.get_value()
	if food >= 100 or selectedItem != null:
		return
	if plant in plants:
		$eatAudio.play()
		if plant.get_growth() > 10:
			addSeed(plant.get_plant_type())
		plant.get_plot().setPlant(null)
		plants.erase(plant)
		plant.queue_free()
		food += plant.get_growth()
		food = min(food, 100)
		foodBar.set_value(food)
	else:
		print("Error: plant not in plants list")

func removeTorch(torch):
	if torch in torches:
		torches.erase(torch)
		torch.queue_free()
		print("removed torch")
	else:
		print("Error: torch not in torch list")
	
	
func relightTorch(torch):
	if lightCount > 0 and selectedItem == null:
		torch.get_node("TextureProgress").value = 100
		torch.get_node("disappearTimer").stop()
		torch.get_node("Node2D").visible = false
		torch.get_node("Timer").start()
		torch.play("burn")
		torch.get_node("Light2D").enabled = true
		lightCount -= 1
		lightScore.text = str(lightCount)
		if lightCount > 0:
			torchButtonCount.text = str(lightCount/2)
		litTorches.append(torch)

func removeDestroyedPlant(plant):
	if plant in plants:
		get_node("eatAudio").play()
		plant.get_plot().setPlant(null)
		plants.erase(plant)
		plant.queue_free()
	else:
		print("Error: plant not in plants list")

func _spawnEnemies():
	if nightCounter == 1:
		showAvoidMonsterTutorial()
	var enemy2Count = int((nightCounter - 1) * 0.5)
	if enemy2Count > 0:
		showAvoidOtherMonsterTutorial()
	for i in range(nightCounter):
		placeEnemy("enemy1")
	for i in range(enemy2Count):
		placeEnemy("enemy2")
	
func placeEnemy(enemyType):
	randomize()
	var enemyPosition = Vector2(0,0)
	var toCloseToLight = true
	while toCloseToLight:
		enemyPosition = Vector2(rand_range($Camera2D.limit_left, $Camera2D.limit_right), $Camera2D.limit_top)
		if litTorches.size() == 0:
			toCloseToLight = false
		for torch in litTorches:
			if abs(torch.get_global_position().x - enemyPosition.x) < 50:
				toCloseToLight = true
				break
			toCloseToLight = false
	print("placed enemy at " + str(enemyPosition))
	if enemyType == "enemy2":
		var enemyInstance = specialEnemy.instance()
		enemyInstance.set_position(enemyPosition)
		enemyInstance.connectSignalFromPlayer("moved", self, "getDirection")
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
	for enemy1 in specialEnemies:
		enemy1.queue_free()
	specialEnemies = []
	
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
	showCollectLightTutorial()
	
func getLightCount():
	return lightCount

func setMouseInPlot(plot):
	if plot.mouseInArea:
		plot.mouseInArea = false
	else:
		plot.mouseInArea = true

func _on_PositionUpdateTimer_timeout():
	emit_signal("moved", global_position, plants, torches, litTorches)
	

func showVideo():
	if admob.is_rewarded_video_loaded():
		admob.show_rewarded_video()
	

func goToMainMenu():
	if play_games_services.isSignedIn():
		play_games_services.submitLeaderBoardScore(LEADERBOARD_ID, nightCounter)
		if toast:
			toast.sendToast("Submitting high score")
	for i in get_tree().get_root().get_children():
		i.queue_free()
	_despawnEnemies()
	get_tree().paused = false
	get_tree().change_scene("res://MainMenu.tscn")
	
func showEatFood():
	eatFoodLabel.visible = true
	eatFoodMessageShown = true
	
func hideEatFood():
	eatFoodLabel.visible = false
	eatFoodMessageShown = false
	
func showDeathPopup():
	_stop_light_timer()
	get_tree().paused = true
	$deathAudio.play()
	if !play_games_services.isSignedIn():
		deathPopUp.get_node("Control/AnimationPlayer").play("flash")
		deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton3").show()
	else:
		deathPopUp.get_node("Control/AnimationPlayer").stop()
		deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton3").hide()
	if ad_loaded:
		print("ad loaded")
		deathPopUp.get_node("Control/VBoxContainer/Label3").show()
		deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton").show()
		deathPopUp.get_node("Control/VBoxContainer/Label").show()
		
		deathPopUp.get_node("Control/VBoxContainer/Label3").text = "You have " + str(lives) + " lives remaining..."
		lives -= 1
	else:
		print("ad not loaded")
		deathPopUp.get_node("Control/VBoxContainer/Label3").hide()
		deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton").hide()
		deathPopUp.get_node("Control/VBoxContainer/Label").hide()
		if play_games_services.isSignedIn():
			play_games_services.submitLeaderBoardScore(LEADERBOARD_ID, nightCounter)
			if toast:
				toast.sendToast("Submitting high score")
	if lives < 0:
		print("out of lives")
		deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton").hide()
		deathPopUp.get_node("Control/VBoxContainer/Label").hide()
		if play_games_services.isSignedIn():
			play_games_services.submitLeaderBoardScore(LEADERBOARD_ID, nightCounter)
			if toast:
				toast.sendToast("Submitting high score")
	deathPopUp.get_node("Control/VBoxContainer/HBoxContainer/Label2").text = str(nightCounter) + " days"
	while $deathAudio.playing:
		pass
	deathPopUp.popup_centered()
	
func _on_rewarded(currency, amount):
	_despawnEnemies()
	admob.load_rewarded_video()
	food = 100
	foodBar.set_value(int(food))
	deathPopUp.hide()
	get_tree().paused = false
	

func _on_rewarded_video_ad_failed_to_load(errorCode):
	ad_loaded = false
	if toast:
		toast.sendToast("Could not load reward video with error code: " + str(errorCode))

func _on_rewarded_video_ad_loaded():
	ad_loaded = true
	

func _on_Area2D2_mouse_entered():
	placedInRange = true


func _on_Area2D2_mouse_exited():
	placedInRange = false


func _on_PlacingArea_input_event(viewport, event, shape_idx):
	if event.is_action_pressed("mouseLeft") and selectedItem == "torch":
		attemptToPlaceTorch()
	

func _on_sign_in_success(account_id: String) -> void:
	print("success")
	deathPopUp.get_node("Control/AnimationPlayer").stop()
	deathPopUp.get_node("Control/VBoxContainer/HBoxContainer2/TextureButton3").hide()
  
func _on_sign_in_failed(error_code: int) -> void:
	print("failed")
	print(error_code)
	if toast:
		toast.sendToast("Sign in failed with error code: " + str(error_code))

func _on_leaderboard_score_submitted(leaderboard_id: String):
	print("successfully submitted score")

func _on_leaderboard_score_submitting_failed(leaderboard_id: String):
	print("error submitting score")
	if toast:
		toast.sendToast("Error submitting to leaderboard")
		
func signIntoLeaderboard():
	if toast:
		toast.sendToast("Attempting to sign in to Google Play Services")
	play_games_services.signIn()
		


func showHelpPopup(text):
	helpPopUp.get_node("Label").text = text
	_stop_light_timer()
	get_tree().paused = true
	helpPopUp.popup_centered()

func _on_HelpPopup_popup_hide():
	_start_light_timer()
	get_tree().paused = false

func loadSettings():
	var config = ConfigFile.new()
	var err = config.load("user://configuration.ini")
	if err == OK:
		firstTutorial = parseSetting("first-tutorial", config)
		itemPlaceTutorial = parseSetting("item-place-tutorial", config)
		eatPlantTutorial = parseSetting("eat-plant-tutorial", config)
		collectLightTutorial = parseSetting("collect-light-tutorial", config)
		avoidMonsterTutorial = parseSetting("avoid-monster-tutorial", config)
		avoidOtherMonsterTutorial = parseSetting("avoid-other-monster-tutorial", config)
			
func parseSetting(setting, config):
	var settingVal = config.get_value("Config", setting, "1")
	if settingVal == "1":
		return true
	else:
		return false
		
func updateSetting(setting, newValue):
	var config = ConfigFile.new()
	var err = config.load("user://configuration.ini")
	if err == OK:
		config.set_value("Config", setting, newValue)
	config.save("user://configuration.ini")
			
func showClickItemTutorial():
	if itemPlaceTutorial:
		itemPlaceTutorial = false
		updateSetting("item-place-tutorial", "0")
		var helpText = """Tap to place a selected item!
	The green box indicates your range. Plants can only be placed on the brown plots"""
		showHelpPopup(helpText)

func showEatPlantTutorial():
	if eatPlantTutorial:
		eatPlantTutorial = false
		updateSetting("eat-plant-tutorial", "0")
		var helpText = """Tap on a plant to eat it!
		The longer a plant has been growing the more hunger it will fill. Plants are fully grown when the 'eat me' message is shown"""
		showHelpPopup(helpText)

func showCollectLightTutorial():
	if collectLightTutorial:
		collectLightTutorial = false
		updateSetting("collect-light-tutorial", "0")
		var helpText = """Collect stars for light!
		Use two light to place one torch. Use one light to relight a torch"""
		showHelpPopup(helpText)

func showAvoidMonsterTutorial():
	if avoidMonsterTutorial:
		avoidMonsterTutorial = false
		updateSetting("avoid-monster-tutorial", "0")
		var helpText = """Night is falling!
		Monsters will come in the night and try eat you or your plants. Place torches to keep them at bay"""
		showHelpPopup(helpText)

func showAvoidOtherMonsterTutorial():
	if avoidOtherMonsterTutorial:
		avoidOtherMonsterTutorial = false
		updateSetting("avoid-other-monster-tutorial", "0")
		var helpText = """Night is falling!
		Tonight a new monster will come that can put out torches. It will run from you though so keep an eye on your torches"""
		showHelpPopup(helpText)
