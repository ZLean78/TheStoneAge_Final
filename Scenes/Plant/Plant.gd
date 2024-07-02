extends "res://Scenes/PickupObject/PickupObject.gd"




# Called when the node enters the scene tree for the first time.
func _ready():
	points = 60
	the_sprite = get_child(0)
	type = "plant"
	
func _physics_process(_delta):
	_plant_animate()



func _plant_animate():	
	if empty == true:
		$AnimationPlayer.play("empty")
	else:
		$AnimationPlayer.play("full")



