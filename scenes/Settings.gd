extends Node2D

var play_games_services
var toast
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var config = ConfigFile.new()
	var err = config.load("user://configuration.ini")
	if err == OK:
		var autoSigninVal = config.get_value("Config", "auto-sign-in", "0")
		if autoSigninVal == "0":
			$VBoxContainer/HBoxContainer/VBoxContainer2/CheckButton.pressed = false
		else:
			$VBoxContainer/HBoxContainer/VBoxContainer2/CheckButton.pressed = true
	else:
		$VBoxContainer/HBoxContainer/VBoxContainer2/CheckButton.pressed = false
	if(Engine.has_singleton("GodotToast")):
		toast= Engine.get_singleton("GodotToast")
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		var show_popups := true
		play_games_services.init(show_popups)
		play_games_services.connect("_on_sign_out_success", self, "_on_sign_out_success") # no params
		if play_games_services.isSignedIn():
			$VBoxContainer/HBoxContainer/VBoxContainer2/SignOutButton.disabled = false
		else:
			$VBoxContainer/HBoxContainer/VBoxContainer2/SignOutButton.disabled = true
	else:
		$VBoxContainer/HBoxContainer/VBoxContainer2/SignOutButton.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MenuButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_Credits_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")


func _on_CheckButton_toggled(button_pressed):
	var config = ConfigFile.new()
	config.load("user://configuration.ini")
	if button_pressed:
		config.set_value("Config", "auto-sign-in", "1")
	else:
		config.set_value("Config", "auto-sign-in", "0")
	config.save("user://configuration.ini")


func _on_SignOutButton_pressed():
	if play_games_services:
		if play_games_services.isSignedIn():
			play_games_services.signOut()
		else:
			if toast:
				toast.sendToast("Already signed out")
				
func _on_sign_out_success():
	var config = ConfigFile.new()
	config.load("user://configuration.ini")
	config.set_value("Config", "auto-sign-in", "0")
	config.save("user://configuration.ini")
	$VBoxContainer/HBoxContainer/VBoxContainer2/SignOutButton.disabled = true
