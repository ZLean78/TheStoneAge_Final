extends ColorRect

var food_points = 0
var leaves_points = 0
var phrase = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _set_food_points(var _food_points):
	food_points=_food_points	
	_set_label_food_points(food_points)
	
func _set_leaves_points(var _leaves_points):
	leaves_points=_leaves_points	
	_set_label_leaves_points(leaves_points)

func _set_label_food_points(var _food_points):
	$Label.text = "COMIDA: " + str(_food_points)
	
func _set_label_leaves_points(var _leaves_points):
	$Label3.text = "HOJAS: " + str(_leaves_points)

func _set_phrase(var _phrase):
	phrase = _phrase
	$Label2.text = phrase
