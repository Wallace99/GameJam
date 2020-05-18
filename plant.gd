extends Sprite

var age = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var growth = 1
var sizes = []
var plant_type
var plot


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_plot(_plot):
	plot = _plot
	
func get_plot():
	return plot


func set_sizes(plantSizes):
	sizes = plantSizes

func get_growth():
	return growth

func get_plant_type():
	return plant_type

func _on_GrowTimer_timeout():
	if growth < 20:
		growth += 1
		if growth % 5 == 0:
			setPlantImage(plant_type)
		print("plant grew")
	else:
		get_node("GrowTimer").stop()

func setPlantImage(plantType):
	plant_type = plantType 
	if growth <= 5:
		set_texture(sizes[0])
		set_offset(Vector2(0, 5))
	if growth > 5 and growth <= 10:
		set_texture(sizes[1])
		set_offset(Vector2(0, 0))
	elif growth > 10:
		set_texture(sizes[2])
		set_offset(Vector2(0, -5))
