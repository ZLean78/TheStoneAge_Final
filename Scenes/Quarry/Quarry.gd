extends "res://Scenes/PickupObject/PickupObject.gd"



# Called when the node enters the scene tree for the first time.
func _ready():
	points = 150
	the_sprite = get_child(0)
	type = "quarry"



func _process(_delta):
	if empty:
		visible=false
	else:
		visible=true






