extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var play_games_services
var toast
var autoSignin
var showHighScoreAfter = false



# Called when the node enters the scene tree for the first time.
func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://configuration.ini")
	if err == OK:
		var autoSigninVal = config.get_value("Config", "auto-sign-in", "0")
		if autoSigninVal == "0":
			autoSignin = false
		else:
			autoSignin = true
	else:
		config.set_value("Config", "auto-sign-in", "0")
		config.set_value("Config", "first-tutorial", "1")
		config.set_value("Config", "item-place-tutorial", "1")
		config.set_value("Config", "eat-plant-tutorial", "1")
		config.set_value("Config", "collect-light-tutorial", "1")
		config.set_value("Config", "avoid-monster-tutorial", "1")
		config.set_value("Config", "avoid-other-monster-tutorial", "1")
		autoSignin = false
	config.save("user://configuration.ini")
		
	if(Engine.has_singleton("GodotToast")):
		toast= Engine.get_singleton("GodotToast")
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		var show_popups := true 
		play_games_services.init(show_popups)
		play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success") # account_id: String
		play_games_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed") # error_code: in
		play_games_services.connect("_on_sign_out_success", self, "_on_sign_out_success") # no params
		play_games_services.connect("_on_sign_out_failed", self, "_on_sign_out_failed") # no params
		if !play_games_services.isSignedIn() and autoSignin:
			play_games_services.signIn()
	else:
		print("play services not connected")
		if toast:
			toast.sendToast("Couldn't connect to Google Play Services")
	
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	get_tree().change_scene("res://Main.tscn")
	get_tree().paused = false


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://scenes/Settings.tscn")


func _on_Button_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_NextButton2_pressed():
	get_tree().change_scene("res://scenes/Credits2.tscn")


func _on_PreviousButton2_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")


func _on_TutorialButton_pressed():
	get_tree().change_scene("res://scenes/Tutorial.tscn")


func _on_ControlsButton_pressed():
	get_tree().change_scene("res://scenes/Tutorial2.tscn")


func _on_NextCreditsButton_pressed():
	get_tree().change_scene("res://scenes/Credits3.tscn")


func _on_PreviousCreditsButton2_pressed():
	get_tree().change_scene("res://scenes/Credits2.tscn")

func _on_sign_in_success(account_id: String) -> void:
	print("success")
	if showHighScoreAfter:
		showHighScoreAfter = false
		play_games_services.showLeaderBoard("CgkIm-rjr6cEEAIQAA")
		var config = ConfigFile.new()
		config.load("user://configuration.ini")
		config.set_value("Config", "auto-sign-in", "1")
		config.save("user://configuration.ini")
		autoSignin = true
	
func _on_sign_in_failed(error_code: int) -> void:
	print("failed")
	print(error_code)
	if toast:
		toast.sendToast("Sign in failed with error code: " + str(error_code))


func _on_HighscoresButton_pressed():
	if play_games_services and play_games_services.isSignedIn():
		play_games_services.showLeaderBoard("CgkIm-rjr6cEEAIQAA")
	else:
		if toast:
			toast.sendToast("Attempting to sign in to Google Play Services")
		if play_games_services:
			showHighScoreAfter = true
			play_games_services.signIn()


func _on_Credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")


func _on_CheckButton_toggled(button_pressed):
	var config = ConfigFile.new()
	config.load("user://configuration.ini")
	if button_pressed:
		config.set_value("Config", "auto-sign-in", "1")
		autoSignin = true
	else:
		config.set_value("Config", "auto-sign-in", "1")
		autoSignin = false
	config.save("user://configuration.ini")
		
	
func _on_sign_out_success():
	if toast:
		toast.sendToast("Signed out successfully")
	
func _on_sign_out_failed():
	if toast:
		toast.sendToast("Error signing out")

func _on_SignOutButton_pressed():
	if play_games_services:
		if play_games_services.isSignedIn():
			play_games_services.signOut()
		else:
			if toast:
				toast.sendToast("Already signed out")
