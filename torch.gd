extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal stopTimer

onready var animationPlayer = get_tree().get_root().get_node("Node2D").get_node("AnimationPlayer")

# Called when the node enters the scene tree for the first time.
func _ready():
	play("burn")
	$TextureProgress.connect("outOfLight", self, "outOfLight")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if animationPlayer.current_animation_position >= 25 and animationPlayer.current_animation_position <= 35:
		$Light2D.energy = ((animationPlayer.current_animation_position - 25) * 0.1) + 0.1
	elif animationPlayer.current_animation_position >= 55 and animationPlayer.current_animation_position <= 60:
		$Light2D.energy = 1 + (((55 - animationPlayer.current_animation_position) * 0.1) + 0.1)
	elif animationPlayer.current_animation_position >= 0 and animationPlayer.current_animation_position <= 4:
		$Light2D.energy = (5 - animationPlayer.current_animation_position) * 0.1
	elif animationPlayer.current_animation_position > 4 and animationPlayer.current_animation_position < 25:
		$Light2D.energy = 0.1
	elif animationPlayer.current_animation_position > 35 and animationPlayer.current_animation_position < 55:
		$Light2D.energy = 1.1
	if $RayCast2D.is_colliding():
		var rayCollision = $RayCast2D.get_collision_point()
		rayCollision.y -= 10
		set_position(rayCollision)
		$RayCast2D.enabled = false

func outOfLight():
	emit_signal("stopTimer")
	play("normal")
	$Light2D.enabled = false
