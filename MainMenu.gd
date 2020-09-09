extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	get_tree().change_scene("res://Main.tscn")
	get_tree().paused = false


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://scenes/Credits.tscn")


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
