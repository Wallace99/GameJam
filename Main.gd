extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("day_night_cycle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var fps = $CanvasLayer/fps
	fps.text = str(Engine.get_frames_per_second())
